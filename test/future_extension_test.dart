import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Future Extensions', () {
    test('minWait ensures minimum duration', () async {
      final start = DateTime.now();
      const minDuration = Duration(milliseconds: 200);

      await Future.value(1).minWait(minDuration);

      final elapsed = DateTime.now().difference(start);
      expect(
        elapsed.inMilliseconds,
        greaterThanOrEqualTo(190),
      ); // leeway for execution time
    });

    test('timeoutOrNull returns value if completes in time', () async {
      final result = await Future.delayed(
        const Duration(milliseconds: 50),
        () => 'success',
      ).timeoutOrNull(const Duration(milliseconds: 100));

      expect(result, 'success');
    });

    test('timeoutOrNull returns null if times out', () async {
      final result = await Future.delayed(
        const Duration(milliseconds: 100),
        () => 'success',
      ).timeoutOrNull(const Duration(milliseconds: 50));

      expect(result, null);
    });
  });

  group('Future Callback Extensions', () {
    test('retry retries on failure', () async {
      var attempts = 0;
      final result = await (() async {
        attempts++;
        if (attempts < 3) throw Exception('fail');
        return 'success';
      }).retry(retries: 3, delay: const Duration(milliseconds: 10));

      expect(result, 'success');
      expect(attempts, 3);
    });

    test('retry fails after max retries', () async {
      var attempts = 0;
      final future = (() async {
        attempts++;
        throw Exception('fail');
      }).retry(retries: 3, delay: const Duration(milliseconds: 10));

      await expectLater(future, throwsException);
      expect(attempts, 4);
    });

    test('retry respects retryIf', () async {
      var attempts = 0;
      expect(
        () =>
            (() async {
              attempts++;
              throw Exception('fatal');
            }).retry(
              retries: 3,
              delay: const Duration(milliseconds: 10),
              retryIf: (e) => e.toString().contains('recoverable'),
            ),
        throwsException,
      );
      expect(attempts, 1); // Should not retry
    });
  });

  group('Future Iterable Extensions', () {
    test('waitConcurrency runs tasks', () async {
      final results = await [
        () async => 1,
        () async => 2,
        () async => 3,
      ].waitConcurrency(concurrency: 2);

      expect(results, unorderedEquals([1, 2, 3]));
    });

    test('waitConcurrency respects concurrency', () async {
      var activeCount = 0;
      var maxActive = 0;

      final tasks = List.generate(
        10,
        (i) => () async {
          activeCount++;
          if (activeCount > maxActive) maxActive = activeCount;
          await Future<void>.delayed(const Duration(milliseconds: 10));
          activeCount--;
          return i;
        },
      );

      await tasks.waitConcurrency(concurrency: 3);
      expect(maxActive, lessThanOrEqualTo(3));
    });

    test('waitConcurrency propagates errors', () async {
      final tasks = [
        () async => 1,
        () async => throw StateError('boom'),
        () async => 3,
      ];

      await expectLater(
        tasks.waitConcurrency(concurrency: 2),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('7.0.0 ordered concurrency', () {
    test('waitConcurrency returns input order when asked', () async {
      final delays = [30, 10, 20, 0];
      final tasks = [
        for (final (index, delay) in delays.indexed)
          () => Future<int>.delayed(Duration(milliseconds: delay), () => index),
      ];
      expect(await tasks.waitConcurrency(concurrency: 4), [3, 1, 2, 0]);
      expect(await tasks.waitConcurrency(concurrency: 4, preserveOrder: true), [
        0,
        1,
        2,
        3,
      ]);
    });

    test('mapConcurrent keeps input order and the concurrency limit', () async {
      var active = 0;
      var peak = 0;
      final result = await [40, 0, 20, 10, 30].mapConcurrent(
        (ms) async {
          active++;
          if (active > peak) peak = active;
          await Future<void>.delayed(Duration(milliseconds: ms));
          active--;
          return ms;
        },
        parallelism: 2,
        preserveOrder: true,
      );
      expect(result, [40, 0, 20, 10, 30]);
      expect(peak, 2);
    });

    test('preserveOrder keeps null results in place', () async {
      final tasks = <Future<int?> Function()>[() async => null, () async => 1];
      expect(await tasks.waitConcurrency(preserveOrder: true), [null, 1]);
    });

    test('invalid limits fail the returned future', () async {
      await expectLater(
        [1].mapConcurrent((e) async => e, parallelism: 0),
        throwsArgumentError,
      );
      await expectLater(
        <Future<int> Function()>[].waitConcurrency(concurrency: 0),
        throwsArgumentError,
      );
    });

    test('the first failure wins and later failures stay handled', () async {
      final tasks = <Future<int> Function()>[
        () => Future<int>.delayed(
          const Duration(milliseconds: 5),
          () => throw StateError('first'),
        ),
        () => Future<int>.delayed(
          const Duration(milliseconds: 30),
          () => throw StateError('second'),
        ),
      ];
      await expectLater(
        tasks.waitConcurrency(concurrency: 2, preserveOrder: true),
        throwsA(isA<StateError>()),
      );
      // Let the second task fail; the test zone would report it if unhandled.
      await Future<void>.delayed(const Duration(milliseconds: 40));
    });
  });
}
