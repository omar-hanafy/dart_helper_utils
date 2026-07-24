import 'dart:async';
import 'dart:convert';

import 'package:dart_helper_utils/dart_helper_utils.dart';

/// Extensions for common String helpers.
///
/// Text transformations (casing, slugs, trimming, truncation, masking) live in
/// the `stringo` package, which this package re-exports. What remains here is
/// the domain-specific layer: format validation, parsing, and encoding.
extension DHUStringExtensions on String {
  /// Base64 Encode for this String
  String base64Encode() => base64.encode(utf8.encode(this));

  /// Base64 Decode
  String base64Decode({bool? allowMalformed}) =>
      utf8.decode(base64.decode(this), allowMalformed: allowMalformed);

  /// Parses this string into a [Duration].
  ///
  /// Supported formats:
  /// - Clock format: "HH:mm:ss" or "mm:ss"
  /// - Token format: "1h 20m", "2d 3h 4m 5s"
  ///
  /// Throws [FormatException] for invalid input.
  Duration parseDuration() {
    final original = this;
    var input = trim();
    if (input.isEmpty) {
      throw FormatException('Invalid duration', original);
    }

    var isNegative = false;
    if (input.startsWith('-')) {
      isNegative = true;
      input = input.substring(1).trimLeft();
    }

    if (input.isEmpty) {
      throw FormatException('Invalid duration', original);
    }

    FormatException invalid([String? reason]) =>
        FormatException(reason ?? 'Invalid duration', original);

    Duration parseClock(String value) {
      final parts = value.split(':');
      if (parts.length < 2 || parts.length > 3) {
        throw invalid('Invalid clock duration');
      }

      int hours = 0;
      int minutes = 0;
      int seconds = 0;

      try {
        if (parts.length == 3) {
          hours = int.parse(parts[0]);
          minutes = int.parse(parts[1]);
          seconds = int.parse(parts[2]);
          if (minutes >= 60 || seconds >= 60) {
            throw invalid('Invalid clock duration');
          }
        } else {
          minutes = int.parse(parts[0]);
          seconds = int.parse(parts[1]);
          if (seconds >= 60) {
            throw invalid('Invalid clock duration');
          }
        }
      } on FormatException {
        throw invalid('Invalid clock duration');
      }

      if (hours < 0 || minutes < 0 || seconds < 0) {
        throw invalid('Invalid clock duration');
      }

      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }

    Duration parseTokens(String value) {
      final regex = RegExp(r'(\d+)\s*([dhms])', caseSensitive: false);
      final matches = regex.allMatches(value);
      if (matches.isEmpty) {
        throw invalid();
      }

      final leftover = value.replaceAll(regex, '').trim();
      if (leftover.isNotEmpty) {
        throw invalid();
      }

      var days = 0;
      var hours = 0;
      var minutes = 0;
      var seconds = 0;

      for (final match in matches) {
        final amount = int.parse(match.group(1)!);
        final unit = match.group(2)!.toLowerCase();
        switch (unit) {
          case 'd':
            days += amount;
            break;
          case 'h':
            hours += amount;
            break;
          case 'm':
            minutes += amount;
            break;
          case 's':
            seconds += amount;
            break;
        }
      }

      return Duration(
        days: days,
        hours: hours,
        minutes: minutes,
        seconds: seconds,
      );
    }

    final duration = input.contains(':')
        ? parseClock(input)
        : parseTokens(input.replaceAll(RegExp(r'\s+'), ' '));

    return isNegative
        ? Duration(microseconds: -duration.inMicroseconds)
        : duration;
  }
}

/// Extensions for nullable String helpers.
///
/// Text transformations live in the re-exported `stringo` package; these are
/// the format validators and remaining odds and ends.
extension DHUNullSafeStringExtensions on String? {
  /// Checks if the string is a palindrome.
  bool get isPalindrome {
    if (isEmptyOrNull) return false;

    final cleanString = this!
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '')
        .replaceAll(RegExp('[^0-9a-zA-Z]+'), '');

