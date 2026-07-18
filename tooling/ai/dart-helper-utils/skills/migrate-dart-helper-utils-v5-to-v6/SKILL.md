---
name: migrate-dart-helper-utils-v5-to-v6
description: Use when upgrading a project from dart_helper_utils 5.x or earlier to 6.x, or fixing compile errors after that bump - ConvertObject/toString1/ParsingException renames, altKeys to alternativeKeys, firstValueForKeys to tryGetRaw, removed Paginator/DoublyLinkedList/country data/StringSimilarity, httpFormat to httpDateFormat, flatJson to flatMap, TimeUtils.throttle signature change, percentile 0-100 range, delay methods, or helpers that moved to convert_object or package collection.
---

# Migrate dart_helper_utils v5 to v6

v6 is a large breaking release: all conversion logic moved to the
`convert_object` package (re-exported, so one DHU import still works),
several features moved to standalone packages, and many members were
renamed or removed. Source and target: any 5.x (and the same checklist
covers 4.x code, which mostly compiled unchanged under 5.x) to 6.x.

## Preconditions

1. Clean git working tree; do the migration on a branch. Rollback is
   discarding that branch - never reset user work without explicit
   confirmation.
2. Run the test suite BEFORE migrating and record the baseline.
3. Confirm the current version: `grep -A2 'dart_helper_utils' pubspec.lock`.
   Already >= 6.0.0 means only leftover compile errors need the tables here,
   not the dependency change.

## Detect usage (scope the work)

```bash
grep -rln "package:dart_helper_utils" lib/ test/
# v5-only symbols that will break:
grep -rnE "ConvertObject\.|ParsingException|toString1|altKeys|firstValueForKeys|firstElementForIndices|httpFormat|flatJson|makeEncodable|safelyEncodedJson|DoublyLinkedList|Paginator|InfinitePaginator|AsyncPaginator|StringSimilarity|similarityTo|compareWith|DHUCountry|DHUTimezone|convertTo<" lib/ test/
# bare top-level conversion helpers (v5):
grep -rnE "\b(toNum|toInt|toDouble|toBool|toDateTime|toUri|toList|toSet|toMap|toBigInt|toType|tryTo[A-Z][a-zA-Z]*)\(" lib/ test/
```

For a large codebase, delegate the sweep to a read-only search subagent and
have it return the file list with per-symbol counts.

## Ordered steps

1. Bump the dependency: `dart_helper_utils: ^6.0.2` (SDK `^3.10.0`);
   `dart pub get`. Solver conflicts usually mean an old SDK constraint or a
   direct pin on pre-1.1 `convert_object`.
2. Apply the mechanical renames from
   [references/v5-to-v6-api-mapping.md](references/v5-to-v6-api-mapping.md).
   Headlines: `ConvertObject.` to `Convert.`, `toString1` to
   `Convert.string`, bare `toInt(x)` to `convertToInt(x)`,
   `ParsingException` to `ConversionException` (context is `e.context`),
   `altKeys:` to `alternativeKeys:`, `firstValueForKeys` to `tryGetRaw`,
   `httpFormat` to `httpDateFormat`, `flatJson` to `flatMap`,
   `makeEncodable`/`safelyEncodedJson` to `toJsonSafe()`/`toJsonString()`.
3. Replace REMOVED features (each needs a decision, not a rename):
   - Paginator/AsyncPaginator/InfinitePaginator: no v6 equivalent; move to
     a pagination package or inline the logic.
   - DoublyLinkedList: `doubly_linked_list` package.
   - StringSimilarity/`similarityTo`/`compareWith`:
     `string_search_algorithms` package (algorithm enum renamed, e.g.
     `levenshteinDistance` to `levenshtein`).
   - DHUCountry/DHUTimezone datasets: removed; use a dedicated data source.
   - `obj.isInt`/`isDouble`/`isNull` object getters: standard Dart checks or
     `tryConvertToInt(obj) != null`.
   - `list.convertTo<T>()`: `convertToList<T>(list)` (Set keeps
     `convertTo`).
