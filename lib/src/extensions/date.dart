import 'package:dart_helper_utils/dart_helper_utils.dart';

/// Calendar lookups on numbers: month and weekday names, and checks against
/// the current date.
///
/// Weekday numbers follow ISO 8601 and [DateTime.weekday]: Monday is 1 and
/// Sunday is 7. Month numbers are 1-based.
extension NumberToDateUtils on num {
  /// Gets the full month name (e.g., "January") corresponding to this number (1-12).
  ///
  /// Example:
  /// ```dart
  /// 1.toFullMonthName; // `Returns "January"
  /// 12.toFullMonthName; // Returns "December"
  /// ```
  /// If the number is outside the range 1-12, it will be clamped within this range.
  String get toFullMonthName {
    final monthIndex = toInt().clamp(1, 12);
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
  /// If the number is outside the range 1-7, it will be clamped within this range.
  String get toFullDayName {
    final dayIndex = toInt().clamp(1, 7);
    return fullWeekdays[dayIndex]!;
  }

  /// Gets the short day name (e.g., "Mon") corresponding to this number (1-7).
  ///
  /// Example:
  /// ```dart
  /// 1.toSmallDayName; // Returns "Mon"
  /// 7.toSmallDayName; // Returns "Sun"
  /// ```
  /// If the number is outside the range 1-7, it will be clamped within this range.
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

  /// Checks if the number (assumed to represent a month, 1-based) is within the specified range of months.
  ///
  /// This method handles ranges that cross the year boundary (e.g., December to February).
  ///
  /// Example:
  /// ```dart
  /// 3.isBetweenMonths(12, 2); // Returns false, March is outside December-February
  /// 1.isBetweenMonths(12, 2); // Returns true, January is within December-February
  /// 6.isBetweenMonths(3, 8);  // Returns true, June is within March-August
  /// ```
  bool isBetweenMonths(int startMonth, int endMonth) {
    final month = toInt();
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
    return toInt() == now.weekday;
  }

  /// Checks if the number (assumed to represent a year) corresponds to the current year.
  ///
  /// Example:
  /// ```dart
  /// 2024.isCurrentYear; // Returns true if the current year is 2024
  /// ```
  bool get isCurrentYear {
    final now = DateTime.now();
    return toInt() == now.year;
  }

  /// Checks if the number (assumed to represent a month, 1-based) corresponds to the current month.
  ///
  /// Example:
  /// ```dart
  /// 8.isCurrentMonth; // Returns true if the current month is August
  /// ```
  bool get isCurrentMonth {
    final now = DateTime.now();
    return toInt() == now.month;
  }

  /// Checks if the number (assumed to represent a day, 1-based) corresponds to the current day of the month.
  ///
  /// Example:
  /// ```dart
  /// 15.isCurrentDay; // Returns true if today is the 15th of the month
  /// ```
  bool get isCurrentDay {
    final now = DateTime.now();
    return toInt() == now.day;
  }
}

/// Null-safe checks and conversions for a [DateTime] that may be `null`.
///
/// Every check returns `false` for a `null` receiver, and every conversion
/// returns `null`. Checks against "today" compare the receiver's calendar
/// fields with the local current date.
extension DHUNullableDateExtensions on DateTime? {
  /// Converts this DateTime to the local time zone.
  ///
  /// Returns `null` if this DateTime is `null`.
  DateTime? get local => this?.toLocal();

  /// Converts this DateTime to UTC and returns an ISO 8601 string representation.
  ///
  /// Returns `null` if this DateTime is `null`.
  /// Example: "2024-01-15T10:30:00.000Z"
  String? get toUtcIso => this?.toUtc().toIso8601String();

  /// Whether this date falls on the calendar day after today.
  bool get isTomorrow {
    if (this == null) return false;
    return this!.remainingDays == 1;
  }

  /// Whether this date falls on today's calendar day.
  bool get isToday {
    if (this == null) return false;
    final now = DateTime.now();
    return this!.year == now.year &&
        this!.month == now.month &&
        this!.day == now.day;
  }

  /// Whether this date falls on the calendar day before today.
  bool get isYesterday {
    if (this == null) return false;
    return this!.remainingDays == -1;
  }

  /// Whether this moment is later than now.
  ///
  /// Renamed from `isPresent` in 7.0.0; `dart fix --apply` migrates callers.
  bool get isFuture => this != null && this!.isAfter(DateTime.now());

  /// Whether this moment is earlier than now.
  bool get isPast => this != null && this!.isBefore(DateTime.now());

  /// Whether this moment is earlier than now and no more than a week before
  /// the start of today.
  bool get isInPastWeek {
    if (this == null) return false;
    final now = DateTime.now();
    return now.dateOnly.previousWeek.isBefore(this!) && now.isAfter(this!);
  }

