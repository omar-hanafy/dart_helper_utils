---
name: migrate-dart-helper-utils-v6-to-v7
description: Use when upgrading a project from dart_helper_utils 6.x to 7.x, or fixing analyzer errors and deprecation warnings after that bump - isAtSameDayAs/addOrSubtractMonths/tomorrow/isPresent/formatASyQQQ/enforceRtlIn/swap/find renames, String isEmptyOrNull to isBlank, Dart 3.13.5 and stringo 3 requirements, the removed Iterable.find, int statistics now returning double, mask and insert returning String?, UTC and daylight-saving changes in date helpers, isDOCX/isXLSX precision, typed Debouncer executionHistory, DebouncerState no longer being Equatable, or test values that changed because 7.0 fixed a bug.
---

# Migrate dart_helper_utils v6 to v7

v7 is a correctness release. The renames are automated: the package ships
`dart fix` data, and every renamed member stays as a deprecated alias until
8.0.0, so that code compiles before and after the fix. Two members were
removed outright, `Iterable.find` and `DHUNullableSetExtensions`; they are
compile errors until `dart fix --apply` rewrites them. The rest are behavior
corrections that need a human decision only where the project relied on the
old (wrong) result.

## Preconditions

1. Clean git working tree; migrate on a branch. Never reset user work
   without explicit confirmation.
2. Run the tests BEFORE migrating and record the baseline.
3. Confirm versions: `dart pub deps --style=compact | grep '^- dart_helper_utils '`
   (`flutter pub deps` in a Flutter app) and `dart --version`. 7.x needs Dart 3.13.5 or later (Flutter 3.47.7 or
   later). A 5.x project must take the migrate-dart-helper-utils-v5-to-v6
   hop first.

## Ordered steps

1. Set `dart_helper_utils: ^7.0.0`; run `dart pub get` (or
   `flutter pub get`). A solver failure usually means the installed Dart SDK
   is older than 3.13.5 (Flutter older than 3.47.7), or a dependency pins
   `stringo` below 3.0.0. If code imports `package:equatable` without listing
   it, add `equatable` to the project's own dependencies: 7.x dropped it, so
   the import fails with "Target of URI doesn't exist".
2. Run `dart fix --dry-run`, then `dart fix --apply`. It rewrites:

   | 6.x | 7.x |
   |---|---|
   | `isAtSameYearAs` ... `isAtSameMicrosecondAs` | `isSameYearAs` ... `isSameMicrosecondAs` |
   | `addOrSubtractYears` / `addOrSubtractMonths` | `addYears` / `addMonths` |
   | `addOrSubtractDays` (and Minutes, Seconds, Milliseconds, Microseconds) | `addDays` (and the matching `add*`) |
   | `date.tomorrow` / `date.yesterday` | `date.nextDay` / `date.previousDay` |
   | `date.isPresent` | `date.isFuture` |
   | `formatASyQQQ` | `formatAsyQQQ` |
   | `enforceRtlIn()` | `enforceRtl()` |
   | `iterable.swap(i, j)` on a non-`List` | `iterable.swapped(i, j)` |
   | `text.isEmptyOrNull` / `text.isNotEmptyOrNull` on `String?` | `text.isBlank` / `text.isNotBlank` |
   | `iterable.find(test)` (removed) | `iterable.firstWhereOrNull(test)` |
   | `DHUNullableSetExtensions(set)` (removed) | `DHUCollectionsExtensionsNS(set)` |

   Leave `list.swap(i, j)` on a `List` alone: it is collection's in-place
   swap. `isEmptyOrNull` on `Iterable?`/`Map?` is unchanged and not
   deprecated.
3. Fix the one form `dart fix` cannot: an explicit
   `DHUCollectionsExtensions(x).find(test)` becomes
   `x.firstWhereOrNull(test)`.
4. Run `dart analyze`. Remaining errors come from the type and class changes
   below, not from renames.
5. Walk the behavior checklist below, then run the tests and compare with
   the baseline.

## Behavior checklist

Search first; most projects hit only a few items.

```bash
grep -rnE "\.(mean|median|variance|standardDeviation)\b" lib/ test/
grep -rnE "startOfDay|dateOnly|startOf(Month|Year)|(first|last)DayOf(Month|Week)|(previous|next)(Month|Day|Week)|add(Days|Months|Years|BusinessDays)|subtract(Days|Months|Years)|daysUpTo|daysInMonth|remainingDays|passedDays|daysDifferenceTo|isTomorrow|isYesterday" lib/ test/
grep -rnE "isDOC|isXLSX|isValidPhoneNumber|executionHistory|DebouncerState|bufferCount|rateLimit|roundTo|floorTo|ceilTo|httpDateFormat|lastOrDefault|\.mode\b" lib/ test/
grep -rnE "\.(truncate|mask|insert|removeSurrounding|replaceAfter|replaceBefore|slugify|toCharArray|toWords)\b" lib/ test/
```

