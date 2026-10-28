/// Every factual claim the AI plugin skills make, asserted against the API.
///
/// `tooling/ai/dart-helper-utils/skills/` tells coding assistants what this
/// package does. Those files are excluded from the pub archive, so nothing
/// else in the build notices them going stale, and a wrong skill is worse
/// than a missing one: it makes an assistant confidently write broken code.
///
/// AGENTS.md requires skill facts to match the source. This is that rule,
/// enforced: when a claim here changes, update the skill in the same change.
library;

import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  test('use-dart-helper-utils claims match the shipped API', () {
    final failures = <String>[];
    void check(String claim, Object? actual, Object? expected) {
      if (actual.toString() == expected.toString()) return;
      failures.add(
        '$claim\n    skill says: $expected\n    actual    : $actual',
      );
    }

    // Exact names table.
    final config = <String, Object?>{
      'db': {'host': 'localhost'},
      'items': [
        {'id': 7},
      ],
    };
    check('getPath dotted', config.getPath('db.host'), 'localhost');
    check('getPath bracket index', config.getPath('items[0].id'), 7);
    check(
      'flatMap flattens lists',
      {
        'a': {'b': 1},
        'c': [1, 2],
      }.flatMap(),
      {'a.b': 1, 'c.0': 1, 'c.1': 2},
    );
    check(
      'tryGetRaw first non-null alternative',
      <String, Object?>{
        'id': null,
        'userId': 7,
      }.tryGetRaw('id', alternativeKeys: ['userId']),
      7,
    );
    check('chunks', [1, 2, 3].chunks(2), [
      [1, 2],
      [3],
    ]);
    check('partition record', [1, 2, 3, 4].partition((v) => v.isEven), (
      [2, 4],
      [1, 3],
    ));
    check(
      'parseDuration tokens',
      '1h 30m'.parseDuration(),
      const Duration(hours: 1, minutes: 30),
    );
    check(
      'httpDateFormat RFC-1123',
      DateTime.utc(1970).httpDateFormat,
      'Thu, 01 Jan 1970 00:00:00 GMT',
    );
    check('retry delay 408', 408.statusCodeRetryDelay, '0:00:05.000000');
    check('retry delay 429', 429.statusCodeRetryDelay, '0:01:00.000000');
    check('retry delay 503', 503.statusCodeRetryDelay, '0:05:00.000000');
    check('retry delay 504', 504.statusCodeRetryDelay, '0:00:10.000000');
    check('retry delay non-retryable', 200.statusCodeRetryDelay, Duration.zero);
    check('isUuid getter', '123e4567-e89b-12d3-a456-426614174000'.isUuid, true);

    // 7.0 names.
    final march31 = DateTime(2024, 3, 31, 9);
    check('isSameDayAs', march31.isSameDayAs(DateTime(2024, 3, 31, 23)), true);
    check('addMonths clamps', march31.addMonths(-1), DateTime(2024, 2, 29, 9));
    check('nextDay', march31.nextDay, DateTime(2024, 4, 1, 9));
    check('previousDay', march31.previousDay, DateTime(2024, 3, 30, 9));
    check(
      'isFuture',
      DateTime.now().add(const Duration(hours: 1)).isFuture,
      true,
    );
    final list = [1, 2, 3];
    check('swapped copies', list.swapped(0, 2), [3, 2, 1]);
    check('swapped leaves source', list, [1, 2, 3]);
    list.swap(0, 2);
    check('List.swap is in place (collection)', list, [3, 2, 1]);
    check('firstWhereOrNull', [1, 2, 3].firstWhereOrNull((v) => v > 1), 2);
    check('isBlank', '  '.isBlank, true);
    check('isNotBlank', ' x '.isNotBlank, true);

    // Strings.
    check(
      'toTitleCase first word',
      'the lord of the rings'.toTitleCase,
      'The Lord of the Rings',
    );
    check('slugify drops non-ASCII', 'Café au lait!'.slugify(), 'caf-au-lait');
    check(
      'slugify empty separator throws',
      _throws<ArgumentError>(() => 'a b'.slugify(separator: '')),
      true,
    );
    check(
      'maskEmail keeps two chars',
      'johndoe@gmail.com'.maskEmail,
      'jo****@gmail.com',
    );
    check('truncate counts the suffix', 'Hello World'.truncate(5), 'He...');
    check('mask on a null String? returns null', _maskNullable(null), null);

    // MIME and phone checks.
    check('isDOCX is .docx only', 'a.doc'.isDOCX, false);
    check('isDOC is .doc only', 'a.docx'.isDOC, false);
    check(
      'isWord accepts both',
      ['a.doc', 'a.docx'].every((f) => f.isWord),
      true,
    );
    check('isXLSX is .xlsx only', 'a.xls'.isXLSX, false);
    check(
      'isExcel accepts both',
      ['a.xls', 'a.xlsx'].every((f) => f.isExcel),
      true,
    );
    check(
      'isValidPhoneNumber on String?',
      _phoneNullable('+44 20 7946 0958'),
      true,
    );
    check('isValidPhoneNumber permissive', '555-1234'.isValidPhoneNumber, true);

    // Maps and collections.
    final base = {
      'a': {'x': 1},
      'b': 1,
    };
    final merged = base.deepMerge({
      'a': {'y': 2},
      'b': 2,
    });
    check('deepMerge recursive, other wins', merged, {
      'a': {'x': 1, 'y': 2},
      'b': 2,
    });
    check('deepMerge returns a new map', identical(merged, base), false);
    final presence = <String, int?>{'k': null};
    presence.setIfMissing('k', 1);
    check('setIfMissing keeps a present null', presence['k'], null);
    check(
      'distinctBy equals without hashCode throws',
      _throws<ArgumentError>(
        () => [1].distinctBy((v) => v, equals: (a, b) => a == b),
      ),
      true,
    );
    check(
      'getRandom on empty throws',
      _throws<StateError>(() => <int>[].getRandom()),
      true,
    );

    // Numbers and statistics.
    check('int mean is exact', [1, 2].mean, 1.5);
    check('int median is exact', [1, 2].median, 1.5);
    check('int mode stays int', [1, 1, 2].mode, [1]);
    check('percentile 0-100', [0, 10, 20, 30, 40].percentile(100), 40);
    check('asBool > 0 (convert_object)', (-1).asBool, false);
    check('int.gcd (SDK)', 12.gcd(18), 6);

    // Dates and durations.
    check(
      'daysInMonth is a whole-week grid',
      DateTime(2024, 2, 10).daysInMonth.length % 7,
      0,
    );
    check(
      'addBusinessDays negative',
      DateTime(2024, 6, 10).addBusinessDays(-1),
      DateTime(2024, 6, 7),
    );
    check(
      'firstDayOfWeek defaults to Monday',
      DateTime(2024, 6, 12).firstDayOfWeek(),
      DateTime(2024, 6, 10),
    );
    check(
      'UTC stays UTC',
      DateTime.utc(2024, 3, 15, 22).startOfDay.isUtc,
      true,
    );
    final changeDay = DateTime(2024, 3, 10, 15);
    check(
      'whole-day floorTo matches startOfDay',
      changeDay.floorTo(const Duration(days: 1)),
      changeDay.startOfDay,
    );
    const span = Duration(hours: 1, minutes: 3, seconds: 4);
    check('toClockString', span.toClockString(), '01:03:04');
    check('toHumanShort', span.toHumanShort(), '1h 3m 4s');

    // Intl wrappers.
    check(
      'formatAsReadableNumber',
      1234567.89.formatAsReadableNumber(trimTrailingZeros: true),
      '1,234,567.89',
    );
    check('formatAsyQQQ', DateTime(2024, 5).formatAsyQQQ('en_US'), 'Q2 2024');
    check('enforceRtl', 'abc'.enforceRtl(), Bidi.enforceRtlInText('abc'));
    check(
      'pluralize',
      1.pluralize(other: 'items', one: 'item', locale: 'en'),
      'item',
    );

    expect(failures, isEmpty, reason: failures.join('\n'));
  });

  test('async-with-dart-helper-utils claims match the shipped API', () async {
    expect(
      () => Debouncer(delay: Duration.zero),
      throwsArgumentError,
      reason: 'Debouncer validates delay > 0',
    );
    expect(
      () => Debouncer(
        delay: const Duration(seconds: 1),
        maxWait: const Duration(milliseconds: 500),
      ),
      throwsArgumentError,
      reason: 'maxWait must be > delay',
    );

    final debounced = TimeUtils.debounce(
      () {},
      const Duration(milliseconds: 10),
    );
    expect(debounced, isA<DebouncedCallback>());
    debounced.dispose();

    final throttler = Throttler(interval: const Duration(milliseconds: 10));
    expect(throttler.trailing, isFalse, reason: 'trailing defaults to false');
    throttler.dispose();
    final throttled = TimeUtils.throttle(
      () async {},
      const Duration(milliseconds: 10),
    );
    expect(throttled, isA<ThrottledCallback>());
    throttled.dispose();

    expect(() => const Stream<int>.empty().bufferCount(0), throwsArgumentError);

    final source = StreamController<int>();
    final limited = source.stream.rateLimit(1, const Duration(minutes: 1));
    final seen = <int>[];
    final subscription = limited.listen(seen.add);
    source
      ..add(1)
      ..add(2);
    await pumpEventQueue();
    expect(seen, [1], reason: 'rateLimit drops events over the cap');
    await subscription.cancel();
    await source.close();

    final tasks = [
      () => Future<int>.delayed(const Duration(milliseconds: 20), () => 0),
      () => Future<int>.value(1),
    ];
    expect(await tasks.waitConcurrency(concurrency: 2), [
      1,
      0,
    ], reason: 'completion order by default');
    expect(await tasks.waitConcurrency(concurrency: 2, preserveOrder: true), [
      0,
      1,
    ], reason: 'preserveOrder gives input order');

    final history = Debouncer(
      delay: const Duration(milliseconds: 5),
      maxHistorySize: 1,
    );
    history.run(() {});
    await history.flush();
    expect(history.executionHistory.single.success, isTrue);
    expect(history.executionHistory.single.toMap()['success'], isTrue);
    history.dispose();

    // Retry parameter names differ between futures and streams.
    final retried = await (() async => 1).retry(
      retries: 1,
      delay: const Duration(milliseconds: 1),
      retryIf: (_) => true,
    );
    expect(retried, 1);
    Stream<int> factory() => Stream.value(1);
    final stream = factory.retry(
      retryCount: 1,
      delayFactor: const Duration(milliseconds: 1),
      shouldRetry: (_) => true,
    );
    expect(await stream.toList(), [1]);

    await expectLater(
      TimeUtils.runWithTimeout(
        task: () => Future<void>.delayed(const Duration(milliseconds: 50)),
        timeout: const Duration(milliseconds: 1),
      ),
      throwsA(isA<TimeoutException>()),
      reason: 'runWithTimeout is a soft deadline that throws',
    );
  });
}

String? _maskNullable(String? value) => value.mask();

bool _phoneNullable(String? value) => value.isValidPhoneNumber;

bool _throws<T extends Object>(void Function() body) {
  try {
    body();
    return false;
  } on Object catch (error) {
    return error is T;
  }
}
