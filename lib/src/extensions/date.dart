import 'package:dart_helper_utils/dart_helper_utils.dart';

// String→DateTime conversions moved to convert_object.

/// NumberToDateUtils
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
    final monthIndex = this.toInt().clamp(1, 12);
    return fullMonthsNames[monthIndex]!;
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
    final dayIndex = this.toInt().clamp(1, 7);
    return fullWeekdays[dayIndex]!;
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
  // Removed: prefer ConvertObject.toDateTime(this) for epoch values.

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

/// DHUNullableDateExtensions
extension DHUNullableDateExtensions on DateTime? {
  /// checks local
  DateTime? get local => this?.toLocal();

  /// checks toUtcIso
  String? get toUtcIso => this?.toUtc().toIso8601String();

  /// checks isTomorrow
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

  /// checks isYesterday
  bool get isYesterday {
    if (this == null) return false;
    final now = DateTime.now();

    // Quick check to rule out dates that are far away
    if (this!.year != now.year || this!.month != now.month) {
      return false;
    }

    return passedDays == -1;
  }

  /// checks isPresent
  bool get isPresent => isNotNull && this!.isAfter(DateTime.now());

  /// checks isPast
  bool get isPast => isNotNull && this!.isBefore(DateTime.now());

  /// checks isInPastWeek
  bool get isInPastWeek {
    if (isNull) return false;
    final now = DateTime.now();
    return now.dateOnly.previousWeek.isBefore(this!) && now.isAfter(this!);
  }

  /// checks isInThisYear
  bool get isInThisYear => isNotNull && this!.year == DateTime.now().year;

  /// checks isInThisMonth
  bool get isInThisMonth {
    if (isNull) return false;
    final now = DateTime.now();
    return this!.month == now.month && this!.year == now.year;
  }

  /// checks isLeapYear
  bool get isLeapYear {
    if (isNull) return false;
    return (this!.year % 4 == 0) &&
        ((this!.year % 100 != 0) || (this!.year % 400 == 0));
  }

  /// Checks if this nullable [DateTime] falls between two other [DateTime]
  /// objects.
  ///
  /// See [DHUDateExtensions.isBetween] for full parameter documentation.
  ///
  /// Returns `false` if this nullable DateTime is null.
  ///
  bool isBetween(
    DateTime start,
    DateTime end, {
    bool inclusiveStart = true,
    bool inclusiveEnd = false,
    bool ignoreTime = false,
    bool normalize = false,
  }) {
    if (this == null) return false;

    return this!.isBetween(
      start,
      end,
      inclusiveStart: inclusiveStart,
      inclusiveEnd: inclusiveEnd,
      ignoreTime: ignoreTime,
      normalize: normalize,
    );
  }

  /// checks passedDuration
  Duration? get passedDuration =>
      isNull ? null : DateTime.now().difference(this!);

  /// checks remainingDuration
  Duration? get remainingDuration =>
      isNull ? null : this!.difference(DateTime.now());

  /// Returns the number of days remaining until this DateTime.
  int? get remainingDays => isNull ? null : this!.remainingDays;

  /// checks passedDays
  int? get passedDays => isNull ? null : this!.passedDays;
}

/// DHUDateExtensions
extension DHUDateExtensions on DateTime {
  /// Converts this DateTime to local time.
  DateTime get local => toLocal();

  // TODO(ME): Rename this to httpDateFormat.
  /// Format a date to "DAY, DD MON YYYY hh:mm:ss GMT" according to
  /// [RFC-1123](https://tools.ietf.org/html/rfc1123 "RFC-1123"),
  /// e.g. `Thu, 1 Jan 1970 00:00:00 GMT`.
  String get httpFormat {
    final weekday = smallWeekdays[this.weekday];
    final month = smallMonthsNames[this.month];
    final d = toUtc();
    final sb = StringBuffer()
      ..write(weekday)
      ..write(', ')
      ..write(d.day <= 9 ? '0' : '')
      ..write(d.day)
      ..write(' ')
      ..write(month)
      ..write(' ')
      ..write(d.year)
      ..write(d.hour <= 9 ? ' 0' : ' ')
      ..write(d.hour)
      ..write(d.minute <= 9 ? ':0' : ':')
      ..write(d.minute)
      ..write(d.second <= 9 ? ':0' : ':')
      ..write(d.second)
      ..write(' GMT');

    return sb.toString();
  }

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
  int get passedDays {
    final today = DateTime.now();
    // If the date is after today, return 0 as no days have passed yet
    // Otherwise, return the positive difference
    return isAfter(today) ? 0 : today.daysDifferenceTo(this);
  }

