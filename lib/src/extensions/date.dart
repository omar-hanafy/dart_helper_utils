import 'dart:io';

import 'package:dart_helper_utils/dart_helper_utils.dart';

int get millisecondsSinceEpochNow => DateTime.now().millisecondsSinceEpoch;

extension DHUDateString on String {
  /// Parse string to [DateTime] using null Safety
  DateTime get toDateTime => DateTime.parse(this);

  DateTime get timestampToDate => this.toInt.timestampToDate;
}

extension DHUDateNullString on String? {
  DateTime? get tryToDateTime {
    if (isBlank) return null;
    try {
      return DateTime.tryParse(this!);
    } catch (_) {}
    return null;
  }

  DateTime? get tryTimestampToDate {
    if (isBlank) return null;
    try {
      this.toInt.timestampToDate;
    } catch (_) {}
    return null;
  }
}

extension NumberToDateUtils on num {
  /// Gets the full month name (e.g., "January") corresponding to this number (1-12).
  ///
  /// Example:
  /// ```dart
  /// 1.toFullMonthName; // Returns "January"
  /// 12.toFullMonthName; // Returns "December"
  /// ```
  /// If the number is outside the range 1-12, it will be clamped within this range.
  String get toFullMonthName {
    final monthIndex = this.toInt().clamp(1, 12) - 1;
    return [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ][monthIndex];
  }

  /// Gets the full day name (e.g., "Monday") corresponding to this number (1-7).
  ///
  /// This method follows ISO 8601, where the week starts on Monday (1) and ends on Sunday (7).
  ///
  /// Example:
  /// ```dart
  /// 1.toFullDayName; // Returns "Monday"
  /// 7.toFullDayName; // Returns "Sunday"
  /// ```
  /// If the number is outside the range 1-7, it will be normalized within this range using modulo arithmetic.
  String get toFullDayName {
    final dayIndex = (this.toInt() - 1) % 7; // Ensure value is within 0-6
    return [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ][dayIndex];
  }

  /// Gets the short day name (e.g., "Mon") corresponding to this number (1-7).
  ///
  /// Example:
  /// ```dart
  /// 1.toSmallDayName; // Returns "Mon"
  /// 7.toSmallDayName; // Returns "Sun"
  /// ```
  /// If the number is outside the range 1-7, it will be normalized within this range using modulo arithmetic.
  String get toSmallDayName => toFullDayName.substring(0, 3);

  /// Gets the short month name (e.g., "Jan") corresponding to this number (1-12).
  ///
  /// Example:
  /// ```dart
  /// 1.toSmallMonthName; // Returns "Jan"
  /// 12.toSmallMonthName; // Returns "Dec"
  /// ```
  /// If the number is outside the range 1-12, it will be clamped within this range.
  String get toSmallMonthName => toFullMonthName.substring(0, 3);

  /// Converts a numeric timestamp (in milliseconds since epoch) to a DateTime object.
  ///
  /// Example:
  /// ```dart
  /// 1609459200000.timestampToDate; // Returns DateTime for 2021-01-01 00:00:00.000
  /// ```
  DateTime get timestampToDate =>
      DateTime.fromMillisecondsSinceEpoch(this.toInt());

  /// Checks if the number (assumed to represent a month, 1-based) is within the specified range of months.
  ///
  /// This method handles ranges that cross the year boundary (e.g., December to February).
  ///
  /// Example:
  /// ```dart
  /// 3.isBetweenMonths(12, 2); // Returns true, March is within December-February
  /// 6.isBetweenMonths(3, 8);  // Returns true, June is within March-August
  /// ```
  bool isBetweenMonths(int startMonth, int endMonth) {
    final month = this.toInt();
    // Handle cases where the range crosses over the year boundary (e.g., December to February)
    if (startMonth > endMonth) {
      return month >= startMonth || month <= endMonth;
    } else {
      return month >= startMonth && month <= endMonth;
    }
  }

  /// Checks if the number (assumed to represent a day of the week, 1-based) corresponds to the current day of the week.
  ///
  /// This method follows ISO 8601, where the week starts on Monday (1) and ends on Sunday (7).
  ///
  /// Example:
  /// ```dart
  /// 1.isCurrentDayOfWeek; // Returns true if today is Monday
  /// 7.isCurrentDayOfWeek; // Returns true if today is Sunday
  /// ```
  bool get isCurrentDayOfWeek {
    final now = DateTime.now();
    return this.toInt() == now.weekday;
  }

