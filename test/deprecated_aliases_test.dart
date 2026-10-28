// The 7.0.0 migration aliases are exercised on purpose: each must forward to
// its replacement until 8.0.0 removes it together with this file.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('7.0.0 deprecated aliases forward to their replacements', () {
    final a = DateTime(2024, 3, 15, 10, 20, 30, 400, 500);
    final b = DateTime(2024, 3, 15, 10, 20, 30, 400, 900);

    test('isAtSame*As', () {
      expect(a.isAtSameYearAs(b), a.isSameYearAs(b));
      expect(a.isAtSameMonthAs(b), a.isSameMonthAs(b));
      expect(a.isAtSameDayAs(b), a.isSameDayAs(b));
      expect(a.isAtSameHourAs(b), a.isSameHourAs(b));
      expect(a.isAtSameMinuteAs(b), a.isSameMinuteAs(b));
      expect(a.isAtSameSecondAs(b), a.isSameSecondAs(b));
      expect(a.isAtSameMillisecondAs(b), a.isSameMillisecondAs(b));
      expect(a.isAtSameMicrosecondAs(b), isFalse);
      expect(a.isAtSameMicrosecondAs(a), isTrue);
    });

    test('addOrSubtract*', () {
      expect(a.addOrSubtractYears(-1), a.addYears(-1));
      expect(a.addOrSubtractMonths(-2), a.addMonths(-2));
      expect(a.addOrSubtractDays(3), a.addDays(3));
      expect(a.addOrSubtractMinutes(4), a.addMinutes(4));
      expect(a.addOrSubtractSeconds(5), a.addSeconds(5));
      expect(a.addOrSubtractMilliseconds(6), a.addMilliseconds(6));
      expect(a.addOrSubtractMicroseconds(7), a.addMicroseconds(7));
    });

    test('tomorrow, yesterday, and isPresent', () {
      expect(a.tomorrow, a.nextDay);
      expect(a.yesterday, a.previousDay);
      final later = DateTime.now().add(const Duration(hours: 1));
      expect(later.isPresent, later.isFuture);
      DateTime? none;
      expect(none.isPresent, isFalse);
    });

    test('formatASyQQQ and enforceRtlIn', () {
      expect(a.formatASyQQQ('en_US'), a.formatAsyQQQ('en_US'));
      expect('abc'.enforceRtlIn(), 'abc'.enforceRtl());
    });

    test('String? isEmptyOrNull and isNotEmptyOrNull', () {
      String? none;
      expect(none.isEmptyOrNull, isTrue);
      expect('  '.isEmptyOrNull, isTrue);
      expect('x'.isEmptyOrNull, isFalse);
      expect(none.isNotEmptyOrNull, isFalse);
      expect(' x '.isNotEmptyOrNull, isTrue);
      // Collections keep their own (non-deprecated) members.
      expect(<int>[].isEmptyOrNull, isTrue);
      expect(<String, int>{'a': 1}.isNotEmptyOrNull, isTrue);
    });
  });
}
