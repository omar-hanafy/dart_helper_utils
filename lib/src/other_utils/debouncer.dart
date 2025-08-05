/// A versatile debouncer library for Dart.
///
/// This debouncer consolidates rapid events by scheduling actions to run
/// after a configurable delay, with options for immediate execution and
/// a maximum wait threshold. It supports synchronous and asynchronous actions,
/// error handling, real‐time state monitoring via a stream, pause/resume functionality,
/// and state resets without disposal.
///
/// ## Example Usage in Isolates / Background Processing
///
/// ```dart
/// // Create a debouncer in a background isolate:
/// final debouncer = Debouncer(
///   delay: Duration(milliseconds: 300),
///   maxWait: Duration(seconds: 2),
///   immediate: false,
///   debugLabel: 'BackgroundTask',
/// );
///
/// // Listen to state updates:
/// debouncer.stateStream.listen((state) {
///   print('Debouncer state: $state');
/// });
///
/// // Schedule an action:
/// debouncer.run(() {
///   print('Action executed in isolate');
/// });
///
/// // Pause and later resume the debouncer:
/// debouncer.pause();
/// // ... some time later
/// debouncer.resume();
/// ```
///
/// ## Threading Considerations
///
/// This debouncer is designed for use within a single isolate. If you plan to
/// share it across isolates, manage state and messaging carefully.
///
/// ## Performance Considerations
///
/// The debouncer is optimized for minimal overhead. If scheduling actions at
/// very high frequency, consider fine-tuning the delay and maxWait parameters.
///
/// ## Custom Timing Strategies
///
/// You may supply a custom [timerFactory] to override the default [Timer] creation,
/// which is useful for testing or implementing specialized timing logic.
library;

import 'dart:async';
import 'dart:developer';

import 'package:equatable/equatable.dart';

/// A function signature for logging messages.
typedef LoggerFunction = void Function(String message);

/// A function signature for creating timers.
/// [timerFactory] allows customizing timer creation, useful for testing or
/// specialized timing behavior. Defaults to standard [Timer.new].
typedef TimerFactory = Timer Function(
    Duration duration, void Function() callback);

/// A function signature for asynchronous actions.
typedef AsyncAction = FutureOr<void> Function();

