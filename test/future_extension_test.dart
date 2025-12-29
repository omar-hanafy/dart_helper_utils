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
          await Future.delayed(const Duration(milliseconds: 10));
          activeCount--;
          return i;
        },
      );

      await tasks.waitConcurrency(concurrency: 3);
      expect(maxActive, lessThanOrEqualTo(3));
    });
  });
}