  /// Whether this date falls in the current calendar year.
  bool get isInThisYear => this != null && this!.year == DateTime.now().year;

  /// Whether this date falls in the current calendar month of the current year.
  bool get isInThisMonth {
    if (this == null) return false;
    final now = DateTime.now();
    return this!.month == now.month && this!.year == now.year;
  }

  /// Whether this date's year is a leap year in the Gregorian calendar.
  bool get isLeapYear {
    if (this == null) return false;
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

  /// The time elapsed since this moment, or `null` for a `null` receiver.
  ///
  /// Negative when this moment is in the future.
  Duration? get passedDuration =>
      this == null ? null : DateTime.now().difference(this!);

  /// The time left until this moment, or `null` for a `null` receiver.
  ///
  /// Negative when this moment is in the past.
  Duration? get remainingDuration => this?.difference(DateTime.now());

  /// Returns the number of days remaining until this DateTime.
  /// Returns a positive number for future dates, and negative for past dates.
  int? get remainingDays => this?.remainingDays;

  /// Returns the number of days passed since this DateTime.
  /// Returns a positive number for past dates, and negative for future dates.
  int? get passedDays => this?.passedDays;

  /// Deprecated alias of [isFuture]: "present" never meant "now".
  @Deprecated('Use isFuture. This alias will be removed in 8.0.0.')
  bool get isPresent => isFuture;
}

/// Calendar arithmetic, comparisons, and formatting helpers for [DateTime].
///
/// Day-based arithmetic (`addDays`, `nextDay`, `firstDayOfWeek`,
/// `addBusinessDays`, and friends) moves by calendar days and keeps the
/// wall-clock time, so it stays correct across daylight-saving transitions.
/// On the day of a change, a time the clocks skip moves forward by the
/// length of the jump, and a time they repeat resolves to its first
/// occurrence (unless the receiver is itself the repeat, so `addDays(0)`
/// returns it). Sub-day arithmetic (`addHours` and smaller) adds exact
/// durations.
/// Every helper that builds a new date keeps the receiver's time zone: a UTC
/// input produces a UTC result.
extension DHUDateExtensions on DateTime {
  /// Converts this DateTime to local time.
  DateTime get local => toLocal();

