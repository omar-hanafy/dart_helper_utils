import 'dart:async';
import 'dart:math';

import 'package:dart_helper_utils/src/exceptions/exceptions.dart';
import 'package:dart_helper_utils/src/src.dart';

extension DHUHttpEx on num? {
  bool get isSuccessCode => this == 200 || this == 201;

  bool get isClientErrorCode => this != null && this! >= 400 && this! < 500;

  bool get isServerErrorCode => this != null && this! >= 500 && this! < 600;

  bool get isRedirectionCode => this != null && this! >= 300 && this! < 400;

  bool get isValidPhoneNumber => toString().isValidPhoneNumber;

  String get toHttpStatusMessage => httpStatusMessages[this] ?? 'Not Found';
}

extension DHUNullSafeNumExtensions on num? {
  int? get tryToInt => this?.toInt();

  double? get tryToDouble => this?.toDouble();

  num percentage(num total, {bool allowDecimals = true}) {
    if (this != null) {
      final result = this! >= total ? 100 : max((this! / total) * 100, 0);
      if (allowDecimals) {
        return double.parse(result.toStringAsFixed(2));
      } else {
        return result.toInt();
      }
    }
    return 0;
  }

  bool get isNegative => isNotNull && this! > 0;

  bool get isPositive => isNotNull && this! > 0;

  bool get isZeroOrNull => isNull || this! == 0;

  /// Returns `true` if this integer is greater than *0*.
  bool get asBool => (this ?? 0) > 0;

  /// Returns a string representation of the number with a given number of
  /// decimal places.
  ///
  /// If [keepTrailingZeros] is `true`, trailing zeros will be kept in the
  /// result, otherwise, they will be removed along with any unnecessary
  /// decimal points.
  String toDecimalString(int decimalPlaces, {bool keepTrailingZeros = false}) {
    var formatted = this?.toStringAsFixed(decimalPlaces) ?? '';

    // If the user doesn't want to keep trailing zeros
    if (!keepTrailingZeros) {
      formatted = formatted
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }

    return formatted;
  }
}

extension DHUNumExtensions on num {
  /// Returns if the number is positive
  bool get isPositive => this > 0;

  /// Returns if the number is negative
  bool get isNegative => this < 0;

  /// Returns if the number is zer0
  bool get isZero => this == 0;

  bool get isValidPhoneNumber => toString().isValidPhoneNumber;

  /// Returns number of digits in this number
  int get numberOfDigits => toString().length;

  String get removeTrailingZero =>
      toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');

  double get roundToFiftyOrHundred =>
      this + (50 - ((this % 50) > 0 ? this % 50 : 50));

  double get roundToTenth => (this / 10).ceil() * 10;

  /// Returns tenth of the number
  double get tenth => this / 10;

  /// Returns fourth of the number
  double get fourth => this / 4;

  /// Returns third of the number
  double get third => this / 3;

  /// Returns half of the number
  double get half => this / 2;

  int get getRandom => Random().nextInt(this.toInt());

  int random([int? seed]) => Random(seed).nextInt(this.toInt());

  /// Converts a number to a format that includes Greek symbols for thousands, millions, and beyond.
  ///
  /// Example usage:
  ///   print(1000.asGreeks); // Output: 1.0K
  ///   print(1500000.asGreeks); // Output: 1.5M
  ///   print(2500000000.asGreeks); // Output: 2.5B
  ///
  /// Here is a list of all symbols along with their corresponding names and values.
  /// k: Kilo, 10^3
  /// M: Mega, 10^6
  /// G: Giga, 10^9
  /// T: Tera, 10^12
  /// P: Peta, 10^15
  /// E: Exa, 10^18
  /// Z: Zetta, 10^21
  /// Y: Yotta, 10^24
  String asGreeks([int zerosFractionDigits = 0, int fractionDigits = 1]) {
    if (this < 1000) {
      return zerosFractionDigits <= 0
          ? this.toInt().toString()
          : toStringAsFixed(zerosFractionDigits);
    }

    var magnitude = 0;
    var reducedNum = this;
    while (reducedNum >= 1000 && magnitude < greekNumberSuffixes.length) {
      reducedNum /= 1000;
      magnitude++;
    }

    final symbol = magnitude > 0 ? greekNumberSuffixes[magnitude - 1] : '';

    return fractionDigits <= 0
        ? '${reducedNum.toInt()}$symbol'
        : '${reducedNum.toStringAsFixed(fractionDigits)}$symbol';
  }

