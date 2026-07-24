---
name: use-dart-helper-utils
description: Use when writing or reviewing Dart/Flutter code that uses the dart_helper_utils package - deep map utilities (flatMap, unflatten, getPath, setPath, deepMerge), string casing/slugify/masking/parseDuration/truncate, MIME filename checks, iterable chunks/windowed/partition/distinctBy, number stats and HTTP status helpers, DateTime and Duration extensions, intl formatting wrappers (formatAsReadableNumber, dateFormat, pluralize), Uri rebuild, or deciding between dart_helper_utils and direct collection/intl/convert_object imports.
---

# Use dart_helper_utils correctly

dart_helper_utils (DHU) is a batteries-included utility package. One import
exposes three layers, and agents reliably misattribute or misname members
across them - use the exact names below instead of memory.

## The one-import model

`import 'package:dart_helper_utils/dart_helper_utils.dart';` gives you:

1. DHU's own extensions and helpers (this skill).
2. ALL of `package:collection` (`firstOrNull`, `groupBy`, `mapIndexed`,
   `DeepCollectionEquality`, ...) - re-exported wholesale.
3. ALL of `package:convert_object` (`Convert.toX`, map `getInt`/`tryGetString`
   getters, `convertToList`, `.convert` fluent chains, `toJsonString`, ...).
4. ALL of `package:stringo` (since DHU 6.1.0) - string text transformations:
   casing, `slugify`, `truncate`, `mask`, whitespace, blank/character checks.
5. ONLY five intl symbols: `Bidi`, `BidiFormatter`, `DateFormat`, `Intl`,
   `NumberFormat`. Anything else from intl needs a direct `package:intl` import.

Consequences:

- Do NOT add `collection` or `convert_object` imports next to a DHU import;
  the DHU import already provides them and duplicate imports invite
  ambiguous-extension errors with pre-6 DHU code.
- Conversion questions (getInt, fromJson factories, ConvertConfig, enum
  parsing) belong to convert_object. If the convert-object plugin is
  installed, its parse-with-convert-object skill is the deeper source.

## Step 0: Inspect the project first

1. Resolved version: `grep -A2 'dart_helper_utils' pubspec.lock`. This skill
   documents 6.x. For 5.x-or-older projects, use the
   migrate-dart-helper-utils-v5-to-v6 skill before writing new code.
2. Match existing style: `grep -rn "dart_helper_utils" lib/ | head` to see how
   the project already uses it; do not mix idioms in one file.

## Exact names agents get wrong (verified against source)

| Task | WRONG guesses | Actual API |
|---|---|---|
| Dot-path read/write | `getNested`/`setNested` | `map.getPath('db.host')`, `map.setPath('db.port', 5432)` (String-keyed maps; `items[0].id` bracket indices supported) |
| Nested to flat and back | `unflatMap` | `map.flatMap({delimiter, excludeArrays})` and `map.unflatten({delimiter, parseIndices})` |
| Raw multi-key lookup | `altKeys:` | `map.tryGetRaw('id', alternativeKeys: ['userId', 'uid'])` (first NON-null wins; from convert_object 1.1+) |
| Fixed-size chunks | `chunked(2)` | `iterable.chunks(2)` |
| Sliding windows | - | `windowed(3, step: 1, partials: false)` |
| Split by predicate | - | `partition(pred)` returns a `(List<E>, List<E>)` record (matching, rest) |
| Parse "1h 30m" | `toDuration()` | `'1h 30m'.parseDuration()` - ONLY clock (`HH:mm:ss`, `mm:ss`) and token (`2d 3h 4m 5s`) formats; no ISO-8601, no bare numbers; throws `FormatException` |
| HTTP date header | `httpFormat` (v5) | `dateTime.httpDateFormat` (getter, RFC-1123) |
| Retry delay for status | `suggestedRetryDelay` | `statusCode.statusCodeRetryDelay` (408 5s, 429 1m, 503 5m, 504 10s; zero for non-retryable) |
| UUID check | `isValidUuid` | `'...'.isUuid` (getter) |

## Casing, slugify, masking (all on String)

Since DHU 6.1.0 these come from the re-exported `stringo` package. The one
DHU import still reaches them - do NOT add a `stringo` import or dependency to
a project that already depends on `dart_helper_utils`. (A project that wants
ONLY these helpers can depend on `stringo` alone; it is zero-dependency.)

