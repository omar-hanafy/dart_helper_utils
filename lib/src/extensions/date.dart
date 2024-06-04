import 'package:dart_helper_utils/dart_helper_utils.dart';

extension FHUDateString on String {
  /// Parse string to [DateTime] using null Safety
  DateTime get toDateTime => DateTime.parse(this);
}

extension FHUDateNullString on String? {
  DateTime? get tryToDateTime => isBlank ? null : DateTime.tryParse(this!);

  DateTime get timestampToDate => this.toInt.timestampToDate;
}

extension NumberToDateNames on num {
  /// Gets the full month name (e.g., "January") corresponding to this number (1-12).
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
  String get toSmallDayName => toFullDayName.substring(0, 3);

  /// Gets the short month name (e.g., "Jan") corresponding to this number (1-12).
  String get toSmallMonthName => toFullMonthName.substring(0, 3);

  // convert all to int and if the number is too large for month def is 12 if too small def is 1 and so on
  DateTime get timestampToDate =>
      DateTime.fromMillisecondsSinceEpoch(this.toInt());
}

extension FHUNullableDateExtensions on DateTime? {
  DateTime? get local => this?.toLocal();

  String? get toUtcIso => this?.toUtc().toIso8601String();

  bool get isTomorrow => remainingDays == 1;

  /// return true if the date is today
  bool get isToday => remainingDays == 0;

  bool get isYesterday => passedDays == 1;

  bool get isPresent => isNotNull && this!.isAfter(DateTime.now());

  bool get isPast => isNotNull && this!.isBefore(DateTime.now());

  bool get isInPastWeek {
    if (isNull) return false;
    final now = DateTime.now();
    return now.dateOnly.previousWeek.isBefore(this!) && now.isAfter(this!);
  }

  bool get isInThisYear => isNotNull && this!.year == DateTime.now().year;

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

extension FHUDateExtensions on DateTime {
  /// Converts this DateTime to local time.
  DateTime get local => toLocal();

  /// Converts this DateTime to UTC and returns an ISO 8601 string.
  String get toUtcIso => toUtc().toIso;

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
        (month < 12) ? DateTime(year, month + 1) : DateTime(year + 1, 1);
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
