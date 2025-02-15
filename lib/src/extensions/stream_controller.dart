import 'dart:async';
import 'dart:math';

import 'package:dart_helper_utils/dart_helper_utils.dart';

/// ---------------------------------------------------------------------------
/// StreamController Safety Extensions
/// ---------------------------------------------------------------------------

/// Provides safe methods on [StreamController] to avoid common pitfalls
/// such as adding events to a closed controller and swallowing errors.
///
/// Example:
/// ```dart
/// final controller = StreamController<int>();
/// // Safely add an event:
/// controller.safeAdd(42);
/// // Safely close:
/// await controller.safeClose();
/// ```
extension StreamControllerSafeExtensions<T> on StreamController<T> {
  /// Adds an [event] to this controller if it is not closed.
  ///
  /// Returns `true` if the event was added successfully, or `false` if
  /// the controller was already closed.
  bool safeAdd(T event) {
    if (_isClosed()) return false;
    try {
      add(event);
      return true;
    } catch (e) {
      // Optionally log or handle internal add failures.
      return false;
    }
  }

  /// Adds an [error] (with an optional [stackTrace]) to this controller if
  /// it is not closed.
  ///
  /// Returns `true` if the error was added successfully, or `false` if
  /// the controller was closed.
  bool safeAddError(Object error, [StackTrace? stackTrace]) {
    if (_isClosed()) return false;
    try {
      addError(error, stackTrace);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Handles dynamic errors and passes them through [safeAddError].
  void _handleDynamicOnError(dynamic error, dynamic stackTrace) {
    if (error is Object) {
      safeAddError(error, stackTrace is StackTrace ? stackTrace : null);
    }
  }

  /// Closes this controller if it is still open.
  ///
  /// Returns a [Future] that completes when the controller is closed.
  Future<void> safeClose() {
    if (_isClosed()) return Future.value();
    return close();
  }

  /// Adds all events from [events] to this controller.
  ///
  /// If [throttleDuration] is provided, each event is delayed by that
  /// duration to help avoid overwhelming downstream listeners.
  ///
  /// Returns the number of events successfully added.
  Future<int> safeAddAll(Iterable<T> events,
      {Duration? throttleDuration}) async {
    var count = 0;
    for (final event in events) {
      if (safeAdd(event)) {
        count++;
        if (throttleDuration != null) {
          await throttleDuration.delayed<void>();
        }
      }
    }
    return count;
  }

  /// Listens to [sourceStream] and adds its events to this controller.
  ///
  /// Errors from the [sourceStream] are forwarded via [safeAddError].
  /// Returns a [Future] that completes with the number of events added once
  /// [sourceStream] is done.
  Future<int> safeAddStream(Stream<T> sourceStream) async {
    var addedCount = 0;
    final completer = Completer<int>();

    final subscription = sourceStream.listen(
      (event) {
        if (safeAdd(event)) addedCount++;
      },
      onError: _handleDynamicOnError,
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(addedCount);
        }
      },
      cancelOnError: false,
    );

    // If the controller is already closed, cancel the subscription.
    if (_isClosed() && !completer.isCompleted) {
      await subscription.cancel();
      completer.complete(addedCount);
    }
    return completer.future;
  }

  /// Adds the result of a [future] to this controller once it completes.
  ///
  /// If the controller is closed before the [future] completes, the result
  /// is discarded. Optionally, provide [onError] to handle errors.
  Future<void> safeAddFuture(
    Future<T> future, {
    void Function(Object error, StackTrace stackTrace)? onError,
  }) async {
    try {
      final result = await future;
      safeAdd(result);
    } catch (error, stackTrace) {
      if (onError != null) onError(error, stackTrace);
      safeAddError(error, stackTrace);
    }
  }