  /// Returns the duration remaining until this DateTime.
  Duration get remainingDuration => difference(DateTime.now());

  /// Returns the number of days remaining until this DateTime.
  int get remainingDays {
    final today = DateTime.now();
    // If the date is before today, return a negative difference
    return isBefore(today) ? -daysDifferenceTo(today) : daysDifferenceTo(today);
  }

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

  /// Adds or subtracts the specified number of years from this DateTime.
  /// Using a positive value (e.g., 1) adds years, while a negative value (e.g., -1) subtracts years.
  DateTime addOrSubtractYears(int years) {
    final newYear = year + years;
    final newMonth = month;
    var newDay = day;
    // Adjust the day if it exceeds the number of days in the new month
    while (newDay > DateTime(newYear, newMonth + 1, 0).day) {
      newDay--;
    }
    return DateTime(newYear, newMonth, newDay, hour, minute, second,
        millisecond, microsecond);
  }

  /// Adds or subtracts the specified number of months from this DateTime.
  /// Using a positive value (e.g., 1) adds months, while a negative value (e.g., -1) subtracts months.
  DateTime addOrSubtractMonths(int months) {
    final totalMonths = month + months;
    var newYear = year + (totalMonths ~/ 12);
    var newMonth = totalMonths % 12;

    // Handle the case where totalMonths is a multiple of 12 (e.g., adding/subtracting 12, 24, etc. months)
    if (newMonth == 0) {
      newMonth = 12;
      newYear -=
          1; // Adjust the year if we "wrapped around" to December of the previous year
    }

    var newDay = day;
    // Adjust the day if it exceeds the number of days in the new month
    while (newDay > DateTime(newYear, newMonth + 1, 0).day) {
      newDay--;
    }
    return DateTime(newYear, newMonth, newDay, hour, minute, second,
        millisecond, microsecond);
  }

  /// Adds or subtracts the specified number of days from this DateTime.
  /// Using a positive value (e.g., 1) adds days, while a negative value (e.g., -1) subtracts days.
  DateTime addOrSubtractDays(int days) => add(Duration(days: days));

  /// Adds or subtracts the specified number of minutes from this DateTime.
  /// Using a positive value (e.g., 1) adds minutes, while a negative value (e.g., -1) subtracts minutes.
  DateTime addOrSubtractMinutes(int minutes) => add(Duration(minutes: minutes));

  /// Adds or subtracts the specified number of seconds from this DateTime.
  /// Using a positive value (e.g., 1) adds seconds, while a negative value (e.g., -1) subtracts seconds.
  DateTime addOrSubtractSeconds(int seconds) => add(Duration(seconds: seconds));

  /// Adds or subtracts the specified number of milliseconds from this DateTime.
  /// Using a positive value (e.g., 1) adds milliseconds, while a negative value (e.g., -1) subtracts milliseconds.
  DateTime addOrSubtractMilliseconds(int milliseconds) =>
      add(Duration(milliseconds: milliseconds));

  /// Adds or subtracts the specified number of microseconds from this DateTime.
  /// Using a positive value (e.g., 1) adds microseconds, while a negative value (e.g., -1) subtracts microseconds.
  DateTime addOrSubtractMicroseconds(int microseconds) =>
      add(Duration(microseconds: microseconds));

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

  /// Adds the specified number of minutes to this DateTime.
  DateTime addMinutes(int amount) => add(Duration(minutes: amount));

  /// Adds the specified number of seconds to this DateTime.
  DateTime addSeconds(int amount) => add(Duration(seconds: amount));

  /// Adds the specified number of milliseconds to this DateTime.
  DateTime addMilliseconds(int amount) => add(Duration(milliseconds: amount));

  /// Adds the specified number of microseconds to this DateTime.
  DateTime addMicroseconds(int amount) => add(Duration(microseconds: amount));

  /// Subtracts the specified number of days from this DateTime.
  DateTime subtractDays(int amount) => subtract(Duration(days: amount));

  /// Subtracts the specified number of hours from this DateTime.
  DateTime subtractHours(int amount) => subtract(Duration(hours: amount));

  /// Subtracts the specified number of minutes from this DateTime.
  DateTime subtractMinutes(int amount) => subtract(Duration(minutes: amount));

