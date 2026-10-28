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
    if (isClosed) return false;
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
    if (isClosed) return false;
    try {
      addError(error, stackTrace);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Forwards a source stream's error through [safeAddError].
  void _forwardError(Object error, StackTrace stackTrace) {
    safeAddError(error, stackTrace);
  }

  /// Closes this controller if it is still open.
  ///
  /// Returns a [Future] that completes when the controller is closed.
  Future<void> safeClose() {
    if (isClosed) return Future.value();
    return close();
  }

  /// Adds all events from [events] to this controller.
  ///
  /// If [throttleDuration] is provided, each event is delayed by that
  /// duration to help avoid overwhelming downstream listeners.
  ///
  /// Returns the number of events successfully added.
  Future<int> safeAddAll(
    Iterable<T> events, {
    Duration? throttleDuration,
  }) async {
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
      onError: _forwardError,
      onDone: () {
        if (!completer.isCompleted) {
          completer.complete(addedCount);
        }
      },
      cancelOnError: false,
    );

    // If the controller is already closed, cancel the subscription.
    if (isClosed && !completer.isCompleted) {
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
    if (streams.isEmpty) {
      return;
    }
    final completer = Completer<void>();
    var completedCount = 0;
    final subscriptions = <StreamSubscription<T>>[];

    for (final stream in streams) {
      final subscription = stream.listen(
        safeAdd,
        onError: _forwardError,
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
    if (isClosed && !completer.isCompleted) {
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
}

/// Batching, windowing, rate limiting, pausing, and replay transformations
/// for [Stream].
///
/// Transformers that keep state ([bufferCount], [rateLimit]) keep it per
/// subscription: each listener of a broadcast stream gets its own batches
/// and its own rate budget, and the source is not listened to until the
/// returned stream is.
extension StreamTransformations<T> on Stream<T> {
  /// Buffers incoming events into lists of size [count].
  ///
  /// When the buffer reaches [count] elements, it is emitted. Any remaining
  /// events are emitted when the stream closes. Errors are forwarded
  /// immediately without flushing the buffer.
  ///
  /// The returned stream is a broadcast stream if this stream is.
  ///
  /// Example:
  /// ```dart
  /// myStream.bufferCount(3).listen((chunk) {
  ///   print('Received a chunk of ${chunk.length} items');
  /// });
  /// ```
  Stream<List<T>> bufferCount(int count) {
    if (count <= 0) {
      throw ArgumentError.value(count, 'count', 'must be greater than zero');
    }
    return Stream<List<T>>.eventTransformed(
      this,
      (sink) => _BufferCountSink<T>(sink, count),
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
    if (windowDuration.inMilliseconds <= 0) {
      throw ArgumentError('Window duration must be greater than zero');
    }
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
          onError: (Object error, StackTrace stackTrace) {
            timer?.cancel();
            controller?._forwardError(error, stackTrace);
          },
          onDone: () {
            timer?.cancel();
            emitBuffer();
            unawaited(controller?.close());
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
  /// during each [duration] window. Events over the budget are dropped.
  ///
  /// A window opens with the first event after the previous window expired
  /// and is measured with a monotonic clock, so wall-clock changes do not
  /// affect it. The source is listened to only when the returned stream is,
  /// and pausing or cancelling the returned subscription pauses or cancels
  /// the source. The returned stream is a broadcast stream if this stream
  /// is.
  ///
  /// Example:
  /// ```dart
  /// myStream.rateLimit(5, Duration(seconds: 1))
  ///   .listen((data) => print(data));
  /// ```
  Stream<T> rateLimit(int maxEvents, Duration duration) {
    if (maxEvents <= 0) {
      throw ArgumentError.value(
        maxEvents,
        'maxEvents',
        'must be greater than zero',
      );
    }
    if (duration <= Duration.zero) {
      throw ArgumentError.value(
        duration,
        'duration',
        'must be greater than zero',
      );
    }
    return Stream<T>.eventTransformed(
      this,
      (sink) => _RateLimitSink<T>(sink, maxEvents, duration),
    );
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
    T? latestValue;
    var hasValue = false;
    final source = asBroadcastStream();

    return Stream<T>.multi((multiController) {
      if (hasValue) {
        multiController.add(latestValue as T);
      }
      final subscription = source.listen(
        (data) {
          latestValue = data;
          hasValue = true;
          multiController.add(data);
        },
        onError: multiController.addError,
        onDone: multiController.close,
      );
      multiController.onCancel = subscription.cancel;
    });
  }
}

/// ---------------------------------------------------------------------------
/// Stream Factory Extensions
/// ---------------------------------------------------------------------------

/// Extensions for Stream factory functions to support safe retries.
extension DHUStreamFactoryExtensions<T> on Stream<T> Function() {
  /// Retries the stream created by this factory.
  ///
  /// [retryCount] specifies the maximum number of retry attempts.
  /// [delayFactor] determines the base delay for exponential backoff.
  /// [shouldRetry] can be used to decide whether to retry for a specific error.
  ///
  /// This safely handles single-subscription streams by creating a new
  /// stream instance for each attempt.
  Stream<T> retry({
    int retryCount = 3,
    Duration delayFactor = const Duration(seconds: 1),
    bool Function(Object error)? shouldRetry,
  }) async* {
    if (retryCount < 0) {
      throw ArgumentError('retryCount must be non-negative');
    }
    if (delayFactor.inMilliseconds <= 0) {
      throw ArgumentError('delayFactor must be greater than zero');
    }

    var attempts = 0;
    while (true) {
      try {
        await for (final value in this()) {
          yield value;
        }
        break;
      } catch (error) {
        if (attempts < retryCount &&
            (shouldRetry == null || shouldRetry(error))) {
          attempts++;
          final delayMillis =
              delayFactor.inMilliseconds * pow(2, attempts - 1).toInt();
          await delayMillis.millisecondsDelay();
          continue;
        }
        rethrow;
      }
    }
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
    if (retryCount < 0) {
      throw ArgumentError('retryCount must be non-negative');
    }
    if (delayFactor.inMilliseconds <= 0) {
      throw ArgumentError('delayFactor must be greater than zero');
    }

    var attempts = 0;
    while (true) {
      try {
        await for (final value in this) {
          yield value;
        }
        break;
      } catch (error) {
        if (error is StateError) {
          if (error.message.contains('already been listened')) {
            throw StateError(
              'Cannot retry a single-subscription stream that has already been listened to. '
              'Use a broadcast stream or the "retry" extension on a Stream Factory function (Stream<T> Function()) instead.',
            );
          }
        }

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
      onError: (Object error, StackTrace stackTrace) {
        _controller._forwardError(error, stackTrace);
      },
      onDone: () {
        if (!_controller.isClosed) {
          unawaited(_controller.close());
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

/// Per-subscription state for [StreamTransformations.bufferCount].
final class _BufferCountSink<T> implements EventSink<T> {
  _BufferCountSink(this._out, this._count);

  final EventSink<List<T>> _out;
  final int _count;
  List<T> _bucket = <T>[];

  @override
  void add(T event) {
    _bucket.add(event);
    if (_bucket.length >= _count) {
      final full = _bucket;
      _bucket = <T>[];
      _out.add(full);
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _out.addError(error, stackTrace);

  @override
  void close() {
    if (_bucket.isNotEmpty) {
      _out.add(_bucket);
      _bucket = <T>[];
    }
    _out.close();
  }
}

/// Per-subscription state for [StreamTransformations.rateLimit].
final class _RateLimitSink<T> implements EventSink<T> {
  _RateLimitSink(this._out, this._maxEvents, this._window);

  final EventSink<T> _out;
  final int _maxEvents;
  final Duration _window;
  final Stopwatch _clock = Stopwatch()..start();
  Duration? _windowStart;
  int _eventsInWindow = 0;

  @override
  void add(T event) {
    final now = _clock.elapsed;
    final windowStart = _windowStart;
    if (windowStart == null || now - windowStart >= _window) {
      _windowStart = now;
      _eventsInWindow = 0;
    }
    if (_eventsInWindow < _maxEvents) {
      _eventsInWindow++;
      _out.add(event);
    }
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _out.addError(error, stackTrace);

  @override
  void close() => _out.close();
}