  /// Merges events from multiple [streams] into this controller.
  ///
  /// All events and errors from the provided streams are forwarded to this
  /// controller. The returned [Future] completes when all streams have ended.
  Future<void> mergeStreams(List<Stream<T>> streams) async {
    assert(streams.isNotEmpty, 'Streams list cannot be empty');
    final completer = Completer<void>();
    var completedCount = 0;
    final subscriptions = <StreamSubscription<T>>[];

    for (final stream in streams) {
      final subscription = stream.listen(
        safeAdd,
        onError: _handleDynamicOnError,
        onDone: () {
          completedCount++;
          if (completedCount == streams.length && !completer.isCompleted) {
            completer.complete();
          }
        },
      );
      subscriptions.add(subscription);
    }

    // Cancel any active subscriptions if the controller is closed.
    if (_isClosed() && !completer.isCompleted) {
      for (final sub in subscriptions) {
        await sub.cancel();
      }
      completer.complete();
    }
    return completer.future;
  }

  /// Converts this controller into a broadcast controller.
  ///
  /// If the controller is already broadcast, it is returned as-is.
  /// **Caution:** Once switched to broadcast, it cannot be reverted.
  StreamController<T> asBroadcast() {
    if (stream.isBroadcast) return this;
    final broadcastController = StreamController<T>.broadcast();
    stream.listen(
      broadcastController.add,
      onError: broadcastController.addError,
      onDone: broadcastController.close,
    );
    return broadcastController;
  }

  /// Determines whether the controller is closed.
  ///
  /// This helper method uses [hasListener] as a heuristic; adjust it if your
  /// environment provides a more reliable indicator.
  bool _isClosed() {
    if (isClosed) return true;
    // For broadcast controllers, we assume that the controller remains open
    // until explicitly closed.
    if (stream.isBroadcast) return false;
    return !hasListener;
  }
}

/// Additional stream transformations not covered by the official Dart [RateLimit] extension.
extension StreamTransformations<T> on Stream<T> {
  /// Buffers incoming events into lists of size [count].
  ///
  /// When the buffer reaches [count] elements, it is emitted. Any remaining
  /// events are emitted when the stream closes.
  ///
  /// Example:
  /// ```dart
  /// myStream.buffer(3).listen((chunk) {
  ///   print('Received a chunk of ${chunk.length} items');
  /// });
  /// ```
  Stream<List<T>> bufferCount(int count) {
    assert(count > 0, 'Buffer count must be greater than zero');
    final bucket = <T>[];
    return transform(
      StreamTransformer<T, List<T>>.fromHandlers(
        handleData: (data, sink) {
          bucket.add(data);
          if (bucket.length >= count) {
            sink.add(List<T>.from(bucket));
            bucket.clear();
          }
        },
        handleDone: (sink) {
          if (bucket.isNotEmpty) sink.add(List<T>.from(bucket));
          sink.close();
        },
      ),
    );
  }

  /// Buffers events into time-based windows defined by [windowDuration].
  ///
  /// All events occurring within each time window are collected into a list,
  /// which is then emitted when the window expires.
  ///
  /// Example:
  /// ```dart
  /// myStream.window(Duration(seconds: 1))
  ///   .listen((events) => print('Window contained ${events.length} items'));
  /// ```
  Stream<List<T>> window(Duration windowDuration) {
    assert(windowDuration.inMilliseconds > 0,
        'Window duration must be greater than zero');
    StreamController<List<T>>? controller;
    final buffer = <T>[];
    Timer? timer;

    void emitBuffer() {
      if (buffer.isNotEmpty) {
        controller?.add(List<T>.from(buffer));
        buffer.clear();
      }
    }

    controller = StreamController<List<T>>(
      onListen: () {
        timer = Timer.periodic(windowDuration, (_) => emitBuffer());
        final subscription = listen(
          buffer.add,
          onError: (dynamic error, dynamic stackTrace) {
            timer?.cancel();
            controller?._handleDynamicOnError(error, stackTrace);
          },
          onDone: () {
            timer?.cancel();
            emitBuffer();
            controller?.close();
          },
          cancelOnError: false,
        );
        controller?.onCancel = () async {
          timer?.cancel();
          await subscription.cancel();
        };
      },
    );

    return controller.stream;
  }

