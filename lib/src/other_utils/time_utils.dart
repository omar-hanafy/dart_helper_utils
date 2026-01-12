import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:dart_helper_utils/src/other_utils/debouncer.dart';

/// A utility class that provides helper methods for working with time.
abstract class TimeUtils {
  /// Calculates the execution duration of a task, accommodating both synchronous
  /// and asynchronous operations.
  ///
  /// This method starts a stopwatch before the provided task begins, then stops
  /// it once the task completes (either synchronously or when the future
  /// resolves). It returns the elapsed time as a `Duration`.
  ///
  /// **Examples:**
  ///
  /// ```dart
  /// // Measuring a synchronous task
  /// Duration syncDuration = await TimeUtils.executionDuration(() {
  ///   // Perform some synchronous work here
  ///   for (var i = 0; i < 1000000; i++) {}
  /// });
  /// print('Synchronous task took $syncDuration');
  ///
  /// // Measuring an asynchronous task
  /// Duration asyncDuration = await TimeUtils.executionDuration(() async {
  ///   // Perform some asynchronous work here (e.g., network request)
  ///   await Future.delayed(Duration(seconds: 2));
  /// });
  /// print('Asynchronous task took $asyncDuration');
  /// ```
  static Future<Duration> executionDuration(
    FutureOr<void> Function() task,
  ) async {
    final stopwatch = Stopwatch()..start();
    await task(); // Await if the task is a future
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Measures the execution time for a list of tasks, whether synchronous or asynchronous.
  static Future<List<Duration>> executionDurations(
    List<FutureOr<void> Function()> tasks,
  ) async {
    final durations = <Duration>[];

    for (final task in tasks) {
      final duration = await executionDuration(task);
      durations.add(duration);
    }

    return durations;
  }

  /// Compares the execution durations of two tasks, accommodating both synchronous
  /// and asynchronous operations.
  ///
  /// This method returns a tuple of the two durations.
  ///
  /// **Examples:**
  ///
  /// ```dart
  /// var result = await TimeUtils.compareExecutionTimes(
  ///   () {
  ///     // Task 1
  ///     for (var i = 0; i < 1000000; i++) {}
  ///   },
  ///   () async {
  ///     // Task 2
  ///     await Future.delayed(Duration(seconds: 2));
  ///   },
  /// );
  /// print('Task 1 took ${result.item1}, Task 2 took ${result.item2}');
  /// ```
  static Future<(Duration, Duration)> compareExecutionTimes({
    required FutureOr<void> Function() taskA,
    required FutureOr<void> Function() taskB,
  }) async {
    final duration1 = await executionDuration(taskA);
    final duration2 = await executionDuration(taskB);
    return (duration1, duration2);
  }

  /// Creates a debounced callback that delays the execution of [func] until
  /// [duration] has passed since the last time it was invoked.
  ///
  /// The returned object is callable and exposes `cancel` and `flush` methods.
  static DebouncedCallback debounce(
    FutureOr<void> Function() func,
    Duration duration, {
    Duration? maxWait,
    bool immediate = false,
    String? debugLabel,
  }) {
    final debouncer = Debouncer(
      delay: duration,
      maxWait: maxWait,
      immediate: immediate,
      debugLabel: debugLabel,
    );
    return DebouncedCallback(debouncer, func);
  }

  /// Creates a throttled callback that invokes [func] at most once per [interval].
  ///
  /// The returned object is callable like a function and supports `cancel`/`dispose`.
  static ThrottledCallback throttle(
    void Function() func,
    Duration interval, {
    bool leading = true,
    bool trailing = false,
    ThrottlerErrorHandler? onError,
  }) {
    final throttler = Throttler(
      interval: interval,
      leading: leading,
      trailing: trailing,
      onError: onError,
    );
    return ThrottledCallback(throttler, func);
  }

  /// Executes a function periodically with the given interval.
  ///
  /// This method provides a callback `onExecute` that gets called after each
  /// interval, passing the `Timer` and the count of executions.
  ///
  /// **Parameters:**
  /// - `interval`: The duration between each execution of the function.
  /// - `onExecute`: A callback function that gets called after each execution of `func`.
  ///    It receives the `Timer` and the count of executions.
  ///
  /// **Example:**
  ///
  /// ```dart
  /// Timer timer = TimeUtils.runPeriodically(
  ///   interval: Duration(seconds: 1),
  ///   onExecute: (timer, count) {
  ///     print('Executed $count times');
  ///     if (count >= 5) {
  ///       timer.cancel(); // Stop after 5 executions
  ///     }
  ///   }
  /// );
  /// ```
  static Timer runPeriodically({
    required Duration interval,
    required void Function(Timer timer, int count) onExecute,
  }) {
    var count = 0;
    return Timer.periodic(interval, (timer) {
      count++;
      onExecute(timer, count);
    });
  }

  /// Executes a function with a timeout.
  ///
  /// If the timeout elapses first, the returned future completes with a
  /// [TimeoutException]. The original task continues to execute in the
  /// background, and any errors it throws after the timeout are handled
  /// internally to avoid unhandled asynchronous exceptions.
  static Future<T> runWithTimeout<T>({
    required FutureOr<T> Function() task,
    required Duration timeout,
  }) {
    final completer = Completer<T>();
    Timer? timeoutTimer;

    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('The operation has timed out.'),
        );
      }
    });

    final taskFuture = Future<T>.sync(task);
    taskFuture.then((value) {
      if (!completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.complete(value);
      }
    }).catchError((error, stackTrace) {
      if (!completer.isCompleted) {
        timeoutTimer?.cancel();
        completer.completeError(error, stackTrace);
      }
      // Once the completer finished because the timeout elapsed, swallow
      // remaining errors to keep the zone clean.
    });

    return completer.future.whenComplete(() => timeoutTimer?.cancel());
  }
}

