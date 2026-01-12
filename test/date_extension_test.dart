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
        final now = DateTime.now();
        final futureDate = now.add(const Duration(days: 5));
        expect(futureDate.remainingDays, 5);
      });

      test('should return 0 for today', () {
        final now = DateTime.now();
        expect(now.remainingDays, 0);
      });

      test('should return negative difference for past date', () {
        final now = DateTime.now();
        final pastDate = now.subtract(const Duration(days: 3));
        expect(pastDate.remainingDays, -3);
      });
    });

    test('isAtSameYearAs', () {
      final otherDate = DateTime(2022, 12, 31);
      expect(testDate.isAtSameYearAs(otherDate), true);
    });

    test('isSameYearAs', () {
      final otherDate = DateTime(2022, 1, 1);
      expect(testDate.isSameYearAs(otherDate), true);
    });

    test('isAtSameMonthAs', () {
      final otherDate = DateTime(2022, 5);
      expect(testDate.isAtSameMonthAs(otherDate), true);
    });

    test('isSameMonthAs', () {
      final otherDate = DateTime(2022, 5, 1);
      expect(testDate.isSameMonthAs(otherDate), true);
    });

    test('isAtSameDayAs', () {
      final otherDate = DateTime(2022, 5, 10);
      expect(testDate.isAtSameDayAs(otherDate), true);
    });

    test('isAtSameHourAs', () {
      final otherDate = DateTime(2022, 5, 10, 10);
      expect(testDate.isAtSameHourAs(otherDate), true);
    });

    test('isAtSameMinuteAs', () {
      final otherDate = DateTime(2022, 5, 10, 10, 30);
      expect(testDate.isAtSameMinuteAs(otherDate), true);
    });

    test('isAtSameSecondAs', () {
      final otherDate = DateTime(2022, 5, 10, 10, 30);
      expect(testDate.isAtSameSecondAs(otherDate), true);
    });

    test('isAtSameMillisecondAs', () {
      final otherDate = DateTime(2022, 5, 10, 10, 30);
      expect(testDate.isAtSameMillisecondAs(otherDate), true);
    });

    test('isAtSameMicrosecondAs', () {
      final otherDate = DateTime(2022, 5, 10, 10, 30);
      expect(testDate.isAtSameMicrosecondAs(otherDate), true);
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

    test('tomorrow', () {
      final tomorrow = testDate.add(const Duration(days: 1));
      expect(testDate.tomorrow, tomorrow);
    });

    test('yesterday', () {
      final yesterday = testDate.subtract(const Duration(days: 1));
      expect(testDate.yesterday, yesterday);
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

    test('addOrSubtractYears', () {
      final nextYear = testDate.addOrSubtractYears(1);
      final previousYear = testDate.addOrSubtractYears(-1);
      expect(nextYear, DateTime(2023, 5, 10, 10, 30));
      expect(previousYear, DateTime(2021, 5, 10, 10, 30));
    });

    test('addOrSubtractMonths', () {
      final nextMonth = testDate.addOrSubtractMonths(1);
      final previousMonth = testDate.addOrSubtractMonths(-1);
      expect(nextMonth, DateTime(2022, 6, 10, 10, 30));
      expect(previousMonth, DateTime(2022, 4, 10, 10, 30));
    });

    test('addOrSubtractDays', () {
      final nextDay = testDate.addOrSubtractDays(1);
      final previousDay = testDate.addOrSubtractDays(-1);
      expect(nextDay, DateTime(2022, 5, 11, 10, 30));
      expect(previousDay, DateTime(2022, 5, 9, 10, 30));
    });

    test('addOrSubtractMinutes', () {
      final nextMinute = testDate.addOrSubtractMinutes(1);
      final previousMinute = testDate.addOrSubtractMinutes(-1);
      expect(nextMinute, DateTime(2022, 5, 10, 10, 31));
      expect(previousMinute, DateTime(2022, 5, 10, 10, 29));
    });

    test('addOrSubtractSeconds', () {
      final nextSecond = testDate.addOrSubtractSeconds(1);
      final previousSecond = testDate.addOrSubtractSeconds(-1);
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
        // Create dates around DST transition (example for US DST)
        final beforeDST = DateTime(2024, 3, 10, 1, 59);
        final afterDST = DateTime(2024, 3, 10, 3, 1);
        final duringTransition = DateTime(2024, 3, 10, 2, 30);

        expect(
          duringTransition.isBetween(beforeDST, afterDST, normalize: true),
          isTrue,
        );
      });
    });
  });
}