  /// Formats this moment as an HTTP date (RFC 7231 IMF-fixdate, the RFC 1123
  /// format) in GMT, e.g. `Thu, 01 Jan 1970 00:00:00 GMT`.
  ///
  /// Every field, including the weekday and month names, is taken from the
  /// UTC representation of this moment.
  String get httpDateFormat {
    final d = toUtc();
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${smallWeekdays[d.weekday]}, ${twoDigits(d.day)} '
        '${smallMonthsNames[d.month]} ${d.year.toString().padLeft(4, '0')} '
        '${twoDigits(d.hour)}:${twoDigits(d.minute)}:${twoDigits(d.second)} '
        'GMT';
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
  /// The resulting string can be parsed back using [DateTime.parse].
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

  /// The number of calendar days from this date to today.
  ///
  /// Positive for past dates, negative for future dates, `0` for today.
  /// Daylight-saving transitions do not affect the count.
  int get passedDays => _calendarDaysBetween(this, DateTime.now());

  /// Returns the duration remaining until this DateTime.
  Duration get remainingDuration => difference(DateTime.now());

  /// The number of calendar days from today to this date.
  ///
  /// Positive for future dates, negative for past dates, `0` for today.
  /// Daylight-saving transitions do not affect the count.
  int get remainingDays => _calendarDaysBetween(DateTime.now(), this);

  /// Whether this date and [other] fall in the same calendar year.
  bool isSameYearAs(DateTime other) => year == other.year;

  /// Whether this date and [other] fall in the same calendar month of the
  /// same year.
  bool isSameMonthAs(DateTime other) =>
      isSameYearAs(other) && month == other.month;

  /// Whether this date and [other] fall on the same calendar day.
  ///
  /// Compares the year, month, and day fields as they are; it does not
  /// convert either value to another time zone first.
  bool isSameDayAs(DateTime other) => isSameMonthAs(other) && day == other.day;

  /// Whether this date and [other] fall in the same hour of the same day.
  bool isSameHourAs(DateTime other) => isSameDayAs(other) && hour == other.hour;

  /// Whether this date and [other] fall in the same minute of the same hour.
  bool isSameMinuteAs(DateTime other) =>
      isSameHourAs(other) && minute == other.minute;

  /// Whether this date and [other] fall in the same second of the same
  /// minute.
  bool isSameSecondAs(DateTime other) =>
      isSameMinuteAs(other) && second == other.second;

  /// Whether this date and [other] fall in the same millisecond of the same
  /// second.
  bool isSameMillisecondAs(DateTime other) =>
      isSameSecondAs(other) && millisecond == other.millisecond;

  /// Whether this date and [other] share every field down to the
  /// microsecond.
  bool isSameMicrosecondAs(DateTime other) =>
      isSameMillisecondAs(other) && microsecond == other.microsecond;

  /// Midnight at the start of this date's day, in the same time zone.
  DateTime get startOfDay => _dateOnly(this);

  /// Midnight on the first day of this date's month, in the same time zone.
  DateTime get startOfMonth => _date(isUtc, year, month);

  /// Midnight on January 1 of this date's year, in the same time zone.
  DateTime get startOfYear => _date(isUtc, year);

  /// This date at midnight, in the same time zone. Same as [startOfDay].
  DateTime get dateOnly => _dateOnly(this);

  /// The days of a month calendar grid that contains this date's month.
  ///
  /// The grid starts on the Monday on or before the first day of the month
  /// and ends on the Sunday on or after the last day, so its length is
  /// always a multiple of seven and it includes days from the neighboring
  /// months. Each entry is midnight in this date's time zone.
  List<DateTime> get daysInMonth {
    final first = firstDayOfMonth;
    // Mon(1) -> 0 leading days, Sun(7) -> 6 leading days (ISO 8601 weeks).
    final daysBefore = (first.weekday - 1) % DateTime.daysPerWeek;
    final firstToDisplay = _addCalendarDays(first, -daysBefore);
    final last = lastDayOfMonth;
    // Fill the last week through Sunday; the end bound is exclusive.
    final daysAfter = DateTime.daysPerWeek - last.weekday + 1;
    final lastToDisplay = _addCalendarDays(last, daysAfter);
    return firstToDisplay.daysUpTo(lastToDisplay).toList();
  }

  /// The previous calendar day at the same wall-clock time.
  DateTime get previousDay => addDays(-1);

  /// The next calendar day at the same wall-clock time.
  DateTime get nextDay => addDays(1);

  /// The same weekday one week earlier, at the same wall-clock time.
  DateTime get previousWeek => addDays(-DateTime.daysPerWeek);

  /// The same weekday one week later, at the same wall-clock time.
  DateTime get nextWeek => addDays(DateTime.daysPerWeek);

  /// Returns a DateTime representing the first day of the week for this DateTime.
  ///
  /// [startOfWeek] is an optional parameter specifying the weekday that is considered
  /// the start of the week (1 for Monday, 7 for Sunday, etc.). Defaults to Monday.
  ///
  /// The result keeps this date's wall-clock time and time zone.
  DateTime firstDayOfWeek({int startOfWeek = DateTime.monday}) {
    // Normalize the startOfWeek value to be within the range of 1-7
    final normalizedStartOfWeek =
        ((startOfWeek - 1) % DateTime.daysPerWeek) + 1;

    // Calculate the difference between the current weekday and normalizedStartOfWeek
    // and adjust it to be positive and within the range of 0-6
    final daysToSubtract =
        (weekday - normalizedStartOfWeek + DateTime.daysPerWeek) %
        DateTime.daysPerWeek;

    return addDays(-daysToSubtract);
  }

  /// Returns a DateTime representing the last day of the week for this DateTime.
  ///
  /// [startOfWeek] is an optional parameter specifying the weekday that is considered
  /// the start of the week (1 for Monday, 7 for Sunday, etc.). Defaults to Monday.
  ///
  /// The result keeps this date's wall-clock time and time zone.
  DateTime lastDayOfWeek({int startOfWeek = DateTime.monday}) {
    final normalizedStartOfWeek =
        ((startOfWeek - 1) % DateTime.daysPerWeek) + 1;
    final daysToAdd =
        (DateTime.daysPerWeek - weekday + normalizedStartOfWeek - 1) %
        DateTime.daysPerWeek;
    return addDays(daysToAdd);
  }

  /// Midnight on the first day of the previous month, in the same time zone.
  DateTime get previousMonth => _date(isUtc, year, month - 1);

  /// Midnight on the first day of the next month, in the same time zone.
  DateTime get nextMonth => _date(isUtc, year, month + 1);

  /// Midnight on the first day of this date's month, in the same time zone.
  /// Same as [startOfMonth].
  DateTime get firstDayOfMonth => _date(isUtc, year, month);

  /// Midnight on the last day of this date's month, in the same time zone.
  DateTime get lastDayOfMonth => _date(isUtc, year, month + 1, 0);

  /// Moves this date by [years] calendar years, keeping the wall-clock time.
  ///
  /// When the target month is shorter, the day is clamped to its last day,
  /// so February 29 plus one year is February 28. Negative values move back.
  DateTime addYears(int years) => addMonths(years * 12);

  /// Moves this date by [months] calendar months, keeping the wall-clock
  /// time.
  ///
  /// When the target month is shorter, the day is clamped to its last day,
  /// so March 31 minus one month is the last day of February. Negative values
  /// move back across year boundaries.
  DateTime addMonths(int months) {
    final monthIndex = year * 12 + (month - 1) + months;
    final newMonth = monthIndex % 12 + 1;
    final newYear = (monthIndex - (newMonth - 1)) ~/ 12;
    final lastDay = DateTime.utc(newYear, newMonth + 1, 0).day;
    return _withDate(this, newYear, newMonth, day < lastDay ? day : lastDay);
  }

  /// Moves this date back by [years] calendar years. See [addYears].
  DateTime subtractYears(int years) => addYears(-years);

  /// Moves this date back by [months] calendar months. See [addMonths].
  DateTime subtractMonths(int months) => addMonths(-months);

  /// Returns the earlier of this DateTime and [that].
  ///
  /// Returns [that] when both are the same moment.
  DateTime min(DateTime that) => isBefore(that) ? this : that;

  /// Returns the later of this DateTime and [that].
  ///
  /// Returns [that] when both are the same moment.
  DateTime max(DateTime that) => isAfter(that) ? this : that;

  /// Moves this date by [amount] calendar days, keeping the wall-clock time.
  ///
  /// Negative values move back. Unlike `add(Duration(days: amount))`, the
  /// result keeps its time of day across daylight-saving transitions.
  DateTime addDays(int amount) => _addCalendarDays(this, amount);

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

  /// Moves this date back by [amount] calendar days. See [addDays].
  DateTime subtractDays(int amount) => addDays(-amount);

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

  /// Checks if this DateTime occurs within the same week as another DateTime,
  /// regardless of time zone.  Considers a week to start on Monday.
  bool isSameWeekAs(DateTime other) {
    final thisNoonUtc = DateTime.utc(year, month, day, 12);
    final otherNoonUtc = DateTime.utc(other.year, other.month, other.day, 12);

    if (thisNoonUtc.difference(otherNoonUtc).inDays.abs() >= 7) return false;

    // Find the start of the week (Monday) for both dates
    final startOfWeekThis = thisNoonUtc.subtract(
      Duration(days: thisNoonUtc.weekday - 1),
    );
    final startOfWeekOther = otherNoonUtc.subtract(
      Duration(days: otherNoonUtc.weekday - 1),
    );

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
  /// Throws [ArgumentError] if [start] is after [end] (after any
  /// normalization and time stripping).
  bool isBetween(
    DateTime start,
    DateTime end, {
    bool inclusiveStart = true,
    bool inclusiveEnd = false,
    bool ignoreTime = false,
    bool normalize = false,
  }) {
    var self = this;
    var compareStart = start;
    var compareEnd = end;

    // Normalize to UTC if requested so all three dates live in the same clock.
    if (normalize) {
      self = self.toUtc();
      compareStart = start.toUtc();
      compareEnd = end.toUtc();
    }

    // Strip time components if requested while preserving UTC state.
    if (ignoreTime) {
      self = _dateOnly(self);
      compareStart = _dateOnly(compareStart);
      compareEnd = _dateOnly(compareEnd);
    }

    if (compareStart.isAfter(compareEnd)) {
      throw ArgumentError(
        'Start date ($compareStart) must be before or equal to end date ($compareEnd)',
      );
    }

    return (inclusiveStart
            ? !self.isBefore(compareStart)
            : self.isAfter(compareStart)) &&
        (inclusiveEnd ? !self.isAfter(compareEnd) : self.isBefore(compareEnd));
  }

  /// Clamps this DateTime between [start] and [end].
  ///
  /// Returns [start] if this is before the range, [end] if after, or `this`
  /// if it already falls within the range.
  ///
  /// Throws [ArgumentError] if [start] is after [end].
  DateTime clampBetween(DateTime start, DateTime end) {
    if (start.isAfter(end)) {
      throw ArgumentError(
        'Start date ($start) must be before or equal to end date ($end)',
      );
    }
    if (isBefore(start)) return start;
    if (isAfter(end)) return end;
    return this;
  }

  /// The absolute number of calendar days between this date and [other]
  /// (or today when [other] is omitted).
  ///
  /// Ignores the time of day, and daylight-saving transitions do not affect
  /// the count.
  int daysDifferenceTo([DateTime? other]) =>
      _calendarDaysBetween(this, other ?? DateTime.now()).abs();

  /// Generates one [DateTime] per calendar day, starting at this moment
  /// (inclusive) and stopping before [end] (exclusive).
  ///
  /// Each entry is computed from this moment's wall-clock time, so the
  /// sequence stays aligned across daylight-saving transitions. A wall-clock
  /// time that does not exist on one day (a skipped hour) is shifted on that
  /// day only, and one that happens twice (a repeated hour) resolves to its
  /// first occurrence, unless this moment is itself such a repeat: then its
  /// offset is kept, so the first entry is always this moment.
  Iterable<DateTime> daysUpTo(DateTime end) sync* {
    final repeat = _isRepeat(this);
    for (var offset = 0; ; offset++) {
      final current = _addCalendarDays(this, offset, repeat: repeat);
      if (!current.isBefore(end)) return;
      yield current;
    }
  }

  /// Calculates a person's age from this birth date to today, as whole
  /// years, months, and days.
  ///
  /// A February 29 birthday counts as February 28 in non-leap years.
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

  /// Returns true if this date falls on a weekend.
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Returns true if this date falls on a weekday.
  bool get isWeekday => !isWeekend;

  /// Rounds this date to the nearest instant whose wall clock shows a
  /// multiple of [duration]; exact halves round up.
  ///
  /// The result is [floorTo] or [ceilTo], whichever is closer in elapsed
  /// time; [floorTo] describes the alignment. Returns this date unchanged for
  /// [Duration.zero]; a negative [duration] behaves like its magnitude.
  DateTime roundTo(Duration duration) {
    final step = duration.inMicroseconds.abs();
    if (step == 0) return this;
    final floor = _floorTo(this, step);
    if (floor == this) return this;
    final ceil = _ceilTo(this, step);
    return difference(floor) < ceil.difference(this) ? floor : ceil;
  }

  /// The latest instant at or before this date whose wall clock shows a
  /// multiple of [duration], counted from midnight on January 1, 1970.
  ///
  /// A local date aligns to the local wall clock, so whole hours stay whole
  /// in zones with a half-hour offset. Around a clock change, an aligned
  /// time the clocks skip counts as reached at the moment they jump forward,
  /// and one they show again after falling back counts again, so by the
  /// hour the second 01:30 of the night floors to the second 01:00.
  ///
  /// Whole-day steps count calendar dates instead: the result is the first
  /// moment of this date, or of the aligned date before it, so
  /// `floorTo(const Duration(days: 1))` always equals [startOfDay]. Because
  /// the count starts on January 1, 1970, a Thursday, a 7-day step lands on
  /// Thursdays; use [firstDayOfWeek] for calendar weeks.
  ///
  /// Returns this date unchanged for [Duration.zero]; a negative [duration]
  /// behaves like its magnitude.
  DateTime floorTo(Duration duration) {
    final step = duration.inMicroseconds.abs();
    return step == 0 ? this : _floorTo(this, step);
  }

  /// The earliest instant at or after this date whose wall clock shows a
  /// multiple of [duration]. Clock changes are handled as in [floorTo].
  ///
  /// For whole-day steps the result is the first moment of the next aligned
  /// date, or that date's repeated midnight when the clocks fell back past
  /// the first one before this date.
  ///
  /// Returns this date unchanged for [Duration.zero]; a negative [duration]
  /// behaves like its magnitude.
  DateTime ceilTo(Duration duration) {
    final step = duration.inMicroseconds.abs();
    if (step == 0 || _floorTo(this, step) == this) return this;
    return _ceilTo(this, step);
  }

  /// Moves [days] business days forward (or back, when negative), skipping
  /// Saturdays and Sundays. Keeps the wall-clock time.
  DateTime addBusinessDays(int days) {
    var current = this;
    var remaining = days.abs();
    final step = days >= 0 ? 1 : -1;
    var offset = 0;
    final repeat = _isRepeat(this);

    while (remaining > 0) {
      offset += step;
      // Always step from the original wall-clock time so a skipped hour on
      // one day cannot shift every later day.
      current = _addCalendarDays(this, offset, repeat: repeat);
      if (current.isWeekday) {
        remaining--;
      }
    }
    return current;
  }

  // ---------------------------------------------------------------------
  // 7.0.0 aliases, removed in 8.0.0. `dart fix --apply` rewrites callers to
  // the replacement named in each deprecation message.
  // ---------------------------------------------------------------------

  /// Deprecated alias of [isSameYearAs].
  @Deprecated('Use isSameYearAs. This alias will be removed in 8.0.0.')
  bool isAtSameYearAs(DateTime other) => isSameYearAs(other);

  /// Deprecated alias of [isSameMonthAs].
  @Deprecated('Use isSameMonthAs. This alias will be removed in 8.0.0.')
  bool isAtSameMonthAs(DateTime other) => isSameMonthAs(other);

  /// Deprecated alias of [isSameDayAs].
  @Deprecated('Use isSameDayAs. This alias will be removed in 8.0.0.')
  bool isAtSameDayAs(DateTime other) => isSameDayAs(other);

  /// Deprecated alias of [isSameHourAs].
  @Deprecated('Use isSameHourAs. This alias will be removed in 8.0.0.')
  bool isAtSameHourAs(DateTime other) => isSameHourAs(other);

  /// Deprecated alias of [isSameMinuteAs].
  @Deprecated('Use isSameMinuteAs. This alias will be removed in 8.0.0.')
  bool isAtSameMinuteAs(DateTime other) => isSameMinuteAs(other);

  /// Deprecated alias of [isSameSecondAs].
  @Deprecated('Use isSameSecondAs. This alias will be removed in 8.0.0.')
  bool isAtSameSecondAs(DateTime other) => isSameSecondAs(other);

  /// Deprecated alias of [isSameMillisecondAs].
  @Deprecated('Use isSameMillisecondAs. This alias will be removed in 8.0.0.')
  bool isAtSameMillisecondAs(DateTime other) => isSameMillisecondAs(other);

  /// Deprecated alias of [isSameMicrosecondAs].
  @Deprecated('Use isSameMicrosecondAs. This alias will be removed in 8.0.0.')
  bool isAtSameMicrosecondAs(DateTime other) => isSameMicrosecondAs(other);

  /// Deprecated alias of [addYears].
  @Deprecated('Use addYears. This alias will be removed in 8.0.0.')
  DateTime addOrSubtractYears(int years) => addYears(years);

  /// Deprecated alias of [addMonths].
  @Deprecated('Use addMonths. This alias will be removed in 8.0.0.')
  DateTime addOrSubtractMonths(int months) => addMonths(months);

  /// Deprecated alias of [addDays].
  @Deprecated('Use addDays. This alias will be removed in 8.0.0.')
  DateTime addOrSubtractDays(int days) => addDays(days);

  /// Deprecated alias of [addMinutes].
  @Deprecated('Use addMinutes. This alias will be removed in 8.0.0.')
  DateTime addOrSubtractMinutes(int minutes) => addMinutes(minutes);

  /// Deprecated alias of [addSeconds].
  @Deprecated('Use addSeconds. This alias will be removed in 8.0.0.')
  DateTime addOrSubtractSeconds(int seconds) => addSeconds(seconds);

  /// Deprecated alias of [addMilliseconds].
  @Deprecated('Use addMilliseconds. This alias will be removed in 8.0.0.')
  DateTime addOrSubtractMilliseconds(int milliseconds) =>
      addMilliseconds(milliseconds);

  /// Deprecated alias of [addMicroseconds].
  @Deprecated('Use addMicroseconds. This alias will be removed in 8.0.0.')
  DateTime addOrSubtractMicroseconds(int microseconds) =>
      addMicroseconds(microseconds);

  /// Deprecated alias of [nextDay].
  @Deprecated('Use nextDay. This alias will be removed in 8.0.0.')
  DateTime get tomorrow => nextDay;

  /// Deprecated alias of [previousDay].
  @Deprecated('Use previousDay. This alias will be removed in 8.0.0.')
  DateTime get yesterday => previousDay;
}

/// Builds a date at midnight in UTC or local time; out-of-range months and
/// days roll over the way the [DateTime] constructors do.
DateTime _date(bool isUtc, int year, [int month = 1, int day = 1]) =>
    isUtc ? DateTime.utc(year, month, day) : _startOfDate(year, month, day);

DateTime _dateOnly(DateTime date) =>
    _date(date.isUtc, date.year, date.month, date.day);

/// The first moment of a local calendar date: the first occurrence of its
/// midnight, or the moment the clocks jumped into the date when they skipped
/// midnight.
DateTime _startOfDate(int year, int month, int day) {
  final start = _local(year, month, day);
  final micros = start.microsecondsSinceEpoch;
  final offset = _offsetAt(micros);
  final midnight = DateTime.utc(year, month, day).microsecondsSinceEpoch;
  if (micros + offset == midnight) return start;
  // Midnight was skipped, and start is where it would have been before the
  // jump; the jump itself came earlier.
  return DateTime.fromMicrosecondsSinceEpoch(
    _offsetChange(midnight - offset, micros),
  );
}

/// The local time that shows these wall-clock fields, resolved like the
/// local [DateTime] constructor resolves it: a time the clocks repeat gives
/// its first occurrence, and a time they skip gives the moment it would have
/// been before the jump, which is later by the length of the jump.
DateTime _local(
  int year,
  int month,
  int day, [
  int hour = 0,
  int minute = 0,
  int second = 0,
  int millisecond = 0,
  int microsecond = 0,
]) {
  final resolved = DateTime(
    year,
    month,
    day,
    hour,
    minute,
    second,
    millisecond,
    microsecond,
  );
  // The VM looks for an earlier occurrence only two hours back, but clocks
  // have repeated up to 23 hours (Kwajalein, 1969). Clock changes are about
  // a week apart or more, so an earlier occurrence needs a larger offset a
  // day before.
  final micros = resolved.microsecondsSinceEpoch;
  final dayBefore = DateTime.fromMicrosecondsSinceEpoch(
    micros - Duration.microsecondsPerDay,
  );
  if (dayBefore.timeZoneOffset <= resolved.timeZoneOffset) return resolved;
  final earlierOffset = _offsetAt(dayBefore.microsecondsSinceEpoch);
  final first =
      DateTime.utc(
        year,
        month,
        day,
        hour,
        minute,
        second,
        millisecond,
        microsecond,
      ).microsecondsSinceEpoch -
      earlierOffset;
  return first < micros && _offsetAt(first) == earlierOffset
      ? DateTime.fromMicrosecondsSinceEpoch(first)
      : resolved;
}

/// Rebuilds [date] on another calendar day while keeping its wall-clock time
/// and time zone.
///
/// A time the clocks skip moves forward by the length of the jump, and a
/// time they repeat resolves to its first occurrence. The exception is a
/// [date] that is itself the repeat ([repeat], computed when omitted): the
/// result keeps its offset when the target time has that offset too, so
/// `addDays(0)` returns [date].
DateTime _withDate(
  DateTime date,
  int year,
  int month,
  int day, {
  bool? repeat,
}) {
  if (date.isUtc) {
    return DateTime.utc(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }
  final moved = _local(
    year,
    month,
    day,
    date.hour,
    date.minute,
    date.second,
    date.millisecond,
    date.microsecond,
  );
  return (repeat ?? _isRepeat(date)) ? _keepOffset(moved, date) : moved;
}

/// The other occurrence of [candidate]'s wall-clock time when that one has
/// [reference]'s offset, otherwise [candidate].
DateTime _keepOffset(DateTime candidate, DateTime reference) {
  final offset = _offsetAt(reference.microsecondsSinceEpoch);
  final micros = candidate.microsecondsSinceEpoch;
  final candidateOffset = _offsetAt(micros);
  if (candidateOffset == offset) return candidate;
  final shifted = micros + candidateOffset - offset;
  // With that offset, shifted shows the same wall clock as candidate.
  return _offsetAt(shifted) == offset
      ? DateTime.fromMicrosecondsSinceEpoch(shifted)
      : candidate;
}

/// Whether [date] is a local time that is the second occurrence of a
/// repeated wall-clock time.
bool _isRepeat(DateTime date) =>
    !date.isUtc &&
    _local(
          date.year,
          date.month,
          date.day,
          date.hour,
          date.minute,
          date.second,
          date.millisecond,
          date.microsecond,
        ) !=
        date;

DateTime _addCalendarDays(DateTime date, int days, {bool? repeat}) =>
    _withDate(date, date.year, date.month, date.day + days, repeat: repeat);

/// Floor division that rounds toward negative infinity for any sign of [a];
/// [b] must be positive.
int _floorDiv(int a, int b) => (a - a % b) ~/ b;

/// Whether every time field of [date] is zero.
bool _isMidnight(DateTime date) =>
    date.hour == 0 &&
    date.minute == 0 &&
    date.second == 0 &&
    date.millisecond == 0 &&
    date.microsecond == 0;

/// [date]'s calendar date as a count of days from January 1, 1970.
int _dayIndex(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// The first moment of the local calendar date [index] days after
/// January 1, 1970.
DateTime _startOfDayIndex(int index) {
  final date = DateTime.utc(1970, 1, 1 + index);
  return _startOfDate(date.year, date.month, date.day);
}

/// [date] aligned down to a multiple of [step] microseconds, as
/// [DHUDateExtensions.floorTo] describes.
DateTime _floorTo(DateTime date, int step) {
  final micros = date.microsecondsSinceEpoch;
  if (date.isUtc) {
    return DateTime.fromMicrosecondsSinceEpoch(
      _floorDiv(micros, step) * step,
      isUtc: true,
    );
  }
  if (step % Duration.microsecondsPerDay != 0) {
    return DateTime.fromMicrosecondsSinceEpoch(_floorLocal(micros, step));
  }
  final index = _dayIndex(date);
  return _startOfDayIndex(
    index - index % (step ~/ Duration.microsecondsPerDay),
  );
}

/// [date], which [_floorTo] moves, aligned up to a multiple of [step]
/// microseconds, as [DHUDateExtensions.ceilTo] describes.
DateTime _ceilTo(DateTime date, int step) {
  final micros = date.microsecondsSinceEpoch;
  if (date.isUtc) {
    return DateTime.fromMicrosecondsSinceEpoch(
      -_floorDiv(-micros, step) * step,
      isUtc: true,
    );
  }
  if (step % Duration.microsecondsPerDay != 0) {
    return DateTime.fromMicrosecondsSinceEpoch(_ceilLocal(micros, step));
  }
  final days = step ~/ Duration.microsecondsPerDay;
  final index = _dayIndex(date);
  // A repeated midnight that starts its date again, after the clocks fell
  // back past it into the day before, is aligned too; floorTo returns the
  // first occurrence instead. (A repeat inside its own date, as in the
  // Azores, starts nothing.)
  if (index % days == 0 &&
      _isMidnight(date) &&
      _dayIndex(DateTime.fromMicrosecondsSinceEpoch(micros - 1)) < index) {
    return date;
  }
  for (var next = index - index % days + days; ; next += days) {
    final start = _startOfDayIndex(next);
    if (!start.isBefore(date)) return start;
    // The clocks showed that midnight before date, then fell back past it.
    final again = _keepOffset(start, date);
    if (!again.isBefore(date)) return again;
  }
}

/// The local UTC offset, in microseconds, at [micros] since the epoch, as
/// the local wall-clock fields show it.
///
/// On the web, [DateTime.timeZoneOffset] is rounded to whole minutes, while
/// the fields use the exact offset, such as a local mean time with seconds.
int _offsetAt(int micros) {
  final date = DateTime.fromMicrosecondsSinceEpoch(micros);
  return DateTime.utc(
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        date.second,
        date.millisecond,
        date.microsecond,
      ).microsecondsSinceEpoch -
      micros;
}

/// The first instant after [from], at or before [to], whose local offset
/// differs from the offset at [from]. The offset at [to] must differ, and at
/// most one change may lie in between.
///
/// The instant just before the result has the offset at [from].
int _offsetChange(int from, int to) {
  final offset = _offsetAt(from);
  var low = from;
  var high = to;
  while (high - low > 1) {
    final middle = low + (high - low) ~/ 2;
    if (_offsetAt(middle) == offset) {
      low = middle;
    } else {
      high = middle;
    }
  }
  return high;
}

/// The longest stretch checked for a clock change at once. Changes are at
/// least six days apart in the time zone database (the closest since 1900
/// were in Cambridge Bay in 2000), so a day holds at most one.
const _changeFreeSpan = Duration.microsecondsPerDay;

/// The latest instant at or before [micros] whose local wall clock shows a
/// multiple of [step]; an aligned time skipped by a forward jump counts as
/// reached at the jump.
int _floorLocal(int micros, int step) {
  var receiver = micros;
  var offset = _offsetAt(receiver);
  while (true) {
    final wall = _floorDiv(receiver + offset, step) * step;
    final candidate = wall - offset;
    // Check at most a day at once, so a change cannot hide in between.
    final probe = candidate > receiver - _changeFreeSpan
        ? candidate
        : receiver - _changeFreeSpan;
    final probeOffset = _offsetAt(probe);
    if (probeOffset == offset) {
      if (probe == candidate) return candidate;
      receiver = probe; // nothing aligned in between
      continue;
    }
    // The clocks changed between the probe and the receiver.
    final change = _offsetChange(probe, receiver);
    // Jumped forward over the aligned time: it was skipped.
    if (wall >= change + probeOffset) return change;
    // The aligned time, or a later one, happened before the change.
    receiver = change - 1;
    offset = probeOffset;
  }
}

/// The earliest instant at or after [micros] whose local wall clock shows a
/// multiple of [step]; an aligned time skipped by a forward jump counts as
/// reached at the jump.
int _ceilLocal(int micros, int step) {
  var receiver = micros;
  var offset = _offsetAt(receiver);
  while (true) {
    final wall = -_floorDiv(-(receiver + offset), step) * step;
    final candidate = wall - offset;
    // Check at most a day at once, so a change cannot hide in between.
    final probe = candidate < receiver + _changeFreeSpan
        ? candidate
        : receiver + _changeFreeSpan;
    final probeOffset = _offsetAt(probe);
    if (probeOffset == offset) {
      if (probe == candidate) return candidate;
      receiver = probe; // nothing aligned in between
      continue;
    }
    // The clocks change between the receiver and the probe.
    final change = _offsetChange(receiver, probe);
    final laterOffset = _offsetAt(change);
    // Jumping forward over the aligned time: it is skipped.
    if (wall < change + laterOffset) return change;
    // The aligned time, or an earlier one, happens after the change.
    receiver = change;
    offset = laterOffset;
  }
}

/// Calendar days from [from]'s date to [to]'s date, ignoring the time of day.
///
/// Both dates are projected onto UTC midnights, so a daylight-saving day of
/// 23 or 25 hours still counts as one day.
int _calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
