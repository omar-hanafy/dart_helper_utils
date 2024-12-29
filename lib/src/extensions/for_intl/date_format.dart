import 'package:dart_helper_utils/dart_helper_utils.dart';

extension DHUNDateFormatExtension on DateTime? {
  /// Formats the DateTime object using the provided pattern and optional locale.
  /// respects null dates.
  String? tryFormat(String format) =>
      isNull ? null : format.dateFormat().format(this!);

  /// Formats the DateTime object in UTC using the provided pattern and optional locale.
  String? tryDateFormatUtc(String pattern, [String? locale]) =>
      isNull ? null : DateFormat(pattern, locale).format(this!.toUtc());
}

extension DHUDateFormatExtension on DateTime {
  /// Formats the DateTime object using the provided pattern and optional locale.
  String format(String pattern, [String? locale]) =>
      DateFormat(pattern, locale).format(this);

  /// Formats the DateTime object in UTC using the provided pattern and optional locale.
  String dateFormatUtc(String pattern, [String? locale]) =>
      DateFormat(pattern, locale).format(toUtc());

  /// Formats the DateTime object using the yMMMMd format and optional locale.
  String formatAsyMMMMd([String? locale]) =>
      DateFormat.yMMMMd(locale).format(this);

  /// Formats the DateTime object using the EEEE format and optional locale.
  String formatAsEEEE([String? locale]) => DateFormat.EEEE(locale).format(this);

  /// Formats the DateTime object using the EEEEE format and optional locale.
  String formatAsEEEEE([String? locale]) =>
      DateFormat.EEEEE(locale).format(this);

  /// Formats the DateTime object using the LLL format and optional locale.
  String formatAsLLL([String? locale]) => DateFormat.LLL(locale).format(this);

  /// Formats the DateTime object using the LLLL format and optional locale.
  String formatAsLLLL([String? locale]) => DateFormat.LLLL(locale).format(this);

  /// Formats the DateTime object using the M format and optional locale.
  String formatAsM([String? locale]) => DateFormat.M(locale).format(this);

  /// Formats the DateTime object using the Md format and optional locale.
  String formatAsMd([String? locale]) => DateFormat.Md(locale).format(this);

  /// Formats the DateTime object using the MEd format and optional locale.
  String formatAsMEd([String? locale]) => DateFormat.MEd(locale).format(this);

  /// Formats the DateTime object using the MMM format and optional locale.
  String formatAsMMM([String? locale]) => DateFormat.MMM(locale).format(this);

  /// Formats the DateTime object using the MMMd format and optional locale.
  String formatAsMMMd([String? locale]) => DateFormat.MMMd(locale).format(this);

  /// Formats the DateTime object using the MMMEd format and optional locale.
  String formatAsMMMEd([String? locale]) =>
      DateFormat.MMMEd(locale).format(this);

  /// Formats the DateTime object using the MMMM format and optional locale.
  String formatAsMMMM([String? locale]) => DateFormat.MMMM(locale).format(this);

  /// Formats the DateTime object using the MMMMd format and optional locale.
  String formatAsMMMMd([String? locale]) =>
      DateFormat.MMMMd(locale).format(this);

  /// Formats the DateTime object using the MMMMEEEEd format and optional locale.
  String formatAsMMMMEEEEd([String? locale]) =>
      DateFormat.MMMMEEEEd(locale).format(this);

  /// Formats the DateTime object using the QQQ format and optional locale.
  String formatAsQQQ([String? locale]) => DateFormat.QQQ(locale).format(this);

  /// Formats the DateTime object using the QQQQ format and optional locale.
  String formatAsQQQQ([String? locale]) => DateFormat.QQQQ(locale).format(this);

  /// Formats the DateTime object using the yM format and optional locale.
  String formatAsyM([String? locale]) => DateFormat.yM(locale).format(this);

  /// Formats the DateTime object using the yMd format and optional locale.
  String formatAsyMd([String? locale]) => DateFormat.yMd(locale).format(this);

  /// Formats the DateTime object using the yMEd format and optional locale.
  String formatAsyMEd([String? locale]) => DateFormat.yMEd(locale).format(this);

  /// Formats the DateTime object using the yMMM format and optional locale.
  String formatAsyMMM([String? locale]) => DateFormat.yMMM(locale).format(this);

  /// Formats the DateTime object using the yMMMd format and optional locale.
  String formatAsyMMMd([String? locale]) =>
      DateFormat.yMMMd(locale).format(this);

  /// Formats the DateTime object using the yMMMEd format and optional locale.
  String formatAsyMMMEd([String? locale]) =>
      DateFormat.yMMMEd(locale).format(this);

  /// Formats the DateTime object using the yMMMM format and optional locale.
  String formatAsyMMMM([String? locale]) =>
      DateFormat.yMMMM(locale).format(this);

  /// Formats the DateTime object using the yMMMMEEEEd format and optional locale.
  String formatAsyMMMMEEEEd([String? locale]) =>
      DateFormat.yMMMMEEEEd(locale).format(this);