  /// Checks if the number (assumed to represent a year) corresponds to the current year.
  ///
  /// Example:
  /// ```dart
  /// 2024.isCurrentYear; // Returns true if the current year is 2024
  /// ```
  bool get isCurrentYear {
    final now = DateTime.now();
    return this.toInt() == now.year;
  }

  /// Checks if the number (assumed to represent a month, 1-based) corresponds to the current month.
  ///
  /// Example:
  /// ```dart
  /// 8.isCurrentMonth; // Returns true if the current month is August
  /// ```
  bool get isCurrentMonth {
    final now = DateTime.now();
    return this.toInt() == now.month;
  }

  /// Checks if the number (assumed to represent a day, 1-based) corresponds to the current day of the month.
  ///
  /// Example:
  /// ```dart
  /// 15.isCurrentDay; // Returns true if today is the 15th of the month
  /// ```
  bool get isCurrentDay {
    final now = DateTime.now();
    return this.toInt() == now.day;
  }
}

extension DHUNullableDateExtensions on DateTime? {
  DateTime? get local => this?.toLocal();

  String? get toUtcIso => this?.toUtc().toIso8601String();

  bool get isTomorrow {
    if (this == null) return false;
    final now = DateTime.now();

    // Quick check to rule out dates that are far away
    if (this!.year != now.year || this!.month != now.month) {
      return false;
    }

    return remainingDays == 1;
  }

  /// return true if the date is today
  bool get isToday {
    if (this == null) return false;
    final now = DateTime.now();

    // Quick check to rule out dates that are far away
    if (this!.year != now.year || this!.month != now.month) {
      return false;
    }

    return remainingDays == 0;
  }

  bool get isYesterday {
    if (this == null) return false;
    final now = DateTime.now();

    // Quick check to rule out dates that are far away
    if (this!.year != now.year || this!.month != now.month) {
      return false;
    }

    return passedDays == 1;
  }

  bool get isPresent => isNotNull && this!.isAfter(DateTime.now());

  bool get isPast => isNotNull && this!.isBefore(DateTime.now());

  bool get isInPastWeek {
    if (isNull) return false;
    final now = DateTime.now();
    return now.dateOnly.previousWeek.isBefore(this!) && now.isAfter(this!);
  }

  bool get isInThisYear => isNotNull && this!.year == DateTime.now().year;

  bool get isInThisMonth {
    if (isNull) return false;
    final now = DateTime.now();
    return this!.month == now.month && this!.year == now.year;
  }

  bool get isLeapYear {
    if (isNull) return false;
    return (this!.year % 4 == 0) &&
        ((this!.year % 100 != 0) || (this!.year % 400 == 0));
  }

  Duration? get passedDuration =>
      isNull ? null : DateTime.now().difference(this!);

  Duration? get remainingDuration =>
      isNull ? null : this!.difference(DateTime.now());

  /// Returns the number of days remaining until this DateTime.
  int? get remainingDays => isNull ? null : this!.daysDifferenceTo();

  int? get passedDays => isNull ? null : DateTime.now().daysDifferenceTo(this);
}

extension DHUDateExtensions on DateTime {
  /// Converts this DateTime to local time.
  DateTime get local => toLocal();

  /// Format a date to "DAY, DD MON YYYY hh:mm:ss GMT" according to
  /// [RFC-1123](https://tools.ietf.org/html/rfc1123 "RFC-1123"),
  /// e.g. `Thu, 1 Jan 1970 00:00:00 GMT`.
  String get httpFormat => HttpDate.format(this);

  /// Converts this DateTime to UTC and returns an ISO 8601 string.
  String get toUtcIso => toUtc().toIso;

  /// Returns an ISO-8601 full-precision extended format representation.
  ///
  /// The format is `yyyy-MM-ddTHH:mm:ss.mmmuuuZ` for UTC time, and
  /// `yyyy-MM-ddTHH:mm:ss.mmmuuu` (no trailing "Z") for local/non-UTC time,
  /// where:
  ///
  /// * `yyyy` is a, possibly negative, four digit representation of the year,
  ///   if the year is in the range -9999 to 9999,
  ///   otherwise it is a signed six digit representation of the year.
  /// * `MM` is the month in the range 01 to 12,
  /// * `dd` is the day of the month in the range 01 to 31,
  /// * `HH` are hours in the range 00 to 23,
  /// * `mm` are minutes in the range 00 to 59,
  /// * `ss` are seconds in the range 00 to 59 (no leap seconds),
  /// * `mmm` are milliseconds in the range 000 to 999, and
  /// * `uuu` are microseconds in the range 001 to 999. If [microsecond] equals
  ///   0, then this part is omitted.
  ///
  /// The resulting string can be parsed back using [parse].
  /// ```dart
  /// final moonLanding = DateTime.utc(1969, 7, 20, 20, 18, 04);
  /// final isoDate = moonLanding.toIso8601String();
  /// print(isoDate); // 1969-07-20T20:18:04.000Z
  /// ```
  String get toIso => toIso8601String();