- Casing members are GETTERS, not methods: `toCamelCase`, `toPascalCase`,
  `toSnakeCase`, `toKebabCase`, `toTitleCase`, `toScreamingSnakeCase`,
  `toDotCase`, `toWords`, `capitalizeFirstLetter`, and more.
- `toTitleCase` ALWAYS capitalizes the first word (since 6.1.0), then leaves
  later stop words from the public `titleCaseExceptions` set lowercase:
  `'the lord of the rings'.toTitleCase` gives `'The Lord of the Rings'`.
- `slugify()` is a method (`separator` param). ASCII-only: non-ASCII letters
  are DROPPED, not transliterated - do not use it for i18n slugs.
- `maskEmail` (getter) keeps the first two chars of the local part
  (`'johndoe@gmail.com'` becomes `'jo****@gmail.com'`); returns the original
  string unchanged when it is not a valid email.
- `truncate(10)` appends the `'...'` suffix ON TOP of the length (result is up
  to `length + suffix.length` chars) and only when the string is longer than
  `length`.
- MIME checks are filename/extension based getters on `String?`: `isImage`,
  `isVideo`, `isPDF`, `isJSON`, ... They do not read file contents unless you
  pass `headerBytes` to `mimeType()`.

## Map and collection semantics worth knowing

- `deepMerge(other)`: recursive for nested String-keyed maps; `other` wins on
  conflicts; returns a NEW map.
- `setIfMissing` checks key PRESENCE - it will not overwrite an existing key
  even when its value is null.
- `distinctBy(keySelector)`: pass `equals` and `hashCode` TOGETHER or neither;
  supplying only one throws `ArgumentError`.
- `getRandom()` throws `StateError` on an empty iterable; use `tryGetRandom()`
  on nullable iterables.
- Stats (`mean`, `median`, `percentile`, `standardDeviation`) exist on
  `Iterable<num>` directly; `percentile(90)` takes the 0-100 range (v6 change
  from 0-1).

## Dates and durations

- `date.isBetween(start, end)` is start-INclusive, end-EXclusive by default.
- `daysInMonth` returns a full CALENDAR GRID (padded to whole Mon-Sun weeks),
  not just the month's days - use `lastDayOfMonth.day` for the day count.
- `addBusinessDays(n)` skips weekends (negative n supported).
- `firstDayOfWeek()`/`lastDayOfWeek()` are methods with a
  `startOfWeek: DateTime.monday` default.
- Duration: `toClockString()` gives `HH:mm:ss`; `toHumanShort()` gives
  `1h 3m 4s`; `2.secondsDelay()` and `duration.delayed()` schedule futures.

## Intl wrappers

- `1234567.89.formatAsReadableNumber(trimTrailingZeros: true)`,
  `formatAsCurrency`, `formatAsCompact`, `formatAsPercentage` on num.
- `dateTime.format('yMMMd')` plus ~30 `formatAsX` shortcuts
  (`formatAsyMMMMd`, `formatAsEEEE`, ...).
- `'string'.dateFormat([locale])` returns a `DateFormat` for that string.
- `count.pluralize(other: 'items', one: 'item')` and
  `'name'.genderSelect(...)` wrap Intl.

## Verification

After edits: `dart analyze` the touched paths and run the project's tests.
When you used a member from the table above, confirm it resolves (analyzer
errors on undefined members mean a wrong name or a pre-6 DHU version).

## Failure handling

- Undefined-member analyzer errors on names from this skill: check the
  resolved package version first (`pubspec.lock`); 5.x has different names
  (see the migrate-dart-helper-utils-v5-to-v6 skill).
- Ambiguous-extension errors: the file probably imports `collection`,
  `convert_object`, or an old DHU alongside the DHU import - keep exactly one
  provider per file.
- Anything about debouncing, throttling, streams, or bounded-concurrency
  futures: use the async-with-dart-helper-utils skill; those APIs have
  lifecycle rules this skill does not cover.

## Full API tables

For the complete per-domain member lists (strings, casing, MIME, maps,
iterables, numbers/HTTP/stats, dates, durations, URI, intl, bool, globals,
constants), read
[references/api-quick-reference.md](references/api-quick-reference.md).

## When NOT to use this package

- One trivial helper in a project that does not already depend on DHU: prefer
  plain Dart or the focused package (`collection`, `intl`) instead of adding a
  broad dependency.
- Type conversion only: depend on `convert_object` directly; DHU re-exports it
  but pulls in more.