  /// Formats the DateTime object using the yQQQ format and optional locale.
  String formatASyQQQ([String? locale]) => DateFormat.yQQQ(locale).format(this);

  /// Formats the DateTime object using the yQQQQ format and optional locale.
  String formatAsyQQQQ([String? locale]) =>
      DateFormat.yQQQQ(locale).format(this);

  /// Formats the DateTime object using the H format and optional locale.
  String formatAsH([String? locale]) => DateFormat.H(locale).format(this);

  /// Formats the DateTime object using the Hm format and optional locale.
  String formatAsHm([String? locale]) => DateFormat.Hm(locale).format(this);

  /// Formats the DateTime object using the Hms format and optional locale.
  String formatAsHms([String? locale]) => DateFormat.Hms(locale).format(this);
}

extension DHUDateFormatStringExtension on String {
  /// Parses a date string in either of the formats RFC-1123, RFC-850, or ANSI C's asctime().
  ///
  /// - **RFC-1123**: Commonly used in HTTP headers. Example: `Thu, 30 Aug 2024 12:00:00 GMT`.
  /// - **RFC-850**: An older format, less commonly used today. Example: `Thursday, 30-Aug-24 12:00:00 GMT`.
  /// - **ANSI C's `asctime()`**: A format used by the C programming language's standard library. Example: `Thu Aug 30 12:00:00 2024`.
  ///
  ///  Usage:
  /// ```dart
  /// String rfc1123Date = "Thu, 30 Aug 2024 12:00:00 GMT";
  /// DateTime? parsedDate = rfc1123Date.parseHttpDate();
  /// print(parsedDate?.toIso8601String()); // Outputs: 2024-08-30T12:00:00.000Z
  ///
  /// String asctimeDate = "Thu Aug 30 12:00:00 2024";
  /// DateTime? parsedDate2 = asctimeDate.parseHttpDate();
  /// print(parsedDate2?.toIso8601String()); // Outputs: 2024-08-30T12:00:00.000Z or null if parsing fails
  /// ```
  ///
  /// This method tries to parse the date string using the appropriate format. If parsing fails,
  /// it returns `null` instead of throwing an exception.
  DateTime? parseHttpDate([bool utc = false]) {
    final formats = [
      DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US'), // RFC-1123
      DateFormat("EEEE, dd-MMM-yy HH:mm:ss 'GMT'", 'en_US'), // RFC-850
      DateFormat('EEE MMM d HH:mm:ss yyyy', 'en_US'), // ANSI C's asctime()
    ];

    for (final format in formats) {
      try {
        return utc ? format.parseUtc(this) : format.parse(this);
      } catch (_) {
        // Continue to the next format if parsing fails.
      }
    }

    return null;
  }

