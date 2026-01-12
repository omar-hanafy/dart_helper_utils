import 'dart:async';
import 'dart:math' as math;

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:meta/meta.dart';

int? _asHttpStatusCode(num? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value % 1 == 0) return value.toInt();
  return null;
}

/// DHUHttpEx
extension DHUHttpEx on num? {
  /// Checks if the status code represents a successful response (2xx)
  bool get isSuccessCode => this != null && this! >= 200 && this! < 300;

  /// Checks if the status code specifically represents OK (200)
  bool get isOkCode => this == 200;

  /// Checks if the status code specifically represents Created (201)
  bool get isCreatedCode => this == 201;

  /// Checks if the status code specifically represents Accepted (202)
  bool get isAcceptedCode => this == 202;

  /// Checks if the status code specifically represents No Content (204)
  bool get isNoContentCode => this == 204;

  /// Checks if the status code represents a client error (4xx)
  bool get isClientErrorCode => this != null && this! >= 400 && this! < 500;

  /// Checks if the status code represents a server error (5xx)
  bool get isServerErrorCode => this != null && this! >= 500 && this! < 600;

  /// Checks if the status code represents a redirection (3xx)
  bool get isRedirectionCode => this != null && this! >= 300 && this! < 400;

  /// Checks if the status code represents a temporary redirection
  bool get isTemporaryRedirect => this == 302 || this == 307;

  /// Checks if the status code represents a permanent redirection
  bool get isPermanentRedirect => this == 301 || this == 308;

  /// Checks if the status code represents an authentication error
  bool get isAuthenticationError => this == 401 || this == 403;

  /// Checks if the status code represents a validation error
  bool get isValidationError => this == 422;

  /// Checks if the status code represents a rate limit error
  bool get isRateLimitError => this == 429;

  /// Checks if the status code represents a timeout error
  bool get isTimeoutError => this == 408 || this == 504;

  /// Checks if the status code represents a conflict
  bool get isConflictError => this == 409;

  /// Checks if the status code represents a not found error
  bool get isNotFoundError => this == 404;

  /// Checks if the request should be retried based on the status code
  bool get isRetryableError =>
      this == 408 || // Request Timeout
      this == 429 || // Too Many Requests
      this == 503 || // Service Unavailable
      this == 504; // Gateway Timeout

  /// Gets suggested retry delay as a Duration based on status code
  Duration get statusCodeRetryDelay {
    if (!isRetryableError) return Duration.zero;
    return switch (this!.toInt()) {
      408 => const Duration(seconds: 5), // Request Timeout: 5 seconds
      429 => const Duration(minutes: 1), // Rate Limit: 1 minute
      503 => const Duration(minutes: 5), // Service Unavailable: 5 minutes
      504 => const Duration(seconds: 10), // Gateway Timeout: 10 seconds
      _ => const Duration(seconds: 30), // Default: 30 seconds
    };
  }

  /// Returns the HTTP status message associated with the number.
  /// If the status code is not found, it returns "Not Found".
  String get toHttpStatusMessage {
    final statusCode = _asHttpStatusCode(this);
    return statusCode == null
        ? 'Not Found'
        : (httpStatusMessages[statusCode] ?? 'Not Found');
  }

  /// Returns the user-friendly HTTP status message associated with the number.
  /// If the status code is not found, it returns "Not Found".
  String get toHttpStatusUserMessage {
    final statusCode = _asHttpStatusCode(this);
    return statusCode == null
        ? 'Not Found'
        : (httpStatusUserMessage[statusCode] ?? 'Not Found');
  }

  /// Returns the developer-friendly HTTP status message associated with the number.
  /// If the status code is not found, it returns "Not Found".
  String get toHttpStatusDevMessage {
    final statusCode = _asHttpStatusCode(this);
    return statusCode == null
        ? 'Not Found'
        : (httpStatusDevMessage[statusCode] ?? 'Not Found');
  }

  /// Returns `true` if the string representation of this number is a valid phone number.
  bool get isValidPhoneNumber => toString().isValidPhoneNumber;
}

