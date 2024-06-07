import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:intl/intl.dart';

extension DHUNumberFormatNullableStringExtensions on String? {
  /// Tries to parse the string to a number with the given [newPattern] and [locale].
  /// Returns null if the string is null or empty.
  num? tryToNumFormatted([String? newPattern, String? locale]) =>
      isBlank ? null : NumberFormat(newPattern, locale).tryParse(this!);

  /// Tries to parse the string to an integer with the given [newPattern] and [locale].
  /// Returns null if the string is null or empty.
  int? tryToIntFormatted([String? newPattern, String? locale]) =>
      tryToNumFormatted(newPattern, locale)?.toInt();

  /// Tries to parse the string to a double with the given [newPattern] and [locale].
  /// Returns null if the string is null or empty.
  double? tryToDoubleFormatted([String? newPattern, String? locale]) =>
      tryToNumFormatted(newPattern, locale)?.toDouble();
}

extension DHUNumberFormatStringExtensions on String {
  /// Parses the string to a number with the given [newPattern] and [locale].
  num toNumFormatted([String? newPattern, String? locale]) =>
      NumberFormat(newPattern, locale).parse(this);

  /// Parses the string to an integer with the given [newPattern] and [locale].
  int toIntFormatted([String? newPattern, String? locale]) =>
      toNumFormatted(newPattern, locale).toInt();

  /// Parses the string to a double with the given [newPattern] and [locale].
  double toDoubleFormatted([String? newPattern, String? locale]) =>
      toNumFormatted(newPattern, locale).toDouble();
}

extension DHUNumberFormatExtensions on num {
  /// Formats the number as currency with the given [locale], [symbol], and [decimalDigits].
  String formatAsCurrency({
    String? locale,
    String symbol = r'$',
    int decimalDigits = 2,
  }) {
    return NumberFormat.currency(
            locale: locale, symbol: symbol, decimalDigits: decimalDigits)
        .format(this);
  }

  /// Formats the number as simple currency with the given [locale] and [name].
  String formatAsSimpleCurrency({String? locale, String? name}) {
    return NumberFormat.simpleCurrency(locale: locale, name: name).format(this);
  }

  /// Formats the number in a compact form with the given [locale].
  String formatAsCompact({String? locale}) {
    return NumberFormat.compact(locale: locale).format(this);
  }

  /// Formats the number in a long compact form with the given [locale].
  String formatAsCompactLong({String? locale}) {
    return NumberFormat.compactLong(locale: locale).format(this);
  }

  /// Formats the number as compact simple currency with the given [locale] and [name].
  String formatAsCompactCurrency({String? locale, String? name}) {
    return NumberFormat.compactSimpleCurrency(locale: locale, name: name)
        .format(this);
  }

  /// Formats the number as a decimal with the given [locale] and [decimalDigits].
  String formatAsDecimal({String? locale, int decimalDigits = 2}) {
    return NumberFormat.decimalPattern(locale).format(this);
  }

  /// Formats the number as a percentage with the given [locale].
  String formatAsPercentage({String? locale}) {
    return NumberFormat.percentPattern(locale).format(this);
  }

  /// Formats the number as a decimal percentage with the given [locale] and [decimalDigits].
  String formatAsDecimalPercent({String? locale, int decimalDigits = 2}) {
    return NumberFormat.decimalPercentPattern(
            locale: locale, decimalDigits: decimalDigits)
        .format(this);
  }

  /// Formats the number as a scientific value with the given [locale].
  String formatAsScientific({String? locale}) {
    return NumberFormat.scientificPattern(locale).format(this);
  }

  /// Formats the number using a custom [pattern] with the given [locale].
  String formatWithCustomPattern(String pattern, {String? locale}) {
    return NumberFormat(pattern, locale).format(this);
  }
}