  /// Parses a date-time string into a `DateTime` object, automatically trying
  /// various formats to handle diverse inputs.
  ///
  /// This function intelligently handles a wide range of date and time formats,
  /// from ISO 8601 to more casual expressions. It prioritizes formats that are
  /// less ambiguous (e.g., 'yyyy-MM-dd') over those that might vary by locale or
  /// interpretation (e.g., 'MM/dd/yyyy').
  ///
  /// **Parameters:**
  ///
  /// - `locale` (optional): A locale string (e.g., 'en_US') to customize the
  ///    parsing behavior for region-specific formats. If `null`, uses the default
  ///    locale or the current locale if `useCurrentLocale` is true.
  /// - `useCurrentLocale` (optional, default: `false`): If `true` and `locale` is
  ///    null, the current system locale will be used.
  /// - `utc` (optional, default: `false`): If `true`, the returned `DateTime`
  ///    object will be in UTC timezone. Otherwise, it will be in the local timezone.
  ///
  /// **Returns:**
  ///
  /// - A `DateTime` object representing the parsed date and time.
  ///
  /// **Exceptions:**
  ///
  /// - Throws a `FormatException` if the input string cannot be parsed successfully
  ///   using any of the supported formats.
  ///
  /// **Example Usage:**
  ///
  /// ```dart
  /// // Simple ISO 8601
  /// DateTime date1 = "2024-06-10T10:30:00Z".toDateAutoFormat();
  /// print(date1); // 2024-06-10 10:30:00.000Z
  ///
  /// // Compact file name format
  /// DateTime date2 = "20240610_1545".toDateAutoFormat();
  /// print(date2); // 2024-06-10 15:45:00.000
  ///
  /// // Casual format with locale
  /// DateTime date3 = "Tuesday, June 11th, 2024 at 2:15 PM".toDateAutoFormat(locale: 'en_US');
  /// print(date3); // 2024-06-11 14:15:00.000
  /// ```
  DateTime toDateAutoFormat({
    String? locale,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    // Determine the locale to use
    final effectiveLocale =
        locale ?? (useCurrentLocale ? Intl.getCurrentLocale() : null);

    // 2. Common Format Parsing (without explicit format)
    try {
      final parsedDate = DateTime.parse(
        this,
      ); // ISO 8601 (with or without time, 'Z' or offset)
      return utc ? parsedDate.toUtc() : parsedDate;
    } catch (_) {}

    final httpDate = parseHttpDate(utc);
    if (httpDate != null) return httpDate;

    final formats = {
      // ISO 8601-like (most standard, unambiguous)
      'yyyy-MM-ddTHH:mm:ss.SSSZ',
      'yyyy-MM-ddTHH:mm:ssZ',
      'yyyy-MM-dd HH:mm:ss',
      "EEEE, MMMM d'th', yyyy 'at' h:mm a",
      "EEEE, MMMM d'th', yyyy 'at' h:mm",
      "EEEE, MMMM d'th', yyyy",

      // Unambiguous Month and Day Formats
      'MMMM d, yyyy HH:mm:ss',
      'd MMMM yyyy HH:mm:ss',
      'MMMM d, yyyy',
      'd MMMM yyyy',
      'DAY, DD MON YYYY hh:mm:ss GMT',

      // Compact (often used in file names)
      'yyyyMMddHHmmss',
      'yyyyMMdd',

      // Other Unambiguous Formats
      'EEEE, MMMM d, yyyy',
      'EEEE d MMMM yyyy',
      'MMMM d, yyyy h:mm a',
      'dd/MM/yyyy HH:mm Z',

      // Potentially Ambiguous Formats (place these lower in the list)
      'ddMMyyyy HH:mm:ss',
      'ddMMyyyy',
      'MM/dd/yyyy HH:mm:ss',
      'dd/MM/yyyy HH:mm:ss',
      'MM/dd/yyyy',
      'dd/MM/yyyy',

      // Time Only
      'HH:mm:ss',
      'hh:mm:ss a',
      'HH:mm',
      'hh:mm a',

      // Individual Components (least specific)
      'yyyy',
      'MM',
      'MMM',
      'MMMM',
      'dd',
      'EEEE',
      'EEE',
    };

    for (final format in formats) {
      try {
        final parsedDate =
            DateFormat(format, effectiveLocale).parseStrict(this);
        return utc ? parsedDate.toUtc() : parsedDate;
      } catch (_) {}
    }

    throw FormatException('Invalid or unsupported date format', this);
  }

  /// Parses the string to [DateTime] using the provided format, locale, and UTC option.
  DateTime toDateFormatted([
    String? format,
    String? locale,
    bool utc = false,
  ]) =>
      DateFormat(format, locale).parse(this, utc);

  /// Parses the string to [DateTime] using the provided format, locale, and UTC option, with loose parsing.
  DateTime toDateFormattedLoose([
    String? format,
    String? locale,
    bool utc = false,
  ]) =>
      DateFormat(format, locale).parseLoose(this, utc);

  /// Parses the string to [DateTime] using the provided format, locale, and UTC option, with strict parsing.
  DateTime toDateFormattedStrict([
    String? format,
    String? locale,
    bool utc = false,
  ]) =>
      DateFormat(format, locale).parseStrict(this, utc);

  /// Parses the string to [DateTime] in UTC using the provided format and locale.
  DateTime toDateFormattedUtc([
    String? format,
    String? locale,
  ]) =>
      DateFormat(format, locale).parseUtc(this);
}

extension DHUDateFormatNStringExtension on String? {
  /// Creates a DateFormat object using the string as the pattern and optional locale.
  DateFormat dateFormat([String? locale]) => DateFormat(this, locale);

  /// uses the original `toDateFormatted] but returns null on any errors.
  DateTime? tryToDateAutoFormat({
    String? locale,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    if (isBlank) return null;
    try {
      this!.toDateAutoFormat(
        locale: locale,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
      );
    } catch (_) {}
    return null;
  }

  /// Attempts to parse the nullable string to [DateTime] using the provided format, locale, and UTC option.
  DateTime? tryToDateFormatted([
    String? format,
    String? locale,
    bool utc = false,
  ]) =>
      isBlank ? null : DateFormat(format, locale).tryParse(this!, utc);

  /// Attempts to parse the nullable string to [DateTime] using the provided format, locale, and UTC option, with loose parsing.
  DateTime? tryToDateFormattedLoose([
    String? format,
    String? locale,
    bool utc = false,
  ]) =>
      isBlank ? null : DateFormat(format, locale).tryParseLoose(this!, utc);

  /// Attempts to parse the nullable string to [DateTime] using the provided format, locale, and UTC option, with strict parsing.
  DateTime? tryToDateFormattedStrict([
    String? format,
    String? locale,
    bool utc = false,
  ]) =>
      isBlank ? null : DateFormat(format, locale).tryParseStrict(this!, utc);

  /// Attempts to parse the nullable string to [DateTime] in UTC using the provided format and locale.
  DateTime? tryToDateFormattedUtc([
    String? format,
    String? locale,
  ]) =>
      isBlank ? null : DateFormat(format, locale).tryParseUtc(this!);

  /// Checks if the locale exists in DateFormat.
  bool get localeExists => DateFormat.localeExists(this);
}