  /// Adds the specified duration to this DateTime.
  DateTime operator +(Duration duration) => add(duration);

  /// Subtracts the specified duration from this DateTime.
  DateTime operator -(Duration duration) => subtract(duration);

  /// Returns the duration that has passed since this DateTime.
  Duration get passedDuration => DateTime.now().difference(this);

  /// Returns the number of days that have passed since this DateTime.
  int get passedDays => DateTime.now().daysDifferenceTo(this);

  /// Returns the duration remaining until this DateTime.
  Duration get remainingDuration => difference(DateTime.now());

  /// Returns the number of days remaining until this DateTime.
  int get remainingDays => daysDifferenceTo();

  /// Checks if this DateTime is in the same year as [other].
  bool isAtSameYearAs(DateTime other) => year == other.year;

  /// Checks if this DateTime is in the same month and year as [other].
  bool isAtSameMonthAs(DateTime other) =>
      isAtSameYearAs(other) && month == other.month;

  /// Checks if this DateTime is on the same day, month, and year as [other].
  bool isAtSameDayAs(DateTime other) =>
      isAtSameMonthAs(other) && day == other.day;

  /// Checks if this DateTime is in the same hour, day, month, and year as [other].
  bool isAtSameHourAs(DateTime other) =>
      isAtSameDayAs(other) && hour == other.hour;

  /// Checks if this DateTime is in the same minute, hour, day, month, and year as [other].
  bool isAtSameMinuteAs(DateTime other) =>
      isAtSameHourAs(other) && minute == other.minute;

  /// Checks if this DateTime is in the same second, minute, hour, day, month, and year as [other].
  bool isAtSameSecondAs(DateTime other) =>
      isAtSameMinuteAs(other) && second == other.second;

  /// Checks if this DateTime is in the same millisecond, second, minute, hour, day, month, and year as [other].
  bool isAtSameMillisecondAs(DateTime other) =>
      isAtSameSecondAs(other) && millisecond == other.millisecond;

  /// Checks if this DateTime is in the same microsecond, millisecond, second, minute, hour, day, month, and year as [other].
  bool isAtSameMicrosecondAs(DateTime other) =>
      isAtSameMillisecondAs(other) && microsecond == other.microsecond;

  /// Returns a DateTime representing the start of the day for this DateTime.
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns a DateTime representing the start of the month for this DateTime.
  DateTime get startOfMonth => DateTime(year, month);

  /// Returns a DateTime representing the start of the year for this DateTime.
  DateTime get startOfYear => DateTime(year);

  /// Returns a DateTime representing tomorrow relative to this DateTime.
  DateTime get tomorrow => add(const Duration(days: 1));

  /// Returns a DateTime representing yesterday relative to this DateTime.
  DateTime get yesterday => subtract(const Duration(days: 1));

  /// Returns a DateTime representing only the date part of this DateTime.
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns a list of DateTimes representing the days in the same month as this DateTime.
  List<DateTime> get daysInMonth {
    final first = firstDayOfMonth;
    final daysBefore = first.weekday;
    final firstToDisplay = first.subtract(Duration(days: daysBefore));
    final last = lastDayOfMonth;
    var daysAfter = 7 - last.weekday;
    if (daysAfter == 0) {
      daysAfter = 7;
    }
    final lastToDisplay = last.add(Duration(days: daysAfter));
    return firstToDisplay.daysUpTo(lastToDisplay).toList();
  }

  /// Returns a DateTime representing the previous day relative to this DateTime.
  DateTime get previousDay => addDays(-1);

  /// Returns a DateTime representing the next day relative to this DateTime.
  DateTime get nextDay => addDays(1);

  /// Returns a DateTime representing the previous week relative to this DateTime.
  DateTime get previousWeek => subtract(const Duration(days: 7));

  /// Returns a DateTime representing the next week relative to this DateTime.
  DateTime get nextWeek => add(const Duration(days: 7));