/// An immutable snapshot of a debouncer's state.
class DebouncerState extends Equatable {
  /// Constructs a new [DebouncerState].
  const DebouncerState({
    required this.isRunning,
    required this.isDisposed,
    required this.executionCount,
    this.lastExecutionTime,
    this.remainingTime,
    this.remainingMaxWait,
    this.isPaused = false,
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

  /// Whether the debouncer is currently paused.
  final bool isPaused;

  @override
  String toString() {
    return 'DebouncerState('
        'isRunning: $isRunning, '
        'isDisposed: $isDisposed, '
        'executionCount: $executionCount, '
        'lastExecutionTime: $lastExecutionTime, '
        'remainingTime: $remainingTime, '
        'remainingMaxWait: $remainingMaxWait, '
        'isPaused: $isPaused'
        ')';
  }

  @override
  List<Object?> get props => [
        isRunning,
        isDisposed,
        executionCount,
        lastExecutionTime,
        remainingTime,
        remainingMaxWait,
        isPaused,
      ];

  /// Creates a copy of this state with optional field updates.
  DebouncerState copyWith({
    bool? isRunning,
    bool? isDisposed,
    int? executionCount,
    DateTime? lastExecutionTime,
    Duration? remainingTime,
    Duration? remainingMaxWait,
    bool? isPaused,
  }) {
    return DebouncerState(
      isRunning: isRunning ?? this.isRunning,
      isDisposed: isDisposed ?? this.isDisposed,
      executionCount: executionCount ?? this.executionCount,
      lastExecutionTime: lastExecutionTime ?? this.lastExecutionTime,
      remainingTime: remainingTime ?? this.remainingTime,
      remainingMaxWait: remainingMaxWait ?? this.remainingMaxWait,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}

/// A versatile debouncer that helps consolidate rapid events by scheduling actions to run after a delay.
/// It features immediate execution, max-wait thresholds, pause/resume support, and reset functionality.
///
/// See the library docs above for usage, threading, performance, and custom timing considerations.
class Debouncer {
  /// Creates a new [Debouncer] instance.
  ///
  /// - [delay] specifies how long to wait after the last call before executing the action.
  ///   It must be greater than zero.
  /// - [maxWait] sets an upper limit on how long to wait before forcing execution.
  ///   If provided, it must be greater than [delay].
  /// - When [immediate] is true, the first call in a burst executes immediately,
  ///   and later calls during that burst are debounced.
  /// - [onError] is an optional callback to handle errors thrown during the action.
  /// - [debugLabel] helps tag log messages.
  /// - [maxHistorySize] defines how many past execution records to store (0 disables history).
  /// - [logger] can be provided to inject a custom logging function.
  /// - [timerFactory] allows for custom timer creation. Defaults to [Timer].
  Debouncer({
    required Duration delay,
    Duration? maxWait,
    bool immediate = false,
    void Function(Object error, StackTrace stackTrace)? onError,
    String? debugLabel,
    int maxHistorySize = 0,
    LoggerFunction? logger,
    TimerFactory? timerFactory,
  })  : _delay = delay,
        _maxWait = maxWait,
        _immediate = immediate,
        _onError = onError,
        _debugLabel = debugLabel,
        _maxHistorySize = maxHistorySize,
        _logger = logger,
        _timerFactory = timerFactory ?? Timer.new {
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

  final TimerFactory _timerFactory;

  // --------------------- Timer Management ---------------------
  Timer? _timer;
  Timer? _maxWaitTimer;

  // --------------------- Timestamps ---------------------
  DateTime? _firstCallTime;
  DateTime? _lastCallTime;
  DateTime? _lastExecutionTime;

  // --------------------- Execution Tracking ---------------------
  int _executionCount = 0;
  AsyncAction? _lastAction;
  final List<_ExecutionRecord> _executionHistory = [];

  // --------------------- Pause Management ---------------------
  bool _isPaused = false;
  Duration? _remainingDelayOnPause;
  Duration? _remainingMaxWaitOnPause;
  DateTime? _pauseTimestamp;

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

  /// Whether the debouncer is currently paused.
  bool get isPaused => _isPaused;

  /// Time remaining until the next scheduled execution fires.
  Duration? get remainingTime {
    if (_timer == null || _lastCallTime == null) return null;
    if (_isPaused && _remainingDelayOnPause != null) {
      return _remainingDelayOnPause;
    }
    final elapsed = DateTime.now().difference(_lastCallTime!);
    final remaining = _delay - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Time remaining until the maxWait timer forces execution.
  Duration? get remainingMaxWait {
    if (_maxWaitTimer == null || _firstCallTime == null || _maxWait == null) {
      return null;
    }
    if (_isPaused && _remainingMaxWaitOnPause != null) {
      return _remainingMaxWaitOnPause;
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

  /// The average execution time of successful actions.
  ///
  /// Returns null if no successful executions have occurred.
  Duration? get averageExecutionTime {
    final successfulRecords = _executionHistory.where((r) => r.success);
    if (successfulRecords.isEmpty) return null;
    final totalMicroseconds = successfulRecords.fold<int>(
        0, (sum, r) => sum + r.duration.inMicroseconds);
    final avgMicroseconds = totalMicroseconds ~/ successfulRecords.length;
    return Duration(microseconds: avgMicroseconds);
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
        isPaused: isPaused,
      );

  /// Schedules [action] to run after [delay]. In immediate mode, the first call
  /// executes right away while subsequent calls during that burst are debounced.
  ///
  /// Throws a [StateError] if the debouncer has been disposed.
  void run(AsyncAction action) {
    _ensureNotDisposed();
    if (_isPaused) {
      // If paused, store the action and timestamp without scheduling timers.
      _lastAction = action;
      _lastCallTime = DateTime.now();
      _logDebug('Debouncer is paused. Action stored for later execution.');
      _publishState();
      return;
    }

    _lastAction = action;
    final now = DateTime.now();
    _lastCallTime = now;
    _firstCallTime ??= now;

    // In immediate mode, execute the first action immediately.
    if (_immediate && _timer == null) {
      _executeAction(action);
    }

    // Cancel any existing timers.
    _cancelTimers();

    // Schedule a trailing timer only if not in immediate mode (or if resuming a pending action).
    if (!_immediate || _lastAction != null) {
      _timer = _timerFactory(_delay, () {
        if (!_immediate && _lastAction != null) {
          _executeAction(_lastAction!);
        }
        _cancelTimers();
      });
    }

    // Set up a maxWait timer if specified.
    if (_maxWait != null && _maxWaitTimer == null) {
      _maxWaitTimer = _timerFactory(_maxWait!, () {
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
    if (_isPaused) {
      _logDebug('Cannot flush while paused.');
      return;
    }
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
  bool runIfNotPending(AsyncAction action) {
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

  /// Resets the debouncer's internal state without disposing it.
  ///
  /// This clears all timers, execution history, and internal counters.
  void reset() {
    _ensureNotDisposed();
    cancel();
    _firstCallTime = null;
    _lastCallTime = null;
    _lastExecutionTime = null;
    _executionCount = 0;
    _executionHistory.clear();
    _isPaused = false;
    _remainingDelayOnPause = null;
    _remainingMaxWaitOnPause = null;
    _pauseTimestamp = null;
    _logDebug('Debouncer state has been reset.');
    _publishState();
  }

  /// Pauses the debouncer, cancelling active timers.
  ///
  /// Any pending action will be resumed when [resume] is called.
  void pause() {
    _ensureNotDisposed();
    if (_isPaused) {
      _logDebug('Already paused, ignoring pause call');
      return;
    }
    _isPaused = true;
    _pauseTimestamp = DateTime.now();
    // Capture remaining time for main timer.
    if (_timer != null && _lastCallTime != null) {
      final elapsed = DateTime.now().difference(_lastCallTime!);
      final remaining = _delay - elapsed;
      _remainingDelayOnPause = remaining.isNegative ? Duration.zero : remaining;
      _timer?.cancel();
      _timer = null;
    }
    // Capture remaining time for maxWait timer.
    if (_maxWaitTimer != null && _firstCallTime != null && _maxWait != null) {
      final elapsed = DateTime.now().difference(_firstCallTime!);
      final remaining = _maxWait! - elapsed;
      _remainingMaxWaitOnPause =
          remaining.isNegative ? Duration.zero : remaining;
      _maxWaitTimer?.cancel();
      _maxWaitTimer = null;
    }
    _logDebug('Debouncer paused.');
    _publishState();
  }

  /// Resumes the debouncer, scheduling pending actions if necessary.
  void resume() {
    _ensureNotDisposed();
    if (!_isPaused) return;
    _isPaused = false;
    final now = DateTime.now();
    // Adjust timestamps to account for the paused duration.
    if (_pauseTimestamp != null && _lastCallTime != null) {
      final pauseDuration = now.difference(_pauseTimestamp!);
      _lastCallTime = _lastCallTime!.add(pauseDuration);
      if (_firstCallTime != null) {
        _firstCallTime = _firstCallTime!.add(pauseDuration);
      }
    }
    // Re-schedule timers if a pending action exists.
    if (_lastAction != null) {
      _timer = _timerFactory(_remainingDelayOnPause ?? _delay, () {
        if (!_immediate && _lastAction != null) {
          _executeAction(_lastAction!);
        }
        _cancelTimers();
      });
      if (_maxWait != null) {
        _maxWaitTimer =
            _timerFactory(_remainingMaxWaitOnPause ?? _maxWait!, () {
          if (_lastAction != null) {
            _executeAction(_lastAction!);
            _cancelTimers();
          }
        });
      }
    }
    _remainingDelayOnPause = null;
    _remainingMaxWaitOnPause = null;
    _pauseTimestamp = null;
    _logDebug('Debouncer resumed.');
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
    );

    _stateController
      .._safeAdd(finalState)
      ..close();
    _logDebug('Debouncer disposed.');
  }

  // --------------------- Private Helpers ---------------------

  /// Executes the provided [action] while handling errors and tracking execution.
  Future<void> _executeAction(AsyncAction action) async {
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

  /// Cancels any active timers and resets burst state.
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
    final logMessage =
        'Debouncer${_debugLabel != null ? '($_debugLabel)' : ''}: $message';
    if (_logger != null) {
      _logger!(logMessage);
    } else if (_debugLabel != null) {
      log(logMessage);
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
  /// Creates a new execution record.
  const _ExecutionRecord({
    required this.startTime,
    required this.endTime,
    required this.success,
    this.error,
  });

  /// The start time of the execution.
  final DateTime startTime;

  /// The end time of the execution.
  final DateTime endTime;

  /// Whether the execution was successful.
  final bool success;

  /// Any error encountered during execution.
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

// Extension on StreamController to safely add data.
extension _StreamControllerExtension<T> on StreamController<T> {
  void _safeAdd(T data) {
    if (!isClosed) {
      add(data);
    }
  }
}
