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
      final days = DateTime(testDate.year, testDate.month, testDate.day)
          .daysDifferenceTo(DateTime.now());
      expect(testDate.passedDays, days);
    });

    test('remainingDuration', () {
      final duration = testDate.difference(DateTime.now());
      expect(testDate.remainingDuration.inDays, duration.inDays);
    });

    test('remainingDays', () {
      final days = DateTime.now().daysDifferenceTo(testDate);
      expect(testDate.remainingDays, days);
    });

    test('isAtSameYearAs', () {
      final otherDate = DateTime(2022, 12, 31);
      expect(testDate.isAtSameYearAs(otherDate), true);
    });

    test('isAtSameMonthAs', () {
      final otherDate = DateTime(2022, 5);
      expect(testDate.isAtSameMonthAs(otherDate), true);
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
      expect(testDate.firstDayOfWeek(),
          DateTime(2022, 5, 9, testDate.hour, testDate.minute));
    });

    test('lastDayOfWeek', () {
      expect(testDate.lastDayOfWeek(),
          DateTime(2022, 5, 15, testDate.hour, testDate.minute));
    });

    // Optionally, test with Sunday as the start of the week
    test('firstDayOfWeek (Sunday start)', () {
      expect(testDate.firstDayOfWeek(startOfWeek: DateTime.sunday),
          DateTime(2022, 5, 8, testDate.hour, testDate.minute));
    });

    test('lastDayOfWeek (Sunday start)', () {
      expect(testDate.lastDayOfWeek(startOfWeek: DateTime.sunday),
          DateTime(2022, 5, 14, testDate.hour, testDate.minute));
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

    test('addOrRemoveYears', () {
      final nextYear = testDate.addOrRemoveYears(1);
      final previousYear = testDate.addOrRemoveYears(-1);
      expect(nextYear, DateTime(2023, 5, 10, 10, 30));
      expect(previousYear, DateTime(2021, 5, 10, 10, 30));
    });

    test('addOrRemoveMonths', () {
      final nextMonth = testDate.addOrRemoveMonths(1);
      final previousMonth = testDate.addOrRemoveMonths(-1);
      expect(nextMonth, DateTime(2022, 6, 10, 10, 30));
      expect(previousMonth, DateTime(2022, 4, 10, 10, 30));
    });

    test('addOrRemoveDays', () {
      final nextDay = testDate.addOrRemoveDays(1);
      final previousDay = testDate.addOrRemoveDays(-1);
      expect(nextDay, DateTime(2022, 5, 11, 10, 30));
      expect(previousDay, DateTime(2022, 5, 9, 10, 30));
    });

    test('addOrRemoveMinutes', () {
      final nextMinute = testDate.addOrRemoveMinutes(1);
      final previousMinute = testDate.addOrRemoveMinutes(-1);
      expect(nextMinute, DateTime(2022, 5, 10, 10, 31));
      expect(previousMinute, DateTime(2022, 5, 10, 10, 29));
    });

    test('addOrRemoveSeconds', () {
      final nextSecond = testDate.addOrRemoveSeconds(1);
      final previousSecond = testDate.addOrRemoveSeconds(-1);
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
        expect('2022-05-10'.tryToDateTime, DateTime(2022, 5, 10));
        expect('invalid-date'.tryToDateTime, null);
      });

      test('toDateTime', () {
        expect('2022-05-10'.toDateTime, DateTime(2022, 5, 10));
      });

      test('timestampToDate', () {
        expect('1652188800000'.timestampToDate,
            DateTime.fromMillisecondsSinceEpoch(1652188800000));
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
        expect(1652188800000.timestampToDate,
            DateTime.fromMillisecondsSinceEpoch(1652188800000));
      });
      test('timestampToDate', () {
        expect(1652188800000.timestampToDate,
            DateTime.fromMillisecondsSinceEpoch(1652188800000));
      });
    });
  });
}
