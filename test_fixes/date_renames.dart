import 'package:dart_helper_utils/dart_helper_utils.dart';

void comparisons(DateTime a, DateTime b) {
  print(a.isAtSameYearAs(b));
  print(a.isAtSameMonthAs(b));
  print(a.isAtSameDayAs(b));
  print(a.isAtSameHourAs(b));
  print(a.isAtSameMinuteAs(b));
  print(a.isAtSameSecondAs(b));
  print(a.isAtSameMillisecondAs(b));
  print(a.isAtSameMicrosecondAs(b));
}

void arithmetic(DateTime a) {
  print(a.addOrSubtractYears(1));
  print(a.addOrSubtractMonths(-2));
  print(a.addOrSubtractDays(3));
  print(a.addOrSubtractMinutes(4));
  print(a.addOrSubtractSeconds(5));
  print(a.addOrSubtractMilliseconds(6));
  print(a.addOrSubtractMicroseconds(7));
  print(a.toUtc().addOrSubtractDays(1));
}

String quarter(DateTime a) => a.formatASyQQQ() + a.formatASyQQQ('en_US');

DateTime next(DateTime date) => date.tomorrow;

DateTime previousFromExpression(DateTime date) => date.toUtc().yesterday;

bool futureNonNull(DateTime date) => date.isPresent;

bool futureNullable(DateTime? date) => date.isPresent;

bool Function(DateTime) tearOff(DateTime date) => date.isAtSameDayAs;

bool explicitMethod(DateTime a, DateTime b) =>
    DHUDateExtensions(a).isAtSameDayAs(b);

DateTime explicitGetter(DateTime a) => DHUDateExtensions(a).tomorrow;

bool explicitNullable(DateTime? a) => DHUNullableDateExtensions(a).isPresent;

String explicitFormat(DateTime a) => DHUDateFormatExtension(a).formatASyQQQ();

// Controls: same-named members on other types must not change.
class Calendar {
  DateTime get tomorrow => DateTime(2000);

  bool isAtSameDayAs(DateTime other) => false;
}

DateTime controlGetter(Calendar calendar) => calendar.tomorrow;

bool controlMethod(Calendar calendar, DateTime b) =>
    calendar.isAtSameDayAs(b);
