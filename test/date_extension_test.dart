import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('DHUDateExtensions', () {
    final testDate = DateTime(2022, 5, 10, 10, 30);

    test('local', () {
      expect(testDate.local, testDate.toLocal());
    });

    test('format', () {
      expect(testDate.format('yyyy-MM-dd'), '2022-05-10');
    });

    test('toUtcIso', () {
      expect(testDate.toUtcIso, testDate.toUtc().toIso8601String());
    });

    test('copyWith', () {
      final updated = testDate.copyWith(month: 7, day: 2, minute: 45);
      expect(updated, DateTime(2022, 7, 2, 10, 45));
    });

    test('copyWith preserves utc flag', () {
      final utcDate = DateTime.utc(2022, 5, 10, 10, 30);
      final updated = utcDate.copyWith(day: 11);
      expect(updated.isUtc, isTrue);
      expect(updated, DateTime.utc(2022, 5, 11, 10, 30));
    });

    test('copyWith can switch to utc', () {
      final updated = testDate.copyWith(isUtc: true, hour: 5);
      expect(updated.isUtc, isTrue);
      expect(updated, DateTime.utc(2022, 5, 10, 5, 30));
    });

    test('operator +', () {
      const duration = Duration(days: 1);
      expect(testDate + duration, testDate.add(duration));
    });

    test('operator -', () {
      const duration = Duration(days: 1);
      expect(testDate - duration, testDate.subtract(duration));
    });

    test('passedDuration', () {
      final duration = DateTime.now().difference(testDate);
      expect(testDate.passedDuration.inDays, duration.inDays);
    });

    test('passedDays', () {
      final days = DateTime(
        testDate.year,
        testDate.month,
        testDate.day,
      ).daysDifferenceTo(DateTime.now());
      expect(testDate.passedDays, days);
    });

    test('remainingDuration', () {
      final duration = testDate.difference(DateTime.now());
      expect(testDate.remainingDuration.inDays, duration.inDays);
    });

    group('remainingDays', () {
      test('should return positive difference for future date', () {
        final futureDate = DateTime.now().dateOnly.add(const Duration(days: 5));
        expect(futureDate.remainingDays, greaterThan(0));
      });

      test('should return 0 for today', () {
        final now = DateTime.now();
        expect(now.remainingDays, 0);
      });

      test('should return negative difference for past date', () {
        final pastDate = DateTime.now().dateOnly.subtract(
          const Duration(days: 3),
        );
        expect(pastDate.remainingDays, lessThan(0));
      });
    });

    test('isSameYearAs', () {
      final otherDate = DateTime(2022, 12, 31);
      expect(testDate.isSameYearAs(otherDate), true);
    });

    test('isSameYearAs', () {
      final otherDate = DateTime(2022, 1, 1);
      expect(testDate.isSameYearAs(otherDate), true);
    });

    test('isSameMonthAs', () {
      final otherDate = DateTime(2022, 5);
      expect(testDate.isSameMonthAs(otherDate), true);
    });

    test('isSameMonthAs', () {
      final otherDate = DateTime(2022, 5, 1);
      expect(testDate.isSameMonthAs(otherDate), true);
    });

    test('isSameDayAs', () {
      final otherDate = DateTime(2022, 5, 10);
      expect(testDate.isSameDayAs(otherDate), true);
    });

    test('isSameHourAs', () {
      final otherDate = DateTime(2022, 5, 10, 10);
      expect(testDate.isSameHourAs(otherDate), true);
    });

    test('isSameMinuteAs', () {
      final otherDate = DateTime(2022, 5, 10, 10, 30);
      expect(testDate.isSameMinuteAs(otherDate), true);
    });

    test('isSameSecondAs', () {
      final otherDate = DateTime(2022, 5, 10, 10, 30);
      expect(testDate.isSameSecondAs(otherDate), true);
    });

    test('isSameMillisecondAs', () {
      final otherDate = DateTime(2022, 5, 10, 10, 30);
      expect(testDate.isSameMillisecondAs(otherDate), true);
    });

    test('isSameMicrosecondAs', () {
      final otherDate = DateTime(2022, 5, 10, 10, 30);
      expect(testDate.isSameMicrosecondAs(otherDate), true);
    });

    test('startOfDay', () {
      final startOfDay = DateTime(2022, 5, 10);
      expect(testDate.startOfDay, startOfDay);
    });

    test('startOfMonth', () {
      final startOfMonth = DateTime(2022, 5);
      expect(testDate.startOfMonth, startOfMonth);
    });

    test('startOfYear', () {
      final startOfYear = DateTime(2022);
      expect(testDate.startOfYear, startOfYear);
    });

    test('nextDay', () {
      final tomorrow = testDate.add(const Duration(days: 1));
      expect(testDate.nextDay, tomorrow);
    });

    test('previousDay', () {
      final yesterday = testDate.subtract(const Duration(days: 1));
      expect(testDate.previousDay, yesterday);
    });

    test('dateOnly', () {
      final dateOnly = DateTime(2022, 5, 10);
      expect(testDate.dateOnly, dateOnly);
    });

    test('daysInMonth', () {
      final daysInMonth = testDate.daysInMonth
          .where((date) => date.month == testDate.month)
          .toList();
      expect(daysInMonth.length, greaterThanOrEqualTo(28));
      expect(daysInMonth.length, lessThanOrEqualTo(31));
    });

    test('daysInMonth alignment for Monday start', () {
      // Oct 2023 starts on a Sunday (Oct 1st 2023 is Sunday)
      final oct1 = DateTime(2023, 10, 1);
      final days = oct1.daysInMonth;
      // Monday start: Sun(1st) is the 7th day.
      // Grid starts Mon Sept 25.
      expect(days.first.day, equals(25));
      expect(days.first.month, equals(9));
    });

    test('daysInMonth ends on Sunday without extra week', () {
      // April 2023 ends on a Sunday (Apr 30, 2023).
      final april1 = DateTime(2023, 4, 1);
      final days = april1.daysInMonth;
      expect(days.last, DateTime(2023, 4, 30));
    });

    test('previousDay', () {
      final previousDay = testDate.add(const Duration(days: -1));
      expect(testDate.previousDay, previousDay);
    });

    test('nextDay', () {
      final nextDay = testDate.add(const Duration(days: 1));
      expect(testDate.nextDay, nextDay);
    });

    test('previousWeek', () {
      final previousWeek = testDate.subtract(const Duration(days: 7));
      expect(testDate.previousWeek, previousWeek);
    });

    test('nextWeek', () {
      final nextWeek = testDate.add(const Duration(days: 7));
      expect(testDate.nextWeek, nextWeek);
    });

    test('firstDayOfWeek', () {
      expect(
        testDate.firstDayOfWeek(),
        DateTime(2022, 5, 9, testDate.hour, testDate.minute),
      );
    });

    test('lastDayOfWeek', () {
      expect(
        testDate.lastDayOfWeek(),
        DateTime(2022, 5, 15, testDate.hour, testDate.minute),
      );
    });

    // Optionally, test with Sunday as the start of the week
    test('firstDayOfWeek (Sunday start)', () {
      expect(
        testDate.firstDayOfWeek(startOfWeek: DateTime.sunday),
        DateTime(2022, 5, 8, testDate.hour, testDate.minute),
      );
    });

    test('lastDayOfWeek (Sunday start)', () {
      expect(
        testDate.lastDayOfWeek(startOfWeek: DateTime.sunday),
        DateTime(2022, 5, 14, testDate.hour, testDate.minute),
      );
    });

    test('previousMonth', () {
      final previousMonth = DateTime(2022, 4);
      expect(testDate.previousMonth, previousMonth);
    });

    test('nextMonth', () {
      final nextMonth = DateTime(2022, 6);
      expect(testDate.nextMonth, nextMonth);
    });

    test('firstDayOfMonth', () {
      final firstDayOfMonth = DateTime(2022, 5);
      expect(testDate.firstDayOfMonth, firstDayOfMonth);
    });

    test('lastDayOfMonth', () {
      final lastDayOfMonth = DateTime(2022, 5, 31);
      expect(testDate.lastDayOfMonth, lastDayOfMonth);
    });

    test('addYears', () {
      final nextYear = testDate.addYears(1);
      final previousYear = testDate.addYears(-1);
      expect(nextYear, DateTime(2023, 5, 10, 10, 30));
      expect(previousYear, DateTime(2021, 5, 10, 10, 30));
    });

    test('addMonths', () {
      final nextMonth = testDate.addMonths(1);
      final previousMonth = testDate.addMonths(-1);
      expect(nextMonth, DateTime(2022, 6, 10, 10, 30));
      expect(previousMonth, DateTime(2022, 4, 10, 10, 30));
    });

    test('addDays', () {
      final nextDay = testDate.addDays(1);
      final previousDay = testDate.addDays(-1);
      expect(nextDay, DateTime(2022, 5, 11, 10, 30));
      expect(previousDay, DateTime(2022, 5, 9, 10, 30));
    });

    test('addMinutes', () {
      final nextMinute = testDate.addMinutes(1);
      final previousMinute = testDate.addMinutes(-1);
      expect(nextMinute, DateTime(2022, 5, 10, 10, 31));
      expect(previousMinute, DateTime(2022, 5, 10, 10, 29));
    });

    test('addSeconds', () {
      final nextSecond = testDate.addSeconds(1);
      final previousSecond = testDate.addSeconds(-1);
      expect(nextSecond, DateTime(2022, 5, 10, 10, 30, 1));
      expect(previousSecond, DateTime(2022, 5, 10, 10, 29, 59));
    });

    test('min', () {
      final earlierDate = DateTime(2022, 5, 9);
      expect(testDate.min(earlierDate), earlierDate);
    });

    test('max', () {
      final laterDate = DateTime(2022, 5, 11);
      expect(testDate.max(laterDate), laterDate);
    });

    group('clampBetween', () {
      final start = DateTime(2022, 5, 1);
      final end = DateTime(2022, 5, 31);

      test('returns start when before range', () {
        final before = DateTime(2022, 4, 30);
        expect(before.clampBetween(start, end), start);
      });

      test('returns end when after range', () {
        final after = DateTime(2022, 6, 1);
        expect(after.clampBetween(start, end), end);
      });

      test('returns same value when in range', () {
        expect(testDate.clampBetween(start, end), testDate);
      });

      test('throws when start is after end', () {
        expect(
          () => testDate.clampBetween(end, start),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    test('addDays', () {
      final addedDays = testDate.addDays(1);
      expect(addedDays, DateTime(2022, 5, 11, 10, 30));
    });

    test('addHours', () {
      final addedHours = testDate.addHours(1);
      expect(addedHours, DateTime(2022, 5, 10, 11, 30));
    });

    test('isSameHourAs', () {
      final sameHour = DateTime(2022, 5, 10, 10);
      expect(testDate.isSameHourAs(sameHour), true);
    });

    test('isSameDayAs', () {
      final sameDay = DateTime(2022, 5, 10);
      expect(testDate.isSameDayAs(sameDay), true);
    });

    test('isSameWeekAs', () {
      final sameWeek = DateTime(2022, 5, 12);
      expect(testDate.isSameWeekAs(sameWeek), true);
    });

    test('daysDifferenceTo', () {
      final daysDifference = testDate.daysDifferenceTo(DateTime(2022, 5, 15));
      expect(daysDifference, 5);
    });

    test('daysUpTo', () {
      final end = DateTime(2022, 5, 15);
      final days = testDate.dateOnly.daysUpTo(end.dateOnly).toList();
      expect(days.length, 5);
      expect(days.first, testDate.dateOnly);
      expect(days.last, DateTime(2022, 5, 14));
    });

    // Tests for DHUDateNullString extension
    group('DHUDateNullString', () {
      test('tryToDateTime', () {
        expect('2022-05-10'.convert.tryToDateTime(), DateTime(2022, 5, 10));
        expect('invalid-date'.convert.tryToDateTime(), null);
      });

      test('toDateTime', () {
        expect('2022-05-10'.convert.toDateTime(), DateTime(2022, 5, 10));
      });

      test('timestampToDate', () {
        const timestamp = 1652188800000;
        expect(
          timestamp.convert.toDateTime(),
          DateTime.fromMillisecondsSinceEpoch(timestamp),
        );
      });
    });

    // Tests for DHUToDate extension
    group('DHUToDate', () {
      test('toSmallMonthName', () {
        expect(1.toSmallMonthName, 'Jan');
        expect(12.toSmallMonthName, 'Dec');
        expect(5.toSmallMonthName, 'May');
      });

      test('toFullMonthName', () {
        expect(1.toFullMonthName, 'January');
        expect(12.toFullMonthName, 'December');
        expect(5.toFullMonthName, 'May');
      });

      test('toFullDayName', () {
        expect(1.toFullDayName, 'Monday');
        expect(7.toFullDayName, 'Sunday');
        expect(3.toFullDayName, 'Wednesday');
      });

      test('toSmallDayName', () {
        expect(1.toSmallDayName, 'Mon');
        expect(7.toSmallDayName, 'Sun');
        expect(3.toSmallDayName, 'Wed');
      });

      test('timestampToDate', () {
        expect(
          1652188800000.convert.toDateTime(),
          DateTime.fromMillisecondsSinceEpoch(1652188800000),
        );
      });
      test('timestampToDate duplicate', () {
        expect(
          1652188800000.convert.toDateTime(),
          DateTime.fromMillisecondsSinceEpoch(1652188800000),
        );
      });
    });
  });
  group('DateTimeBetween', () {
    final startDate = DateTime(2024, 1, 1, 10); // 2024-01-01 10:00:00
    final endDate = DateTime(2024, 1, 5, 20); // 2024-01-05 20:00:00
    final midDate = DateTime(2024, 1, 3, 12); // 2024-01-03 12:00:00

    group('Basic range validations', () {
      test('mid date is between start and end', () {
        expect(midDate.isBetween(startDate, endDate), isTrue);
      });

      test('dates before start date are not in range', () {
        final beforeStart = startDate.subtract(const Duration(seconds: 1));
        expect(beforeStart.isBetween(startDate, endDate), isFalse);
      });

      test('dates after end date are not in range', () {
        final afterEnd = endDate.add(const Duration(seconds: 1));
        expect(afterEnd.isBetween(startDate, endDate), isFalse);
      });
    });

    group('Boundary behaviors', () {
      test('default behavior (inclusive start, exclusive end)', () {
        expect(startDate.isBetween(startDate, endDate), isTrue);
        expect(endDate.isBetween(startDate, endDate), isFalse);
      });

      test('fully inclusive boundaries', () {
        expect(
          startDate.isBetween(startDate, endDate, inclusiveEnd: true),
          isTrue,
        );
        expect(
          endDate.isBetween(startDate, endDate, inclusiveEnd: true),
          isTrue,
        );
      });

      test('fully exclusive boundaries', () {
        expect(
          startDate.isBetween(startDate, endDate, inclusiveStart: false),
          isFalse,
        );
        expect(
          endDate.isBetween(startDate, endDate, inclusiveStart: false),
          isFalse,
        );
        expect(
          midDate.isBetween(startDate, endDate, inclusiveStart: false),
          isTrue,
        );
      });
    });

    group('Time handling', () {
      test('ignoreTime parameter properly ignores time components', () {
        final sameDay = DateTime(2024);
        final sameDayDifferentTime = DateTime(2024, 1, 1, 23, 59, 59);

        expect(
          sameDay.isBetween(sameDayDifferentTime, endDate, ignoreTime: true),
          isTrue,
        );
        expect(sameDay.isBetween(sameDayDifferentTime, endDate), isFalse);
      });

      test('milliseconds and microseconds are considered', () {
        final preciseDateStart = DateTime(2024, 1, 1, 10, 0, 0, 0, 1);
        final preciseDateEnd = DateTime(2024, 1, 1, 10, 0, 0, 0, 3);
        final preciseDateMid = DateTime(2024, 1, 1, 10, 0, 0, 0, 2);

        expect(
          preciseDateMid.isBetween(preciseDateStart, preciseDateEnd),
          isTrue,
        );
      });
    });

    group('Timezone handling', () {
      test('normalize parameter converts all dates to UTC', () {
        // Create a sequence of dates in local time
        final localStart = DateTime(2024, 1, 1, 10);
        final localMid = DateTime(2024, 1, 1, 11);
        final localEnd = DateTime(2024, 1, 1, 12);

        // This should be true because the relative time differences are preserved
        expect(
          localMid.isBetween(localStart, localEnd, normalize: true),
          isTrue,
        );

        // Create equivalent UTC dates
        final utcStart = localStart.toUtc();
        final utcMid = localMid.toUtc();
        final utcEnd = localEnd.toUtc();

        // This should also be true as they represent the same moments in time
        expect(utcMid.isBetween(utcStart, utcEnd, normalize: true), isTrue);

        // Cross-timezone comparison should work
        expect(localMid.isBetween(utcStart, utcEnd, normalize: true), isTrue);
      });

      test('timezone differences are handled correctly', () {
        // Create two dates 2 hours apart in local time
        final start = DateTime(2024, 1, 1, 10);
        final end = DateTime(2024, 1, 1, 12);

        // Create a date in UTC that would fall between them
        final utcMid = start.toUtc().add(const Duration(hours: 1));

        expect(utcMid.isBetween(start, end, normalize: true), isTrue);
      });
    });
    group('Edge cases and error handling', () {
      test('throws ArgumentError for invalid date range', () {
        expect(
          () => midDate.isBetween(endDate, startDate),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.message,
              'message',
              contains('must be before or equal'),
            ),
          ),
        );
      });

      test('handles equal start and end dates', () {
        final date = DateTime(2024);

        expect(date.isBetween(date, date, inclusiveEnd: true), isTrue);
        expect(date.isBetween(date, date, inclusiveStart: false), isFalse);
      });

      test('handles null for nullable extension', () {
        DateTime? nullDate;
        expect(nullDate.isBetween(startDate, endDate), isFalse);
      });
    });

    group('DST transitions', () {
      test('handles dates across daylight savings transitions', () {
        // Dates around the US spring-forward transition. 02:xx local does not
        // exist in zones that observe it, so derive the middle instant from
        // real elapsed time instead of constructing a wall-clock 02:30.
        final beforeDST = DateTime(2024, 3, 10, 1, 59);
        final afterDST = DateTime(2024, 3, 10, 3, 1);
        final duringTransition = beforeDST.add(const Duration(minutes: 1));

        expect(
          duringTransition.isBetween(beforeDST, afterDST, normalize: true),
          isTrue,
        );
      });
    });
  });

  group('7.0.0 calendar corrections', () {
    test('httpDateFormat takes every field from UTC', () {
      // 15:30 UTC on Dec 31 is already Jan 1 in zones east of UTC+8:30;
      // weekday and month must still come from the UTC side.
      final instant = DateTime.utc(2023, 12, 31, 15, 30, 5);
      expect(instant.httpDateFormat, 'Sun, 31 Dec 2023 15:30:05 GMT');
      expect(instant.toLocal().httpDateFormat, 'Sun, 31 Dec 2023 15:30:05 GMT');
      expect(
        DateTime.utc(1970).httpDateFormat,
        'Thu, 01 Jan 1970 00:00:00 GMT',
      );
    });

    test('date-building helpers keep a UTC receiver in UTC', () {
      final utc = DateTime.utc(2024, 3, 15, 22, 45);
      final results = <String, DateTime>{
        'startOfDay': utc.startOfDay,
        'dateOnly': utc.dateOnly,
        'startOfMonth': utc.startOfMonth,
        'startOfYear': utc.startOfYear,
        'firstDayOfMonth': utc.firstDayOfMonth,
        'lastDayOfMonth': utc.lastDayOfMonth,
        'previousMonth': utc.previousMonth,
        'nextMonth': utc.nextMonth,
        'addMonths': utc.addMonths(1),
        'addYears': utc.addYears(1),
        'addDays': utc.addDays(1),
      };
      for (final entry in results.entries) {
        expect(entry.value.isUtc, isTrue, reason: entry.key);
      }
      expect(utc.startOfDay, DateTime.utc(2024, 3, 15));
      expect(utc.startOfMonth, DateTime.utc(2024, 3));
      expect(utc.startOfYear, DateTime.utc(2024));
      expect(utc.lastDayOfMonth, DateTime.utc(2024, 3, 31));
      expect(utc.previousMonth, DateTime.utc(2024, 2));
      expect(utc.nextMonth, DateTime.utc(2024, 4));
      expect(DateTime.utc(2024, 12, 5).nextMonth, DateTime.utc(2025));
      expect(DateTime.utc(2024, 1, 5).previousMonth, DateTime.utc(2023, 12));
    });

    test('addMonths crosses year boundaries in both directions', () {
      final jan15 = DateTime(2024, 1, 15, 9, 30);
      expect(jan15.addMonths(-1), DateTime(2023, 12, 15, 9, 30));
      expect(jan15.addMonths(-2), DateTime(2023, 11, 15, 9, 30));
      expect(jan15.addMonths(-13), DateTime(2022, 12, 15, 9, 30));
      expect(jan15.addMonths(13), DateTime(2025, 2, 15, 9, 30));
      expect(jan15.subtractMonths(2), DateTime(2023, 11, 15, 9, 30));
      expect(jan15.addMonths(0), jan15);
    });

    test('addMonths and addYears clamp to the end of shorter months', () {
      // Noon exists everywhere; midnight on 2024-03-31 does not in the Azores,
      // where the clocks jump from 00:00 to 01:00 that night.
      expect(
        DateTime(2024, 3, 31, 12).addMonths(-1),
        DateTime(2024, 2, 29, 12),
      );
      expect(
        DateTime(2023, 3, 31, 12).addMonths(-1),
        DateTime(2023, 2, 28, 12),
      );
      expect(DateTime(2024, 1, 31, 12).addMonths(1), DateTime(2024, 2, 29, 12));
      expect(DateTime(2024, 5, 31, 12).addMonths(1), DateTime(2024, 6, 30, 12));
      expect(DateTime(2024, 2, 29, 12).addYears(1), DateTime(2025, 2, 28, 12));
      expect(DateTime(2024, 2, 29, 12).addYears(4), DateTime(2028, 2, 29, 12));
      expect(
        DateTime(2024, 2, 29, 12).subtractYears(1),
        DateTime(2023, 2, 28, 12),
      );
    });

    test('day arithmetic keeps the wall-clock time across DST changes', () {
      // US spring-forward and fall-back days of 2024. In zones without DST
      // these are ordinary days and the expectations still hold.
      expect(DateTime(2024, 3, 10).addDays(1), DateTime(2024, 3, 11));
      expect(DateTime(2024, 3, 10).nextDay, DateTime(2024, 3, 11));
      expect(DateTime(2024, 11, 3).addDays(1), DateTime(2024, 11, 4));
      expect(DateTime(2024, 11, 4).previousDay, DateTime(2024, 11, 3));
      expect(DateTime(2024, 3, 5, 8).nextWeek, DateTime(2024, 3, 12, 8));
      expect(DateTime(2024, 3, 12, 8).previousWeek, DateTime(2024, 3, 5, 8));
      expect(DateTime(2024, 3, 12, 8).subtractDays(7), DateTime(2024, 3, 5, 8));
    });

    test('daysUpTo and daysInMonth do not drift after a DST change', () {
      final days = DateTime(2024, 3, 1).daysUpTo(DateTime(2024, 4, 1)).toList();
      expect(days, hasLength(31));
      expect(days.last, DateTime(2024, 3, 31));
      final november = DateTime(2024, 11, 15).daysInMonth;
      expect(november.length % DateTime.daysPerWeek, 0);
      expect(november.last, DateTime(2024, 12, 1));
    });

    test('calendar-day differences ignore 23- and 25-hour days', () {
      expect(DateTime(2024, 3, 10).daysDifferenceTo(DateTime(2024, 3, 11)), 1);
      expect(DateTime(2024, 11, 3).daysDifferenceTo(DateTime(2024, 11, 4)), 1);
      expect(
        DateTime(2024, 3, 11, 23).daysDifferenceTo(DateTime(2024, 3, 9, 1)),
        2,
      );
    });

    test('isSame*As compares down to the requested unit', () {
      final base = DateTime(2024, 6, 1, 10, 20, 30, 400, 500);
      expect(base.isSameMinuteAs(base.copyWith(second: 59)), isTrue);
      expect(base.isSameMinuteAs(base.copyWith(minute: 21)), isFalse);
      expect(base.isSameSecondAs(base.copyWith(millisecond: 999)), isTrue);
      expect(base.isSameSecondAs(base.copyWith(second: 31)), isFalse);
      expect(base.isSameMillisecondAs(base.copyWith(microsecond: 1)), isTrue);
      expect(
        base.isSameMillisecondAs(base.copyWith(millisecond: 401)),
        isFalse,
      );
      expect(base.isSameMicrosecondAs(base.copyWith()), isTrue);
      expect(
        base.isSameMicrosecondAs(base.copyWith(microsecond: 501)),
        isFalse,
      );
      expect(base.isSameHourAs(base.copyWith(day: 2)), isFalse);
    });

    test('min and max compare at microsecond precision', () {
      final earlier = DateTime.utc(2024);
      final later = earlier.add(const Duration(microseconds: 1));
      expect(earlier.min(later), earlier);
      expect(later.min(earlier), earlier);
      expect(earlier.max(later), later);
      expect(later.max(earlier), later);
    });

    test('rounding helpers floor correctly before the epoch', () {
      final beforeEpoch = DateTime.utc(1969, 12, 31, 23, 30);
      const hour = Duration(hours: 1);
      expect(beforeEpoch.floorTo(hour), DateTime.utc(1969, 12, 31, 23));
      expect(beforeEpoch.ceilTo(hour), DateTime.utc(1970));
      expect(beforeEpoch.roundTo(hour), DateTime.utc(1970));
      expect(beforeEpoch.floorTo(-hour), DateTime.utc(1969, 12, 31, 23));
      expect(beforeEpoch.floorTo(Duration.zero), beforeEpoch);
    });

    test('rounding helpers align to the local wall clock', () {
      final local = DateTime(2024, 1, 1, 12, 34);
      expect(local.floorTo(const Duration(hours: 1)), DateTime(2024, 1, 1, 12));
      expect(
        local.ceilTo(const Duration(minutes: 15)),
        DateTime(2024, 1, 1, 12, 45),
      );
      expect(
        local.roundTo(const Duration(minutes: 30)),
        DateTime(2024, 1, 1, 12, 30),
      );
      expect(local.floorTo(const Duration(hours: 1)).isUtc, isFalse);
    });

    test('addBusinessDays skips weekends in both directions', () {
      final friday = DateTime(2024, 6, 7, 9);
      final monday = DateTime(2024, 6, 10, 9);
      expect(friday.addBusinessDays(1), monday);
      expect(monday.addBusinessDays(-1), friday);
      expect(friday.addBusinessDays(5), DateTime(2024, 6, 14, 9));
      expect(friday.addBusinessDays(0), friday);
    });

    test('isFuture replaces isPresent', () {
      final now = DateTime.now();
      expect(now.add(const Duration(hours: 1)).isFuture, isTrue);
      expect(now.subtract(const Duration(hours: 1)).isFuture, isFalse);
      const DateTime? none = null;
      expect(none.isFuture, isFalse);
    });

    test('copyWith now resolves to the SDK implementation', () {
      // dart_helper_utils dropped its own copyWith in 7.0.0 because
      // dart:core ships an identical DateTime.copyWith.
      final utc = DateTime.utc(2024, 2, 29, 23, 59);
      expect(utc.copyWith(year: 2025), DateTime.utc(2025, 3, 1, 23, 59));
      expect(utc.copyWith(isUtc: false).isUtc, isFalse);
    });

    test('the repeated fall-back hour keeps the receiver instance', () {
      // 06:30:30 UTC on 2024-11-03 is 01:30:30 EST, the SECOND 01:30:30 in
      // America/New_York. Rebuilding that wall-clock time with the local
      // constructor would pick the first (EDT) one, an hour earlier. The
      // assertions hold in every zone; CI runs them in New York too.
      final repeated = DateTime.utc(2024, 11, 3, 6, 30, 30).toLocal();
      const minute = Duration(minutes: 1);

      final floor = repeated.floorTo(minute);
      final ceil = repeated.ceilTo(minute);
      expect(repeated.difference(floor), const Duration(seconds: 30));
      expect(ceil.difference(repeated), const Duration(seconds: 30));
      expect(floor.isAfter(repeated), isFalse);
      expect(ceil.isBefore(repeated), isFalse);
      expect(floor.roundTo(const Duration(seconds: 1)), floor);

      expect(repeated.addDays(0), repeated);
      expect(repeated.daysUpTo(repeated.add(minute)).first, repeated);
      expect(repeated.firstDayOfWeek(startOfWeek: repeated.weekday), repeated);
    });

    test('roundTo does not overflow near the end of the DateTime range', () {
      final late = DateTime.utc(200000, 1, 1, 0, 40);
      expect(
        late.roundTo(const Duration(hours: 1)),
        DateTime.utc(200000, 1, 1, 1),
      );
      expect(late.floorTo(const Duration(hours: 1)), DateTime.utc(200000));
    }, testOn: 'vm');
  });
}
