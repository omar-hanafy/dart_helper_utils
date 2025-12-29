import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:dart_helper_utils/src/extensions/extensions.dart';

/// Nullable String casing helpers.
extension DHUNullSafeCaseConversionExtensions on String? {
  /// Converts the string to lowercase if it's not null.
  String? tryToLowerCase() => this?.toLowerCase();

  /// Converts the string to uppercase if it's not null.
  String? tryToUpperCase() => this?.toUpperCase();
}

/// String case conversion helpers.
extension DHUCaseConversionExtensions on String {
  /// Splits the string into a list of words based on camel case, underscores, hyphens, and spaces.
  List<String> get toWords =>
      split(RegExp(r'(?<=[a-z])(?=[A-Z])|[_\-\s]+|(?<=[A-Z])(?=[A-Z][a-z])'));

  /// Converts the string to PascalCase (UpperCamelCase).
  /// Example: "hello_world" => "HelloWorld"
  String get toPascalCase =>
      toWords.map((word) => word.capitalizeFirstLowerRest).join();

  /// Converts the string to Title Case.
  /// Example: "hello_world" => "Hello World"
  String get toTitleCase => toWords
      .map(
        (word) => word.shouldIgnoreCapitalization
            ? word.toLowerCase()
            : word.capitalizeFirstLowerRest,
      )
      .join(' ');

  /// Converts the string to camelCase (dromedaryCase).
  /// Example: "hello_world" => "helloWorld"
  String get toCamelCase {
    final words = toWords;
    for (var i = 0; i < words.length; i++) {
      words[i] = (i == 0
          ? words[i].toLowerCase()
          : words[i].capitalizeFirstLowerRest);
    }
    return words.join();
  }

  /// Converts the string to snake_case (snail_case, pothole_case).
  /// Example: "helloWorld" => "hello_world"
  String get toSnakeCase => toWords.join('_').toLowerCase();

  /// Converts the string to kebab-case (dash-case, lisp-case, spinal-case).
  /// Example: "helloWorld" => "hello-world"
  String get toKebabCase => toWords.join('-').toLowerCase();

  /// Converts the string to SCREAMING_SNAKE_CASE (MACRO_CASE, CONSTANT_CASE, ALL_CAPS).
  /// Example: "helloWorld" => "HELLO_WORLD"
  String get toScreamingSnakeCase => toWords.join('_').toUpperCase();

  /// Converts the string to SCREAMING-KEBAB-CASE (COBOL-CASE).
  /// Example: "helloWorld" => "HELLO-WORLD"
  String get toScreamingKebabCase => toWords.join('-').toUpperCase();

  /// Converts the string to Pascal_Snake_Case.
  /// Example: "helloWorld" => "Hello_World"
  String get toPascalSnakeCase =>
      toWords.map((word) => word.capitalizeFirstLowerRest).join('_');

  /// Converts the string to Pascal-Kebab-Case.
  /// Example: "helloWorld" => "Hello-World"
  String get toPascalKebabCase =>
      toWords.map((word) => word.capitalizeFirstLowerRest).join('-');

  /// Converts the string to Train-Case (HTTP-Header-Case).
  /// Example: "helloWorld" => "Hello-World"
  String get toTrainCase =>
      toWords.map((word) => word.capitalizeFirstLowerRest).join('-');

  /// Converts the string to camel_Snake_Case.
  /// Example: "helloWorld" => "hello_World"
  String get toCamelSnakeCase {
    final words = toWords;
    for (var i = 0; i < words.length; i++) {
      words[i] = (i == 0
          ? words[i].toLowerCase()
          : words[i].capitalizeFirstLowerRest);
    }
    return words.join('_');
  }

  /// Converts the string to camel-Kebab-Case.
  /// Example: "helloWorld" => "hello-World"
  String get toCamelKebabCase {
    final words = toWords;
    for (var i = 0; i < words.length; i++) {
      words[i] = (i == 0
          ? words[i].toLowerCase()
          : words[i].capitalizeFirstLowerRest);
    }
    return words.join('-');
  }

  /// Converts the string to dot.case.
  /// Example: "helloWorld" => "hello.world"
  String get toDotCase => toWords.join('.').toLowerCase();

  /// Converts the string to flatcase.
  /// Example: "HelloWorld" => "helloworld"
  String get toFlatCase => toWords.join().toLowerCase();

  /// Converts the string to SCREAMINGCASE (UPPERCASE).
  /// Example: "helloWorld" => "HELLOWORLD"
  String get toScreamingCase => toWords.join().toUpperCase();

  /// Capitalizes only the first letter of the string, preserving the rest of the case.
  /// Example: "flutter AND DART" => "Flutter AND DART"
  String get capitalizeFirstLetter =>
      isBlank ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Lowercases only the first letter of the string, preserving the rest of the case.
  /// Example: "FLUTTER AND DART" => "fLUTTER AND DART"
  String get lowercaseFirstLetter =>
      isBlank ? this : '${this[0].toLowerCase()}${substring(1)}';

  /// Capitalizes the first letter of the string and lowers the rest.
  /// Example: "FLUTTER AND DART" => "Flutter and dart"
  String get capitalizeFirstLowerRest =>
      isBlank ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';

  /// Capitalizes the first letter of each word in the string while maintaining
  /// the `-`, `_`, and space characters.
  ///
  /// If you want to ignore the `_` and `-` characters, use the [toTitleCase].
  ///
  /// Example:
  /// ```dart
  /// String input = 'example-string_for general use-sample.';
  /// String title = input.toTitle;
  /// print(title); // Output: 'Example-String_For General Use-Sample.'
  /// ```
  String get toTitle => splitMapJoin(
    RegExp('[-_]'),
    onMatch: (match) => match.group(0)!,
    onNonMatch: (subWord) => subWord.isNotEmpty ? subWord.toTitleCase : subWord,
  );

  /// Determines if capitalization should be ignored for this string.
  /// Returns true if the string starts with a number or is a common lowercase word in titles.
  bool get shouldIgnoreCapitalization =>
      startsWithNumber || _titleCaseExceptions.contains(toLowerCase());
}

List<String> get _titleCaseExceptions => const <String>[
  'a',
  'abaft',
  'about',
  'above',
  'afore',
  'after',
  'along',
  'amid',
  'among',
  'an',
  'apud',
  'as',
  'aside',
  'at',
  'atop',
  'below',
  'but',
  'by',
  'circa',
  'down',
  'for',
  'from',
  'given',
  'in',
  'into',
  'lest',
  'like',
  'mid',
  'midst',
  'minus',
  'near',
  'next',
  'of',
  'off',
  'on',
  'onto',
  'out',
  'over',
  'pace',
  'past',
  'per',
  'plus',
  'pro',
  'qua',
  'round',
  'sans',
  'save',
  'since',
  'than',
  'thru',
  'till',
  'times',
  'to',
  'under',
  'until',
  'unto',
  'up',
  'upon',
  'via',
  'vice',
  'with',
  'worth',
  'the',
  'and',
  'nor',
  'or',
  'yet',
  'so',
];
