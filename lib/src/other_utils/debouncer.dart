// ignore_for_file: avoid_redundant_argument_values
import 'dart:async';
import 'dart:developer';

import 'package:dart_helper_utils/src/extensions/stream_controller.dart';

/// A function signature for logging messages.
typedef LoggerFunction = void Function(String message);

/// An immutable snapshot of a debouncer's state.
class DebouncerState {
  /// Constructs a new [DebouncerState].
  const DebouncerState({
    required this.isRunning,
    required this.isDisposed,
    required this.executionCount,
    this.lastExecutionTime,
    this.remainingTime,
    this.remainingMaxWait,
  });

  /// Whether a debounced action is currently scheduled.
  final bool isRunning;

  /// Whether the debouncer has been disposed.
  final bool isDisposed;

  /// Total number of times the debounced action has executed.
  final int executionCount;

  /// The timestamp of the last execution.
  final DateTime? lastExecutionTime;

  /// Time remaining until the next scheduled execution.
  final Duration? remainingTime;

  /// Time remaining until the maximum wait threshold forces execution.
  final Duration? remainingMaxWait;

  @override
  String toString() {
    return 'DebouncerState('
        'isRunning: $isRunning, '
        'isDisposed: $isDisposed, '
        'executionCount: $executionCount, '
        'lastExecutionTime: $lastExecutionTime, '
        'remainingTime: $remainingTime, '
        'remainingMaxWait: $remainingMaxWait'
        ')';
  }
}

/// A versatile debouncer that helps consolidate rapid events
/// by scheduling actions to run after a delay, with optional immediate
/// execution and a maximum wait threshold.
///
/// This class supports synchronous and asynchronous actions, error handling,
/// and real‐time state monitoring via a stream.
class Debouncer {
  /// Creates a new [Debouncer] instance.
  ///
  /// - [delay] specifies how long to wait after the last call before executing
  ///   the action. It must be greater than zero.
  /// - [maxWait] sets an upper limit on how long to wait before forcing execution.
  ///   If provided, it must be greater than [delay].
  /// - When [immediate] is true, the first call in a burst executes immediately,
  ///   and later calls during that burst are debounced.
  /// - [onError] is an optional callback to handle errors thrown during the action.
  /// - [debugLabel] helps tag log messages.
  /// - [maxHistorySize] defines how many past execution records to store (0 disables history).
  /// - [logger] can be provided to inject a custom logging function.
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

  // --------------------- Configuration ---------------------
  final Duration _delay;
  final Duration? _maxWait;
  final bool _immediate;
  final void Function(Object, StackTrace)? _onError;
  final String? _debugLabel;
  final int _maxHistorySize;
  final LoggerFunction? _logger;

  // --------------------- Timer Management ---------------------
  Timer? _timer;
  Timer? _maxWaitTimer;

  // --------------------- Timestamps ---------------------
  DateTime? _firstCallTime;
  DateTime? _lastCallTime;
  DateTime? _lastExecutionTime;

  // --------------------- Execution Tracking ---------------------
  int _executionCount = 0;
  FutureOr<void> Function()? _lastAction;
  final List<_ExecutionRecord> _executionHistory = [];

  // --------------------- Disposal ---------------------
  bool _isDisposed = false;
  final _stateController = StreamController<DebouncerState>.broadcast();

  // --------------------- Public API ---------------------

  /// A stream that emits updates of the debouncer's state.
  Stream<DebouncerState> get stateStream => _stateController.stream;

  /// Total number of times the debounced action has executed.
  int get executionCount => _executionCount;

  /// The timestamp of the last executed action.
  DateTime? get lastExecutionTime => _lastExecutionTime;

  /// Whether there is a scheduled action pending.
  bool get isRunning => _timer?.isActive ?? false;

  /// Whether the debouncer has been disposed.
  bool get isDisposed => _isDisposed;

