/// Invariants that only a time zone with clock changes can break.
///
/// Every expectation is computed from the clock changes of the zone the test
/// process runs in, found by probing offsets, never from the local DateTime
/// constructor or from the library itself. CI runs the file under zones with
/// changes at 02:00 (New York), gaps at midnight (Cairo), 30-minute shifts
/// (Lord Howe), a midnight repeated within its date (Azores), changes past
/// midnight (St. John's, until 2011), 2- and 3-hour shifts (Troll, Casey),
/// and a 45-minute offset (Chatham), and on Node, where JavaScript's Date
/// resolves local times. In a zone without changes, such as UTC, there is
/// nothing to check.
library;

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  test('the transition scan finds clock changes where the zone has them', () {
    final changesClocks =
        DateTime(2024).timeZoneOffset != DateTime(2024, 7).timeZoneOffset;
    if (changesClocks) expect(_transitions, isNotEmpty);
  });

  test('floorTo, ceilTo, and roundTo find the nearest aligned instants', () {
    final failures = _Failures();
    for (final transition in _transitions) {
      final receivers = _receiversAround(transition);
      for (final step in _clockSteps) {
        final micros = step.inMicroseconds;
        // Long steps walk day by day, so a sparser sample keeps this fast.
        final sample = micros > _dayMicros
            ? [for (var i = 0; i < receivers.length; i += 25) receivers[i]]
            : receivers;
        for (final x in sample) {
          final floor = x.floorTo(step);
          final ceil = x.ceilTo(step);
          final round = x.roundTo(step);
          final expectedFloor = _expectedFloor(x, micros);
          final expectedCeil = _expectedCeil(x, micros);
          final expectedRound =
              expectedFloor == x ||
                  x.difference(expectedFloor) < expectedCeil.difference(x)
              ? expectedFloor
              : expectedCeil;
          void check(bool ok, String what, DateTime result) {
            if (!ok) failures.add(what, step, x, result);
          }

          check(floor == expectedFloor, 'floorTo', floor);
          check(ceil == expectedCeil, 'ceilTo', ceil);
          check(round == expectedRound, 'roundTo', round);
          check(floor.floorTo(step) == floor, 'floorTo not idempotent', floor);
          check(ceil.ceilTo(step) == ceil, 'ceilTo not idempotent', ceil);
          check(round.roundTo(step) == round, 'roundTo not idempotent', round);
        }
      }
    }
    expect(failures.messages, isEmpty, reason: failures.summary);
  });

  test('whole-day steps count calendar dates', () {
    final failures = _Failures();
    for (final transition in _transitions) {
      for (final x in _receiversAround(transition)) {
        if (x.floorTo(_day) != x.startOfDay) {
          failures.add('floorTo != startOfDay', _day, x, x.floorTo(_day));
        }
        for (final days in const [1, 2, 7, 150, 400]) {
          final step = Duration(days: days);
          final index = _dayIndex(x);
          final aligned = index - index % days;
          final starts = _startsOfDate(aligned);
          final floor = x.floorTo(step);
          if (floor != starts.first) {
            failures.add('floorTo is not the date start', step, x, floor);
          }
          // x itself when it starts an aligned date; otherwise the first
          // start of the next aligned date at or after x, which is that
          // midnight's repeat when the clocks fell back past the first one.
          final expectedCeil = starts.contains(x)
              ? x
              : [
                  ..._startsOfDate(aligned + days),
                  ..._startsOfDate(aligned + 2 * days),
                ].firstWhere((start) => !start.isBefore(x));
          final ceil = x.ceilTo(step);
          if (ceil != expectedCeil) {
            failures.add('ceilTo is not the next date start', step, x, ceil);
          }
          final round = x.roundTo(step);
          final expectedRound =
              floor == x || x.difference(floor) < ceil.difference(x)
              ? floor
              : ceil;
          if (round != expectedRound) failures.add('roundTo', step, x, round);
        }
      }
    }
    expect(failures.messages, isEmpty, reason: failures.summary);
  });

  test('a long step finds aligned times inside a repeated stretch', () {
    // For each fall-back, pick a step near 350 days with a grid point in
    // the middle of the repeated stretch. The neighboring grid points are a
    // season away, at the receiver's own offset, so code that assumes one
    // clock change per step accepts them and misses this one.
    var checked = 0;
    for (final jump in _transitions) {
      final before = jump.subtract(const Duration(microseconds: 1));
      final repeated =
          (before.timeZoneOffset - jump.timeZoneOffset).inMicroseconds;
      if (repeated <= 0) continue; // a forward jump
      final landing = _wallMicros(jump);
      final target = landing + repeated ~/ 2;
      if (target < 350 * _dayMicros) continue; // no 350-day grid this early
      final count = target ~/ (350 * _dayMicros);
      final step = target ~/ count;
      final grid = step * count; // within microseconds of target
      final first = DateTime.fromMicrosecondsSinceEpoch(
        grid - before.timeZoneOffset.inMicroseconds,
      );
      final second = DateTime.fromMicrosecondsSinceEpoch(
        grid - jump.timeZoneOffset.inMicroseconds,
      );
      final duration = Duration(microseconds: step);
      final inSecondPass = jump.add(Duration(microseconds: repeated ~/ 4));
      final inFirstPass = first.add(Duration(microseconds: repeated ~/ 8));
      expect(inSecondPass.floorTo(duration), first, reason: '$inSecondPass');
      expect(inFirstPass.ceilTo(duration), second, reason: '$inFirstPass');
      checked++;
    }
    final fallsBack = _transitions.any(
      (t) =>
          t.subtract(const Duration(microseconds: 1)).timeZoneOffset >
          t.timeZoneOffset,
    );
    expect(checked > 0, fallsBack);
  });

  test('dates before standard time align to their exact local mean time', () {
    // Until the 1880s most zones kept local mean time, an offset with
    // seconds (New York -4:56:02, Lord Howe +10:36:20). On the web,
    // timeZoneOffset rounds such offsets to whole minutes, so arithmetic on
    // it lands seconds off the wall clock. CI runs this file on Node.
    for (final year in const [1880, 1903, 1960]) {
      final x = DateTime(year, 6, 15, 10, 20);
      final hour = x.floorTo(const Duration(hours: 1));
      expect([hour.hour, hour.minute, hour.second], [10, 0, 0], reason: '$x');
      final next = x.ceilTo(const Duration(hours: 1));
      expect([next.hour, next.minute, next.second], [11, 0, 0], reason: '$x');
      final day = x.floorTo(const Duration(days: 1));
      expect([day.day, day.hour, day.minute, day.second], [15, 0, 0, 0]);
      expect(day, x.startOfDay);
    }
  });

  test('a sub-day step restarts where clocks fall back', () {
    // When New York falls back, the clock shows 01:00 a second time, so the
    // hour that follows floors to that second 01:00 and the end of the
    // first pass ceils to it. Whole days are calendar days instead (above).
    // The step divides both the repeated stretch and the time the clocks
    // land on, so the landing time is aligned in every zone.
    for (final jump in _transitions) {
      final before = jump.subtract(const Duration(microseconds: 1));
      final repeated = before.timeZoneOffset - jump.timeZoneOffset;
      if (repeated <= Duration.zero) continue; // a forward jump
      final landing = _wallMicros(jump) % _dayMicros;
      final step = Duration(microseconds: repeated.inMicroseconds.gcd(landing));
      final half = step ~/ 2;
      expect(jump.add(half).floorTo(step), jump, reason: 'after $jump');
      expect(jump.subtract(half).ceilTo(step), jump, reason: 'before $jump');
      expect(jump.floorTo(step), jump, reason: 'at $jump');
    }
  });

  test('calendar-day moves keep the wall clock and the first occurrence', () {
    final failures = _Failures();
    for (final transition in _transitions) {
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

const _dayMicros = Duration.microsecondsPerDay;

/// Steps that follow the clock, including long ones that are not whole days
/// and so can span two clock changes.
const _clockSteps = [
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
  Duration(hours: 25),
  Duration(hours: 36),
  Duration(days: 150, hours: 1),
  Duration(days: 400, minutes: 7),
];

int _offsetAt(int micros) =>
    DateTime.fromMicrosecondsSinceEpoch(micros).timeZoneOffset.inMicroseconds;

/// Every local clock change from 2008 through 2026, in microseconds since
/// the epoch, found by probing the offset every 12 hours and bisecting each
/// change. (Changes are at least six days apart in the time zone database.)
final List<int> _changes = () {
  const probe = 12 * Duration.microsecondsPerHour;
  final result = <int>[];
  final to = DateTime.utc(2027).microsecondsSinceEpoch;
  for (
    var low = DateTime.utc(2008).microsecondsSinceEpoch;
    low < to;
    low += probe
  ) {
    final offset = _offsetAt(low);
    if (_offsetAt(low + probe) == offset) continue;
    var before = low;
    var after = low + probe;
    while (after - before > 1) {
      final middle = before + (after - before) ~/ 2;
      if (_offsetAt(middle) == offset) {
        before = middle;
      } else {
        after = middle;
      }
    }
    result.add(after);
  }
  return result;
}();

/// The changes the receivers sit around: those of 2010 (the last year St.
/// John's changed clocks past midnight, with Casey shifting by 3 hours) and
/// of 2024 and 2025.
final List<DateTime> _transitions = [
  for (final change in _changes)
    if (DateTime.fromMicrosecondsSinceEpoch(change, isUtc: true).year
        case 2010 || 2024 || 2025)
      DateTime.fromMicrosecondsSinceEpoch(change),
];

/// The offset segments covering [from, to), as (start, end, offset): the
/// first starts at [from], every other one at a clock change.
List<(int, int, int)> _segments(int from, int to) {
  final cuts = [
    from,
    for (final change in _changes)
      if (change > from && change < to) change,
    to,
  ];
  return [
    for (var i = 0; i + 1 < cuts.length; i++)
      (cuts[i], cuts[i + 1], _offsetAt(cuts[i])),
  ];
}

int _floorMultiple(int value, int step) => value - value % step;

int _ceilMultiple(int value, int step) => -_floorMultiple(-value, step);

/// Whether a forward jump at the start of `segments[i]` skipped a wall-clock
/// time that is a multiple of [step].
bool _skipsAligned(List<(int, int, int)> segments, int i, int step) {
  if (i == 0) return false;
  final (start, _, offset) = segments[i];
  final before = segments[i - 1].$3;
  return offset > before &&
      _floorMultiple(start + offset - 1, step) >= start + before;
}

/// The latest instant at or before [x] whose wall clock shows a multiple of
/// [step], or at which the clocks jumped over such a time.
DateTime _expectedFloor(DateTime x, int step) {
  final end = x.microsecondsSinceEpoch + 1;
  final segments = _segments(end - step - 3 * _dayMicros, end);
  var best = segments.first.$1;
  for (var i = 0; i < segments.length; i++) {
    final (start, stop, offset) = segments[i];
    final at = _floorMultiple(stop - 1 + offset, step) - offset;
    if (at >= start && at > best) best = at;
    if (_skipsAligned(segments, i, step) && start > best) best = start;
  }
  return DateTime.fromMicrosecondsSinceEpoch(best);
}

/// The earliest instant at or after [x] whose wall clock shows a multiple
/// of [step], or at which the clocks jump over such a time.
DateTime _expectedCeil(DateTime x, int step) {
  final from = x.microsecondsSinceEpoch;
  // Start just before x, so a change exactly at x counts as a jump.
  final segments = _segments(from - 1, from + step + 3 * _dayMicros);
  var best = segments.last.$2;
  for (var i = 0; i < segments.length; i++) {
    final (start, stop, offset) = segments[i];
    final lowest = start > from ? start : from;
    final at = _ceilMultiple(lowest + offset, step) - offset;
    if (at < stop && at < best) best = at;
    if (_skipsAligned(segments, i, step) && start < best) best = start;
  }
  return DateTime.fromMicrosecondsSinceEpoch(best);
}

/// The instants whose wall clock shows [wall] (wall-clock fields read as
/// UTC), earliest first.
List<int> _occurrences(int wall) => [
  for (final (start, stop, offset) in _segments(
    wall - 2 * _dayMicros,
    wall + 2 * _dayMicros,
  ))
    if (wall - offset >= start && wall - offset < stop) wall - offset,
];

/// Every moment that starts the local date [index] days after 1970-01-01,
/// earliest first: each instant whose wall clock shows its midnight right
/// after showing an earlier date, or the moment the clocks jumped past that
/// midnight. (A midnight the clocks repeat within its own date, as in the
/// Azores, starts nothing the second time.)
List<DateTime> _startsOfDate(int index) {
  final midnight = DateTime.utc(1970, 1, 1 + index).microsecondsSinceEpoch;
  final segments = _segments(
    midnight - 2 * _dayMicros,
    midnight + 2 * _dayMicros,
  );
  final starts = <DateTime>[];
  for (var i = 0; i < segments.length; i++) {
    final (start, stop, offset) = segments[i];
    final at = midnight - offset;
    if (at >= start && at < stop) {
      final before = DateTime.fromMicrosecondsSinceEpoch(at - 1);
      if (_dayIndex(before) < index) {
        starts.add(DateTime.fromMicrosecondsSinceEpoch(at));
      }
    } else if (i > 0 &&
        start + segments[i - 1].$3 <= midnight &&
        midnight < start + offset) {
      starts.add(DateTime.fromMicrosecondsSinceEpoch(start)); // skipped
    }
  }
  return starts;
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

/// [date]'s calendar date as a count of days from January 1, 1970.
int _dayIndex(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day).millisecondsSinceEpoch ~/
    Duration.millisecondsPerDay;

/// Whether [date] is a later occurrence of a wall-clock time the clocks
/// repeated.
bool _isLaterOccurrence(DateTime date) =>
    _occurrences(_wallMicros(date)).first != date.microsecondsSinceEpoch;

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