  /// Utility to delay some callback (or code execution).
// TODO(Omar): Add a separated implementation of delay() with the ability to stop it.
  ///
  /// Sample:
  /// ```dart
  /// void main() async {
  ///   print('+ wait for 2 seconds');
  ///   await 2.delay();
  ///   print('- 2 seconds completed');
  ///   print('+ callback in 1.2sec');
  ///   1.delay(() => print('- 1.2sec callback called'));
  ///   print('currently running callback 1.2sec');
  /// }
  ///```
  Future<void> delay([FutureOr<dynamic> Function()? callback]) async =>
      Future.delayed(
        Duration(milliseconds: (this * 1000).round()),
        callback,
      );

  Future<void> get daysDelay => Future.delayed(asDays);

  Future<void> get hoursDelay => Future.delayed(asHours);

  Future<void> get minDelay => Future.delayed(asMinutes);

  Future<void> get secDelay => Future.delayed(asSeconds);

  Future<void> get millisecondsDelay => Future.delayed(asMilliseconds);

  /// Easy way to make Durations from numbers.
  ///
  /// Sample:
  /// ```dart
  /// print(1.seconds + 200.asMilliseconds);
  /// print(1.hours + 30.asMinutes);
  /// print(1.5.asHours);
  ///```
  Duration get asMilliseconds => Duration(microseconds: (this * 1000).round());

  Duration get asSeconds => Duration(milliseconds: (this * 1000).round());

  Duration get asMinutes =>
      Duration(seconds: (this * Duration.secondsPerMinute).round());

  Duration get asHours =>
      Duration(minutes: (this * Duration.minutesPerHour).round());

  Duration get asDays => Duration(hours: (this * Duration.hoursPerDay).round());

  /// Returns a sequence of integer, starting from [this],
  /// increments by [step] and ends at [end]
  Iterable<num> until(int end, {int step = 1}) sync* {
    if (step == 0) {
// ignore: only_throw_errors
      throw RException.steps();
    }

    var currentNumber = this;

    if (step > 0) {
      while (currentNumber < end) {
        yield currentNumber;
        currentNumber += step;
      }
    } else {
      while (currentNumber > end) {
        yield currentNumber;
        currentNumber += step;
      }
    }
  }

  /// Safely divides two numbers with custom handling for division by zero and zero values.
  ///
  /// - Returns [whenBothZero] if both `this` and `b` are zero.
  /// - Returns [whenDivByZero] if dividing by zero unless [returnNaNOnDivByZero] is `true`.
  /// - Otherwise, returns `this / b`.
  double safeDivide(
    num b, {
    num whenBothZero = 0,
    num whenDivByZero = double.infinity,
    bool returnNaNOnDivByZero = false,
  }) =>
      NumbersHelper.safeDivide(
        this,
        b,
        whenDivByZero: whenDivByZero,
        whenBothZero: whenBothZero,
        returnNaNOnDivByZero: returnNaNOnDivByZero,
      );

  /// Rounds this number to the nearest multiple of [multiple].
  num roundToNearestMultiple(num multiple) =>
      (this / multiple).round() * multiple;

  /// Rounds this number up to the nearest multiple of [multiple].
  num roundUpToMultiple(num multiple) => (this / multiple).ceil() * multiple;

  /// Rounds this number down to the nearest multiple of [multiple].
  num roundDownToMultiple(num multiple) => (this / multiple).floor() * multiple;

  /// Checks if this number is between [min] and [max].
  /// [inclusive] determines whether the range includes the endpoints.
  bool isBetween(num min, num max, {bool inclusive = true}) {
    return inclusive
        ? (this >= min && this <= max)
        : (this > min && this < max);
  }

  /// Converts this number to a percentage string with [fractionDigits] decimal places.
  String toPercent({int fractionDigits = 2}) {
    return '${(this * 100).toStringAsFixed(fractionDigits)}%';
  }

