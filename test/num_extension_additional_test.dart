import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('HTTP status helpers', () {
    test('status code checks', () {
      expect(200.isSuccessCode, isTrue);
      expect(404.isNotFoundError, isTrue);
      expect(429.isRateLimitError, isTrue);
      expect(500.isServerErrorCode, isTrue);
      expect(302.isTemporaryRedirect, isTrue);
    });

    test('status messages', () {
      expect(200.toHttpStatusMessage, 'OK');
      expect(200.0.toHttpStatusMessage, 'OK');
      expect(200.5.toHttpStatusMessage, 'Not Found');
      expect(404.toHttpStatusUserMessage, isNotEmpty);
      expect(404.toHttpStatusDevMessage, isNotEmpty);
      expect(999.toHttpStatusMessage, 'Not Found');
    });

    test('status retry delay', () {
      expect(429.statusCodeRetryDelay, const Duration(minutes: 1));
      expect(200.statusCodeRetryDelay, Duration.zero);
    });
  });

  group('Nullable num extensions', () {
    test('tryToInt and tryToDouble', () {
      num? value;
      expect(value.tryToInt(), isNull);
      expect(value.tryToDouble(), isNull);
      value = 2.5;
      expect(value.tryToInt(), 2);
      expect(value.tryToDouble(), 2.5);
    });

    test('percentage handles zero and decimals', () {
      num? value = 25;
      expect(value.percentage(200), 12.5);
      expect(value.percentage(0), 0);
    });

    test('bool and zero helpers', () {
      num? value;
      expect(value.isZeroOrNull, isTrue);
      value = -1;
      expect(value.isNegative, isTrue);
      value = 2;
      expect(value.isPositive, isTrue);
      expect(value.asBool, isTrue);
    });

    test('toDecimalString trims zeros', () {
      num? value = 12.10;
      expect(value.toDecimalString(2), '12.1');
      expect(value.toDecimalString(2, keepTrailingZeros: true), '12.10');
    });
  });

  group('Num extensions', () {
    test('basic helpers', () {
      expect(5.isPositive, isTrue);
      expect((-1).isNegative, isTrue);
      expect(0.isZero, isTrue);
      expect(123.numberOfDigits, 3);
      expect(12.3400.removeTrailingZero, '12.34');
    });

    test('rounding helpers', () {
      expect(151.roundToFiftyOrHundred, 200);
      expect(150.roundToFiftyOrHundred, 150);
      expect(21.roundToTenth, 30);
      expect(10.tenth, 1);
      expect(12.fourth, 3);
      expect(9.third, 3);
      expect(8.half, 4);
    });

    test('random with seed is deterministic', () {
      expect(10.random(1), 10.random(1));
      expect(10.getRandom, inInclusiveRange(0, 9));
    });

    test('random and getRandom throw for invalid upper bound', () {
      expect(() => 0.getRandom, throwsRangeError);
      expect(() => (-1).getRandom, throwsRangeError);
      expect(() => 0.random(), throwsRangeError);
      expect(() => 0.5.getRandom, throwsRangeError);
      expect(() => 0.99.getRandom, throwsRangeError);
    });

    test('asGreeks formats large numbers', () {
      expect(999.asGreeks(0), '999');
      expect(1500.asGreeks(0), '1.5K');
      expect(1500.asGreeks(0, 0), '1K');
    });

    test('toFileSize caps suffixes', () {
      expect(1024.toFileSize(), '1.00 KB');
      expect(0.toFileSize(), '0 B');
    });

    test('duration conversions', () {
      expect(1.asMilliseconds, const Duration(milliseconds: 1));
      expect(1.asSeconds, const Duration(seconds: 1));
      expect(1.asMinutes, const Duration(minutes: 1));
    });

    test('sqrt and until', () {
      expect(16.sqrt(), 4);
      expect((-1).sqrt(), 0);
      expect(1.until(5).toList(), [1, 2, 3, 4]);
      expect(5.until(1, step: -2).toList(), [5, 3]);
      expect(() => 1.until(5, step: 0).toList(), throwsA(isA<RException>()));
    });

    test('safeDivide and multiples', () {
      expect(10.safeDivide(2), 5);
      expect(10.safeDivide(0, whenDivByZero: -1), -1);
      expect(10.roundToNearestMultiple(4), 12);
      expect(10.roundUpToMultiple(4), 12);
      expect(10.roundDownToMultiple(4), 8);
    });

    test('comparison helpers', () {
      expect(5.isBetween(1, 5), isTrue);
      expect(5.isBetween(1, 5, inclusive: false), isFalse);
      expect(0.25.toPercent(fractionDigits: 0), '25%');
      expect(10.isApproximatelyEqual(10.005), isTrue);
      expect(10.isCloseTo(10.05, delta: 0.1), isTrue);
    });

    test('scale and fraction helpers', () {
      expect(5.scaleBetween(0, 10), 0.5);
      expect(() => 5.scaleBetween(1, 1), throwsArgumentError);
      expect(1.5.toFractionString(), '1 1/2');
      expect(2.isInteger, isTrue);
      expect(2.5.isInteger, isFalse);
    });
  });

  group('Int extensions', () {
    test('range and arithmetic', () {
      expect(5.inRangeOf(1, 10), 5);
      expect(0.inRangeOf(1, 10), 1);
      expect(11.inRangeOf(1, 10), 10);
      expect(3.absolute, 3);
      expect(3.doubled, 6);
      expect(3.tripled, 9);
      expect(3.quadrupled, 12);
      expect(4.squared, 16);
    });

    test('factorial, gcd, lcm', () {
      expect(5.factorial(), 120);
      expect(() => (-1).factorial(), throwsArgumentError);
      expect(12.gcd(8), 4);
      expect(4.lcm(6), 12);
    });

    test('prime and factors', () {
      expect(7.isPrime(), isTrue);
      expect(1.isPrime(), isFalse);
      expect(12.primeFactors(), [2, 2, 3]);
    });

    test('number property checks', () {
      expect(16.isPerfectSquare(), isTrue);
      expect(27.isPerfectCube(), isTrue);
      expect(21.isFibonacci(), isTrue);
      expect(8.isPowerOf(2), isTrue);
    });

    test('conversion helpers', () {
      expect(10.toBinaryString(), '1010');
      expect(255.toHexString(), 'FF');
      expect(7.bitCount(), 3);
      expect(10.isDivisibleBy(5), isTrue);
    });
  });

  group('Double extensions', () {
    test('range and arithmetic', () {
      expect(5.5.inRangeOf(1, 10), 5.5);
      expect(0.5.inRangeOf(1, 10), 1);
      expect(12.0.inRangeOf(1, 10), 10);
      expect(3.5.absolute, 3.5);
      expect(3.5.doubled, 7.0);
      expect(3.5.tripled, 10.5);
      expect(3.5.quadrupled, 14.0);
      expect(3.0.squared, 9.0);
    });

    test('rounding and fraction', () {
      expect(10.5.roundToNearestMultiple(4), 12);
      expect(10.1.roundUpToMultiple(4), 12);
      expect(10.9.roundDownToMultiple(4), 8);
      expect(() => 10.5.roundToNearestMultiple(0), throwsArgumentError);
      expect(() => 10.5.roundUpToMultiple(0), throwsArgumentError);
      expect(() => 10.5.roundDownToMultiple(0), throwsArgumentError);
      expect(2.5.toFractionString(), '2 1/2');
    });
  });

  group('randomInRange', () {
    test('returns value within bounds', () {
      final value = randomInRange(1, 3, 1);
      expect(value, inInclusiveRange(1, 3));
    });

    test('throws when min > max', () {
      expect(() => randomInRange(5, 1), throwsArgumentError);
    });
  });
}
