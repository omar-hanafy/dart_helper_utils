import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Validation fixes', () {
    group('roundToNearestMultiple', () {
      test('throws ArgumentError when multiple is zero', () {
        expect(
          () => 10.roundToNearestMultiple(0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('works correctly with non-zero multiple', () {
        expect(10.roundToNearestMultiple(3), 9);
        expect(11.roundToNearestMultiple(3), 12);
        expect(12.roundToNearestMultiple(3), 12);
      });
    });

    group('roundUpToMultiple', () {
      test('throws ArgumentError when multiple is zero', () {
        expect(() => 10.roundUpToMultiple(0), throwsA(isA<ArgumentError>()));
      });

      test('works correctly with non-zero multiple', () {
        expect(10.roundUpToMultiple(3), 12);
        expect(9.roundUpToMultiple(3), 9);
        expect(11.roundUpToMultiple(3), 12);
      });
    });

    group('roundDownToMultiple', () {
      test('throws ArgumentError when multiple is zero', () {
        expect(() => 10.roundDownToMultiple(0), throwsA(isA<ArgumentError>()));
      });

      test('works correctly with non-zero multiple', () {
        expect(10.roundDownToMultiple(3), 9);
        expect(11.roundDownToMultiple(3), 9);
        expect(12.roundDownToMultiple(3), 12);
      });
    });

    group('scaleBetween', () {
      test('throws ArgumentError when min equals max', () {
        expect(() => 5.scaleBetween(10, 10), throwsA(isA<ArgumentError>()));
      });

      test('throws ArgumentError when min > max', () {
        expect(() => 5.scaleBetween(20, 10), throwsA(isA<ArgumentError>()));
      });

      test('works correctly with valid range', () {
        expect(15.scaleBetween(10, 20), 0.5);
        expect(10.scaleBetween(10, 20), 0);
        expect(20.scaleBetween(10, 20), 1);
        expect(5.scaleBetween(10, 20), -0.5);
        expect(25.scaleBetween(10, 20), 1.5);
      });
    });

    group('null safety', () {
      test('isValidUrl handles null safely', () {
        expect((null as String?).isValidUrl, false);
        expect(''.isValidUrl, false);
        expect('https://example.com'.isValidUrl, true);
      });

      test('clean getter works with null chaining', () {
        expect((null as String?).clean, null);
        expect('  Hello  \n  World  '.clean, 'HelloWorld');
      });
    });
  });
}