  /// Checks if this number is approximately equal to [other] within a [tolerance].
  bool isApproximatelyEqual(num other, {double tolerance = 0.01}) {
    return (this - other).abs() <= tolerance;
  }

  /// Checks if this number is close to [other] within a [delta].
  bool isCloseTo(num other, {num delta = 0.1}) {
    return (this - other).abs() < delta;
  }

  /// Normalizes this number to a range between [min] and [max].
  num scaleBetween(num min, num max) {
    if (min == max) throw ArgumentError('Min and max cannot be the same.');
    return (this - min) / (max - min);
  }

  /// Converts this number to a fraction string representation.
  String toFractionString() {
    final intPart = truncate();
    final fraction = this - intPart;
    if (fraction == 0) return intPart.toString();
    final gcd = NumbersHelper.gcd((fraction * 1000000).round(), 1000000);
    return '${intPart != 0 ? '$intPart ' : ''}${(fraction * 1000000 / gcd).round()}/${1000000 ~/ gcd}';
  }

  /// Checks if this number is an integer.
  bool get isInteger => this % 1 == 0;

  /// Converts the number to its ordinal representation as either a number with a suffix
  /// (e.g., "1st") or as a word (e.g., "first").
  String toOrdinal({bool asWord = false, bool includeAnd = false}) {
    final number = this.toInt();

    // Return 'zeroth' or '0th' based on asWord
    if (number == 0) return asWord ? 'zeroth' : '0th';

    // Handling negative numbers
    if (number < 0) throw ArgumentError('Negative numbers are not supported');

    return asWord
        ? _dynamicOrdinalWord(number, includeAnd: includeAnd)
        : _asOrdinalSuffixWithNumber();
  }

  /// Generates ordinal words dynamically, including handling hundreds, thousands, and special cases.
  String _dynamicOrdinalWord(int number, {bool includeAnd = false}) {
    final baseOrdinals = {
      1: 'first',
      2: 'second',
      3: 'third',
      4: 'fourth',
      5: 'fifth', // Spelling change
      6: 'sixth',
      7: 'seventh',
      8: 'eighth', // Spelling change
      9: 'ninth', // Spelling change
      10: 'tenth',
      11: 'eleventh',
      12: 'twelfth', // Spelling change
      13: 'thirteenth',
      14: 'fourteenth',
      15: 'fifteenth',
      16: 'sixteenth',
      17: 'seventeenth',
      18: 'eighteenth',
      19: 'nineteenth',
    };

    final tensWords = {
      20: 'twenty',
      30: 'thirty',
      40: 'forty',
      50: 'fifty',
      60: 'sixty',
      70: 'seventy',
      80: 'eighty',
      90: 'ninety',
    };

    final tensOrdinals = {
      20: 'twentieth',
      30: 'thirtieth',
      40: 'fortieth',
      50: 'fiftieth',
      60: 'sixtieth',
      70: 'seventieth',
      80: 'eightieth',
      90: 'ninetieth',
    };

    // Handle numbers less than 20 using base ordinals.
    if (baseOrdinals.containsKey(number)) {
      return baseOrdinals[number]!;
    }

    // Handle exact tens like 20, 30, 40, etc.
    if (tensOrdinals.containsKey(number)) {
      return tensOrdinals[number]!;
    }

    // Handle numbers between 21 and 99
    if (number < 100) {
      final tensDigit = (number ~/ 10) * 10;
      final unitsDigit = number % 10;
      return '${tensWords[tensDigit]}-${baseOrdinals[unitsDigit]}';
    }

    // Handle hundreds (100-999)
    if (number < 1000) {
      return _constructHundreds(number, includeAnd: includeAnd);
    }

    // Handle thousands and larger
    return _constructLargeNumbers(number, includeAnd: includeAnd);
  }

