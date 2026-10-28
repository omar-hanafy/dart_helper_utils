[![dart_helper_utils logo](https://raw.githubusercontent.com/omar-hanafy/dart_helper_utils/main/logo.svg)](https://pub.dev/packages/dart_helper_utils)

[![pub package](https://img.shields.io/pub/v/dart_helper_utils.svg)](https://pub.dev/packages/dart_helper_utils)
[![pub points](https://img.shields.io/pub/points/dart_helper_utils)](https://pub.dev/packages/dart_helper_utils/score)
[![CI](https://github.com/omar-hanafy/dart_helper_utils/actions/workflows/ci.yml/badge.svg)](https://github.com/omar-hanafy/dart_helper_utils/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/omar-hanafy/dart_helper_utils/blob/main/LICENSE)

Extensions and small utilities for everyday Dart: nested maps, strings,
collections, numbers, dates, durations, debouncing, streams, URIs, and intl
formatting. The same import re-exports
[`convert_object`](https://pub.dev/packages/convert_object) for type
conversion, [`stringo`](https://pub.dev/packages/stringo) for string
transforms, all of [`collection`](https://pub.dev/packages/collection), and
the core [`intl`](https://pub.dev/packages/intl) formatters, so one import
covers what would otherwise be five.

It is pure Dart with no Flutter dependency, so it runs in Flutter apps, on
servers, and on the web.

- [API reference](https://pub.dev/documentation/dart_helper_utils/latest/dart_helper_utils/)
- [Changelog](https://pub.dev/packages/dart_helper_utils/changelog)
- [Migration guide](https://github.com/omar-hanafy/dart_helper_utils/blob/main/migration_guides.md)
- [Plugin for AI coding assistants](#ai-coding-assistant-support) (Claude
  Code, Codex, and Antigravity)

## Install

```bash
dart pub add dart_helper_utils
```

In a Flutter app, run `flutter pub add dart_helper_utils`. Version 7 needs
Dart 3.13.5 or later (Flutter 3.47.7 or later). Then import the one library:

```dart
import 'package:dart_helper_utils/dart_helper_utils.dart';
```

## A quick look

```dart
final config = {
  'db': {
    'host': 'localhost',
    'pool': {'size': '20'},
  },
  'tags': ['api', 'internal'],
};

print(config.getPath('db.pool.size')); // 20
print(config.flatMap()['tags.1']); // internal
print([1, 2, 3, 4, 5].chunks(2)); // [[1, 2], [3, 4], [5]]
print('1h 30m'.parseDuration().inMinutes); // 90
print(1234567.891.formatAsReadableNumber()); // 1,234,567.89
print('invoice.pdf'.isPDF); // true
print(DateTime(2024, 1, 31).addMonths(1)); // 2024-02-29 00:00:00.000
```

## What's included

| Area | Examples |
|---|---|
| Maps | `getPath`, `setPath`, `flatMap`, `unflatten`, `deepMerge`, `setIfMissing`, and convert_object's typed reads (`getInt`, `getString`, `getList`, `tryGetRaw`) |
| Strings | `isValidEmail`, `isUuid`, `isValidIp4`, `parseDuration`, file-type checks by name (`isPDF`, `isImage`, `isWord`, `mimeType`), and stringo's `toSnakeCase`, `toTitleCase`, `slugify`, `truncate`, and `mask` |
| Collections | `chunks`, `windowed`, `partition`, `distinctBy`, `swapped`, `getRandom`, and all of `package:collection` (`groupBy`, `firstWhereOrNull`, `mapIndexed`, ...) |
| Numbers | `mean`, `median`, `mode`, `percentile`, `standardDeviation`; HTTP status checks (`isSuccessCode`, `statusCodeRetryDelay`); `toFileSize`, `asGreeks`, `toOrdinal`, `isPrime` |
| Dates | `addDays`, `addMonths`, `addBusinessDays`, `nextDay`, `isSameDayAs`, `isBetween`, `isFuture`, `startOfDay`, `startOfMonth`, `firstDayOfWeek`, `daysInMonth`, `roundTo`, `httpDateFormat` |
| Durations | `toClockString`, `toHumanShort`, `delayed`, and number shortcuts such as `2.secondsDelay()` |
| Async | `Debouncer`, `Throttler`, `TimeUtils.debounce`, `TimeUtils.throttle`, `TimeUtils.runWithTimeout`, `mapConcurrent`, `waitConcurrency`, and Future `minWait`, `timeoutOrNull`, and `retry` |
| Streams | `asPausable`, `rateLimit`, `bufferCount`, `window`, `withLatestValue`, retrying stream factories, and `safeAdd` on a `StreamController` |
| URIs | `rebuild`, `mergeQueryParameters`, `appendPathSegment` |
| Intl | `format` plus about 30 `formatAsX` date shortcuts, `formatAsCurrency`, `formatAsCompact`, `formatAsReadableNumber`, `pluralize`, `enforceRtl` |
| Constants | `httpStatusMessages`, `cssColorNamesToArgb`, and precompiled validator patterns (`patternValidEmail`, `patternValidUrl`, ...) |

The [API reference](https://pub.dev/documentation/dart_helper_utils/latest/dart_helper_utils/)
documents every member.

## Debouncing and throttling

```dart
final debouncer = Debouncer(
  delay: const Duration(milliseconds: 300),
  maxWait: const Duration(seconds: 2),
);

void onQueryChanged(String query) => debouncer.run(() => search(query));

// When the screen or service goes away:
debouncer.dispose();
```

`maxWait` makes a long burst of input still run the action at least every
two seconds. A `Debouncer` can also fire on the leading edge
(`immediate: true`), pause and resume, `flush` a pending action, publish its
state on `stateStream`, and keep a typed `executionHistory`. `Throttler` and
`TimeUtils.throttle` cover the opposite case: run at most once per interval.

## Bounded concurrency

```dart
// Up to 4 uploads run at once; results come back in input order.
final urls = await files.mapConcurrent(
  upload,
  parallelism: 4,
  preserveOrder: true,
);
```

Without `preserveOrder: true`, results arrive in completion order, which is
faster to consume when order does not matter. `waitConcurrency` does the
same for a list of task functions.

## Streams without a reactive dependency

```dart
final limited = clicks.rateLimit(5, const Duration(seconds: 1));
final batches = logLines.bufferCount(100);
final latest = prices.withLatestValue();
```

`rateLimit` drops events over 5 per second, `bufferCount` emits lists of 100
events, and `withLatestValue` replays the last price to each new listener.
Each listener of a broadcast stream gets its own batches and its own rate
budget.

## Soft timeouts

```dart
try {
  final report = await TimeUtils.runWithTimeout(
    task: fetchReport,
    timeout: const Duration(seconds: 5),
  );
  show(report);
} on TimeoutException {
  showSlowNetworkBanner();
}
```

The timeout ends the wait, not the task: `fetchReport` keeps running in the
background. Use `timeoutOrNull` on a `Future` to get `null` instead of an
exception.

## Nested maps

```dart
final payload = {
  'user': {
    'name': 'Ada',
    'langs': ['dart', 'go'],
  },
};

print(payload.getPath('user.langs[1]')); // go
final flat = payload.flatMap();
print(flat); // {user.name: Ada, user.langs.0: dart, user.langs.1: go}
print(flat.unflatten()); // {user: {name: Ada, langs: [dart, go]}}
```

`getPath` and `setPath` read and write dotted paths with `[index]` steps
into lists, and `unflatten` turns numbered keys back into lists.

## Dates that follow the calendar

```dart
final saturday = DateTime(2024, 3, 9, 10, 30);
print(saturday.addDays(1)); // 2024-03-10 10:30:00.000
print(saturday.nextWeek); // 2024-03-16 10:30:00.000
print(saturday.isSameDayAs(DateTime(2024, 3, 9, 23, 59))); // true

final friday = DateTime(2024, 6, 14);
print(friday.addBusinessDays(1)); // 2024-06-17 00:00:00.000

final utcNoon = DateTime.utc(2024, 5, 17, 12);
print(utcNoon.startOfMonth); // 2024-05-01 00:00:00.000Z
```

Day arithmetic moves by calendar days and keeps the wall-clock time, even
across a daylight-saving change: where clocks jump forward on March 10, the
first line still prints 10:30, although only 23 hours pass. Use
`add(const Duration(days: 1))` when you need exactly 24 hours. Helpers keep
the receiver's time zone, so a UTC date stays UTC.

On the day of a change, a time the clocks skip moves forward by the jump, and
a time they repeat resolves to its first occurrence, unless the date you
start from is itself the repeat. `floorTo`, `ceilTo`, and
`roundTo` align to the wall clock, and whole-day steps count calendar dates,
so `floorTo(const Duration(days: 1))` equals `startOfDay`. The test suite
checks these rules in nine time zones and on the web.

## Formatting with intl

```dart
print(1234.5.formatAsCurrency(locale: 'en_US')); // $1,234.50
print(DateTime(2024, 5, 17).format('yMMMd', 'en_US')); // May 17, 2024
print(1.pluralize(other: 'files', one: 'file', locale: 'en')); // file
print(3.toOrdinal()); // 3rd
```

Only five intl symbols are re-exported: `Bidi`, `BidiFormatter`,
`DateFormat`, `Intl`, and `NumberFormat`. Import `package:intl` directly for
anything else.

## AI coding-assistant support

This repository also ships a plugin that teaches coding agents the exact
dart_helper_utils API, so they stop guessing member names from older
releases. It is tooling for your agent, not part of the Dart package, and it
contains instructions only: no hooks, MCP servers, or network access.

| Skill | What it covers |
|---|---|
| `use-dart-helper-utils` | Member names and semantics across maps, strings, collections, numbers, dates, durations, intl, and URIs, plus the one-import model |
| `async-with-dart-helper-utils` | Debouncer and throttle lifecycles, stream transformers, futures, bounded concurrency, and their ordering and disposal traps |
| `migrate-dart-helper-utils-v6-to-v7` | The 7.0 upgrade: `dart fix --apply` for the renames, then the behavior checklist |
| `migrate-dart-helper-utils-v5-to-v6` | The 6.0 upgrade, when conversion moved to convert_object |
| `upgrade-dart-helper-utils` | Finding the installed version and ordering the upgrade steps from any older release |

Claude Code (in a session):

```text
/plugin marketplace add omar-hanafy/dart_helper_utils
/plugin install dart-helper-utils@dart-helper-utils-tools
```

Codex:

```bash
codex plugin marketplace add omar-hanafy/dart_helper_utils
codex plugin add dart-helper-utils@dart-helper-utils-tools
```

Antigravity, for the `agy` CLI and the IDE and desktop app, which read the
same plugin folder:

```bash
agy plugin install https://github.com/omar-hanafy/dart_helper_utils/tree/main/tooling/ai/dart-helper-utils
```

Start a new agent session after installing (or run `/reload-plugins` in
Claude Code). The skills load when a request needs them, for example
"upgrade this project to dart_helper_utils 7" or "debounce this search field
with dart_helper_utils and clean it up on dispose".
The [plugin README](https://github.com/omar-hanafy/dart_helper_utils/blob/main/tooling/ai/dart-helper-utils/README.md)
covers updating, removing, and the checks behind it. Installation is tested
in Claude Code 2.1.312, Codex 0.165.0, and Antigravity CLI 1.3.3 and 1.4.9,
and CI repeats the test weekly with each host's current release.

## Upgrading

To move from 6.x to 7.x, raise the constraint to `^7.0.0`, run
`dart pub get`, then let `dart fix` rename the changed members:

```bash
dart fix --dry-run
dart fix --apply
```

It rewrites `isAtSameDayAs` to `isSameDayAs`, `addOrSubtractMonths` to
`addMonths`, `tomorrow` to `nextDay`, and the other renames. The old names
keep compiling as deprecated aliases until 8.0.0, except `Iterable.find` and
`DHUNullableSetExtensions`, which are removed; `dart fix` migrates those
too, apart from an explicit `DHUCollectionsExtensions(x).find(...)` call.
Then review the changes `dart fix` cannot see: `mean`, `median`,
`variance`, and `standardDeviation` on `Iterable<int>` return `double`,
calendar helpers keep UTC dates in UTC, day arithmetic keeps the wall-clock
time, `isDOCX` and `isXLSX` match only their own extensions, and the
re-exported stringo 3 changes `truncate`, `mask`, and a few other string
helpers. The
[migration guide](https://github.com/omar-hanafy/dart_helper_utils/blob/main/migration_guides.md)
lists every step, including those for older versions:

- 6.1.0 moved string transforms to `stringo` and 6.0.0 moved conversion to
  `convert_object`. Both are re-exported, so most call sites did not change.
- 6.0.0 also removed helpers that `package:collection` already provides, and
  the map JSON helpers `encodableCopy` and `encodedJsonString` gave way to
  convert_object's `toJsonSafe` and `toJsonString`.

## Related packages

These started inside dart_helper_utils and now stand alone:

- [convert_object](https://pub.dev/packages/convert_object): type conversion
  (re-exported here)
- [stringo](https://pub.dev/packages/stringo): string transforms
  (re-exported here)
- [string_search_algorithms](https://pub.dev/packages/string_search_algorithms):
  string similarity and substring search
- [doubly_linked_list](https://pub.dev/packages/doubly_linked_list): a
  doubly linked list with O(1) insertions and removals

## Contributing

Bug reports and pull requests are welcome on
[GitHub](https://github.com/omar-hanafy/dart_helper_utils/issues). A change
has to pass formatting, strict analysis, the `dart fix` goldens, and tests
that also run in other time zones and on the web;
[AGENTS.md](https://github.com/omar-hanafy/dart_helper_utils/blob/main/AGENTS.md)
lists the exact commands.

## License

MIT. See
[LICENSE](https://github.com/omar-hanafy/dart_helper_utils/blob/main/LICENSE).
