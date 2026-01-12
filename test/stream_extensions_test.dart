import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('StreamController safety extensions', () {
    test('safeAdd returns false when closed', () async {
      final controller = StreamController<int>();
      controller.stream.listen((_) {});
      await controller.close();
      expect(controller.safeAdd(1), isFalse);
    });

    test('safeAddError forwards errors', () async {
      final controller = StreamController<int>();
      final errors = <Object>[];
      controller.stream.listen((_) {}, onError: errors.add);
      expect(controller.safeAddError(Exception('boom')), isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(errors.length, 1);
      await controller.close();
    });

    test('safeAddAll adds events', () async {
      final controller = StreamController<int>();
      final events = <int>[];
      controller.stream.listen(events.add);
      final count = await controller.safeAddAll([1, 2, 3]);
      expect(count, 3);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, [1, 2, 3]);
      await controller.close();
    });

    test('safeAddStream forwards stream events', () async {
      final controller = StreamController<int>();
      final events = <int>[];
      controller.stream.listen(events.add);
      final count = await controller.safeAddStream(Stream.fromIterable([1, 2]));
      expect(count, 2);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, [1, 2]);
      await controller.close();
    });

    test('safeAddFuture forwards future result', () async {
      final controller = StreamController<int>();
      final events = <int>[];
      controller.stream.listen(events.add);
      await controller.safeAddFuture(Future.value(10));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, [10]);
      await controller.close();
    });

    test('mergeStreams forwards multiple streams', () async {
      final controller = StreamController<int>();
      final events = <int>[];
      controller.stream.listen(events.add);
      await controller.mergeStreams([
        Stream.fromIterable([1, 2]),
        Stream.fromIterable([3]),
      ]);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, unorderedEquals([1, 2, 3]));
      await controller.close();
    });

    test('mergeStreams handles empty list', () async {
      final controller = StreamController<int>();
      controller.stream.listen((_) {});
      await controller.mergeStreams([]);
      await controller.close();
    });

    test('asBroadcast creates broadcast stream', () async {
      final controller = StreamController<int>();
      final broadcast = controller.asBroadcast();
      expect(broadcast.stream.isBroadcast, isTrue);
      final events = <int>[];
      broadcast.stream.listen(events.add);
      controller.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, [1]);
      await controller.close();
    });
  });

  group('Stream transformations', () {
    test('bufferCount groups items', () async {
      final data = await Stream.fromIterable([
        1,
        2,
        3,
        4,
        5,
      ]).bufferCount(2).toList();
      expect(data, [
        [1, 2],
        [3, 4],
        [5],
      ]);
    });

    test('window emits remaining buffer on close', () async {
      final data = await Stream.fromIterable([
        1,
        2,
        3,
      ]).window(const Duration(seconds: 10)).toList();
      expect(data, [
        [1, 2, 3],
      ]);
    });

    test('rateLimit drops excess events', () async {
      final data = await Stream.fromIterable([
        1,
        2,
        3,
        4,
      ]).rateLimit(2, const Duration(days: 1)).toList();
      expect(data, [1, 2]);
    });

    test('bufferCount validates count', () {
      expect(
        () => Stream.fromIterable([1, 2]).bufferCount(0),
        throwsArgumentError,
      );
    });

    test('window validates duration', () {
      expect(
        () => Stream.fromIterable([1]).window(Duration.zero),
        throwsArgumentError,
      );
    });

    test('rateLimit validates arguments', () {
      expect(
        () => Stream.fromIterable([1]).rateLimit(0, const Duration(days: 1)),
        throwsArgumentError,
      );
    });

    test('asPausable pauses and resumes flow', () async {
      final controller = StreamController<int>();
      final pausable = controller.stream.asPausable();
      final events = <int>[];
      pausable.stream.listen(events.add);

      pausable.pause();
      controller
        ..add(1)
        ..add(2);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, isEmpty);

      pausable.resume();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(events, [1, 2]);
      await controller.close();
    });

    test('withLatestValue replays latest to new listeners', () async {
      final controller = StreamController<int>();
      final stream = controller.stream.withLatestValue();
      final firstListener = <int>[];
      stream.listen(firstListener.add);
      controller.add(1);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final secondListener = <int>[];
      stream.listen(secondListener.add);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(firstListener, [1]);
      expect(secondListener, [1]);
      await controller.close();
    });
  });

  group('Stream error recovery', () {
    test('retry resubscribes on error', () async {
      var attempts = 0;
      final stream = Stream<int>.multi((controller) {
        attempts++;
        if (attempts == 1) {
          controller.addError(Exception('fail'));
        } else {
          controller
            ..add(1)
            ..close();
        }
      });

      final values = await stream.retry(retryCount: 1).toList();
      expect(values, [1]);
      expect(attempts, 2);
    });

    test('retry validates arguments', () async {
      final stream = Stream<int>.fromIterable([1]);
      await expectLater(
        () => stream.retry(retryCount: -1).toList(),
        throwsArgumentError,
      );
    });

    test('replaceOnError emits default value', () async {
      final values = await Stream<int>.error(
        Exception('boom'),
      ).replaceOnError(defaultValue: 99).toList();
      expect(values, [99]);
    });

    test('completeOnError completes without error', () async {
      final stream = Stream<int>.multi((controller) {
        controller
          ..add(1)
          ..addError(Exception('boom'))
          ..close();
      });

      final values = await stream.completeOnError().toList();
      expect(values, [1]);
    });

    test('retry throws informative error on single-subscription stream',
        () async {
      final controller = StreamController<int>();
      controller.addError(Exception('Fail 1'));

      final retriedStream = controller.stream.retry(retryCount: 1);

      try {
        await retriedStream.toList();
        fail('Should have thrown StateError');
      } catch (e) {
        expect(e, isA<StateError>());
        expect(
          e.toString(),
          contains('Cannot retry a single-subscription stream'),
        );
      }
      await controller.close();
    });

    test('Stream factory retry works correctly', () async {
      var attempts = 0;
      Stream<int> createStream() {
        attempts++;
        if (attempts == 1) return Stream.error(Exception('Fail'));
        return Stream.value(42);
      }

      final stream = createStream.retry();
      final values = await stream.toList();
      expect(values, [42]);
      expect(attempts, 2);
    });
  });
}