  /// Constructs the words for numbers in the hundreds range.
  String _constructHundreds(int number, {bool includeAnd = false}) {
    final hundredsDigit = number ~/ 100;
    final remainder = number % 100;
    final hundredPart = '${_dynamicCardinalWord(hundredsDigit)} hundred';
    if (remainder == 0) return '${hundredPart}th';
    final connector = includeAnd ? ' and ' : ' ';
    return '$hundredPart$connector${_dynamicOrdinalWord(remainder, includeAnd: includeAnd)}';
  }

  /// Constructs the words for numbers in the thousands range and above.
  String _constructLargeNumbers(int number, {bool includeAnd = false}) {
    final units = [
      '',
      ' thousand',
      ' million',
      ' billion',
      ' trillion',
      ' quadrillion',
      ' quintillion',
      // Add more if needed
    ];
    var num = number;

    // Split the number into chunks of three digits
    final parts = <int>[];
    while (num > 0) {
      parts.add(num % 1000);
      num ~/= 1000;
    }

    // Construct the word representation
    final words = <String>[];
    var appliedTh = false;
    for (var i = parts.length - 1; i >= 0; i--) {
      if (parts[i] == 0) continue;
      String partWord;
      if (i > 0) {
        partWord = '${_dynamicCardinalWord(parts[i])}${units[i]}';
        if (!appliedTh && parts.sublist(0, i).every((p) => p == 0)) {
          // Apply 'th' to the last non-zero group
          partWord += 'th';
          appliedTh = true;
        }
      } else {
        // Apply ordinal to the last non-zero group
        if (!appliedTh) {
          partWord = _dynamicOrdinalWord(parts[i], includeAnd: includeAnd);
          appliedTh = true;
        } else {
          partWord = _dynamicCardinalWord(parts[i]);
        }
      }
      words.add(partWord);
    }

    // Include 'and' appropriately
    if (includeAnd && words.length > 1 && parts[0] < 100) {
      // Insert 'and' before the last element
      words.insert(words.length - 1, 'and');
    }

    return words.join(' ').trim();
  }

  /// Generates cardinal words dynamically.
  String _dynamicCardinalWord(int number) {
    final baseCardinals = {
      1: 'one',
      2: 'two',
      3: 'three',
      4: 'four',
      5: 'five',
      6: 'six',
      7: 'seven',
      8: 'eight',
      9: 'nine',
      10: 'ten',
      11: 'eleven',
      12: 'twelve',
      13: 'thirteen',
      14: 'fourteen',
      15: 'fifteen',
      16: 'sixteen',
      17: 'seventeen',
      18: 'eighteen',
      19: 'nineteen',
    };

    final tensWords = {
      20: 'twenty',
      30: 'thirty',
      40: 'forty',
      50: 'fifty',
      60: 'sixty',
      70: 'seventy',
      80: 'eighty',
      90: 'ninety',
    };

    if (baseCardinals.containsKey(number)) return baseCardinals[number]!;
    if (tensWords.containsKey(number)) return tensWords[number]!;

    if (number < 100) {
      final tensDigit = (number ~/ 10) * 10;
      final unitsDigit = number % 10;
      return '${tensWords[tensDigit]}-${baseCardinals[unitsDigit]}';
    }

    if (number < 1000) {
      final hundredsDigit = number ~/ 100;
      final remainder = number % 100;
      final hundredPart = '${baseCardinals[hundredsDigit]} hundred';
      if (remainder == 0) return hundredPart;
      return '$hundredPart ${_dynamicCardinalWord(remainder)}';
    }

    // Handle thousands and larger numbers recursively
    return _constructLargeNumbers(number);
  }

  /// Converts the number to its ordinal suffix representation.
  String _asOrdinalSuffixWithNumber() {
    final number = this.toInt();
    // Special case for 11th, 12th, and 13th
    if (number % 100 >= 11 && number % 100 <= 13) return '${number}th';

    return switch (number % 10) {
      1 => '${number}st', // 1st, 21st, etc.
      2 => '${number}nd', // 2nd, 22nd, etc.
      3 => '${number}rd', // 3rd, 23rd, etc.
      _ => '${number}th', // All other cases
    };
  }
}