/// DHUNullSafeNumExtensions
extension DHUNullSafeNumExtensions on num? {
  /// Returns the integer value of the number, or `null` if the number is `null`.
  int? tryToInt() => this?.toInt();

  /// Returns the double value of the number, or `null` if the number is `null`.
  double? tryToDouble() => this?.toDouble();

  /// Returns the percentage of `this` value relative to [total], optionally allowing decimals.
  num percentage(num total, {bool allowDecimals = true}) {
    if (this == null || total == 0) return 0;
    final result = this! >= total ? 100 : math.max((this! / total) * 100, 0);
    if (allowDecimals) {
      return double.parse(result.toStringAsFixed(2));
    } else {
      return result.toInt();
    }
  }

  /// Returns `true` if the number is negative.
  bool get isNegative => this != null && this! < 0;

  /// Returns `true` if the number is positive.
  bool get isPositive => this != null && this! > 0;

  /// Returns `true` if the number is either `null` or zero.
  bool get isZeroOrNull => this == null || this! == 0;

  /// Returns `true` if the number is greater than 0.
  bool get asBool => (this ?? 0) > 0;

  /// Returns a string representation of the number with a given number of decimal places.
  ///
  /// If [keepTrailingZeros] is `true`, trailing zeros will be kept in the result, otherwise, they will be removed.
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

/// DHUNumExtensions
extension DHUNumExtensions on num {
  /// Returns `true` if the number is positive.
  bool get isPositive => this > 0;

  /// Returns `true` if the number is negative.
  bool get isNegative => this < 0;

  /// Returns `true` if the number is zero.
  bool get isZero => this == 0;

  /// Returns `true` if the string representation of this number is a valid phone number.
  bool get isValidPhoneNumber => toString().isValidPhoneNumber;

  /// Returns the number of digits in this number.
  int get numberOfDigits => toString().length;

  /// Removes trailing zeros from the string representation of the number.
  String get removeTrailingZero =>
      toString().replaceAll(RegExp(r'([.]*0)(?!.*\d)'), '');

  /// Rounds the number up to the nearest multiple of 50.
  double get roundToFiftyOrHundred =>
      this + (50 - ((this % 50) > 0 ? this % 50 : 50));

  /// Rounds the number to the nearest multiple of 10.
  double get roundToTenth => (this / 10).ceil() * 10;

  /// Returns one-tenth of the number.
  double get tenth => this / 10;

  /// Returns one-fourth of the number.
  double get fourth => this / 4;

  /// Returns one-third of the number.
  double get third => this / 3;

  /// Returns half of the number.
  double get half => this / 2;

  /// Generates a random integer between 0 (inclusive) and this value (exclusive).
  ///
  /// Throws [RangeError] if this value is less than 1.
  int get getRandom {
    if (this < 1) {
      throw RangeError('Upper bound must be at least 1.');
    }
    return math.Random().nextInt(toInt());
  }

  /// Generates a random integer between 0 (inclusive) and this value (exclusive),
  /// with an optional [seed] for reproducibility.
  ///
  /// Throws [RangeError] if this value is less than 1.
  int random([int? seed]) {
    if (this < 1) {
      throw RangeError('Upper bound must be at least 1.');
    }
    return math.Random(seed).nextInt(toInt());
  }