  /// Returns a DateTime representing the first day of the week for this DateTime.
  ///
  /// [startOfWeek] is an optional parameter specifying the weekday that is considered
  /// the start of the week (1 for Monday, 7 for Sunday, etc.). Defaults to Monday.
  DateTime firstDayOfWeek({int startOfWeek = DateTime.monday}) {
    // Normalize the startOfWeek value to be within the range of 1-7
    final normalizedStartOfWeek =
        ((startOfWeek - 1) % DateTime.daysPerWeek) + 1;

    // Calculate the difference between the current weekday and normalizedStartOfWeek
    // and adjust it to be positive and within the range of 0-6
    final daysToSubtract =
        (weekday - normalizedStartOfWeek + DateTime.daysPerWeek) %
            DateTime.daysPerWeek;

    return subtract(Duration(days: daysToSubtract));
  }

  /// Returns a DateTime representing the last day of the week for this DateTime.
  ///
  /// [startOfWeek] is an optional parameter specifying the weekday that is considered
  /// the start of the week (1 for Monday, 7 for Sunday, etc.). Defaults to Monday.
  DateTime lastDayOfWeek({int startOfWeek = DateTime.monday}) {
    final normalizedStartOfWeek =
        ((startOfWeek - 1) % DateTime.daysPerWeek) + 1;
    final daysToAdd =
        (DateTime.daysPerWeek - weekday + normalizedStartOfWeek - 1) %
            DateTime.daysPerWeek;

    // Convert to UTC and then back to the original timezone to ensure correct midnight
    final utcLastDayOfWeek = toUtc().add(Duration(days: daysToAdd));
    return utcLastDayOfWeek.toLocal();
  }

  /// Returns a DateTime representing the previous month relative to this Date Time.
  DateTime get previousMonth {
    var year = this.year;
    var month = this.month;
    if (month == 1) {
      year--;
      month = 12;
    } else {
      month--;
    }
    return DateTime(year, month);
  }

  /// Returns a DateTime representing the next month relative to this DateTime.
  DateTime get nextMonth {
    var year = this.year;
    var month = this.month;
    if (month == 12) {
      year++;
      month = 1;
    } else {
      month++;
    }
    return DateTime(year, month);
  }

  /// Returns a DateTime representing the first day of the month for this DateTime.
  DateTime get firstDayOfMonth => DateTime(year, month);

  /// Returns a DateTime representing the last day of the month for this DateTime.
  DateTime get lastDayOfMonth {
    final beginningNextMonth =
        (month < 12) ? DateTime(year, month + 1) : DateTime(year + 1);
    return beginningNextMonth.subtract(const Duration(days: 1));
  }

  /// Adds or removes the specified number of years from this DateTime.
  DateTime addOrRemoveYears(int years) {
    final newYear = year + years;
    final newMonth = month;
    var newDay = day;
    // Adjust the day if it exceeds the number of days in the new month
    while (newDay > DateTime(newYear, newMonth + 1, 0).day) {
      newDay--;
    }
    return DateTime(newYear, newMonth, newDay, hour, minute, second);
  }

  /// Adds or removes the specified number of months from this DateTime.
  DateTime addOrRemoveMonths(int months) {
    final totalMonths = month + months;
    final newYear = year + (totalMonths ~/ 12);
    final newMonth = totalMonths % 12 == 0 ? 12 : totalMonths % 12;
    var newDay = day;
    // Adjust the day if it exceeds the number of days in the new month
    while (newDay > DateTime(newYear, newMonth + 1, 0).day) {
      newDay--;
    }
    return DateTime(newYear, newMonth, newDay, hour, minute, second);
  }

  /// Adds or removes the specified number of days from this DateTime.
  DateTime addOrRemoveDays(int days) => add(Duration(days: days));

  /// Adds or removes the specified number of minutes from this DateTime.
  DateTime addOrRemoveMinutes(int minutes) => add(Duration(minutes: minutes));

  /// Adds or removes the specified number of seconds from this DateTime.
  DateTime addOrRemoveSeconds(int seconds) => add(Duration(seconds: seconds));

  /// Returns the minimum of this DateTime and [that].
  DateTime min(DateTime that) =>
      (millisecondsSinceEpoch < that.millisecondsSinceEpoch) ? this : that;

  /// Returns the maximum of this DateTime and [that].
  DateTime max(DateTime that) =>
      (millisecondsSinceEpoch > that.millisecondsSinceEpoch) ? this : that;

