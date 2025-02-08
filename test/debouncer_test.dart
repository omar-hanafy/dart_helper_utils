// ignore_for_file: avoid_redundant_argument_values
import 'dart:async';
import 'dart:io';

// Import your updated debouncer. Adjust the path as needed.
import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';
// Adjust the import path as necessary.

void main() {
  group('Debouncer Initialization', () {
    test('creates instance with valid parameters', () {
      expect(
        () => Debouncer(
          delay: const Duration(milliseconds: 100),
          maxWait: const Duration(milliseconds: 200),
          immediate: false,
          maxHistorySize: 5,
        ),
        returnsNormally,
      );
    });

    test('throws error for non-positive delay', () {
      expect(() => Debouncer(delay: Duration.zero), throwsArgumentError);
    });

    test('throws error when maxWait is not greater than delay', () {
      expect(
        () => Debouncer(
          delay: const Duration(seconds: 2),
          maxWait: const Duration(seconds: 1),
        ),
        throwsArgumentError,
      );
    });

    test('throws error for negative history size', () {
      expect(
        () => Debouncer(
            delay: const Duration(milliseconds: 100), maxHistorySize: -1),
        throwsArgumentError,
      );
    });
  });

  group('Basic Debouncing Behavior', () {
    late Debouncer debouncer;

    setUp(() {
      debouncer = Debouncer(delay: const Duration(milliseconds: 100));
    });

    tearDown(() {
      debouncer.dispose();
    });

    test('executes action after delay (trailing edge)', () async {
      var count = 0;
      debouncer.run(() => count++);
      expect(count, equals(0),
          reason: 'Action should not execute immediately in trailing mode.');
      await 150.millisecondsDelay();
      expect(count, equals(1),
          reason: 'Action should execute after the debounce delay.');
    });

    test('multiple rapid calls execute only once', () async {
      var count = 0;
      for (var i = 0; i < 5; i++) {
        debouncer.run(() => count++);
        await 20.millisecondsDelay();
      }
      expect(count, equals(0),
          reason: 'Action should not execute until the delay expires.');
      await 150.millisecondsDelay();
      expect(count, equals(1),
          reason: 'Only one execution should occur for rapid calls.');
    });

    test('supports asynchronous actions', () async {
      var count = 0;
      final completer = Completer<void>();
      debouncer.run(() async {
        await completer.future;
        count++;
      });
      expect(count, equals(0));
      completer.complete();
      await 150.millisecondsDelay();
      expect(count, equals(1));
    });
  });

  group('Immediate Execution Mode', () {
    late Debouncer immediateDebouncer;

    setUp(() {
      immediateDebouncer = Debouncer(
        delay: const Duration(milliseconds: 100),
        immediate: true,
      );
    });

    tearDown(() {
      immediateDebouncer.dispose();
    });

    test('executes first call immediately', () {
      var count = 0;
      immediateDebouncer.run(() => count++);
      expect(count, equals(1),
          reason: 'Immediate mode should execute the first action right away.');
    });

    test('subsequent calls in burst do not trigger extra immediate executions',
        () async {
      var count = 0;
      immediateDebouncer
        ..run(() => count++)
        // Immediately schedule more calls.

        ..run(() => count++)
        ..run(() => count++);
      expect(count, equals(1),
          reason:
              'Only the first call should execute immediately in immediate mode.');
      await 150.millisecondsDelay();
      expect(count, equals(1),
          reason: 'No additional execution should occur after delay.');
    });
  });

  group('MaxWait Functionality', () {
    late Debouncer maxWaitDebouncer;

    setUp(() {
      maxWaitDebouncer = Debouncer(
        delay: const Duration(milliseconds: 100),
        maxWait: const Duration(milliseconds: 300),
      );
    });

    tearDown(() {
      maxWaitDebouncer.dispose();
    });

    test('forces execution after maxWait even with continuous calls', () async {
      var count = 0;
      final completer = Completer<void>();

      // Schedule rapid calls every 50ms for a total duration of 350ms
      Timer.periodic(const Duration(milliseconds: 50), (t) {
        maxWaitDebouncer.run(() => count++);
        if (t.tick >= 7) {
          t.cancel();
          completer.complete();
        }
      });

      // Wait for the periodic timer to complete
      await completer.future;

      // Wait extra time to allow maxWait execution
      await 400.millisecondsDelay();

      expect(count, greaterThanOrEqualTo(1),
          reason: 'MaxWait should force at least one execution.');

      expect(count, lessThan(3),
          reason: 'Should not execute more than necessary when maxWait fires.');
    });

    test('handles asynchronous actions with maxWait', () async {
      var count = 0;
      final completer = Completer<void>();
      maxWaitDebouncer.run(() async {
        await completer.future;
        count++;
      });
      await 350.millisecondsDelay();
      completer.complete();
      await 100.millisecondsDelay();
      expect(count, equals(1));
    });
  });

  group('Error Handling', () {
    test('calls onError callback when action throws', () async {
      Object? capturedError;
      final errorDebouncer = Debouncer(
        delay: const Duration(milliseconds: 50),
        onError: (error, _) => capturedError = error,
      )..run(() => throw Exception('Test error'));
      await 100.millisecondsDelay();
      expect(capturedError, isNotNull);
      expect(capturedError.toString(), contains('Test error'));
      errorDebouncer.dispose();
    });

    test('flush rethrows error if no onError is provided', () async {
      final errorDebouncer = Debouncer(delay: const Duration(milliseconds: 50))
        ..run(() => throw Exception('Flush error'));
      await expectLater(errorDebouncer.flush(), throwsException);
      errorDebouncer.dispose();
    });
  });

  group('State and Lifecycle Management', () {
    late Debouncer debouncer;

    setUp(() {
      debouncer = Debouncer(
        delay: const Duration(milliseconds: 100),
        maxHistorySize: 5,
        debugLabel: 'TestDebouncer',
      );
    });

    tearDown(() {
      debouncer.dispose();
    });

    test('tracks execution count and history', () async {
      expect(debouncer.executionCount, equals(0));
      debouncer.run(() {});
      await 150.millisecondsDelay();
      expect(debouncer.executionCount, equals(1));
      if (debouncer.executionHistory.isNotEmpty) {
        expect(debouncer.executionHistory.first['success'], isTrue);
      }
    });

    test('cancel prevents pending execution', () async {
      var executed = false;
      debouncer
        ..run(() => executed = true)
        ..cancel();
      await 150.millisecondsDelay();
      expect(executed, isFalse);
    });

    test('dispose prevents further usage', () {
      debouncer.dispose();
      expect(() => debouncer.run(() {}), throwsStateError);
      expect(() => debouncer.flush(), throwsStateError);
      expect(() => debouncer.cancel(), throwsStateError);
    });

    test('runIfNotPending schedules only when no action is pending', () async {
      var count = 0;
      final first = debouncer.runIfNotPending(() => count++);
      expect(first, isTrue);
      final second = debouncer.runIfNotPending(() => count++);
      expect(second, isFalse);
      await 150.millisecondsDelay();
      expect(count, equals(1));
    });

    test('stateStream emits updates', () async {
      final states = <DebouncerState>[];
      final subscription = debouncer.stateStream.listen(states.add);
      debouncer.run(() {});
      await 150.millisecondsDelay();
      await subscription.cancel();
      expect(states.isNotEmpty, isTrue);
      expect(states.last.executionCount, equals(1));
    });
  });

  group('Advanced and Edge Cases', () {
    test('handles extremely short delays', () async {
      final shortDebouncer = Debouncer(delay: const Duration(milliseconds: 1));
      var executed = false;
      shortDebouncer.run(() => executed = true);
      await 5.millisecondsDelay();
      expect(executed, isTrue);
      shortDebouncer.dispose();
    });

    test('concurrent flush and scheduled execution', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 50));
      var count = 0;
      debouncer.run(() => count++);
      await debouncer.flush();
      expect(count, equals(1),
          reason: 'Flush should execute the pending action immediately.');
      await 100.millisecondsDelay();
      expect(count, equals(1),
          reason: 'No additional execution should occur after flush.');
      debouncer.dispose();
    });

    test('stateStream completes after disposal', () async {
      final debouncer = Debouncer(
        delay: const Duration(milliseconds: 50),
        debugLabel: 'EdgeTest',
      );
      final states = <DebouncerState>[];
      var streamDone = false;
      final subscription = debouncer.stateStream.listen(
        states.add,
        onDone: () => streamDone = true,
      );
      debouncer.run(() {});
      await 10.millisecondsDelay();
      debouncer.dispose();
      await 10.millisecondsDelay();
      expect(streamDone, isTrue);
      await subscription.cancel();
    });

    // Memory usage test (platform-dependent)
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
      test('memory usage remains bounded', () async {
        final debouncer = Debouncer(
          delay: const Duration(milliseconds: 50),
          maxHistorySize: 1000,
        );
        final startMemory = ProcessInfo.currentRss;
        for (var i = 0; i < 10000; i++) {
          debouncer.run(() {});
          await 1.millisecondsDelay();
        }
        await 100.millisecondsDelay();
        final endMemory = ProcessInfo.currentRss;
        final memoryDiff = endMemory - startMemory;
        expect(memoryDiff, lessThan(10 * 1024 * 1024),
            reason: 'Memory increase should be bounded (less than 10MB).');
        debouncer.dispose();
      });
    }
  });
}
