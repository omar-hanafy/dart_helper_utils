import 'dart:async';
import 'dart:convert';

import 'package:dart_helper_utils/dart_helper_utils.dart';

///
extension DHUStringExtensions on String {
  /// If the string is empty, return null. Otherwise, return the string.
  String? get nullIfEmpty => isEmpty ? null : this;

  /// If the string is blank (null, empty, or consists only of whitespace),
  /// return null. Otherwise, return the string.
  /// Alias for [isEmptyOrNull].
  String? get nullIfBlank => isBlank ? null : this;

  /// Removes consecutive empty lines, replacing them with single newlines.
  /// Example: "Line1\n\n\nLine2" => "Line1\nLine2"
  String get removeEmptyLines =>
      replaceAll(RegExp(r'(?:[\t ]*(?:\r?\n|\r))+'), '\n');

  /// Converts the string into a single line by replacing newline characters.
  /// Example: "Line1\nLine2" => "Line1Line2"
  String get toOneLine => replaceAll('\n', '');

  /// Removes all whitespace characters (spaces) from the string.
  /// Example: "Line 1 Line 2" => "Line1Line2"
  String get removeWhiteSpaces => replaceAll(' ', '');

  /// Removes all whitespace characters and collapses the string into a single line.
  /// Example: "Line 1\n Line 2" => "Line1Line2"
  String get clean => toOneLine.removeWhiteSpaces;

  /// returns the integer value of the Roman numeral string.
  int get asRomanNumeralToInt => NumbersHelper.fromRomanNumeral(this);

  /// Base64 Encode for this String
  String base64Encode() => base64.encode(utf8.encode(this));

  /// Base64 Decode
  String base64Decode({bool? allowMalformed}) =>
      utf8.decode(base64.decode(this), allowMalformed: allowMalformed);

  /// Measures how similar this string is to another string using the specified algorithm.
  /// it uses the public [StringSimilarity] class which offers different methods
  /// for measuring how similar two strings are.
  double compareWith(
    String other,
    SimilarityAlgorithm algorithm, {
    StringSimilarityConfig config = const StringSimilarityConfig(),
  }) =>
      StringSimilarity.compare(
        this,
        other,
        algorithm,
        config: config,
      );
}

///
extension DHUNullSafeStringExtensions on String? {
  /// Converts the string into a single line by replacing newline characters.
  String? get toOneLine => this?.replaceAll('\n', '');

  /// Removes all whitespace characters (spaces) from the string.
  String? get removeWhiteSpaces => this?.replaceAll(' ', '');

  /// Removes all whitespace characters and collapses the string into a single line.
  String? get clean => toOneLine.removeWhiteSpaces;

  /// Returns true if the string is null, empty, or, after cleaning (collapsing into a single line, removing all whitespaces), is empty.
  bool get isEmptyOrNull => this == null || this!.clean.isEmpty;

  /// Returns true if the string is null, empty, or solely made of whitespace characters.
  /// Alias for [isEmptyOrNull].
  bool get isBlank => isEmptyOrNull;

  /// Returns true if the string is not null, not empty, and, after cleaning (removing all whitespaces and collapsing into a single line), is not empty.
  bool get isNotEmptyOrNull => !isEmptyOrNull;

  /// Returns true if the string is neither null, empty, nor solely made of whitespace characters.
  /// Alias for [isNotEmptyOrNull].
  bool get isNotBlank => isNotEmptyOrNull;

  /// Returns a list of characters from the string.
  List<String> toCharArray() => isNotBlank ? this!.split('') : [];

  /// Returns a new string in which a specified string is inserted at a specified index position in this instance.
  String insert(int index, String str) =>
      (List<String>.from(toCharArray())..insert(index, str)).join();

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

  /// Checks if the string contains only letters and numbers.
  bool get isAlphanumeric => hasMatch(regexAlphanumeric);

  /// Checks if the string contains any characters that are not letters, numbers, or spaces (i.e., special characters).
  bool get hasSpecialChars => hasMatch(regexSpecialChars);

  /// Checks if the string does NOT contain any characters that are not letters, numbers, or spaces (i.e., special characters).
  bool get hasNoSpecialChars => !hasSpecialChars;

  /// Checks if the string starts with a number (digit).
  bool get startsWithNumber => hasMatch(regexStartsWithNumber);

  /// Checks if the string contains any digits.
  bool get containsDigits => hasMatch(regexContainsDigits);

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

  /// Checks if the string is a valid IPv6 address.
  bool get isValidIp6 => hasMatch(regexValidIp6);

  /// Checks if the string is a valid URL.
  bool get isValidUrl => tryToLowerCase.clean.hasMatch(regexValidUrl);

  /// Checks if the string consists only of numbers (no whitespace).
  bool get isNumeric => hasMatch(regexNumeric);

  /// Checks if the string consists only of letters (no whitespace).
  bool get isAlphabet => hasMatch(regexAlphabet);

  /// Checks if the string contains at least one capital letter.
  bool get hasCapitalLetter => hasMatch(regexHasCapitalLetter);

  /// Helper function to check for pattern matches.
  bool hasMatch(
    String pattern, {
    bool multiLine = false,
    bool caseSensitive = true,
    bool unicode = false,
    bool dotAll = false,
  }) =>
      this != null &&
      RegExp(
        pattern,
        caseSensitive: caseSensitive,
        multiLine: multiLine,
        unicode: unicode,
        dotAll: dotAll,
      ).hasMatch(this!);