extension DHUIntExtensions on int {
  /// Return the min if this number is smaller then minimum
  /// Return the max if this number is bigger the the maximum
  /// Return this number if it's between the range
  int inRangeOf(int min, int max) {
    if (min.isNull || max.isNull) throw Exception('min or max cannot be null');
    if (min > max) throw ArgumentError('min must be smaller the max');

    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Returns the absolute value
  int get absolute => abs();

  /// Return this number time two
  int get doubled => this * 2;

  /// Return this number time three
  int get tripled => this * 3;

  /// Return this number time four
  int get quadrupled => this * 4;

  /// Return squared number
  int get squared => this * this;

  /// Returns the factorial of this integer.
  int factorial() {
    if (this < 0) throw ArgumentError('Negative numbers are not allowed.');
    var result = 1;
    for (var i = 2; i <= this; i++) {
      result *= i;
    }
    return result;
  }

  /// Returns the greatest common divisor of this integer and [other].
  int gcd(int other) => NumbersHelper.gcd(this, other);

  /// Returns the least common multiple of this integer and [other].
  int lcm(int other) => (this * other).abs() ~/ gcd(other);

  /// Checks if this integer is a prime number.
  bool isPrime() {
    if (this <= 1) return false;
    for (var i = 2; i <= sqrt(this).toInt(); i++) {
      if (this % i == 0) return false;
    }
    return true;
  }

  /// Returns the prime factors of this integer.
  List<int> primeFactors() {
    var n = this;
    final factors = <int>[];
    for (var i = 2; i <= sqrt(n).toInt(); i++) {
      while (n % i == 0) {
        factors.add(i);
        n ~/= i;
      }
    }
    if (n > 1) factors.add(n);
    return factors;
  }

  /// Converts this integer to a Roman numeral.
  String toRomanNumeral() {
    if (this <= 0 || this >= 4000) {
      throw ArgumentError('Value must be between 1 and 3999');
    }
    final numerals = {
      1000: 'M',
      900: 'CM',
      500: 'D',
      400: 'CD',
      100: 'C',
      90: 'XC',
      50: 'L',
      40: 'XL',
      10: 'X',
      9: 'IX',
      5: 'V',
      4: 'IV',
      1: 'I'
    };
    var num = this;
    final result = StringBuffer();
    numerals.forEach((value, numeral) {
      while (num >= value) {
        result.write(numeral);
        num -= value;
      }
    });
    return result.toString();
  }

  /// Checks if this integer is a perfect square.
  bool isPerfectSquare() {
    if (this < 0) return false;
    final root = sqrt(this).toInt();
    return root * root == this;
  }

  /// Checks if this integer is a perfect cube.
  bool isPerfectCube() {
    final n = abs();
    var cubeRoot = 0;
    while (cubeRoot * cubeRoot * cubeRoot < n) {
      cubeRoot++;
    }
    return cubeRoot * cubeRoot * cubeRoot == n;
  }

  /// Checks if this integer is a Fibonacci number.
  bool isFibonacci() {
    final n1 = 5 * this * this + 4;
    final n2 = 5 * this * this - 4;
    return NumbersHelper.isPerfectSquare(n1) ||
        NumbersHelper.isPerfectSquare(n2);
  }

  /// Checks if this integer is a power of [base].
  bool isPowerOf(int base) {
    if (base <= 1) return this == base;
    var n = this;
    while (n % base == 0) {
      n ~/= base;
    }
    return n == 1;
  }

  /// Converts this integer to a binary string.
  String toBinaryString() => toRadixString(2);

  /// Converts this integer to a hexadecimal string.
  String toHexString() => toRadixString(16).toUpperCase();

  /// Returns the number of set bits in this integer's binary representation.
  int bitCount() => toBinaryString().replaceAll('0', '').length;

  /// Checks if this integer is divisible by [divisor].
  bool isDivisibleBy(int divisor) => this % divisor == 0;
}

extension DHUDoubleExtensions on double {
  /// Return the min if this number is smaller then minimum
  /// Return the max if this number is bigger the the maximum
  /// Return this number if it's between the range
  double inRangeOf(double min, double max) {
    if (min.isNull || max.isNull) throw Exception('min or max cannot be null');
    if (min > max) throw ArgumentError('min must be smaller the max');

    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Returns the absolute value
  double get absolute => abs();

  /// Return this number time two
  double get doubled => this * 2;

  /// Return this number time three
  double get tripled => this * 3;

  /// Return this number time four
  double get quadrupled => this * 4;

  /// Return squared number
  double get squared => this * this;

  /// Rounds this double to the nearest multiple of [multiple].
  double roundToNearestMultiple(double multiple) =>
      (this / multiple).round() * multiple;

  /// Rounds this double up to the nearest multiple of [multiple].
  double roundUpToMultiple(double multiple) =>
      (this / multiple).ceil() * multiple;

  /// Rounds this double down to the nearest multiple of [multiple].
  double roundDownToMultiple(double multiple) =>
      (this / multiple).floor() * multiple;

  /// Converts this double to a fraction string representation.
  String toFractionString() {
    final intPart = truncate();
    final fraction = this - intPart;
    if (fraction == 0) return intPart.toString();
    final gcd = NumbersHelper.gcd((fraction * 1000000).round(), 1000000);
    return '${intPart != 0 ? '$intPart ' : ''}${(fraction * 1000000 / gcd).round()}/${1000000 ~/ gcd}';
  }
}

/// A utility class for numerical helper methods.
abstract class NumbersHelper {
  /// Safely divides two numbers with custom handling for division by zero and zero values.
  ///
  /// - Returns [whenBothZero] if both `a` and `b` are zero.
  /// - Returns [whenDivByZero] if dividing by zero unless [returnNaNOnDivByZero] is `true`.
  /// - Otherwise, returns `a / b`.
  ///
  /// [a] is the numerator, [b] is the denominator.
  /// [whenBothZero] specifies the return value when both are zero (default: 0).
  /// [whenDivByZero] specifies the return value when dividing by zero (default: infinity).
  /// [returnNaNOnDivByZero] sets whether to return NaN on division by zero (default: false).
  ///
  /// Example:
  /// ```dart
  /// print(NumHelpers.safeDivide(0, 0)); // Output: 0
  /// print(NumHelpers.safeDivide(10, 0)); // Output: Infinity
  /// print(NumHelpers.safeDivide(10, 0, whenDivByZero: -1)); // Output: -1
  /// print(NumHelpers.safeDivide(10, 0, returnNaNOnDivByZero: true)); // Output: NaN
  /// print(NumHelpers.safeDivide(10, 2)); // Output: 5
  /// ```
  static double safeDivide(
    num a,
    num b, {
    num whenBothZero = 0,
    num whenDivByZero = double.infinity,
    bool returnNaNOnDivByZero = false,
  }) {
    if (a == 0 && b == 0) return whenBothZero.toDouble();
    if (b == 0) {
      return (returnNaNOnDivByZero ? double.nan : whenDivByZero).toDouble();
    }
    return a / b;
  }

