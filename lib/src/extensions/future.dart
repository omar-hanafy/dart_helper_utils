import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';

/// Extensions for [Future] to add functionality like timeouts and minimum waits.
extension DHUFutureExtensions<T> on Future<T> {
  /// Ensures the future takes *at least* [duration] to complete.
  ///
  /// This is useful for UI to prevent loading spinners from flickering (showing for only a few ms).
  ///
  /// Example:
  /// ```dart
  /// await apiCall().minWait(const Duration(milliseconds: 500));
  /// ```
  Future<T> minWait(Duration duration) async {
    final results = await Future.wait([this, Future<void>.delayed(duration)]);
    return results[0] as T;
  }

  /// Returns the result of the future if it completes within [timeout], otherwise returns `null`.
  ///
  /// This is a safer alternative to [timeout] which throws a [TimeoutException].
  ///
  /// Example:
  /// ```dart
  /// final result = await apiCall().timeoutOrNull(const Duration(seconds: 5));
  /// if (result == null) {
  ///   // Handle timeout
  /// }
  /// ```
  Future<T?> timeoutOrNull(Duration timeout) async {
    try {
      return await this.timeout(timeout);
    } on TimeoutException {
      return null;
    }
  }
}

/// Extensions for [Future] factories/callbacks.
extension DHUFutureCallbackExtensions<T> on Future<T> Function() {
  /// Retries the future [retries] times with an exponential backoff delay.
  ///
  /// [retries] specifies the maximum number of retry attempts.
  /// [delay] determines the base delay for exponential backoff.
  /// [retryIf] can be used to decide whether to retry for a specific error.
  ///
  /// Example:
  /// ```dart
  /// await (() => apiCall()).retry(retries: 3);
  /// ```
  Future<T> retry({
    int retries = 3,
    Duration delay = const Duration(seconds: 1),
    bool Function(Object error)? retryIf,
  }) async {
    var attempts = 0;
    while (true) {
      try {
        return await this();
      } catch (e) {
        if (attempts >= retries || (retryIf != null && !retryIf(e))) {
          rethrow;
        }
        attempts++;
        // Exponential backoff
        final delayMillis = delay.inMilliseconds * (1 << (attempts - 1));
        await Duration(milliseconds: delayMillis).delayed();
      }
    }
  }
}

/// Bounded-concurrency execution for an iterable of task factories.
extension DHUFutureIterableExtension<T> on Iterable<Future<T> Function()> {
  /// Executes the functions in this iterable, running at most [concurrency] futures simultaneously.
  ///
  /// This is useful for batch processing (e.g., uploading files) without overwhelming resources.
  ///
  /// [concurrency] must be positive.
  ///
  /// By default results are returned in completion order, not input order.
  /// Pass `preserveOrder: true` to get them in input order instead.
  ///
  /// If any task throws, the returned future completes with that error. Any
  /// in-flight tasks continue running and their errors are handled internally
  /// to avoid unhandled exceptions.
  ///
  /// Example:
  /// ```dart
  /// final pages = await urls
  ///     .map((url) => () => fetch(url))
  ///     .waitConcurrency(concurrency: 4, preserveOrder: true);
  /// ```
  Future<List<T>> waitConcurrency({
    int concurrency = 5,
    bool preserveOrder = false,
  }) async {
    if (concurrency <= 0) {
      throw ArgumentError.value(concurrency, 'concurrency', 'must be positive');
    }
    final inCompletionOrder = <T>[];
    final byInputIndex = <int, T>{};
    final active = <Future<void>>{};
    var started = 0;

    try {
      for (final task in this) {
        while (active.length >= concurrency) {
          await Future.any(active);
        }

        final index = started++;
        late final Future<void> running;
        running = task()
            .then((result) {
              if (preserveOrder) {
                byInputIndex[index] = result;
              } else {
                inCompletionOrder.add(result);
              }
            })
            .whenComplete(() => active.remove(running));
        active.add(running);
      }
      await Future.wait(active);
    } catch (_) {
      // The first failure wins; later failures of tasks that are still
      // running must not surface as unhandled errors.
      for (final running in active) {
        running.ignore();
      }
      rethrow;
    }
    if (!preserveOrder) return inCompletionOrder;
    return [for (var i = 0; i < started; i++) byInputIndex[i] as T];
  }
}