  /// Time remaining until the next scheduled execution fires.
  Duration? get remainingTime {
    if (_timer == null || _lastCallTime == null) return null;
    final elapsed = DateTime.now().difference(_lastCallTime!);
    final remaining = _delay - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Time remaining until the maxWait timer forces execution.
  Duration? get remainingMaxWait {
    if (_maxWaitTimer == null || _firstCallTime == null || _maxWait == null) {
      return null;
    }
    final elapsed = DateTime.now().difference(_firstCallTime!);
    final remaining = _maxWait! - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Duration since the last execution occurred, or null if none has.
  Duration? get timeSinceLastExecution {
    if (_lastExecutionTime == null) return null;
    return DateTime.now().difference(_lastExecutionTime!);
  }

  /// A list of past execution records represented as maps.
  List<Map<String, dynamic>> get executionHistory =>
      _executionHistory.map((record) => record.toMap()).toList();

  /// Returns a snapshot of the current debouncer state.
  DebouncerState get currentState => DebouncerState(
        isRunning: isRunning,
        isDisposed: isDisposed,
        executionCount: executionCount,
        lastExecutionTime: lastExecutionTime,
        remainingTime: remainingTime,
        remainingMaxWait: remainingMaxWait,
      );

  /// Schedules [action] to run after [delay]. In immediate mode, the first call
  /// executes right away while subsequent calls are debounced.
  ///
  /// Throws a [StateError] if the debouncer has been disposed.
  void run(FutureOr<void> Function() action) {
    _ensureNotDisposed();
    _lastAction = action;
    final now = DateTime.now();
    _lastCallTime = now;
    _firstCallTime ??= now;

    // In immediate mode, execute the first action right away.
    if (_immediate && _timer == null) {
      _executeAction(action);
    }

    // Cancel any existing timers and schedule a new trailing edge timer.
    _cancelTimers();
    _timer = Timer(_delay, () {
      if (!_immediate && _lastAction != null) {
        _executeAction(_lastAction!);
      }
      _cancelTimers();
    });

    // Set up a maxWait timer if specified.
    if (_maxWait != null && _maxWaitTimer == null) {
      _maxWaitTimer = Timer(_maxWait!, () {
        if (_lastAction != null) {
          _executeAction(_lastAction!);
          _cancelTimers();
        }
      });
    }

    _logDebug('Scheduled action.');
    _publishState();
  }

  /// Immediately executes any pending action and cancels timers.
  ///
  /// Returns a [Future] that completes when the action finishes.
  /// Throws a [StateError] if the debouncer has been disposed.
  Future<void> flush() async {
    _ensureNotDisposed();
    if (_lastAction != null) {
      await _executeAction(_lastAction!);
      _cancelTimers();
      _logDebug('Flushed action.');
      _publishState();
    }
  }

  /// Attempts to flush the pending action if one exists.
  ///
  /// Returns true if an action was flushed, false otherwise.
  Future<bool> tryFlush() async {
    if (_lastAction == null) return false;
    await flush();
    return true;
  }

  /// Schedules [action] only if no action is already pending.
  ///
  /// Returns true if the action was scheduled, false if skipped.
  bool runIfNotPending(FutureOr<void> Function() action) {
    if (_lastAction != null) return false;
    run(action);
    return true;
  }

  /// Cancels any pending action and resets timers.
  ///
  /// Throws a [StateError] if the debouncer has been disposed.
  void cancel() {
    _ensureNotDisposed();
    _cancelTimers();
    _lastAction = null;
    _logDebug('Cancelled scheduled action.');
    _publishState();
  }

  /// Disposes the debouncer, cancelling any pending actions,
  /// clearing all state, and closing the state stream.
  ///
  /// After calling [dispose], the debouncer must not be used.
  void dispose() {
    if (_isDisposed) return;
    cancel();
    _isDisposed = true;
    _lastCallTime = null;
    _lastExecutionTime = null;
    _executionCount = 0;
    _executionHistory.clear();

    // Publish final state before closing the stream.
    const finalState = DebouncerState(
      isRunning: false,
      isDisposed: true,
      executionCount: 0,
      lastExecutionTime: null,
      remainingTime: null,
      remainingMaxWait: null,
    );

    _stateController
      ..safeAdd(finalState)
      ..close();
    _logDebug('Debouncer disposed.');
  }

  // --------------------- Private Helpers ---------------------

  /// Executes the provided [action] while handling errors and tracking execution.
  Future<void> _executeAction(FutureOr<void> Function() action) async {
    final startTime = DateTime.now();
    try {
      await Future.sync(action);
      _executionCount++;
      _lastExecutionTime = DateTime.now();

      if (_maxHistorySize > 0) {
        _recordExecution(startTime, _lastExecutionTime!, true);
      }
      _lastAction = null;
      _logDebug('Action executed successfully.');
    } catch (error, stackTrace) {
      if (_maxHistorySize > 0) {
        _recordExecution(startTime, DateTime.now(), false, error: error);
      }
      _logDebug('Action execution failed: $error');
      if (_onError != null) {
        _onError!(error, stackTrace);
      } else {
        rethrow;
      }
    } finally {
      _publishState();
    }
  }

  /// Cancels any active timers and resets the burst state.
  void _cancelTimers() {
    if (_timer?.isActive ?? false) {
      _logDebug('Cancelling main timer.');
      _timer?.cancel();
    }
    _timer = null;

    if (_maxWaitTimer?.isActive ?? false) {
      _logDebug('Cancelling maxWait timer.');
      _maxWaitTimer?.cancel();
    }
    _maxWaitTimer = null;
    _firstCallTime = null;
  }

  /// Publishes the current state via the state stream.
  void _publishState() {
    if (!_isDisposed && !_stateController.isClosed) {
      try {
        _stateController.add(currentState);
      } catch (error, stackTrace) {
        _logDebug('Error publishing state: $error');
        if (_onError != null) {
          _onError!(error, stackTrace);
        } else {
          rethrow;
        }
      }
    }
  }

  /// Logs a debug message using the provided logger or the default log function.
  void _logDebug(String message) {
    if (_logger != null) {
      _logger!(
        'Debouncer${_debugLabel != null ? '($_debugLabel)' : ''}: $message',
      );
    } else if (_debugLabel != null) {
      log('Debouncer($_debugLabel): $message');
    }
  }

  /// Throws a [StateError] if the debouncer has been disposed.
  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Debouncer has been disposed and cannot be used.');
    }
  }

  /// Records an execution event in the history.
  void _recordExecution(
    DateTime start,
    DateTime end,
    bool success, {
    Object? error,
  }) {
    _executionHistory.add(_ExecutionRecord(
      startTime: start,
      endTime: end,
      success: success,
      error: error,
    ));
    // Remove oldest entries if history exceeds [maxHistorySize].
    while (_executionHistory.length > _maxHistorySize) {
      _executionHistory.removeAt(0);
    }
  }
}

/// Internal class for recording details about a single action execution.
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

  /// The duration of the execution.
  Duration get duration => endTime.difference(startTime);

  /// Converts this record to a map for logging or debugging.
  Map<String, dynamic> toMap() => {
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
        'durationSeconds': duration.inMicroseconds / 1e6,
        'success': success,
        'error': error?.toString(),
      };
}
