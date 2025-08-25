import 'package:dart_helper_utils/dart_helper_utils.dart';

/// extension DHUNDateFormatExtension on DateTime?
extension DHUNDateFormatExtension on DateTime? {
  /// Formats the DateTime object using the provided pattern and optional locale.
  /// respects null dates.
  String? tryFormat(String format) =>
      isNull ? null : format.dateFormat().format(this!);

  /// Formats the DateTime object in UTC using the provided pattern and optional locale.
  String? tryDateFormatUtc(String pattern, [String? locale]) =>
      isNull ? null : DateFormat(pattern, locale).format(this!.toUtc());
}

/// extension DHUDateFormatExtension on DateTime
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

/// extension DHUDateFormatStringExtension on String
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

  /// Parses this string into a `DateTime`, trying multiple formats with sensible
  /// priorities and fallbacks.
  ///
  /// **Parsing order (highest → lowest):**
  /// 1. ISO-8601 / RFC3339 via `DateTime.parse` (handles `Z` and numeric offsets).
  /// 2. HTTP-date (RFC 7231), e.g. `Tue, 11 Jun 2024 14:15:00 GMT` → treated as UTC.
  /// 3. Unix epoch: 10-digit seconds or 13-digit milliseconds since 1970-01-01 UTC.
  /// 4. Common explicit patterns after normalization (underscores → spaces, ordinals
  ///    like `1st/2nd/3rd/4th` removed). Examples it accepts:
  ///    - `yyyy-MM-dd HH:mm:ss`
  ///    - `yyyyMMdd_HHmm`, `yyyyMMdd_HHmmss`, `yyyyMMddHHmmss`, `yyyyMMdd`
  ///    - Long forms with words (locale-aware): `MMMM d, yyyy`, `MMMM d, yyyy h:mm a`,
  ///      `EEEE, MMMM d, yyyy`, etc.
  /// 5. Time-only inputs (`HH:mm`, `HH:mm:ss`, `hh:mm a`, …): interpreted as **today**
  ///    in the local timezone, then converted if `utc: true`.
  ///
  /// **Locale & ambiguity:**
  /// - If `locale` is provided (or `useCurrentLocale` is `true`), month/day names and
  ///   ambiguous numeric formats honor that locale. Specifically:
  ///   - `en_US*` prefers `MM/dd/yyyy`.
  ///   - Other locales prefer `dd/MM/yyyy`.
  /// - For non-English month/day names you must ensure
  ///   `initializeDateFormatting(<locale>)` was called before parsing.
  ///
  /// **Timezone semantics:**
  /// - If the input includes an explicit offset or `Z`, that offset is used.
  /// - Otherwise the parsed value is considered local time. If `utc` is `true`, the
  ///   result is converted to UTC before returning.
  /// - HTTP-date inputs are interpreted as UTC by spec.
  ///
  /// **Parameters:**
  /// - `locale` (optional): BCP-47/ICU locale, e.g. `en_US`, `fr_FR`.
  /// - `useCurrentLocale` (optional, default `false`): If `true` and `locale` is
  ///   `null`, uses `Intl.getCurrentLocale()` for locale-aware parsing.
  /// - `utc` (optional, default `false`): Convert the parsed `DateTime` to UTC.
  ///
  /// **Returns:** A `DateTime` representing the parsed value (possibly converted to UTC).
  ///
  /// **Throws:** `FormatException` if the string cannot be parsed by any supported strategy.
  ///
  /// **Examples:**
  /// ```dart
  /// // ISO 8601
  /// final a = "2024-06-10T10:30:00Z".toDateAutoFormat();        // 2024-06-10 10:30:00.000Z
  ///
  /// // Compact filename-style
  /// final b = "20240610_1545".toDateAutoFormat();                // 2024-06-10 15:45:00.000
  ///
  /// // HTTP-date (treated as UTC)
  /// final c = "Tue, 11 Jun 2024 14:15:00 GMT".toDateAutoFormat(utc: true);
  ///
  /// // Locale-aware long form (ordinals handled)
  /// final d = "Tuesday, June 11th, 2024 at 2:15 PM"
  ///     .toDateAutoFormat(locale: 'en_US');                      // 2024-06-11 14:15:00.000
  ///
  /// // Ambiguous numeric day/month resolved by locale
  /// final e = "02/03/2024".toDateAutoFormat(locale: 'en_GB');    // 2024-03-02
  ///
  /// // Time-only -> today
  /// final f = "14:30".toDateAutoFormat();                        // today at 14:30 (local)
  /// ```
  DateTime toDateAutoFormat({
    String? locale,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    final raw = trim();
    if (raw.isEmpty) {
      throw const FormatException('Invalid or unsupported date format', '');
    }

    final effectiveLocale =
        locale ?? (useCurrentLocale ? Intl.getCurrentLocale() : null);

    // 1) ISO/RFC3339 fast path
    try {
      final iso = DateTime.parse(raw); // handles Z/offsets or local
      return utc ? iso.toUtc() : iso;
    } catch (_) {}

    // 2) HTTP-date (RFC 7231) – always GMT/English
    final http = _tryParseHttpDate(raw);
    if (http != null) return utc ? http.toUtc() : (utc ? http.toUtc() : http);

    // 3) Unix epoch seconds / milliseconds
    final unix = _tryParseUnix(raw);
    if (unix != null) return utc ? unix.toUtc() : unix.toLocal();

    // 4) Normalize common nuisances (ordinals, underscores)
    final s = _normalize(raw);

    // 5) Format candidates
    final unambiguous = <String>[
      // common explicit forms that DateTime.parse doesn’t cover with underscores/spaces
      'yyyy-MM-dd HH:mm:ss',
      'yyyyMMdd_HHmm',
      'yyyyMMdd_HHmmss',
      'yyyyMMddHHmmss',
      'yyyyMMdd',

      // long forms with words (needs date symbols for the locale)
      "EEEE, MMMM d, yyyy 'at' h:mm a",
      'EEEE, MMMM d, yyyy',
      // day name present
      'MMMM d, yyyy h:mm a',
      'MMMM d, yyyy',
      'd MMMM yyyy HH:mm:ss',
      'd MMMM yyyy',
    ];

    // Locale-aware ambiguity preference
    final isUS =
        (effectiveLocale ?? Intl.getCurrentLocale()).startsWith('en_US');
    final ambiguous = isUS
        ? <String>[
            'MM/dd/yyyy HH:mm:ss',
            'MM/dd/yyyy',
            'dd/MM/yyyy HH:mm:ss',
            'dd/MM/yyyy',
          ]
        : <String>[
            'dd/MM/yyyy HH:mm:ss',
            'dd/MM/yyyy',
            'MM/dd/yyyy HH:mm:ss',
            'MM/dd/yyyy',
          ];

    // Time-only -> default to "today"
    final timeOnly = <String>[
      'HH:mm:ss',
      'HH:mm',
      'hh:mm:ss a',
      'hh:mm a',
    ];

    // Try date-bearing formats first
    for (final fmt in [...unambiguous, ...ambiguous]) {
      final dt = _tryParseWith(fmt, s, effectiveLocale);
      if (dt != null) return utc ? dt.toUtc() : dt;
    }

    // Then time-only formats -> today
    for (final fmt in timeOnly) {
      final dt = _tryParseWith(fmt, s, effectiveLocale);
      if (dt != null) {
        final now = DateTime.now();
        final today = DateTime(
          now.year,
          now.month,
          now.day,
          dt.hour,
          dt.minute,
          dt.second,
          dt.millisecond,
          dt.microsecond,
        );
        return utc ? today.toUtc() : today;
      }
    }

    throw FormatException('Invalid or unsupported date format', raw);
  }

  DateTime? _tryParseWith(String pattern, String input, String? locale) {
    try {
      final df = DateFormat(pattern, locale);
      return df.parseStrict(input);
    } catch (_) {
      return null;
    }
  }

// RFC 7231 HTTP-date variants
  DateTime? _tryParseHttpDate(String s) {
    // IMF-fixdate (required), plus common legacy forms
    const patterns = <String>[
      "EEE, dd MMM yyyy HH:mm:ss 'GMT'", // e.g., Tue, 15 Nov 1994 08:12:31 GMT
      "EEEE, dd-MMM-yy HH:mm:ss 'GMT'", // obsolete RFC 850
      'EEE MMM d HH:mm:ss yyyy', // ANSI C asctime()
    ];
    for (final p in patterns) {
      try {
        final dt = DateFormat(p, 'en_US').parseStrict(s);
        // First two are explicitly GMT; third is nominally local—treat as UTC to be safe.
        return DateTime.utc(dt.year, dt.month, dt.day, dt.hour, dt.minute,
            dt.second, dt.millisecond, dt.microsecond);
      } catch (_) {}
    }
    return null;
  }

  DateTime? _tryParseUnix(String s) {
    final digits = RegExp(r'^\d{10}$'); // seconds
    final digitsMs = RegExp(r'^\d{13}$'); // milliseconds
    if (digits.hasMatch(s)) {
      final ms = int.parse(s) * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    }
    if (digitsMs.hasMatch(s)) {
      final ms = int.parse(s);
      return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    }
    return null;
  }

  String _normalize(String s) {
    var out = s.trim();

    // Collapse underscores to spaces (common in filenames)
    out = out.replaceAll('_', ' ');

    // Drop ordinal suffixes: 1st, 2nd, 3rd, 4th, ...
    out = out.replaceAll(
        RegExp(r'(\b\d{1,2})(st|nd|rd|th)\b', caseSensitive: false), r'$1');

    // Normalize multiple spaces
    out = out.replaceAll(RegExp(r'\s+'), ' ');

    return out;
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

/// extension DHUDateFormatNStringExtension on String?
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
