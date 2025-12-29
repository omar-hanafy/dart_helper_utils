import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('TimeUtils helpers', () {
    test('executionDuration measures work', () async {
      final duration = await TimeUtils.executionDuration(() async {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      });
      expect(duration.inMilliseconds, greaterThanOrEqualTo(10));
    });

    test('executionDurations returns list of durations', () async {
      final durations = await TimeUtils.executionDurations([
        () => Future<void>.delayed(const Duration(milliseconds: 5)),
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      ]);
      expect(durations.length, 2);
      expect(durations[0].inMilliseconds, greaterThanOrEqualTo(5));
    });

    test('compareExecutionTimes returns tuple', () async {
      final result = await TimeUtils.compareExecutionTimes(
        taskA: () => Future<void>.delayed(const Duration(milliseconds: 5)),
        taskB: () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      expect(result.$1, isA<Duration>());
      expect(result.$2, isA<Duration>());
    });

    test('debounce delays calls', () async {
      var calls = 0;
      final debounced = TimeUtils.debounce(
        () => calls++,
        const Duration(milliseconds: 20),
      );
      debounced();
      debounced();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(calls, 1);
      debounced.dispose();
    });

    test('runPeriodically invokes callback', () async {
      final completer = Completer<void>();
      var ticks = 0;
      final timer = TimeUtils.runPeriodically(
        interval: const Duration(milliseconds: 10),
        onExecute: (timer, count) {
          ticks = count;
          if (count >= 3) {
            timer.cancel();
            completer.complete();
          }
        },
      );
      await completer.future;
      timer.cancel();
      expect(ticks, greaterThanOrEqualTo(3));
    });

    test('runWithTimeout completes or times out', () async {
      final result = await TimeUtils.runWithTimeout(
        task: () async => 'ok',
        timeout: const Duration(milliseconds: 50),
      );
      expect(result, 'ok');

      await expectLater(
        TimeUtils.runWithTimeout(
          task: () async {
            await Future<void>.delayed(const Duration(milliseconds: 50));
            return 'late';
          },
          timeout: const Duration(milliseconds: 10),
        ),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
