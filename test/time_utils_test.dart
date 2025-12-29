import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('TimeUtils.throttle', () {
    test('executes immediately by default and ignores burst calls', () async {
      var calls = 0;
      final throttled = TimeUtils.throttle(
        () => calls++,
        const Duration(milliseconds: 30),
      );

      throttled();
      throttled();
      throttled();
      expect(calls, 1);

      await Future<void>.delayed(const Duration(milliseconds: 40));
      throttled();
      expect(calls, 2);
    });

    test(
      'trailing executes once after interval when leading is false',
      () async {
        var calls = 0;
        final throttled = TimeUtils.throttle(
          () => calls++,
          const Duration(milliseconds: 30),
          leading: false,
          trailing: true,
        );

        throttled();
        throttled();
        expect(calls, 0);

        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(calls, 1);

        throttled();
        await Future<void>.delayed(const Duration(milliseconds: 40));
        expect(calls, 2);
      },
    );

    test('cancel prevents trailing execution', () async {
      var calls = 0;
      final throttled = TimeUtils.throttle(
        () => calls++,
        const Duration(milliseconds: 30),
        leading: false,
        trailing: true,
      );

      throttled();
      throttled.cancel();

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(calls, 0);
    });

    test('dispose prevents future calls', () {
      final throttled = TimeUtils.throttle(
        () {},
        const Duration(milliseconds: 30),
      );
      throttled.dispose();
      expect(throttled.isDisposed, isTrue);
      expect(() => throttled(), throwsStateError);
    });
  });

  group('TimeUtils.runWithTimeout', () {
    test('returns result before the timeout fires', () async {
      final result = await TimeUtils.runWithTimeout(
        task: () async {
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return 'ok';
        },
        timeout: const Duration(milliseconds: 50),
      );

      expect(result, 'ok');
    });

    test('completes with TimeoutException when the timer expires', () async {
      final future = TimeUtils.runWithTimeout<String>(
        task: () async {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          return 'never';
        },
        timeout: const Duration(milliseconds: 10),
      );

      await expectLater(future, throwsA(isA<TimeoutException>()));
    });

    test('suppresses late errors so the zone stays clean', () async {
      final zoneErrors = <Object>[];
      await runZonedGuarded(
        () async {
          final future = TimeUtils.runWithTimeout<void>(
            task: () async {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              throw StateError('late');
            },
            timeout: const Duration(milliseconds: 10),
          );

          await expectLater(future, throwsA(isA<TimeoutException>()));
          await Future<void>.delayed(const Duration(milliseconds: 100));
        },
        (error, stack) {
          zoneErrors.add(error);
        },
      );

      expect(zoneErrors, isEmpty);
    });
  });
}
