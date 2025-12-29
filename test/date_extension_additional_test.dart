import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('DateTime extensions (additional)', () {
    test('httpDateFormat uses RFC-1123 format', () {
      final date = DateTime.utc(2024, 1, 1, 0, 0, 0);
      expect(date.httpDateFormat, 'Mon, 01 Jan 2024 00:00:00 GMT');
    });

    test('toIso matches toIso8601String', () {
      final date = DateTime(2024, 1, 1);
      expect(date.toIso, date.toIso8601String());
    });

    test('isWeekend and isWeekday', () {
      final saturday = DateTime(2024, 6, 1);
      final monday = DateTime(2024, 6, 3);
      expect(saturday.isWeekend, isTrue);
      expect(saturday.isWeekday, isFalse);
      expect(monday.isWeekday, isTrue);
    });

    test('roundTo, floorTo, and ceilTo', () {
      final date = DateTime(2024, 1, 1, 12, 34, 0);
      final floor = date.floorTo(const Duration(hours: 1));
      final ceil = date.ceilTo(const Duration(hours: 1));
      final round = date.roundTo(const Duration(hours: 1));
      expect(floor, DateTime(2024, 1, 1, 12));
      expect(ceil, DateTime(2024, 1, 1, 13));
      expect(round, DateTime(2024, 1, 1, 13));
    });

    test('lastDayOfWeek preserves UTC', () {
      final date = DateTime.utc(2024, 1, 1, 15, 0);
      final lastDay = date.lastDayOfWeek();
      expect(lastDay.isUtc, isTrue);
      expect(lastDay, DateTime.utc(2024, 1, 7, 15, 0));
    });

    test('addBusinessDays skips weekends', () {
      final friday = DateTime(2024, 1, 5);
      expect(friday.addBusinessDays(1), DateTime(2024, 1, 8));
      expect(friday.addBusinessDays(-1), DateTime(2024, 1, 4));
    });

    test('add/subtract helpers', () {
      final date = DateTime(2024, 1, 1, 12, 0);
      expect(date.addHours(2), DateTime(2024, 1, 1, 14, 0));
      expect(date.subtractHours(2), DateTime(2024, 1, 1, 10, 0));
      expect(date.addMinutes(30), DateTime(2024, 1, 1, 12, 30));
      expect(date.subtractMinutes(30), DateTime(2024, 1, 1, 11, 30));
      expect(date.addSeconds(10), DateTime(2024, 1, 1, 12, 0, 10));
      expect(date.subtractSeconds(10), DateTime(2024, 1, 1, 11, 59, 50));
    });
  });

  group('Nullable DateTime extensions (additional)', () {
    test('isToday, isTomorrow, isYesterday', () {
      final now = DateTime.now();
      expect(now.isToday, isTrue);
      expect(now.add(const Duration(days: 1)).isTomorrow, isTrue);
      expect(now.subtract(const Duration(days: 1)).isYesterday, isTrue);
    });

    test('isLeapYear', () {
      final leap = DateTime(2024, 1, 1);
      final nonLeap = DateTime(2023, 1, 1);
      expect(leap.isLeapYear, isTrue);
      expect(nonLeap.isLeapYear, isFalse);
    });
  });

  group('Numeric date helpers', () {
    test('isBetweenMonths handles year wrap', () {
      expect(1.isBetweenMonths(12, 2), isTrue);
      expect(3.isBetweenMonths(12, 2), isFalse);
    });

    test('isCurrentYear/month/day', () {
      final now = DateTime.now();
      expect(now.year.isCurrentYear, isTrue);
      expect(now.month.isCurrentMonth, isTrue);
      expect(now.day.isCurrentDay, isTrue);
      expect(now.weekday.isCurrentDayOfWeek, isTrue);
    });
  });
}
