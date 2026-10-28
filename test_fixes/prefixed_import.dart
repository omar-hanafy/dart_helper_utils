import 'package:dart_helper_utils/dart_helper_utils.dart' as dhu;

bool sameDay(DateTime a, DateTime b) => a.isAtSameDayAs(b);

DateTime next(DateTime a) => a.tomorrow;

String explicitPrefixed(DateTime a) =>
    dhu.DHUDateFormatExtension(a).formatASyQQQ();
