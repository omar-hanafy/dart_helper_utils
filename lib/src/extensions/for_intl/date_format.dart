import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:intl/intl.dart';

extension DHUNDateFormatExtension on DateTime? {
  String? tryFormat(String format) =>
      isNull ? null : format.dateFormat().format(this!);
}

extension DHUDateFormatExtension on DateTime {
  /// Formats the DateTime object using the provided pattern and optional locale.
  String format(String pattern, [String? locale]) =>
      DateFormat(pattern, locale).format(this);

  String? tryFormat(String format) =>
      isNull ? null : format.dateFormat().format(this);

  /// Formats the DateTime object in UTC using the provided pattern and optional locale.
  String dateFormatUtc(String pattern, [String? locale]) =>
      DateFormat(pattern, locale).format(toUtc());

  /// Formats the DateTime object using the yMMMMd format and optional locale.
  String yMMMMdFormat([String? locale]) =>
      DateFormat.yMMMMd(locale).format(this);

  /// Formats the DateTime object using the d format and optional locale.
  String d_Format([String? locale]) => DateFormat.d(locale).format(this);

  /// Formats the DateTime object using the E format and optional locale.
  String E_Format([String? locale]) => DateFormat.E(locale).format(this);

  /// Formats the DateTime object using the EEEE format and optional locale.
  String EEEE_Format([String? locale]) => DateFormat.EEEE(locale).format(this);

  /// Formats the DateTime object using the EEEEE format and optional locale.
  String EEEEE_Format([String? locale]) =>
      DateFormat.EEEEE(locale).format(this);

  /// Formats the DateTime object using the LLL format and optional locale.
  String LLL_Format([String? locale]) => DateFormat.LLL(locale).format(this);

  /// Formats the DateTime object using the LLLL format and optional locale.
  String LLLL_Format([String? locale]) => DateFormat.LLLL(locale).format(this);

  /// Formats the DateTime object using the M format and optional locale.
  String M_Format([String? locale]) => DateFormat.M(locale).format(this);

  /// Formats the DateTime object using the Md format and optional locale.
  String Md_Format([String? locale]) => DateFormat.Md(locale).format(this);

  /// Formats the DateTime object using the MEd format and optional locale.
  String MEd_Format([String? locale]) => DateFormat.MEd(locale).format(this);

  /// Formats the DateTime object using the MMM format and optional locale.
  String MMM_Format([String? locale]) => DateFormat.MMM(locale).format(this);

  /// Formats the DateTime object using the MMMd format and optional locale.
  String MMMd_Format([String? locale]) => DateFormat.MMMd(locale).format(this);

  /// Formats the DateTime object using the MMMEd format and optional locale.
  String MMMEd_Format([String? locale]) =>
      DateFormat.MMMEd(locale).format(this);

  /// Formats the DateTime object using the MMMM format and optional locale.
  String MMMM_Format([String? locale]) => DateFormat.MMMM(locale).format(this);

  /// Formats the DateTime object using the MMMMd format and optional locale.
  String MMMMd_Format([String? locale]) =>
      DateFormat.MMMMd(locale).format(this);

  /// Formats the DateTime object using the MMMMEEEEd format and optional locale.
  String MMMMEEEEd_Format([String? locale]) =>
      DateFormat.MMMMEEEEd(locale).format(this);

  /// Formats the DateTime object using the QQQ format and optional locale.
  String QQQ_Format([String? locale]) => DateFormat.QQQ(locale).format(this);

  /// Formats the DateTime object using the QQQQ format and optional locale.
  String QQQQ_Format([String? locale]) => DateFormat.QQQQ(locale).format(this);

  /// Formats the DateTime object using the y format and optional locale.
  String y_Format([String? locale]) => DateFormat.y(locale).format(this);

  /// Formats the DateTime object using the yM format and optional locale.
  String yM_Format([String? locale]) => DateFormat.yM(locale).format(this);

  /// Formats the DateTime object using the yMd format and optional locale.
  String yMd_Format([String? locale]) => DateFormat.yMd(locale).format(this);

  /// Formats the DateTime object using the yMEd format and optional locale.
  String yMEd_Format([String? locale]) => DateFormat.yMEd(locale).format(this);

  /// Formats the DateTime object using the yMMM format and optional locale.
  String yMMM_Format([String? locale]) => DateFormat.yMMM(locale).format(this);

  /// Formats the DateTime object using the yMMMd format and optional locale.
  String yMMMd_Format([String? locale]) =>
      DateFormat.yMMMd(locale).format(this);

  /// Formats the DateTime object using the yMMMEd format and optional locale.
  String yMMMEd_Format([String? locale]) =>
      DateFormat.yMMMEd(locale).format(this);

  /// Formats the DateTime object using the yMMMM format and optional locale.
  String yMMMM_Format([String? locale]) =>
      DateFormat.yMMMM(locale).format(this);

  /// Formats the DateTime object using the yMMMMd format and optional locale.
  String yMMMMd_Format([String? locale]) =>
      DateFormat.yMMMMd(locale).format(this);

  /// Formats the DateTime object using the yMMMMEEEEd format and optional locale.
  String yMMMMEEEEd_Format([String? locale]) =>
      DateFormat.yMMMMEEEEd(locale).format(this);

  /// Formats the DateTime object using the yQQQ format and optional locale.
  String yQQQ_Format([String? locale]) => DateFormat.yQQQ(locale).format(this);

  /// Formats the DateTime object using the yQQQQ format and optional locale.
  String yQQQQ_Format([String? locale]) =>
      DateFormat.yQQQQ(locale).format(this);

  /// Formats the DateTime object using the H format and optional locale.
  String H_Format([String? locale]) => DateFormat.H(locale).format(this);

  /// Formats the DateTime object using the Hm format and optional locale.
  String Hm_Format([String? locale]) => DateFormat.Hm(locale).format(this);

  /// Formats the DateTime object using the Hms format and optional locale.
  String Hms_Format([String? locale]) => DateFormat.Hms(locale).format(this);

  /// Formats the DateTime object using the j format and optional locale.
  String j_Format([String? locale]) => DateFormat.j(locale).format(this);

  /// Formats the DateTime object using the jm format and optional locale.
  String jm_Format([String? locale]) => DateFormat.jm(locale).format(this);

  /// Formats the DateTime object using the jms format and optional locale.
  String jms_Format([String? locale]) => DateFormat.jms(locale).format(this);
}

extension DHUDateFormatStringExtension on String {
  /// Creates a DateFormat object using the string as the pattern and optional locale.
  DateFormat dateFormat([String? locale]) => DateFormat(this, locale);

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
