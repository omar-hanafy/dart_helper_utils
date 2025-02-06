import 'dart:async';
import 'dart:developer';

/// A simple typedef for injecting any logging solution you like.
typedef LoggerFunction = void Function(String message);

/// A read‐only snapshot of the Debouncer’s current state.
class DebouncerState {
  /// Main construction DebouncerState.
  const DebouncerState({
    required this.isRunning,
    required this.isDisposed,
    required this.executionCount,
    this.lastExecutionTime,
    this.remainingTime,
    this.remainingMaxWait,
  });

  /// True if there's a pending delayed call that hasn't fired yet.
  final bool isRunning;

  /// True if [dispose] was already called on this debouncer.
  final bool isDisposed;

  /// Number of times the debounced action has successfully executed.
  final int executionCount;

  /// The time at which the last execution completed.
  final DateTime? lastExecutionTime;

  /// How much longer until the next scheduled execution fires.
  final Duration? remainingTime;

  /// How much longer until the max wait threshold forces an execution.
  final Duration? remainingMaxWait;

  @override
  String toString() {
    return 'DebouncerState('
        'running: $isRunning, '
        'disposed: $isDisposed, '
        'count: $executionCount, '
        'lastExecution: $lastExecutionTime, '
        'remainingTime: $remainingTime, '
        'remainingMaxWait: $remainingMaxWait'
        ')';
  }
}

/// An enhanced debouncer offering sophisticated control over delayed function
/// execution, including asynchronous support, logging, and real‐time state
/// monitoring via a broadcast stream.
class Debouncer {
  /// Creates an enhanced [Debouncer] with various configuration options.
  ///
  /// * [delay]: The time to wait before firing the debounced action.
  /// * [maxWait]: The maximum time to wait before forcing an execution.
  /// * [immediate]: Whether to execute on the leading edge instead of trailing.
  /// * [onError]: Optional callback for handling errors during the action.
  /// * [debugLabel]: A label that can be printed with debug logs.
  /// * [maxHistorySize]: How many past execution records to keep (0 = no history).
  /// * [logger]: An injectable logging function. If not set, uses `print` if [debugLabel] is provided.
  Debouncer({
    required Duration delay,
    Duration? maxWait,
    bool immediate = false,
    void Function(Object error, StackTrace stackTrace)? onError,
    String? debugLabel,
    int maxHistorySize = 0,
    LoggerFunction? logger,
  })  : _delay = delay,
        _maxWait = maxWait,
        _immediate = immediate,
        _onError = onError,
        _debugLabel = debugLabel,
        _maxHistorySize = maxHistorySize,
        _logger = logger {
    if (delay <= Duration.zero) {
      throw ArgumentError('Delay must be greater than zero.');
    }
    if (maxWait != null && maxWait <= delay) {
      throw ArgumentError('maxWait must be greater than delay.');
    }
    if (maxHistorySize < 0) {
      throw ArgumentError('maxHistorySize must be >= 0.');
    }
  }

  // Core configuration fields.
  final Duration _delay;
  final Duration? _maxWait;
  final bool _immediate;
  final void Function(Object, StackTrace)? _onError;
  final String? _debugLabel;
  final int _maxHistorySize;
  final LoggerFunction? _logger;

  // Timers for the debouncing and max-wait logic.
  Timer? _timer;
  Timer? _maxWaitTimer;

  // Keeps track of when the last call and last execution happened.
  DateTime? _lastCallTime;
  DateTime? _lastExecutionTime;

  // Counts how many times the debounced action has executed.
  int _executionCount = 0;

  // The action to eventually run (can be sync or async).
  FutureOr<void> Function()? _lastAction;

  // Execution history (kept if maxHistorySize > 0).
  final List<_ExecutionRecord> _executionHistory = [];

  // Tracks whether dispose() has been called.
  bool _isDisposed = false;

  // Broadcast controller for observing state changes in real time.
  final _stateController = StreamController<DebouncerState>.broadcast();

  /// A stream of [DebouncerState] updates. You can subscribe to this to
  /// monitor running/disposed status, pending times, etc.
  Stream<DebouncerState> get stateStream => _stateController.stream;

