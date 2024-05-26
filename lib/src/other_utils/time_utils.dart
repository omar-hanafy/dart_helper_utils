import 'dart:async';

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
      FutureOr<void> Function() task) async {
    final stopwatch = Stopwatch()..start();
    await task(); // Await if the task is a future
    stopwatch.stop();
    return stopwatch.elapsed;
  }

  /// Measures the execution time for a list of tasks, whether synchronous or asynchronous.
  static Future<List<Duration>> executionDurations(
      List<FutureOr<void> Function()> tasks) async {
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

  /// Creates a throttled function that only invokes the function at most once
  /// per every `interval` milliseconds.
  static Function throttle(void Function() func, Duration interval) {
    var isThrottled = false;
    return () {
      if (!isThrottled) {
        isThrottled = true;
        Timer(interval, () => isThrottled = false);
        func();
      }
    };
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
    return Timer.periodic(interval, (timer) async {
      count++;
      onExecute(timer, count);
    });
  }

  /// Executes a function with a timeout, cancelling the execution if it exceeds
  /// the specified duration.
  static Future<T> runWithTimeout<T>({
    required FutureOr<T> Function() task,
    required Duration timeout,
  }) async {
    final completer = Completer<T>();
    final timer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException('The operation has timed out.'),
        );
      }
    });
    try {
      final result = await task();
      if (!completer.isCompleted) completer.complete(result);
    } catch (e) {
      if (!completer.isCompleted) completer.completeError(e);
    } finally {
      timer.cancel();
    }

    return completer.future;
  }
}