/// A function signature for throttled actions.
typedef ThrottlerAction = FutureOr<void> Function();

/// A function signature for throttler error handling.
typedef ThrottlerErrorHandler = void Function(Object error, StackTrace stack);

/// A lightweight throttler for rate-limiting actions over time.
class Throttler {
  /// Creates a [Throttler] that enforces a minimum delay between executions.
  Throttler({
    required this.interval,
    this.leading = true,
    this.trailing = false,
    ThrottlerErrorHandler? onError,
    Timer Function(Duration duration, void Function() callback)? timerFactory,
  })  : _onError = onError,
        _timerFactory = timerFactory ?? Timer.new;

  /// Minimum delay between executions.
  final Duration interval;

  /// Whether to execute immediately on the first call in a burst.
  final bool leading;

  /// Whether to execute once at the end of a throttling window.
  final bool trailing;

  final ThrottlerErrorHandler? _onError;
  final Timer Function(Duration duration, void Function() callback)
      _timerFactory;
  Timer? _timer;
  bool _isThrottled = false;
  bool _isDisposed = false;
  ThrottlerAction? _pendingAction;

  /// Returns `true` if throttling is currently active.
  bool get isThrottled => _isThrottled;

  /// Returns `true` if the throttler has been disposed.
  bool get isDisposed => _isDisposed;

  /// Runs [action] under the current throttling rules.
  void run(ThrottlerAction action) {
    _ensureNotDisposed();
    if (_isThrottled) {
      if (trailing) _pendingAction = action;
      return;
    }

    if (leading) {
      _executeAction(action);
    } else if (trailing) {
      _pendingAction = action;
    }

    _startTimer();
  }

  /// Cancels any pending action and clears the current throttle window.
  void cancel() {
    if (_isDisposed) return;
    _timer?.cancel();
    _timer = null;
    _pendingAction = null;
    _isThrottled = false;
  }

  /// Disposes the throttler and releases timers.
  void dispose() {
    if (_isDisposed) return;
    cancel();
    _isDisposed = true;
  }

  void _startTimer() {
    _timer?.cancel();
    _isThrottled = true;
    _timer = _timerFactory(interval, _onTimer);
  }

  void _onTimer() {
    final pending = _pendingAction;
    _pendingAction = null;
    _isThrottled = false;

    if (trailing && pending != null) {
      _executeAction(pending);
      _startTimer();
    }
  }

  void _executeAction(ThrottlerAction action) {
    Future.sync(action).catchError((Object error, StackTrace stackTrace) {
      final handler = _onError;
      if (handler != null) {
        handler(error, stackTrace);
      } else {
        throw error;
      }
    });
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('Throttler has been disposed and cannot be used.');
    }
  }
}

/// Callable wrapper that exposes throttling controls.
class ThrottledCallback {
  /// Creates a callable wrapper around a [Throttler] and action.
  ThrottledCallback(this._throttler, this._action);

  final Throttler _throttler;
  final void Function() _action;

  /// Invokes the throttled action.
  void call() => _throttler.run(_action);

  /// Cancels any pending action and resets the throttle window.
  void cancel() => _throttler.cancel();

  /// Disposes the throttler.
  void dispose() => _throttler.dispose();

  /// Returns `true` if the throttler is disposed.
  bool get isDisposed => _throttler.isDisposed;
}
