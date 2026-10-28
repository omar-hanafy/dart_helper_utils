import 'package:dart_helper_utils/dart_helper_utils.dart'
    show DHUDateExtensions, DHUNullableDateExtensions;

bool sameMonth(DateTime a, DateTime b) => a.isAtSameMonthAs(b);

DateTime monthLater(DateTime a) => a.addOrSubtractMonths(1);

bool future(DateTime? a) => a.isPresent;