| Change | What to check |
|---|---|
| `Iterable<int>` `mean`/`median`/`variance`/`standardDeviation` return `double` (no truncation) | Analyzer flags `int` assignments; add `.round()`/`.toInt()` only if truncation was intended |
| UTC receivers stay UTC in `startOfDay`, `dateOnly`, `startOfMonth`, `startOfYear`, `firstDayOfMonth`, `lastDayOfMonth`, `previousMonth`, `nextMonth`, `addMonths`, `addYears` | Remove `toUtc()`/`toLocal()` workarounds around these calls |
| Day arithmetic (`addDays`, `nextDay`, `nextWeek`, `firstDayOfWeek`, `addBusinessDays`, `daysUpTo`, ...) keeps wall-clock time across DST; every `daysInMonth` entry is the `startOfDay` of its date | Use `date.add(const Duration(days: n))` where exact 24-hour steps are required |
| `remainingDays`, `passedDays`, `daysDifferenceTo`, `isTomorrow`, `isYesterday` count calendar days | Drop off-by-one compensation around DST |
| `roundTo`/`floorTo`/`ceilTo` align to the receiver's wall clock; `floorTo(const Duration(days: 1))` equals `startOfDay`, and multi-day steps count calendar dates from 1970-01-01 (a Thursday) | Matters in half-hour zones, around clock changes, and for pre-1970 dates; use `firstDayOfWeek` for weeks |
| `httpDateFormat` takes every field from UTC | Drop manual `toUtc()` workarounds |
| `isDOCX` is only .docx, `isDOC` only .doc, `isXLSX` only .xlsx | Use `isWord` / `isExcel` to accept either format |
| `String?.isValidPhoneNumber` uses the same permissive check as `String` | For the old strict pattern use `patternValidPhoneNumber` |
| `Debouncer.executionHistory` is `List<DebouncerExecutionRecord>` | `record['success']` becomes `record.success`; `toMap()` gives the old map |
| `DebouncerState` no longer extends `Equatable` | Code using `props` or `is Equatable` needs editing; `==` is unchanged |
| `bufferCount`/`rateLimit` keep per-subscription state; `rateLimit` subscribes lazily | Tests that relied on events before `listen` must listen first |
| `TimeUtils` and `NumbersHelper` are `abstract final` | Subclasses or mocks that `implements` them no longer compile |
| Re-exported stringo 3 behavior | `'Hello World'.truncate(5)` is `'He...'`; `mask` and `insert` now return `String?` on every receiver, including a non-null `String` (6.x returned `String`), so append `?? ''` where a `String` is required (`truncate`, `removeSurrounding`, `replaceAfter`, and `replaceBefore` already returned `String?`); `slugify` turns `-`, `_`, and whitespace all into the separator; `toCharArray` splits by code point; `toWords` drops empty words |
| `lastOrDefault` returns `E`, not `E?` | Remove the now-dead `?? fallback` after it (`dead_null_aware_expression`) |
| Results corrected in 7.0 (bug fixes) | `addMonths` with a negative offset across a year (6.x: January minus 2 months gave November of the same year), negative `asGreeks`, `isPowerOf(0)`, `toFileSize` below 1 byte, `bitCount`/`primeFactors`/`isFibonacci` on negatives, `lcm(0)`, the sign of `NumbersHelper.gcd`, `Debouncer.remainingTime`/`remainingMaxWait` while paused (frozen values, not `null`), `DateTime.min`/`max` at microsecond precision. Update tests that asserted the old values |

Removed duplicates need no action in normal code: `DateTime.copyWith`
(dart:core has it), `int.gcd`, non-null `num.isNegative` (SDK members), and
`num?.asBool` (convert_object has the same rule) still resolve. Only an
explicit extension override of them, such as `DHUDateExtensions(d).copyWith`,
needs the override removed. `isNegative` on a `num?` now delegates to the
SDK getter, so `-0.0` counts as negative there too.

## Verification

1. `dart analyze` reports no errors and no `deprecated_member_use` from
   dart_helper_utils (a leftover means `dart fix` was not re-run after
   manual edits; run it again).
2. Run the full test suite and compare with the baseline; investigate every
   new failure against the behavior checklist before changing a test.

## Failure handling

- `dart fix --apply` changes nothing: the project still resolves 6.x. Check
  `pubspec.lock`, then re-run `dart pub get`.
- `undefined_getter`/`undefined_method` for `isEmptyOrNull` on a `String`
  from a direct `package:stringo` import: stringo 2+ removed it; replace it
  with `isBlank` by hand or import dart_helper_utils in that file.
- Version solving failed on `stringo`: another dependency pins stringo 1.x
  or 2.x; upgrade that dependency or add a temporary
  `dependency_overrides` only after checking its changelog.
