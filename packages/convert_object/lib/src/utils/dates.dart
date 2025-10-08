import 'package:intl/intl.dart';

extension DateParsingStringX on String {
  DateTime toDateTime() => DateTime.parse(trim());

  DateTime? tryToDateTime() {
    try {
      return toDateTime();
    } catch (_) {
      return null;
    }
  }

  DateTime toDateFormatted(String format, String? locale, {bool utc = false}) {
    final df = DateFormat(format, locale);
    final dt = df.parse(this, true); // parse as UTC
    return utc ? dt.toUtc() : dt.toLocal();
  }

  DateTime? tryToDateFormatted(String format, String? locale,
      {bool utc = false}) {
    try {
      return toDateFormatted(format, locale, utc: utc);
    } catch (_) {
      return null;
    }
  }

  /// Parses this string into a `DateTime` using multiple strategies.
  ///
  /// Parsing order (highest → lowest):
  /// 1) ISO-8601 / RFC3339 via `DateTime.parse` (handles `Z` and numeric offsets).
  /// 2) HTTP-date (IMF-fixdate), e.g. `Tue, 11 Jun 2024 14:15:00 GMT` → UTC.
  /// 3) Unix epoch seconds (10 digits) or milliseconds (13 digits).
  /// 4) Common explicit patterns after normalization (underscores→spaces, ordinals removed).
  /// 5) Time-only inputs interpreted as today (local), then optionally converted to UTC.
  DateTime toDateAutoFormat({
    String? locale,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    final raw = trim();
    if (raw.isEmpty) {
      throw const FormatException('Invalid or unsupported date format', '');
    }

    // Resolve effective locale for ambiguous names/patterns
    final effectiveLocale = locale ?? (useCurrentLocale ? Intl.getCurrentLocale() : null);

    // 1) ISO/RFC3339 fast path
    try {
      final iso = DateTime.parse(raw); // if no offset, parsed as local
      return utc ? iso.toUtc() : iso;
    } catch (_) {}

    // 2) HTTP-date (RFC 7231 IMF-fixdate)
    final http = _tryParseHttpDate(raw);
    if (http != null) return utc ? http.toUtc() : http;

    // 3) Unix epoch seconds / milliseconds
    final unix = _tryParseUnix(raw);
    if (unix != null) return utc ? unix.toUtc() : unix.toLocal();

    // 4) Normalize nuisances (ordinals, underscores)
    final s = _normalize(raw);

    // 5) Format candidates
    final unambiguous = <String>[
      'yyyy-MM-dd HH:mm:ss',
      'yyyyMMdd_HHmm',
      'yyyyMMdd_HHmmss',
      'yyyyMMddHHmmss',
      'yyyyMMdd',

      // long forms (English; other locales require initialized date symbols)
      "EEEE, MMMM d, yyyy 'at' h:mm a",
      'EEEE, MMMM d, yyyy',
      'MMMM d, yyyy h:mm a',
      'MMMM d, yyyy',
      'd MMMM yyyy HH:mm:ss',
      'd MMMM yyyy',
    ];

    // Ambiguous numeric preference based on locale
    final isUS = (effectiveLocale ?? Intl.getCurrentLocale()).startsWith('en_US');
    final ambiguous = isUS
        ? <String>['MM/dd/yyyy HH:mm:ss', 'MM/dd/yyyy', 'dd/MM/yyyy HH:mm:ss', 'dd/MM/yyyy']
        : <String>['dd/MM/yyyy HH:mm:ss', 'dd/MM/yyyy', 'MM/dd/yyyy HH:mm:ss', 'MM/dd/yyyy'];

    // Try date-bearing formats first
    for (final fmt in [...unambiguous, ...ambiguous]) {
      final dt = _tryParseWith(fmt, s, effectiveLocale);
      if (dt != null) return utc ? dt.toUtc() : dt;
    }

    // Time-only formats → today
    for (final fmt in ['HH:mm:ss', 'HH:mm', 'hh:mm:ss a', 'hh:mm a']) {
      final t = _tryParseWith(fmt, s, effectiveLocale);
      if (t != null) {
        final now = DateTime.now();
        final today = DateTime(
          now.year,
          now.month,
          now.day,
          t.hour,
          t.minute,
          t.second,
          t.millisecond,
          t.microsecond,
        );
        return utc ? today.toUtc() : today;
      }
    }

    throw FormatException('Invalid or unsupported date format', raw);
  }

  DateTime? tryToDateAutoFormat({
    String? locale,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    try {
      return toDateAutoFormat(
        locale: locale,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
      );
    } catch (_) {
      return null;
    }
  }
}

// --- Helpers ---------------------------------------------------------------

DateTime? _tryParseHttpDate(String s) {
  // IMF-fixdate: EEE, dd MMM yyyy HH:mm:ss GMT
  try {
    final f = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
    // Parse as UTC-like; DateFormat returns local, but string is GMT
    final dt = f.parseUtc(s);
    return dt.toUtc();
  } catch (_) {
    return null;
  }
}

DateTime? _tryParseUnix(String s) {
  final digits = RegExp(r'^\d{10}(?:\d{3})?$');
  if (!digits.hasMatch(s)) return null;
  try {
    final n = int.parse(s);
    final ms = s.length == 13 ? n : n * 1000;
    return DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  } catch (_) {
    return null;
  }
}

String _normalize(String s) {
  var out = s.replaceAll('_', ' ');
  // Remove English ordinals: 1st, 2nd, 3rd, 4th, ...
  out = out.replaceAll(RegExp(r'\b(\d+)(st|nd|rd|th)\b', caseSensitive: false), r'$1');
  return out.trim();
}

DateTime? _tryParseWith(String fmt, String s, String? locale) {
  try {
    final f = DateFormat(fmt, locale);
    return f.parse(s);
  } catch (_) {
    return null;
  }
}