  /// Limits the rate of event emissions, allowing at most [maxEvents]
  /// during each [duration] window.
  ///
  /// Example:
  /// ```dart
  /// myStream.rateLimit(5, Duration(seconds: 1))
  ///   .listen((data) => print(data));
  /// ```
  Stream<T> rateLimit(int maxEvents, Duration duration) {
    assert(maxEvents > 0, 'maxEvents must be greater than zero');
    assert(duration.inMilliseconds > 0, 'Duration must be greater than zero');

    var eventCount = 0;
    var windowStart = DateTime.now();
    final controller = StreamController<T>();
    late StreamSubscription<T> subscription;

    void resetCounter() {
      eventCount = 0;
      windowStart = DateTime.now();
    }

    subscription = listen(
      (data) {
        final now = DateTime.now();
        if (now.difference(windowStart) >= duration) {
          resetCounter();
        }
        if (eventCount < maxEvents) {
          eventCount++;
          controller.add(data);
        }
      },
      onError: (dynamic error, dynamic stackTrace) {
        controller._handleDynamicOnError(error, stackTrace);
      },
      onDone: controller.close,
      cancelOnError: false,
    );

    controller.onCancel = () async {
      await subscription.cancel();
    };

    return controller.stream;
  }

  /// Returns a pausable version of this stream.
  ///
  /// Use the returned [PausableStream] to pause and resume event flow.
  ///
  /// Example:
  /// ```dart
  /// final pausable = myStream.asPausable();
  /// pausable.stream.listen((data) => print(data));
  /// // Later, pause or resume as needed:
  /// pausable.pause();
  /// pausable.resume();
  /// ```
  PausableStream<T> asPausable() {
    return PausableStream<T>(this);
  }

  /// Returns a stream that replays the latest emitted value to new subscribers.
  ///
  /// This is similar in behavior to a “behavior subject” – whenever a new
  /// listener subscribes, it immediately receives the most recent value.
  ///
  /// Example:
  /// ```dart
  /// myStream.withLatestValue().listen((data) => print('Listener got: $data'));
  /// ```
  Stream<T> withLatestValue() {
    final controller = StreamController<T>.broadcast();
    T? latestValue;
    var hasValue = false;

    final subscription = listen(
      (data) {
        latestValue = data;
        hasValue = true;
        controller.add(data);
      },
      onError: (dynamic error, dynamic stackTrace) {
        controller._handleDynamicOnError(error, stackTrace);
      },
      onDone: controller.close,
    );

    controller
      ..onListen = () {
        if (hasValue) {
          controller.add(latestValue as T);
        }
      }
      ..onCancel = () async {
        await subscription.cancel();
      };

    return controller.stream;
  }
}

/// ---------------------------------------------------------------------------
/// Stream Error Recovery Extensions
/// ---------------------------------------------------------------------------

