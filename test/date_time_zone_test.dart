/// Invariants that only a time zone with clock changes can break.
///
/// Every check is derived from the transitions of the zone the test process
/// runs in, so the file needs no zone names: CI runs it under several zones
/// (the "Test calendar logic in other time zones" step) to cover changes at
/// 02:00 (New York), gaps at midnight (Cairo), 30-minute shifts (Lord Howe),
/// a repeated midnight (Azores), 2-hour shifts (Troll), and a 45-minute
/// offset (Chatham), and on Node, where JavaScript's Date resolves local
/// times. In a zone without changes, such as UTC, there is nothing to check.
library;

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  final transitions = _localTransitions(
    from: DateTime.utc(2024),
    to: DateTime.utc(2026),
  );

  test('the transition scan finds clock changes where the zone has them', () {
    final changesClocks =
        DateTime(2024).timeZoneOffset != DateTime(2024, 7).timeZoneOffset;
    if (changesClocks) expect(transitions, isNotEmpty);
  });

  test('floorTo, ceilTo, and roundTo bracket every receiver consistently', () {
    final failures = _Failures();
    for (final transition in transitions) {
      final receivers = _receiversAround(transition);
      for (final step in _steps) {
        DateTime? previousFloor;
        DateTime? previousCeil;
        for (final x in receivers) {
          final floor = x.floorTo(step);
          final ceil = x.ceilTo(step);
          final round = x.roundTo(step);
          void check(bool ok, String what, DateTime result) {
            if (!ok) failures.add(what, step, x, result);
          }

          check(!floor.isAfter(x), 'floorTo after the receiver', floor);
          check(!ceil.isBefore(x), 'ceilTo before the receiver', ceil);
          check(round == floor || round == ceil, 'roundTo off the grid', round);
          check(floor.floorTo(step) == floor, 'floorTo not idempotent', floor);
          check(floor.ceilTo(step) == floor, 'ceilTo moves a floor', floor);
          check(ceil.ceilTo(step) == ceil, 'ceilTo not idempotent', ceil);
          check(ceil.floorTo(step) == ceil, 'floorTo moves a ceil', ceil);
          check(round.roundTo(step) == round, 'roundTo not idempotent', round);
          if (floor != x) {
            final beforeCeil = ceil.subtract(const Duration(microseconds: 1));
            check(
              beforeCeil.floorTo(step) == floor,
              'a grid instant between floorTo and ceilTo',
              beforeCeil.floorTo(step),
            );
          }
          check(
            _isAligned(floor, step) || _followsJump(floor),
            'floorTo shows an unaligned wall clock',
            floor,
          );
          check(
            _isAligned(ceil, step) || _followsJump(ceil),
            'ceilTo shows an unaligned wall clock',
            ceil,
          );
          if (previousFloor != null) {
            check(!floor.isBefore(previousFloor), 'floorTo went back', floor);
          }
          if (previousCeil != null) {
            check(!ceil.isBefore(previousCeil), 'ceilTo went back', ceil);
          }
          previousFloor = floor;
          previousCeil = ceil;
        }
      }
    }
    expect(failures.messages, isEmpty, reason: failures.summary);
  });

  test('whole-day steps agree with startOfDay', () {
    final failures = _Failures();
    for (final transition in transitions) {
      for (final x in _receiversAround(transition)) {
        final floor = x.floorTo(const Duration(days: 1));
        if (floor != x.startOfDay) {
          failures.add('floorTo(1 day) != startOfDay', _day, x, floor);
        }
        // The start of the next calendar date. Not nextDay.startOfDay: when
        // the clocks skip nextDay's time, it moves into the day after.
        final next = DateTime(x.year, x.month, x.day + 1);
        final ceil = x.ceilTo(const Duration(days: 1));
        if (ceil != x && ceil != next) {
          failures.add('ceilTo(1 day) is not the next midnight', _day, x, ceil);
        }
      }
    }
    expect(failures.messages, isEmpty, reason: failures.summary);
  });

  test('a sub-day step restarts where clocks fall back', () {
    // When New York falls back, the clock shows 01:00 a second time, so the
    // hour that follows floors to that second 01:00 and the end of the
    // first pass ceils to it. Whole days are calendar days instead (above).
    // The step divides both the repeated stretch and the time the clocks
    // land on, so the landing time is aligned in every zone.
    for (final jump in transitions) {
      final before = jump.subtract(const Duration(microseconds: 1));
      final repeated = before.timeZoneOffset - jump.timeZoneOffset;
      if (repeated <= Duration.zero) continue; // a forward jump
      final landing = _wallMicros(jump) % Duration.microsecondsPerDay;
      final step = Duration(microseconds: repeated.inMicroseconds.gcd(landing));
      final half = step ~/ 2;
      expect(jump.add(half).floorTo(step), jump, reason: 'after $jump');
      expect(jump.subtract(half).ceilTo(step), jump, reason: 'before $jump');
      expect(jump.floorTo(step), jump, reason: 'at $jump');
    }
  });

  test('calendar-day moves keep the wall clock and the first occurrence', () {
    final failures = _Failures();
    for (final transition in transitions) {
      for (final x in _receiversAround(transition)) {
        final same = x.addDays(0);
        if (same != x) failures.add('addDays(0)', _day, x, same);
        final first = x.daysUpTo(x.add(const Duration(microseconds: 1))).first;
        if (first != x) failures.add('daysUpTo start', _day, x, first);
        if (_isLaterOccurrence(x)) continue;
        for (final days in const [-7, -1, 1, 7]) {
          final moved = x.addDays(days);
          // A moved receiver lands on a first occurrence: the repeated hour
          // of a later fall-back belongs to its first pass.
          if (_isLaterOccurrence(moved)) {
            failures.add('addDays($days) picked a repeat', _day, x, moved);
          }
          // A time the clocks skipped moves forward, so it cannot come back.
          if (!_landsOn(moved, x, days)) continue;
          final back = moved.addDays(-days);
          if (back != x) {
            failures.add('addDays($days) round trip', _day, x, back);
          }
        }
        final nextDay = x.nextDay;
        if (_landsOn(nextDay, x, 1) && nextDay.previousDay != x) {
          failures.add('nextDay.previousDay', _day, x, nextDay.previousDay);
        }
      }
    }
    expect(failures.messages, isEmpty, reason: failures.summary);
  });
}