  /// Calculates the mean of a list of [values].
  static num mean(List<num> values) {
    if (values.isEmpty) throw ArgumentError('The list cannot be empty.');
    return values.reduce((a, b) => a + b) / values.length;
  }

  /// Calculates the median of a list of [values].
  static num median(List<num> values) {
    if (values.isEmpty) throw ArgumentError('The list cannot be empty.');
    final sortedValues = List<num>.from(values)..sort();
    final middle = sortedValues.length ~/ 2;
    if (sortedValues.length.isEven) {
      return (sortedValues[middle - 1] + sortedValues[middle]) / 2;
    } else {
      return sortedValues[middle];
    }
  }

  /// Finds the mode(s) of a list of [values].
  static List<num> mode(List<num> values) {
    if (values.isEmpty) throw ArgumentError('The list cannot be empty.');
    final frequencyMap = <num, int>{};
    for (final value in values) {
      frequencyMap[value] = (frequencyMap[value] ?? 0) + 1;
    }
    final maxFrequency = frequencyMap.values.reduce(max);
    return frequencyMap.entries
        .where((entry) => entry.value == maxFrequency)
        .map((entry) => entry.key)
        .toList();
  }

  /// Calculates the variance of a list of [values].
  static num variance(List<num> values) {
    if (values.isEmpty) throw ArgumentError('The list cannot be empty.');
    final m = mean(values);
    return mean(values.map((value) => pow(value - m, 2)).toList());
  }