4. Fix duplicate-helper removals: `firstOrNull`, `groupBy`, `mapIndexed`,
   `whereNotNull`, ... now come from the re-exported `package:collection`;
   the same names keep working with ONE DHU import. Ambiguous-extension
   errors mean a file imports both DHU and `collection` (or old DHU
   leftovers) - keep a single provider per file.
5. `dart analyze` and iterate until clean.

## Behavior changes to audit (compile-clean but different at runtime)

- `alternativeKeys` (all typed map getters) now picks the first NON-null
  value; a present-but-null key no longer short-circuits. Audit sites that
  relied on the old behavior; use `containsKey` to distinguish absence.
- `tryToBool` returns null (not false) for unknown values; add `?? false`
  where a false fallback was assumed.
- Numeric parsing is LENIENT by default (commas, spaces, `(123)` as -123);
  set `NumberOptions(strictParsing: true)` via `Convert.configure` to keep
  strict v5 behavior.
- URI parsing auto-detects emails/phones into mailto and tel URIs; disable
  with `UriOptions(detectEmails: false, detectPhoneNumbers: false)`.
- `toDateTime` now accepts numeric epochs (seconds or milliseconds by
  magnitude).
- `percentile` now takes 0-100 (v5 took 0-1): `values.percentile(0.5)`
  must become `values.percentile(50)`.
- `TimeUtils.throttle` signature changed from named `duration:`/`function:`
  to positional `(func, interval, {leading, trailing, onError})` returning a
  callable `ThrottledCallback` with `cancel`/`dispose`.
- `TimeUtils.runWithTimeout` now completes with `TimeoutException` while the
  task keeps running (late errors swallowed).
- `tryRemoveWhere` now takes a predicate and actually removes.
- `setIfMissing` checks key presence, not null values.
- `getRandom` on an empty iterable throws `StateError`; `randomInRange`
  validates min <= max.
- `concatWithSingleList`/`concatWithMultipleList` return the non-empty side
  when one side is empty.
- Delay helpers are methods now: `2.secondsDelay()`, not `2.secDelay`
  (a v4-to-v5 change that often surfaces here).

## Cases requiring human judgment

- Code that parsed `ParsingException` text or inspected `e.parsingInfo`:
  rewrite against `ConversionException.context`/`fullReport()`.
- Dynamic dispatch (`(x as dynamic).toInt()`): greps cannot find these;
  rely on the recorded test baseline.
- Heavy paginator usage: propose the replacement package and get agreement
  before rewriting screens around it.

## Validation

- `dart analyze` clean, then the full test suite compared against the
  pre-migration baseline.
- Re-grep the v5-only symbol list above; zero hits expected.
- Runtime spot-check any `alternativeKeys`, bool-parsing, and percentile
  call sites (the silent behavior changes).

## Before/after example

```dart
// v5
final id = ConvertObject.toInt(json, mapKey: 'id');
final name = ConvertObject.toString1(json['name']);
final raw = json.firstValueForKeys('a', altKeys: ['b']);
final when = date.httpFormat;
final p = scores.percentile(0.9);
try { ... } on ParsingException catch (e) { log(e.parsingInfo.toString()); }

// v6
final id = Convert.toInt(json, mapKey: 'id');
final name = Convert.string(json['name']);
final raw = json.tryGetRaw('a', alternativeKeys: ['b']);
final when = date.httpDateFormat;
final p = scores.percentile(90);
try { ... } on ConversionException catch (e) { log(e.fullReport()); }
```

## Failure handling

- If the project is on 4.x or older, the extra v4-era changes (paginator
  lifecycle, delay methods) are already covered above; for v2/v3-era code
  use the upgrade-dart-helper-utils skill to sequence hops.
- If a symbol is in neither the mapping nor the removals, check the
  package's migration_guides.md and CHANGELOG.md for the installed version
  before inventing a replacement.