  /// Current number of times the debounced action has executed.
  int get executionCount => _executionCount;

  /// The time at which the last execution finished, or null if none yet.
  DateTime? get lastExecutionTime => _lastExecutionTime;

  /// True if there's a scheduled execution that hasn't fired yet.
  bool get isRunning => _timer?.isActive ?? false;

  /// True if this debouncer has been disposed and is no longer usable.
  bool get isDisposed => _isDisposed;

  /// How much longer until the next scheduled execution fires, if any.
  Duration? get remainingTime {
    if (_timer == null || _lastCallTime == null) return null;
    final elapsed = DateTime.now().difference(_lastCallTime!);
    final remaining = _delay - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// How long until the max wait threshold forces an execution (if defined).
  Duration? get remainingMaxWait {
    if (_maxWaitTimer == null || _lastCallTime == null || _maxWait == null) {
      return null;
    }
    final elapsed = DateTime.now().difference(_lastCallTime!);
    final remaining = _maxWait! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// How long it's been since the last actual execution completed, or null if no execution yet.
  Duration? get timeSinceLastExecution {
    if (_lastExecutionTime == null) return null;
    return DateTime.now().difference(_lastExecutionTime!);
  }

  /// Returns a list of past executions (if [maxHistorySize] > 0).
  /// Each record includes startTime, endTime, duration (in seconds), success, and error if any.
  List<Map<String, dynamic>> get executionHistory {
    return _executionHistory.map((r) => r.toMap()).toList();
  }

  /// Provides a snapshot of the debouncer's current state.
  DebouncerState get currentState => DebouncerState(
        isRunning: isRunning,
        isDisposed: isDisposed,
        executionCount: executionCount,
        lastExecutionTime: lastExecutionTime,
        remainingTime: remainingTime,
        remainingMaxWait: remainingMaxWait,
      );

  /// Schedules [action] to run after [delay], resetting the timer if called again
  /// before [delay] elapses. If [immediate] is true and this is the first call,
  /// [action] is executed immediately, and then further calls are debounced.
  ///
  /// [action] can be a sync or async function. If it's async, we'll await it.
  /// Throws a [StateError] if this debouncer is already disposed.
  void run(FutureOr<void> Function() action) {
    _ensureNotDisposed();
    _lastAction = action;
    _lastCallTime = DateTime.now();

    // If immediate mode is enabled and no timer is active, run now.
    if (_immediate && _timer == null) {
      _executeAction(action);
    }

    // Reset the main timer for the trailing edge.
    _timer?.cancel();
    _timer = Timer(_delay, () {
      if (!_immediate && _lastAction != null) {
        _executeAction(_lastAction!);
      }
      _resetTimers();
    });

    // If maxWait is set, start its timer only if not already started this cycle.
    if (_maxWait != null && _maxWaitTimer == null) {
      _maxWaitTimer = Timer(_maxWait!, () {
        if (_lastAction != null) {
          _executeAction(_lastAction!);
          _resetTimers();
        }
      });
    }

    _logDebug('Action scheduled');
    _publishState();
  }

  /// Forces the pending action to execute right away (if any). Resets the timers.
  ///
  /// If the action is async, returns a future that completes when the action finishes.
  /// Throws a [StateError] if this debouncer is already disposed.
  Future<void> flush() async {
    _ensureNotDisposed();
    if (_lastAction != null) {
      await _executeAction(_lastAction!);
      _resetTimers();
      _logDebug('Action flushed');
      _publishState();
    }
  }

  /// Returns true if there's a pending action that hasn't executed yet.
  bool get hasPendingAction => _lastAction != null;

  /// Returns the total pending duration including maxWait if applicable.
  Duration? get totalPendingDuration {
    final normal = remainingTime;
    final maxWait = remainingMaxWait;

    if (normal == null) return maxWait;
    if (maxWait == null) return normal;

    return normal < maxWait ? normal : maxWait;
  }

  /// Executes the action and returns true if it was executed, false if no action was pending.
  Future<bool> tryFlush() async {
    if (!hasPendingAction) return false;
    await flush();
    return true;
  }

  /// Sugar for running an action only if no action is currently pending.
  /// Returns true if the action was scheduled, false if skipped due to pending action.
  bool runIfNotPending(FutureOr<void> Function() action) {
    if (hasPendingAction) return false;
    run(action);
    return true;
  }

  /// Cancels any pending action, clearing timers and discarding the last scheduled action.
  ///
  /// Throws a [StateError] if this debouncer is already disposed.
  void cancel() {
    _ensureNotDisposed();
    _resetTimers();
    _lastAction = null;
    _logDebug('Cancelled');
    _publishState();
  }

  /// Permanently disposes of this debouncer. Cancels any pending actions,
  /// clears state, and closes the [stateStream]. Once disposed, the debouncer
  /// can no longer be used.
  void dispose() {
    if (_isDisposed) return;
    cancel();
    _isDisposed = true;
    _lastCallTime = null;
    _lastExecutionTime = null;
    _executionCount = 0;
    _executionHistory.clear();
    _stateController.close();
    _logDebug('Disposed');
    _publishState();
  }

  /// Actually runs [action], tracking success/failure and updating counters.
  /// Catches errors and passes them to [onError] if defined, otherwise rethrows.
  Future<void> _executeAction(FutureOr<void> Function() action) async {
    final startTime = DateTime.now();
    try {
      // If the function is sync, this runs immediately. If async, we wait.
      await Future.sync(action);

      _executionCount++;
      _lastExecutionTime = DateTime.now();

      // Record success if we’re tracking history.
      if (_maxHistorySize > 0) {
        _recordExecution(
          startTime: startTime,
          endTime: _lastExecutionTime!,
          success: true,
        );
      }
      _lastAction = null;
      _logDebug('Action executed successfully');
    } catch (error, stackTrace) {
      // If an error occurs, record it if we keep history.
      if (_maxHistorySize > 0) {
        _recordExecution(
          startTime: startTime,
          endTime: DateTime.now(),
          success: false,
          error: error,
        );
      }
      _logDebug('Action failed: $error');

      if (_onError != null) {
        _onError!(error, stackTrace);
      } else {
        rethrow; // If no handler, rethrow the error to the caller.
      }
    } finally {
      // Always update the state after the action completes/fails.
      _publishState();
    }
  }

  /// Cancels any active timers for this cycle.
  void _resetTimers() {
    _timer?.cancel();
    _timer = null;
    _maxWaitTimer?.cancel();
    _maxWaitTimer = null;
  }

  /// Logs debug info, either via the injected logger or via [print] if [debugLabel] is set.
  void _logDebug(String message) {
    if (_logger != null) {
      _logger!('Debouncer($_debugLabel): $message');
    } else if (_debugLabel != null) {
      log('Debouncer($_debugLabel): $message');
    }
  }

  /// Ensures the debouncer isn't used after being disposed.
  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Cannot use Debouncer after it has been disposed.');
    }
  }

  /// Publishes the current debouncer state to the stateStream.
  void _publishState() {
    if (!_isDisposed) {
      _stateController.add(currentState);
    }
  }

  /// Records an action’s execution details to the debouncer’s history.
  void _recordExecution({
    required DateTime startTime,
    required DateTime endTime,
    required bool success,
    Object? error,
  }) {
    _executionHistory.add(
      _ExecutionRecord(
        startTime: startTime,
        endTime: endTime,
        success: success,
        error: error,
      ),
    );

    // If we exceed the max history, remove the oldest entries.
    while (_executionHistory.length > _maxHistorySize) {
      _executionHistory.removeAt(0);
    }
  }
}

/// Internal class storing details of a single execution instance.
class _ExecutionRecord {
  _ExecutionRecord({
    required this.startTime,
    required this.endTime,
    required this.success,
    this.error,
  });

  final DateTime startTime;
  final DateTime endTime;
  final bool success;
  final Object? error;

  /// Duration of the action in [endTime - startTime].
  Duration get duration => endTime.difference(startTime);

  /// Converts the record into a map. Useful for logging or debugging.
  Map<String, dynamic> toMap() => {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'durationSeconds': duration.inMicroseconds / 1e6,
        'success': success,
        'error': error?.toString(),
      };
}