  /// Converts a number to a string with Greek symbols for thousands, millions, etc.
  ///
  /// Example usage:
  ///   print(1000.asGreeks); // Output: 1.0K
  ///   print(1500000.asGreeks); // Output: 1.5M
  ///   print(2500000000.asGreeks); // Output: 2.5B
  String asGreeks([int zerosFractionDigits = 0, int fractionDigits = 1]) {
    if (this < 1000) {
      return zerosFractionDigits <= 0
          ? toInt().toString()
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

  /// Converts bytes to a human-readable string (e.g., "1.5 MB").
  String toFileSize({int decimals = 2}) {
    if (this <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
    var i = (math.log(this) / math.log(1024)).floor();
    if (i >= suffixes.length) {
      i = suffixes.length - 1;
    }
    return '${(this / math.pow(1024, i)).toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  /// Delay equivalent to the number of days.
  @optionalTypeArgs
  Future<T> daysDelay<T extends Object?>([
    FutureOr<T> Function()? computation,
  ]) => Future.delayed(asDays, computation);

  /// Delay equivalent to the number of hours.
  @optionalTypeArgs
  Future<T> hoursDelay<T extends Object?>([
    FutureOr<T> Function()? computation,
  ]) => Future.delayed(asHours, computation);

  /// Delay equivalent to the number of minutes.
  @optionalTypeArgs
  Future<T> minutesDelay<T extends Object?>([
    FutureOr<T> Function()? computation,
  ]) => Future.delayed(asMinutes, computation);

  /// Delay equivalent to the number of seconds.
  @optionalTypeArgs
  Future<T> secondsDelay<T extends Object?>([
    FutureOr<T> Function()? computation,
  ]) => Future.delayed(asSeconds, computation);

  /// Delay equivalent to the number of milliseconds.
  @optionalTypeArgs
  Future<T> millisecondsDelay<T extends Object?>([
    FutureOr<T> Function()? computation,
  ]) => Future.delayed(asMilliseconds, computation);

  /// Converts the number to a Duration in milliseconds.
  Duration get asMilliseconds => Duration(milliseconds: round());

  /// Converts the number to a Duration in seconds.
  Duration get asSeconds => Duration(milliseconds: (this * 1000).round());

  /// Converts the number to a Duration in minutes.
  Duration get asMinutes =>
      Duration(seconds: (this * Duration.secondsPerMinute).round());

  /// Converts the number to a Duration in hours.
  Duration get asHours =>
      Duration(minutes: (this * Duration.minutesPerHour).round());

  /// Converts the number to a Duration in days.
  Duration get asDays => Duration(hours: (this * Duration.hoursPerDay).round());

  /// Returns the square root of the number.
  double sqrt() => (this > 0) ? math.sqrt(toDouble()) : 0.0;

  /// Returns a sequence of integers starting from `this`,
  /// incrementing by [step] and ending at [end].
  Iterable<num> until(int end, {int step = 1}) sync* {
    if (step == 0) {
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
  }) => NumbersHelper.safeDivide(
    this,
    b,
    whenDivByZero: whenDivByZero,
    whenBothZero: whenBothZero,
    returnNaNOnDivByZero: returnNaNOnDivByZero,
  );

  /// Rounds this number to the nearest multiple of [multiple].
  ///
  /// Throws [ArgumentError] if [multiple] is zero.
  num roundToNearestMultiple(num multiple) {
    if (multiple == 0) {
      throw ArgumentError('Multiple cannot be zero.');
    }
    return (this / multiple).round() * multiple;
  }

  /// Rounds this number up to the nearest multiple of [multiple].
  ///
  /// Throws [ArgumentError] if [multiple] is zero.
  num roundUpToMultiple(num multiple) {
    if (multiple == 0) {
      throw ArgumentError('Multiple cannot be zero.');
    }
    return (this / multiple).ceil() * multiple;
  }

  /// Rounds this number down to the nearest multiple of [multiple].
  ///
  /// Throws [ArgumentError] if [multiple] is zero.
  num roundDownToMultiple(num multiple) {
    if (multiple == 0) {
      throw ArgumentError('Multiple cannot be zero.');
    }
    return (this / multiple).floor() * multiple;
  }

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
  ///
  /// Returns a value between 0 and 1 representing where this value falls
  /// in the range from [min] to [max].
  ///
  /// Throws [ArgumentError] if [min] equals [max] or if [min] > [max].
  num scaleBetween(num min, num max) {
    if (min == max) {
      throw ArgumentError('Min and max cannot be the same.');
    }
    if (min > max) {
      throw ArgumentError('Min cannot be greater than max.');
    }
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
    final number = toInt();

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
    final number = toInt();
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

/// DHUIntExtensions
extension DHUIntExtensions on int {
  /// Return the min if this number is smaller then minimum
  /// Return the max if this number is bigger the the maximum
  /// Return this number if it's between the range
  int inRangeOf(int min, int max) {
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
    for (var i = 2; i <= math.sqrt(this).toInt(); i++) {
      if (this % i == 0) return false;
    }
    return true;
  }

  /// Returns the prime factors of this integer.
  List<int> primeFactors() {
    var n = this;
    final factors = <int>[];
    for (var i = 2; i <= math.sqrt(n).toInt(); i++) {
      while (n % i == 0) {
        factors.add(i);
        n ~/= i;
      }
    }
    if (n > 1) factors.add(n);
    return factors;
  }

  /// Checks if this integer is a perfect square.
  bool isPerfectSquare() {
    if (this < 0) return false;
    final root = math.sqrt(this).toInt();
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

/// DHUDoubleExtensions
extension DHUDoubleExtensions on double {
  /// Return the min if this number is smaller then minimum
  /// Return the max if this number is bigger the the maximum
  /// Return this number if it's between the range
  double inRangeOf(double min, double max) {
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
  ///
  /// Throws [ArgumentError] if [multiple] is zero.
  double roundToNearestMultiple(double multiple) {
    if (multiple == 0) {
      throw ArgumentError('Multiple cannot be zero.');
    }
    return (this / multiple).round() * multiple;
  }

  /// Rounds this double up to the nearest multiple of [multiple].
  ///
  /// Throws [ArgumentError] if [multiple] is zero.
  double roundUpToMultiple(double multiple) {
    if (multiple == 0) {
      throw ArgumentError('Multiple cannot be zero.');
    }
    return (this / multiple).ceil() * multiple;
  }

  /// Rounds this double down to the nearest multiple of [multiple].
  ///
  /// Throws [ArgumentError] if [multiple] is zero.
  double roundDownToMultiple(double multiple) {
    if (multiple == 0) {
      throw ArgumentError('Multiple cannot be zero.');
    }
    return (this / multiple).floor() * multiple;
  }

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
  /// print(NumbersHelper.safeDivide(0, 0)); // Output: 0
  /// print(NumbersHelper.safeDivide(10, 0)); // Output: Infinity
  /// print(NumbersHelper.safeDivide(10, 0, whenDivByZero: -1)); // Output: -1
  /// print(NumbersHelper.safeDivide(10, 0, returnNaNOnDivByZero: true)); // Output: NaN
  /// print(NumbersHelper.safeDivide(10, 2)); // Output: 5
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
    num sum = 0;
    for (final value in values) {
      sum += value;
    }
    return sum / values.length;
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
    final maxFrequency = frequencyMap.values.reduce(math.max);
    return frequencyMap.entries
        .where((entry) => entry.value == maxFrequency)
        .map((entry) => entry.key)
        .toList();
  }

  /// Calculates the variance of a list of [values].
  static num variance(List<num> values) {
    if (values.isEmpty) throw ArgumentError('The list cannot be empty.');
    final m = mean(values);
    return mean(values.map((value) => math.pow(value - m, 2)).toList());
  }

  /// Calculates the standard deviation of a list of [values].
  static num standardDeviation(List<num> values) => math.sqrt(variance(values));

  /// Calculates the specified [percentile] of a list of [values].
  ///
  /// [percentile] must be between 0 and 100 inclusive.
  static num percentile(List<num> values, double percentile) {
    if (values.isEmpty) throw ArgumentError('The list cannot be empty.');
    if (percentile < 0 || percentile > 100) {
      throw ArgumentError('Percentile must be between 0 and 100.');
    }
    final sortedValues = List<num>.from(values)..sort();
    final rank = percentile / 100;
    final index = (rank * (values.length - 1)).round();
    return sortedValues[index];
  }

  /// Calculates the greatest common divisor (GCD) of two integers [a] and [b].
  static int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);

  /// Checks if a number [n] is a perfect square.
  static bool isPerfectSquare(int n) {
    final sqrtN = math.sqrt(n).toInt();
    return sqrtN * sqrtN == n;
  }
}

/// Extension on [Iterable<num>] providing statistical operations.
///
/// This extension adds properties to calculate the mean, median, mode,
/// variance, standard deviation, and percentiles of a numeric iterable.
extension DHUListNumStats on Iterable<num> {
  /// Calculates the mean (average) of the numbers in the iterable.
  num get mean => NumbersHelper.mean(toList());

  /// Determines the median value of the numbers in the iterable.
  num get median => NumbersHelper.median(toList());

  /// Finds the mode(s) of the numbers in the iterable.
  ///
  /// Returns a list of numbers that appear most frequently.
  List<num> get mode => NumbersHelper.mode(toList());

  /// Computes the variance of the numbers in the iterable.
  num get variance => NumbersHelper.variance(toList());

  /// Calculates the standard deviation of the numbers in the iterable.
  num get standardDeviation => NumbersHelper.standardDeviation(toList());

  /// Computes the specified [percentile] of the numbers in the iterable.
  ///
  /// The [percentile] should be a value between 0 and 100.
  num percentile(double percentile) =>
      NumbersHelper.percentile(toList(), percentile);
}

/// Extension on [Iterable<int>] providing statistical operations.
///
/// This extension adds properties to calculate the mean, median, mode,
/// variance, standard deviation, and percentiles of an integer iterable.
extension DHUListIntStats on Iterable<int> {
  /// Calculates the mean (average) of the integers in the iterable.
  int get mean => NumbersHelper.mean(toList()).toInt();

  /// Determines the median value of the integers in the iterable.
  int get median => NumbersHelper.median(toList()).toInt();

  /// Finds the mode(s) of the integers in the iterable.
  ///
  /// Returns a list of integers that appear most frequently.
  List<int> get mode => convertToList<int>(NumbersHelper.mode(toList()));

  /// Computes the variance of the integers in the iterable.
  int get variance => NumbersHelper.variance(toList()).toInt();

  /// Calculates the standard deviation of the integers in the iterable.
  int get standardDeviation =>
      NumbersHelper.standardDeviation(toList()).toInt();

  /// Computes the specified [percentile] of the integers in the iterable.
  ///
  /// The [percentile] should be a value between 0 and 100.
  int percentile(double percentile) =>
      NumbersHelper.percentile(toList(), percentile).toInt();
}

/// Extension on [Iterable<double>] providing statistical operations.
///
/// This extension adds properties to calculate the mean, median, mode,
/// variance, standard deviation, and percentiles of a double iterable.
extension DHUListDoubleStats on Iterable<double> {
  /// Calculates the mean (average) of the doubles in the iterable.
  double get mean => NumbersHelper.mean(toList()).toDouble();

  /// Determines the median value of the doubles in the iterable.
  double get median => NumbersHelper.median(toList()).toDouble();

  /// Finds the mode(s) of the doubles in the iterable.
  ///
  /// Returns a list of doubles that appear most frequently.
  List<double> get mode => convertToList<double>(NumbersHelper.mode(toList()));

  /// Computes the variance of the doubles in the iterable.
  double get variance => NumbersHelper.variance(toList()).toDouble();

  /// Calculates the standard deviation of the doubles in the iterable.
  double get standardDeviation =>
      NumbersHelper.standardDeviation(toList()).toDouble();

  /// Computes the specified [percentile] of the doubles in the iterable.
  ///
  /// The [percentile] should be a value between 0 and 100.
  double percentile(double percentile) =>
      NumbersHelper.percentile(toList(), percentile).toDouble();
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
/// [min] and [max] are treated as integer bounds via `toInt()`.
/// Throws [ArgumentError] if [min] is greater than [max].
///
/// If a [seed] is provided, it is used to initialize the random number generator
/// for reproducible results.
/// Example:
/// ```dart
/// int randomNumber = randomInRange(1, 10);
/// ```
int randomInRange(num min, num max, [int? seed]) {
  if (min > max) {
    throw ArgumentError('min must be less than or equal to max.');
  }
  return ((max - min + 1).random(seed) + min).toInt();
}
