import 'package:dart_helper_utils/dart_helper_utils.dart';

/// extension DHUNDateFormatExtension on DateTime?
extension DHUNDateFormatExtension on DateTime? {
  /// Formats the DateTime object using the provided pattern and optional locale.
  /// respects null dates.
  String? tryFormat(String format) =>
      this == null ? null : format.dateFormat().format(this!);

  /// Formats the DateTime object in UTC using the provided pattern and optional locale.
  String? tryDateFormatUtc(String pattern, [String? locale]) =>
      this == null ? null : DateFormat(pattern, locale).format(this!.toUtc());
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

/// extension DHUDateFormatNStringExtension on String?
extension DHUDateFormatNStringExtension on String? {
  /// Creates a DateFormat object using the string as the pattern and optional locale.
  DateFormat dateFormat([String? locale]) => DateFormat(this, locale);
}
