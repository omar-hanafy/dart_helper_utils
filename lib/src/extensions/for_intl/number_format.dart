import 'package:dart_helper_utils/dart_helper_utils.dart';

extension DHUNumberFormatNullableStringExtensions on String? {
  /// Creates a [NumberFormat] object using the string as the pattern, along with the given [locale].
  NumberFormat numberFormat({String? locale}) => NumberFormat(this, locale);

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

  /// Creates a [NumberFormat] object as currency using the string as the currency symbol, along with the given locale and optional decimal digits.
  NumberFormat symbolCurrencyFormat({
    String? locale,
    String? name,
    int? decimalDigits,
    String? customPattern,
  }) {
    return NumberFormat.currency(
      symbol: this,
      name: name,
      customPattern: customPattern,
      locale: locale,
      decimalDigits: decimalDigits,
    );
  }

  ///  Creates a [NumberFormat] object as simple currency using the string as the currency name, along with the given locale.
  NumberFormat simpleCurrencyFormat({String? locale, int? decimalDigits}) {
    return NumberFormat.simpleCurrency(
      name: this,
      locale: locale,
      decimalDigits: decimalDigits,
    );
  }

  /// Creates a [NumberFormat] object as compact simple currency using the string as the currency name, along with the given locale.
  NumberFormat compactCurrencyFormat({String? locale, int? decimalDigits}) {
    return NumberFormat.compactSimpleCurrency(
      name: this,
      locale: locale,
      decimalDigits: decimalDigits,
    );
  }
}

extension DHUNumberFormatExtensions on num {
  /// Formats the number as currency with the given [locale], [symbol], and [decimalDigits].
  String formatAsCurrency({
    String? locale,
    String symbol = r'$',
    int decimalDigits = 2,
    String? customPattern,
  }) {
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
      customPattern: customPattern,
    ).format(this);
  }

  /// Formats the number as simple currency with the given [locale] and [name].
  String formatAsSimpleCurrency({
    String? locale,
    String? name,
    int? decimalDigits,
  }) {
    return NumberFormat.simpleCurrency(
      locale: locale,
      name: name,
      decimalDigits: decimalDigits,
    ).format(this);
  }

  /// Formats the number in a compact form with the given [locale].
  String formatAsCompact({String? locale}) {
    return NumberFormat.compact(
      locale: locale,
    ).format(this);
  }

  /// Formats the number in a long compact form with the given [locale].
  String formatAsCompactLong({String? locale, bool explicitSign = false}) {
    return NumberFormat.compactLong(
      locale: locale,
      explicitSign: explicitSign,
    ).format(this);
  }

  /// Formats the number as compact simple currency with the given [locale] and [name].
  String formatAsCompactCurrency({
    String? locale,
    String? name,
    int? decimalDigits,
  }) {
    return NumberFormat.compactSimpleCurrency(
      locale: locale,
      name: name,
      decimalDigits: decimalDigits,
    ).format(this);
  }

  /// Formats the number as a decimal with the given [locale] and [decimalDigits].
  String formatAsDecimal({String? locale}) {
    return NumberFormat.decimalPattern(locale).format(this);
  }

  /// Formats the number as a percentage with the given [locale].
  String formatAsPercentage({String? locale}) {
    return NumberFormat.percentPattern(locale).format(this);
  }

  /// Formats the number as a decimal percentage with the given [locale] and [decimalDigits].
  String formatAsDecimalPercent({String? locale, int? decimalDigits}) {
    return NumberFormat.decimalPercentPattern(
      locale: locale,
      decimalDigits: decimalDigits,
    ).format(this);
  }

  /// Formats the number as a scientific value with the given [locale].
  String formatAsScientific({String? locale}) {
    return NumberFormat.scientificPattern(locale).format(this);
  }

  /// Formats the number using a custom [pattern] with the given [locale].
  String formatWithCustomPattern(String pattern, {String? locale}) {
    return NumberFormat(pattern, locale).format(this);
  }

  /// Formats this number into a readable string with customizable options.
  ///
  /// - [locale] specifies the locale to use for formatting (e.g., `'en_US'`, `'de_DE'`).
  ///   If not provided, the default locale of the system will be used.
  ///
  /// - [decimalDigits] determines the maximum number of decimal places to display.
  ///   Must be a non-negative integer. Defaults to `2`.
  ///
  /// - [groupingSeparator] sets the character used for grouping digits (e.g., `','`, `'.'`, `' '`).
  ///   If not provided, the locale's default grouping separator will be used.
  ///
  /// - [decimalSeparator] sets the character used for the decimal point (e.g., `'.'`, `','`).
  ///   If not provided, the locale's default decimal separator will be used.
  ///
  /// - [trimTrailingZeros] if set to `true`, trailing zeros after the decimal point
  ///   will be removed. Defaults to `false`.
  ///
  /// **Example usage:**
  /// ```dart
  /// double number = 1000000.50;
  ///
  /// // Default formatting
  /// String formattedNumber = number.formatAsReadableNumber();
  /// // Output: '1,000,000.50'
  ///
  /// // Indian-style formatting with no decimals and trimmed zeros
  /// formattedNumber = number.formatAsReadableNumber(
  ///   locale: 'en_IN',
  ///   decimalDigits: 0,
  ///   trimTrailingZeros: true,
  /// );
  /// // Output: '10,00,000'
  ///
  /// // European-style formatting
  /// formattedNumber = number.formatAsReadableNumber(
  ///   locale: 'de_DE',
  ///   groupingSeparator: '.',
  ///   decimalSeparator: ',',
  /// );
  /// // Output: '1.000.000,50'
  ///
  /// // Custom separators
  /// formattedNumber = number.formatAsReadableNumber(
  ///   groupingSeparator: ' ',
  ///   decimalSeparator: ',',
  /// );
  /// // Output: '1 000 000,50'
  /// ```
  String formatAsReadableNumber({
    String? locale,
    int decimalDigits = 2,
    String? groupingSeparator,
    String? decimalSeparator,
    bool trimTrailingZeros = false,
  }) {
    // Validate input parameters
    if (decimalDigits < 0) {
      throw ArgumentError('decimalDigits must be non-negative');
    }

    // Create a NumberFormat instance with the specified locale
    final formatter = NumberFormat.decimalPattern(locale)
      // Set the maximum and minimum number of decimal digits
      ..maximumFractionDigits = decimalDigits
      ..minimumFractionDigits = trimTrailingZeros ? 0 : decimalDigits;

    // Store the default separators from the locale
    final defaultGroupingSeparator = formatter.symbols.GROUP_SEP;
    final defaultDecimalSeparator = formatter.symbols.DECIMAL_SEP;

    // Format the number
    var formatted = formatter.format(this);

    // Use a unique placeholder for the decimal separator
    const decimalPlaceholder = '{DECIMAL_PLACEHOLDER}';
    formatted =
        formatted.replaceFirst(defaultDecimalSeparator, decimalPlaceholder);

    // Replace grouping separator if a custom one is provided
    if (groupingSeparator != null && groupingSeparator.isNotEmpty) {
      formatted =
          formatted.replaceAll(defaultGroupingSeparator, groupingSeparator);
    }

    // Replace the decimal placeholder with the custom decimal separator
    if (decimalSeparator != null && decimalSeparator.isNotEmpty) {
      formatted = formatted.replaceFirst(
        decimalPlaceholder,
        decimalSeparator,
      );
    } else {
      // Replace placeholder back to default decimal separator
      formatted = formatted.replaceFirst(
        decimalPlaceholder,
        defaultDecimalSeparator,
      );
    }

    return formatted;
  }
}