  /// Subtracts the specified number of seconds from this DateTime.
  DateTime subtractSeconds(int amount) => subtract(Duration(seconds: amount));

  /// Subtracts the specified number of milliseconds from this DateTime.
  DateTime subtractMilliseconds(int amount) =>
      subtract(Duration(milliseconds: amount));

  /// Subtracts the specified number of microseconds from this DateTime.
  DateTime subtractMicroseconds(int amount) =>
      subtract(Duration(microseconds: amount));

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

  /// Checks if this [DateTime] falls between two other [DateTime] objects,
  /// with options for inclusive or exclusive boundaries and timezone handling.
  ///
  /// [start] and [end] are the boundary [DateTime] objects.
  ///
  /// [inclusiveStart] determines if the [start] date is included in the
  /// range (defaults to `true`).
  ///
  /// [inclusiveEnd] determines if the [end] date is included in the range
  /// (defaults to `false`).
  ///
  /// [ignoreTime] if true, only compares the date part, ignoring time
  /// components (defaults to `false`).
  ///
  /// [normalize] if true, converts all dates to UTC before comparison
  /// (defaults to `false`).
  ///
  /// Throws [ArgumentError] if:
  /// - Either [start] or [end] is null
  /// - [start] date is after [end] date
  ///
  bool isBetween(
    DateTime start,
    DateTime end, {
    bool inclusiveStart = true,
    bool inclusiveEnd = false,
    bool ignoreTime = false,
    bool normalize = false,
  }) {
    // Validate inputs
    ArgumentError.checkNotNull(start, 'start');
    ArgumentError.checkNotNull(end, 'end');

    // Prepare dates for comparison
    var compareStart = start;
    var compareEnd = end;

    // Normalize to UTC if requested
    if (normalize) {
      compareStart = start.toUtc();
      compareEnd = end.toUtc();
      // Directly use 'this' and convert it.
      if (normalize) {
        toUtc();
      }
    }

    // Strip time components if requested
    if (ignoreTime) {
      compareStart = DateTime(start.year, start.month, start.day);
      compareEnd = DateTime(end.year, end.month, end.day);
      // Directly use 'this'
      if (ignoreTime) {
        DateTime(year, month, day);
      }
    }

    // Validate range
    if (compareStart.isAfter(compareEnd)) {
      throw ArgumentError(
          'Start date ($start) must be before or equal to end date ($end)');
    }

    // Perform comparison
    return (inclusiveStart ? !isBefore(compareStart) : isAfter(compareStart)) &&
        (inclusiveEnd ? !isAfter(compareEnd) : isBefore(compareEnd));
  }

  /// Calculates the absolute difference in whole days between this DateTime
  /// and another DateTime (or the current time if none is provided).
  /// Ignores hours, minutes, seconds, and milliseconds.
  int daysDifferenceTo([DateTime? other]) {
    final comparisonDate = other ?? DateTime.now();
    return DateTime(year, month, day)
        .difference(
          DateTime(
            comparisonDate.year,
            comparisonDate.month,
            comparisonDate.day,
          ),
        )
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

  /// calculates the age of a person based on the current date
  ({int years, int months, int days}) calculateAge() {
    // Helper function to determine the number of days in a month
    int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

    final birthDate = toLocal();
    final today = DateTime.now();

    // Check if birth date is Feb 29
    final isLeapDayBirthday = birthDate.month == 2 && birthDate.day == 29;

    // Adjust the birth day for non-leap years
    var birthDay = birthDate.day;
    if (isLeapDayBirthday && !today.isLeapYear) {
      birthDay = 28;
    }

    var years = today.year - birthDate.year;
    var months = today.month - birthDate.month;
    var days = today.day - birthDay;

    // Adjust days and months if necessary
    if (days < 0) {
      months -= 1;
      final prevMonth = (today.month - 1 == 0) ? 12 : today.month - 1;
      days += daysInMonth(today.year, prevMonth);
    }

    if (months < 0) {
      years -= 1;
      months += 12;
    }

    return (years: years, months: months, days: days);
  }
}

///
abstract class DatesHelper {
  /// Whether or not two times are on the same hour.
  static bool isSameHour(DateTime a, DateTime b) => a.isSameHourAs(b);

  /// Whether or not two times are on the same day.
  static bool isSameDay(DateTime a, DateTime b) => a.isSameDayAs(b);

  /// Whether or not two times are on the same week.
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