  /// Adds the specified number of days to this DateTime.
  DateTime addDays(int amount) => add(Duration(days: amount));

  /// Adds the specified number of hours to this DateTime.
  DateTime addHours(int amount) => add(Duration(hours: amount));

  /// Checks if this DateTime occurs on the same hour as another DateTime,
  /// regardless of time zone.
  bool isSameHourAs(DateTime other) => hour == other.hour && isSameDayAs(other);

  /// Checks if this DateTime occurs on the same day as another DateTime,
  /// regardless of time zone.
  bool isSameDayAs(DateTime other) =>
      day == other.day && month == other.month && year == other.year;

  /// Checks if this DateTime occurs within the same week as another DateTime,
  /// regardless of time zone.  Considers a week to start on Monday.
  bool isSameWeekAs(DateTime other) {
    final thisNoonUtc = DateTime.utc(year, month, day, 12);
    final otherNoonUtc = DateTime.utc(other.year, other.month, other.day, 12);

    if (thisNoonUtc.difference(otherNoonUtc).inDays.abs() >= 7) return false;

    // Find the start of the week (Monday) for both dates
    final startOfWeekThis =
        thisNoonUtc.subtract(Duration(days: thisNoonUtc.weekday - 1));
    final startOfWeekOther =
        otherNoonUtc.subtract(Duration(days: otherNoonUtc.weekday - 1));

    return startOfWeekThis.isAtSameMomentAs(startOfWeekOther);
  }

  /// Calculates the absolute difference in whole days between this DateTime
  /// and another DateTime (or the current time if none is provided).
  /// Ignores hours, minutes, seconds, and milliseconds.
  int daysDifferenceTo([DateTime? other]) {
    final comparisonDate = other ?? DateTime.now();
    return DateTime(year, month, day)
        .difference(DateTime(
            comparisonDate.year, comparisonDate.month, comparisonDate.day))
        .inDays
        .abs(); // Ensure positive result
  }

  /// Generates a sequence of DateTime objects representing each day in the range
  /// starting from `this` DateTime (inclusive) up to but not including the `end` DateTime.
  ///
  /// Handles time zone adjustments to ensure accurate day boundaries.
  Iterable<DateTime> daysUpTo(DateTime end) sync* {
    var current = this;
    var currentOffset = current.timeZoneOffset; // Store initial offset
    while (current.isBefore(end)) {
      yield current;
      current = current.add(const Duration(days: 1));

      // Adjust for potential time zone changes during iteration
      final offsetDifference = current.timeZoneOffset - currentOffset;
      if (offsetDifference.inSeconds != 0) {
        currentOffset = current.timeZoneOffset; // Update offset
        current =
            current.subtract(Duration(seconds: offsetDifference.inSeconds));
      }
    }
  }
}

abstract class DatesHelper {
  // Whether or not two times are on the same hour.
  static bool isSameHour(DateTime a, DateTime b) => a.isSameHourAs(b);

  // Whether or not two times are on the same day.
  static bool isSameDay(DateTime a, DateTime b) => a.isSameDayAs(b);

  static bool isSameWeek(DateTime a, DateTime b) => a.isSameWeekAs(b);

  /// Returns the absolute value of the difference in days between two dates.
  /// The difference is calculated by comparing only the year, month, and day values of the dates.
  /// The hour, minute, second, and millisecond values are ignored.
  /// For example, if date1 is August 22nd at 11 p.m. and date2 is August 24th at 12 a.m. midnight,
  /// the difference in days is 2, not a fraction of a day.
  static int diffInDays({required DateTime to, DateTime? from}) =>
      to.daysDifferenceTo(from);

  /// Returns a [DateTime] for each day the given range.
  ///
  /// [start] inclusive
  /// [end] exclusive
  static Iterable<DateTime> daysInRange(DateTime start, DateTime end) =>
      start.daysUpTo(end);
}

/*
**Areas for Improvement**

* **Error Handling:** Consider adding more robust error handling, especially in the parsing extensions, to provide informative messages to the user or log errors appropriately.
* **Documentation:** While the code is generally well-organized, adding more detailed comments or docstrings, especially for complex functions, would improve its understandability and maintainability.
* **Naming Conventions:** Some function names (e.g., `addOrRemoveYears`) could be more concise or descriptive.
* **Testing:** Writing unit tests to cover various scenarios and edge cases would ensure the correctness and reliability of the code.
*/