    // Iterate only up to half the length of the string
    for (var i = 0; i < cleanString.length ~/ 2; i++) {
      if (cleanString[i] != cleanString[cleanString.length - i - 1]) {
        return false;
      }
    }
    return true;
  }

  /// Checks if the string contains any characters that are not letters, numbers, or spaces (i.e., special characters).
  bool get hasSpecialChars => hasMatch(regexSpecialChars);

  /// Checks if the string does NOT contain any characters that are not letters, numbers, or spaces (i.e., special characters).
  bool get hasNoSpecialChars => !hasSpecialChars;

  /// Checks if the string is a valid username.
  bool get isValidUsername => hasMatch(regexValidUsername);

  /// Checks if the string is a valid currency format.
  bool get isValidCurrency => hasMatch(regexValidCurrency);

  /// Checks if the string is a valid phone number.
  bool get isValidPhoneNumber {
    if (isEmptyOrNull || this!.length > 16 || this!.length < 9) return false;
    return hasMatch(regexValidPhoneNumber);
  }

  /// Checks if the string is a valid email address.
  bool get isValidEmail => hasMatch(regexValidEmail);

  /// Checks if the string is an HTML file or URL.
  bool get isValidHTML => (this ?? ' ').toLowerCase().endsWith('.html');

  /// Checks if the string is a valid IPv4 address.
  bool get isValidIp4 => hasMatch(regexValidIp4);

  /// Checks if the string is a valid URL.
  bool get isValidUrl =>
      tryToLowerCase().clean?.hasMatch(regexValidUrl) ?? false;

  /// Checks if the string is a boolean literal (`true`/`false`, case-insensitive).
  bool get isBool {
    final value = this;
    if (value == null) return false;
    final normalized = value.trim().toLowerCase();
    return normalized == 'true' || normalized == 'false';
  }

  /// Wraps the string based on the specified word count, wrap behavior, and delimiter.
  /// Example: "This is a test".wrapString(wrapCount: 2, wrapEach: false) => "This is\na test"
  String wrapString({
    int wordCount = 1,
    bool wrapEach = false,
    String delimiter = '\n',
  }) {
    if (isEmptyOrNull) return '';
    final wrapCount = wordCount <= 0 ? 1 : wordCount;
    // Handling strings with multiple consecutive spaces by reducing them to single spaces.
    final words = this!.trim().replaceAll(RegExp(' +'), ' ').split(' ');
    if (words.isEmpty) return '';
    final buffer = StringBuffer();

    if (wrapEach) {
      for (var i = 0; i < words.length; i++) {
        buffer.write(words[i]);
        if ((i + 1) % wrapCount == 0 && i != words.length - 1) {
          buffer.write(delimiter);
        } else if (i != words.length - 1) {
          buffer.write(' ');
        }
      }
    } else {
      for (var i = 0; i < words.length; i++) {
        buffer.write(words[i]);
        if (i == wrapCount - 1 && words.length > wrapCount) {
          buffer.write(delimiter);
        } else if (i != words.length - 1) {
          buffer.write(' ');
        }
      }
    }

    return buffer.toString();
  }

  /// Returns true if at least one character matches the given [predicate].
  /// The [predicate] should have only one character.
  bool anyChar(bool Function(String element) predicate) =>
      isNotEmptyOrNull && this!.split('').any((s) => predicate(s));

  /// If the string is empty, performs an action.
  Future<T>? ifEmpty<T>(Future<T> Function() action) =>
      isEmptyOrNull ? action() : null;

  /// Returns the last character of the string.
  String get lastIndex {
    if (isEmptyOrNull) return '';
    return this![this!.length - 1];
  }

  // Numeric conversions moved to convert_object. Use:
  //   toNum(this), toDouble(this), toInt(this), tryToNum(this), tryToDouble(this), tryToInt(this)

  /// Shrinks the string to be no more than [maxSize] in length, extending from the end.
  /// Example: In a string with 10 characters, a [maxSize] of 3 would return the last 3 characters.
  String? limitFromEnd(int maxSize) => (this?.length ?? 0) < maxSize
      ? this
      : this!.substring(this!.length - maxSize);

  /// Shrinks the string to be no more than [maxSize] in length, extending from the start.
  /// Example: In a string with 10 characters, a [maxSize] of 3 would return the first 3 characters.
  String? limitFromStart(int maxSize) =>
      (this?.length ?? 0) < maxSize ? this : this!.substring(0, maxSize);

  /// Checks if the string is a valid UUID.
  bool get isUuid {
    if (isEmptyOrNull) return false;
    return RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    ).hasMatch(this!);
  }

  /// Masks the email address for privacy.
  /// Example: "johndoe@gmail.com" -> "jo****@gmail.com"
  String get maskEmail {
    if (this == null || !this!.isValidEmail) return this ?? '';
    final index = this!.indexOf('@');
    if (index <= 2) return '${this![0]}****${this!.substring(index)}';
    return '${this!.substring(0, 2)}****${this!.substring(index)}';
  }
}