/// Provides error recovery strategies on [Stream], including retry logic with
/// exponential backoff and alternative recovery modes.
///
/// The following methods are available:
/// - [retry]: Resubscribes to the source stream when an error occurs,
///   up to a maximum number of attempts.
/// - [replaceOnError]: Replaces an error event with a provided default value,
///   then completes.
/// - [completeOnError]: Completes the stream immediately upon an error.
///
/// Example:
/// ```dart
/// // Retry up to 3 times with an initial delay of 1 second.
/// myStream.retry(retryCount: 3, delayFactor: Duration(seconds: 1))
///   .listen(print, onError: print);
/// ```
extension StreamErrorRecovery<T> on Stream<T> {
  /// Retries the stream subscription in case of error.
  ///
  /// [retryCount] specifies the maximum number of retry attempts.
  /// [delayFactor] determines the base delay for exponential backoff.
  /// [shouldRetry] can be used to decide whether to retry for a specific error.
  ///
  /// Returns a new stream that, upon error, will resubscribe to the source.
  Stream<T> retry({
    int retryCount = 3,
    Duration delayFactor = const Duration(seconds: 1),
    bool Function(Object error)? shouldRetry,
  }) async* {
    assert(retryCount >= 0, 'retryCount must be non-negative');
    assert(delayFactor.inMilliseconds > 0,
        'delayFactor must be greater than zero');

    var attempts = 0;
    while (true) {
      try {
        await for (final value in this) {
          yield value;
        }
        break;
      } catch (error) {
        if (attempts < retryCount &&
            (shouldRetry == null || shouldRetry(error))) {
          attempts++;
          // Exponential backoff: delay = delayFactor * (2 ^ (attempts - 1))
          final delayMillis =
              delayFactor.inMilliseconds * pow(2, attempts - 1).toInt();
          await delayMillis.millisecondsDelay();
          continue;
        }
        rethrow;
      }
    }
  }

  /// Replaces an error event with [defaultValue] and then completes the stream.
  ///
  /// Example:
  /// ```dart
  /// myStream.replaceOnError(defaultValue: fallback)
  ///   .listen(print, onError: print);
  /// ```
  Stream<T> replaceOnError({required T defaultValue}) {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleData: (data, sink) => sink.add(data),
        handleError: (error, stackTrace, sink) {
          sink
            ..add(defaultValue)
            ..close();
        },
      ),
    );
  }

  /// Completes the stream immediately upon an error, swallowing the error.
  ///
  /// Example:
  /// ```dart
  /// myStream.completeOnError()
  ///   .listen(print, onError: (e) => print('Error handled silently'));
  /// ```
  Stream<T> completeOnError() {
    return transform(
      StreamTransformer<T, T>.fromHandlers(
        handleError: (error, stackTrace, sink) {
          sink.close();
        },
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Pausable Stream
/// ---------------------------------------------------------------------------

/// A stream wrapper that allows pausing and resuming of event flow.
///
/// Example:
/// ```dart
/// final pausable = myStream.asPausable();
/// pausable.stream.listen((data) => print(data));
/// // Pause or resume as needed:
/// pausable.pause();
/// pausable.resume();
/// ```
class PausableStream<T> {
  /// Creates a [PausableStream] that wraps the [_source] stream.
  PausableStream(this._source) {
    _controller = StreamController<T>(
      onListen: _start,
      onPause: pause,
      onResume: resume,
      onCancel: _cancel,
    );
  }

  final Stream<T> _source;
  late final StreamController<T> _controller;
  StreamSubscription<T>? _subscription;
  bool _paused = false;
  Completer<void>? _resumeCompleter;

  /// The pausable stream that emits events from the source.
  Stream<T> get stream => _controller.stream;

  void _start() {
    _subscription = _source.listen(
      (data) async {
        if (_paused) {
          _resumeCompleter ??= Completer<void>();
          await _resumeCompleter!.future;
        }
        if (!_controller.isClosed) {
          _controller.add(data);
        }
      },
      onError: (dynamic error, dynamic stackTrace) {
        _controller._handleDynamicOnError(error, stackTrace);
      },
      onDone: () {
        if (!_controller.isClosed) {
          _controller.close();
        }
      },
      cancelOnError: false,
    );
  }

  /// Pauses the stream so that events from the source are held until resumed.
  void pause() {
    if (!_paused) {
      _paused = true;
      _resumeCompleter = Completer<void>();
    }
  }

  /// Resumes the stream, releasing any buffered events.
  void resume() {
    if (_paused) {
      _paused = false;
      _resumeCompleter?.complete();
      _resumeCompleter = null;
    }
  }

  Future<void> _cancel() async {
    await _subscription?.cancel();
  }
}