  /// Calculates the standard deviation of a list of [values].
  static num standardDeviation(List<num> values) => sqrt(variance(values));

  /// Calculates the specified [percentile] of a list of [values].
  static num percentile(List<num> values, double percentile) {
    if (values.isEmpty) throw ArgumentError('The list cannot be empty.');
    final sortedValues = List<num>.from(values)..sort();
    final index = (percentile * (values.length - 1)).round();
    return sortedValues[index];
  }

  /// Calculates the greatest common divisor (GCD) of two integers [a] and [b].
  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  /// Checks if a number [n] is a perfect square.
  static bool isPerfectSquare(int n) {
    final sqrtN = sqrt(n).toInt();
    return sqrtN * sqrtN == n;
  }

  /// Converts a Roman numeral string [romanNumeral] to an integer.
  static int fromRomanNumeral(String romanNumeral) {
    final romanMap = romanNumerals.swapKeysWithValues();
    var i = 0;
    var result = 0;
    while (i < romanNumeral.length) {
      if (i + 1 < romanNumeral.length &&
          romanMap.containsKey(romanNumeral.substring(i, i + 2))) {
        result += romanMap[romanNumeral.substring(i, i + 2)]!;
        i += 2;
      } else {
        result += romanMap[romanNumeral[i]]!;
        i += 1;
      }
    }
    return result;
  }
}

/// Extension on [Iterable<num>] providing statistical operations.
///
/// This extension adds properties to calculate the mean, median, mode,
/// variance, standard deviation, and percentiles of a numeric iterable.
extension DHUListNumStats on Iterable<num> {
  /// Calculates the mean (average) of the numbers in the iterable.
  num get mean => NumbersHelper.mean(this.toList());

  /// Determines the median value of the numbers in the iterable.
  num get median => NumbersHelper.median(this.toList());

  /// Finds the mode(s) of the numbers in the iterable.
  ///
  /// Returns a list of numbers that appear most frequently.
  List<num> get mode => NumbersHelper.mode(this.toList());

  /// Computes the variance of the numbers in the iterable.
  num get variance => NumbersHelper.variance(this.toList());

  /// Calculates the standard deviation of the numbers in the iterable.
  num get standardDeviation => NumbersHelper.standardDeviation(this.toList());

  /// Computes the specified [percentile] of the numbers in the iterable.
  ///
  /// The [percentile] should be a value between 0 and 100.
  num percentile(double percentile) => NumbersHelper.percentile(
        this.toList(),
        percentile,
      );
}

/// Extension on [Iterable<int>] providing statistical operations.
///
/// This extension adds properties to calculate the mean, median, mode,
/// variance, standard deviation, and percentiles of an integer iterable.
extension DHUListIntStats on Iterable<int> {
  /// Calculates the mean (average) of the integers in the iterable.
  int get mean => NumbersHelper.mean(this.toList()).toInt();

  /// Determines the median value of the integers in the iterable.
  int get median => NumbersHelper.median(this.toList()).toInt();

  /// Finds the mode(s) of the integers in the iterable.
  ///
  /// Returns a list of integers that appear most frequently.
  List<int> get mode => NumbersHelper.mode(this.toList()).convertTo<int>();

  /// Computes the variance of the integers in the iterable.
  int get variance => NumbersHelper.variance(this.toList()).toInt();

  /// Calculates the standard deviation of the integers in the iterable.
  int get standardDeviation =>
      NumbersHelper.standardDeviation(this.toList()).toInt();

  /// Computes the specified [percentile] of the integers in the iterable.
  ///
  /// The [percentile] should be a value between 0 and 100.
  int percentile(double percentile) => NumbersHelper.percentile(
        this.toList(),
        percentile,
      ).toInt();
}

/// Extension on [Iterable<double>] providing statistical operations.
///
/// This extension adds properties to calculate the mean, median, mode,
/// variance, standard deviation, and percentiles of a double iterable.
extension DHUListDoubleStats on Iterable<double> {
  /// Calculates the mean (average) of the doubles in the iterable.
  double get mean => NumbersHelper.mean(this.toList()).toDouble();