  /// Checks if the string represents a boolean value.
  bool get isBool => this == 'true' || this == 'false';

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

  /// Compares the current string with another string for equality, ignoring case differences.
  bool equalsIgnoreCase(String? other) =>
      (this == null && other == null) ||
      (this != null &&
          other != null &&
          this!.toLowerCase() == other.toLowerCase());

  /// Returns the string only if the delimiter exists at both ends, otherwise returns the current string.
  String? removeSurrounding(String delimiter) {
    if (this == null) return null;
    final prefix = delimiter;
    final suffix = delimiter;

    if ((this!.length >= prefix.length + suffix.length) &&
        this!.startsWith(prefix) &&
        this!.endsWith(suffix)) {
      return this!.substring(prefix.length, this!.length - suffix.length);
    }
    return this;
  }

  /// Replaces part of the string after the first occurrence of the given delimiter with the [replacement] string.
  /// If the string does not contain the delimiter, returns [defaultValue] which defaults to the original string.
  String? replaceAfter(
    String delimiter,
    String replacement, [
    String? defaultValue,
  ]) {
    if (this == null) return null;
    final index = this!.indexOf(delimiter);
    return (index == -1)
        ? defaultValue.isEmptyOrNull
            ? this
            : defaultValue
        : this!.replaceRange(index + 1, this!.length, replacement);
  }

  /// Replaces part of the string before the first occurrence of the given delimiter with the [replacement] string.
  /// If the string does not contain the delimiter, returns [defaultValue] which defaults to the original string.
  String? replaceBefore(
    String delimiter,
    String replacement, [
    String? defaultValue,
  ]) {
    if (this == null) return null;
    final index = this!.indexOf(delimiter);
    return (index == -1)
        ? defaultValue.isEmptyOrNull
            ? this
            : defaultValue
        : this!.replaceRange(0, index, replacement);
  }

  /// Returns true if at least one character matches the given [predicate].
  /// The [predicate] should have only one character.
  bool anyChar(bool Function(String element) predicate) =>
      isNotEmptyOrNull && this!.split('').any((s) => predicate(s));

  /// Returns the string if it is not null, or the empty string otherwise.
  String get orEmpty => this ?? '';

  /// If the string is empty, performs an action.
  Future<T>? ifEmpty<T>(Future<T> Function() action) =>
      isEmptyOrNull ? action() : null;

  /// Returns the last character of the string.
  String get lastIndex {
    if (isEmptyOrNull) return '';
    return this![this!.length - 1];
  }

  /// Parses the string as a num or returns null if it is not a number.
  num? get tryToNum => this == null ? null : num.tryParse(this!);

  /// Parses the string as a double or returns null if it is not a number.
  double? get tryToDouble =>
      this == null ? null : num.tryParse(this!).tryToDouble;

  /// Parses the string as an int or returns null if it is not a number.
  int? get tryToInt => this == null ? null : num.tryParse(this!).tryToInt;

  /// Parses the string as a num or returns null if it is not a number.
  num get toNum => num.parse(this!);

  /// Parses the string as a double or returns null if it is not a number.
  double get toDouble => num.parse(this!).toDouble();

  /// Parses the string as an int or returns null if it is not a number.
  int get toInt => num.parse(this!).toInt();

  /// Indicates whether the string is null, empty, or consists only of whitespace characters.
  bool get isNullOrWhiteSpace {
    final length = (this?.split('') ?? []).where((x) => x == ' ').length;
    return length == (this?.length ?? 0) || isEmptyOrNull;
  }

  /// Shrinks the string to be no more than [maxSize] in length, extending from the end.
  /// Example: In a string with 10 characters, a [maxSize] of 3 would return the last 3 characters.
  String? limitFromEnd(int maxSize) => (this?.length ?? 0) < maxSize
      ? this
      : this!.substring(this!.length - maxSize);

  /// Shrinks the string to be no more than [maxSize] in length, extending from the start.
  /// Example: In a string with 10 characters, a [maxSize] of 3 would return the first 3 characters.
  String? limitFromStart(int maxSize) =>
      (this?.length ?? 0) < maxSize ? this : this!.substring(0, maxSize);

  /// Converts the string into a boolean.
  /// Returns true if the string is any of these values: "true", "yes", "1", or if the string is a number and greater than 0, false if less than 1. This is also case insensitive.
  bool get asBool {
    try {
      final s = clean.tryToLowerCase ?? 'false';
      return s == 'true' ||
          s == 'yes' ||
          s == '1' ||
          s == 'ok' ||
          s.tryToNum.asBool;
    } catch (_) {
      return false;
    }
  }

  /// Decodes the JSON string into a dynamic data structure.
  /// Returns the decoded dynamic data structure if the string is non-empty and valid JSON.
  /// Returns null if the string is null or empty, or if the string is not a valid JSON format.
  dynamic decode({Object? Function(Object? key, Object? value)? reviver}) =>
      isEmptyOrNull ? null : json.decode(this!, reviver: reviver);

  /// Decodes the JSON string into a dynamic data structure.
  /// Returns the decoded dynamic data structure if the string is non-empty and valid JSON.
  /// Returns null if the string is null or empty, or if the string is not a valid JSON format.
  dynamic tryDecode({Object? Function(Object? key, Object? value)? reviver}) {
    try {
      return decode(reviver: reviver);
    } catch (_) {}
    return null;
  }

  /// property returns the integer value of the Roman numeral string.
  int? get asRomanNumeralToInt =>
      this == null ? null : NumbersHelper.fromRomanNumeral(this!);
}
