import 'dart:io';

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
  DateTime toDateFormatted({
    String? format,
    String? locale,
    bool autoDetectFormat = true,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    // Determine the locale to use
    final effectiveLocale =
        locale ?? (useCurrentLocale ? Intl.getCurrentLocale() : null);

    // 1. Explicit Format Parsing (if provided)
    if (format != null) {
      try {
        final parsedDate = DateFormat(format, effectiveLocale).parse(this);
        return utc ? parsedDate.toUtc() : parsedDate;
      } catch (_) {}
    }

    // 2. Common Format Parsing (without explicit format)
    try {
      final parsedDate = DateTime.parse(
          this); // ISO 8601 (with or without time, 'Z' or offset)
      return utc ? parsedDate.toUtc() : parsedDate;
    } catch (_) {}

    try {
      final parsedDate = HttpDate.parse(this); // Requires 'dart:io' import
      return utc ? parsedDate.toUtc() : parsedDate;
    } catch (_) {}

    if (!autoDetectFormat) throw FormatException('Invalid date format', this);

    final formats = [
      // Most Common Formats First
      'yyyy-MM-dd HH:mm:ss', // ISO 8601-like (but without 'T' separator)
      'yyyy/MM/dd HH:mm:ss',
      'MM/dd/yyyy HH:mm:ss',

      // Variations with Hyphens/Slashes/Dots
      'yyyy-MM-dd',
      'yyyy/MM/dd',
      'MM-dd-yyyy',
      'MM/dd/yyyy',
      'yyyy.MM.dd',
      'MM.dd.yyyy',

      // Date Only (Different Ordering)
      'dd-MM-yyyy',
      'dd/MM/yyyy',

      // Compact Formats
      'yyyyMMddHHmmss', // YYYYMMDDHHmmss
      'yyyyMMdd', // YYYYMMDD
      'ddMMyyyy HH:mm:ss', // DDMMYYYYHHmmss
      'ddMMyyyy', // DDMMYYYY

      // With Full Month Name
      'MMMM d, yyyy HH:mm:ss', // April 23, 1999 14:30:00
      'MMMM d, yyyy', // April 23, 1999

      // Time Only
      'HH:mm:ss', // 24-hour format with seconds
      'hh:mm:ss a', // 12-hour format with AM/PM and seconds
      'HH:mm', // 24-hour format without seconds
      'hh:mm a', // 12-hour format without seconds

      // Additional ISO 8601
      'yyyy-MM-ddTHH:mm:ss.SSSZ', // With milliseconds and timezone 'Z'
    ];

    for (final format in formats) {
      try {
        final parsedDate = DateFormat(format, effectiveLocale).parse(this);
        return utc ? parsedDate.toUtc() : parsedDate;
      } catch (_) {}
    }

    // 4. Regex Parsing with Locale and UTC Handling
    final match = RegExp(
            r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})(?:\s+(\d{1,2}):(\d{1,2}):(\d{1,2}))?(?:\s*([+\-]\d{2}:\d{2})?)?')
        .firstMatch(this);

    if (match != null) {
      final year = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final day = int.parse(match.group(3)!);
      final hour = match.group(4) != null ? int.parse(match.group(4)!) : 0;
      final minute = match.group(5) != null ? int.parse(match.group(5)!) : 0;
      final second = match.group(6) != null ? int.parse(match.group(6)!) : 0;
      final offset =
          match.group(7) != null ? _parseTimeZoneOffset(match.group(7)!) : null;

      return offset != null
          ? DateTime(year, month, day, hour, minute, second).toUtc().add(offset)
          : DateTime(year, month, day, hour, minute, second);
    }

    throw FormatException('Invalid date format', this);
  }

  Duration? _parseTimeZoneOffset(String offsetString) {
    final match = RegExp(r'([+\-])(\d{2}):(\d{2})').firstMatch(offsetString);
    if (match != null) {
      final isNegative = match.group(1) == '-';
      final hours = int.parse(match.group(2)!);
      final minutes = int.parse(match.group(3)!);
      return Duration(hours: hours, minutes: minutes) * (isNegative ? -1 : 1);
    }
    return null;
  }

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

  /// Attempts to parse the nullable string to [DateTime] using the provided format, locale, and UTC option.
  DateTime? tryToDateFormatted({
    String? format,
    String? locale,
    bool autoDetectFormat = true,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    if (isBlank) return null;
    try {
      this!.toDateFormatted(
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
      );
    } catch (_) {}
    return null;
  }

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