const _day = Duration(days: 1);

const _steps = [
  Duration(seconds: 1),
  Duration(minutes: 1),
  Duration(minutes: 7),
  Duration(minutes: 15),
  Duration(minutes: 20),
  Duration(minutes: 30),
  Duration(minutes: 45),
  Duration(hours: 1),
  Duration(minutes: 75),
  Duration(minutes: 90),
  Duration(hours: 2),
  Duration(hours: 3),
  Duration(hours: 5),
  Duration(hours: 6),
  Duration(hours: 12),
  Duration(days: 1),
  Duration(days: 2),
  Duration(days: 7),
];

/// Every instant in [from, to) at which the local offset changes, found by
/// probing every 12 hours and bisecting each change to the microsecond.
List<DateTime> _localTransitions({
  required DateTime from,
  required DateTime to,
}) {
  int offsetAt(int micros) =>
      DateTime.fromMicrosecondsSinceEpoch(micros).timeZoneOffset.inMicroseconds;
  const probe = 12 * Duration.microsecondsPerHour;
  final result = <DateTime>[];
  for (
    var low = from.microsecondsSinceEpoch;
    low < to.microsecondsSinceEpoch;
    low += probe
  ) {
    final offset = offsetAt(low);
    if (offsetAt(low + probe) == offset) continue;
    var before = low;
    var after = low + probe;
    while (after - before > 1) {
      final middle = before + (after - before) ~/ 2;
      if (offsetAt(middle) == offset) {
        before = middle;
      } else {
        after = middle;
      }
    }
    result.add(DateTime.fromMicrosecondsSinceEpoch(after));
  }
  return result;
}

/// Receivers every 7 minutes for 26 hours on each side of [transition], 17
/// seconds off the minute so few are aligned, plus the change itself and its
/// neighbors, in ascending order.
List<DateTime> _receiversAround(DateTime transition) {
  final receivers = [
    for (var k = -223; k <= 223; k++)
      transition.add(Duration(minutes: 7 * k, seconds: 17)),
    transition.subtract(const Duration(microseconds: 1)),
    transition,
    transition.add(const Duration(microseconds: 1)),
  ]..sort();
  return receivers;
}

/// The wall-clock fields of [date] read as a UTC instant.
int _wallMicros(DateTime date) => DateTime.utc(
  date.year,
  date.month,
  date.day,
  date.hour,
  date.minute,
  date.second,
  date.millisecond,
  date.microsecond,
).microsecondsSinceEpoch;

bool _isAligned(DateTime date, Duration step) =>
    _wallMicros(date) % step.inMicroseconds == 0;

/// Whether the clocks changed offset exactly at [date], so its wall clock is
/// where the clocks landed rather than an aligned time.
bool _followsJump(DateTime date) =>
    date.subtract(const Duration(microseconds: 1)).timeZoneOffset !=
    date.timeZoneOffset;

/// Whether [date] is the second occurrence of a wall-clock time the clocks
/// repeated; the local constructor resolves such a time to the first one.
bool _isLaterOccurrence(DateTime date) =>
    DateTime(
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

/// Whether [moved] shows [x]'s time of day on the calendar date [days] after
/// [x]'s. It does not when the clocks skipped that time (Apia skipped all of
/// 2011-12-30).
bool _landsOn(DateTime moved, DateTime x, int days) {
  final date = DateTime.utc(x.year, x.month, x.day + days);
  return moved.year == date.year &&
      moved.month == date.month &&
      moved.day == date.day &&
      moved.hour == x.hour &&
      moved.minute == x.minute &&
      moved.second == x.second &&
      moved.millisecond == x.millisecond &&
      moved.microsecond == x.microsecond;
}

class _Failures {
  final messages = <String>[];

  void add(String what, Duration step, DateTime receiver, DateTime result) {
    messages.add(
      '$what (step $step): $receiver '
      '[${receiver.toUtc()}] -> $result [${result.toUtc()}]',
    );
  }

  String get summary =>
      '${messages.length} failures in ${DateTime(2024).timeZoneName}:\n'
      '${messages.take(15).join('\n')}';
}