  /// Determines the median value of the doubles in the iterable.
  double get median => NumbersHelper.median(this.toList()).toDouble();

  /// Finds the mode(s) of the doubles in the iterable.
  ///
  /// Returns a list of doubles that appear most frequently.
  List<double> get mode =>
      NumbersHelper.mode(this.toList()).convertTo<double>();

  /// Computes the variance of the doubles in the iterable.
  double get variance => NumbersHelper.variance(this.toList()).toDouble();

  /// Calculates the standard deviation of the doubles in the iterable.
  double get standardDeviation =>
      NumbersHelper.standardDeviation(this.toList()).toDouble();

  /// Computes the specified [percentile] of the doubles in the iterable.
  ///
  /// The [percentile] should be a value between 0 and 100.
  double percentile(double percentile) => NumbersHelper.percentile(
        this.toList(),
        percentile,
      ).toDouble();
}

/// Extension on nullable [Iterable<num?>] providing a total sum calculation.
///
/// This extension adds a [total] getter that computes the sum of all non-null
/// numeric values in the iterable. If the iterable is `null` or empty, it
/// returns `0`. Null elements within the iterable are treated as `0` in the
/// sum.
extension DHUIterableNumExtensionsNS on Iterable<num?>? {
  /// Calculates the total sum of the numbers in the iterable.
  ///
  /// - Returns `0` if the iterable is `null` or empty.
  /// - Null elements within the iterable are treated as `0`.
  ///
  /// Example:
  /// ```dart
  /// Iterable<num?>? numbers = [1, 2, null, 4];
  /// num sum = numbers.total; // sum is 7
  /// ```
  num get total {
    if (isEmptyOrNull) return 0;
    num sum = 0;
    for (final current in this!) {
      sum += current ?? 0;
    }
    return sum;
  }
}

/// Extension on nullable [Iterable<int?>] providing a total sum calculation.
///
/// This extension adds a [total] getter that computes the sum of all non-null
/// integer values in the iterable. If the iterable is `null` or empty, it
/// returns `0`. Null elements within the iterable are treated as `0` in the
/// sum.
extension DHUIterableIntExtensionsNS on Iterable<int?>? {
  /// Calculates the total sum of the integers in the iterable.
  ///
  /// - Returns `0` if the iterable is `null` or empty.
  /// - Null elements within the iterable are treated as `0`.
  ///
  /// Example:
  /// ```dart
  /// Iterable<int?>? numbers = [1, 2, null, 4];
  /// int sum = numbers.total; // sum is 7
  /// ```
  int get total {
    if (isEmptyOrNull) return 0;
    var sum = 0;
    for (final current in this!) {
      sum += current ?? 0;
    }
    return sum;
  }
}

/// Extension on nullable [Iterable<double?>] providing a total sum calculation.
///
/// This extension adds a [total] getter that computes the sum of all non-null
/// double values in the iterable. If the iterable is `null` or empty, it
/// returns `0`. Null elements within the iterable are treated as `0.0` in the
/// sum.
extension DHUIterableDoubleExtensionsNS on Iterable<double?>? {
  /// Calculates the total sum of the doubles in the iterable.
  ///
  /// - Returns `0` if the iterable is `null` or empty.
  /// - Null elements within the iterable are treated as `0.0`.
  ///
  /// Example:
  /// ```dart
  /// Iterable<double?>? numbers = [1.5, 2.5, null, 4.0];
  /// double sum = numbers.total; // sum is 8.0
  /// ```
  double get total {
    if (isEmptyOrNull) return 0;
    var sum = 0.0;
    for (final current in this!) {
      sum += current ?? 0.0;
    }
    return sum;
  }
}

/// Generates a random integer within the specified range.
///
/// Returns a random integer between [min] and [max], inclusive.
///
/// If a [seed] is provided, it is used to initialize the random number generator
/// for reproducible results.
/// Example:
/// ```dart
/// int randomNumber = randomInRange(1, 10);
/// ```
int randomInRange(num min, num max, [int? seed]) =>
    ((max - min + 1).random(seed) + min).toInt();
