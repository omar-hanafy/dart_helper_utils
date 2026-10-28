---
name: migrate-dart-helper-utils-v6-to-v7
description: Use when upgrading a project from dart_helper_utils 6.x to 7.x, or fixing analyzer errors and deprecation warnings after that bump - isAtSameDayAs/addOrSubtractMonths/tomorrow/isPresent/formatASyQQQ/enforceRtlIn/swap/find renames, String isEmptyOrNull to isBlank, Dart 3.13.5 and stringo 3 requirements, int statistics now returning double, UTC and daylight-saving changes in date helpers, isDOCX/isXLSX precision, typed Debouncer executionHistory, or DebouncerState no longer being Equatable.
---

# Migrate dart_helper_utils v6 to v7

v7 is a correctness release. The renames are automated: the package ships
`dart fix` data, and every renamed member stays as a deprecated alias until
8.0.0, so the project compiles before and after the fix. The rest are
behavior corrections that need a human decision only where the project relied
on the old (wrong) result.

## Preconditions

1. Clean git working tree; migrate on a branch. Never reset user work
   without explicit confirmation.
2. Run the tests BEFORE migrating and record the baseline.
3. Confirm versions: `grep -A2 'dart_helper_utils' pubspec.lock` and
   `dart --version`. 7.x needs Dart 3.13.5 or later (Flutter 3.47.7 or
   later). A 5.x project must take the migrate-dart-helper-utils-v5-to-v6
   hop first.

## Ordered steps

1. Set `dart_helper_utils: ^7.0.0`; run `dart pub get` (or
   `flutter pub get`). A solver failure usually means the SDK constraint is
   below 3.13.5, or the project pins `stringo` below 3.0.0 or `equatable`
   through this package (7.x no longer depends on equatable).
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
   | `iterable.find(test)` | `iterable.firstWhereOrNull(test)` |
   | `DHUNullableSetExtensions(set)` | `DHUCollectionsExtensionsNS(set)` |

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
grep -rnE "startOfDay|dateOnly|startOf(Month|Year)|(first|last)DayOf(Month|Week)|(previous|next)(Month|Day|Week)|add(Days|Months|Years|BusinessDays)|daysUpTo|daysInMonth" lib/ test/
grep -rnE "isDOC|isXLSX|isValidPhoneNumber|executionHistory|DebouncerState|bufferCount|rateLimit|roundTo|floorTo|ceilTo|httpDateFormat" lib/ test/
```

| Change | What to check |
|---|---|
| `Iterable<int>` `mean`/`median`/`variance`/`standardDeviation` return `double` (no truncation) | Analyzer flags `int` assignments; add `.round()`/`.toInt()` only if truncation was intended |
| UTC receivers stay UTC in `startOfDay`, `dateOnly`, `startOfMonth`, `startOfYear`, `firstDayOfMonth`, `lastDayOfMonth`, `previousMonth`, `nextMonth`, `addMonths`, `addYears` | Remove `toUtc()`/`toLocal()` workarounds around these calls |
| Day arithmetic (`addDays`, `nextDay`, `nextWeek`, `firstDayOfWeek`, `addBusinessDays`, `daysUpTo`, `daysInMonth`, ...) keeps wall-clock time across DST | Use `date.add(const Duration(days: n))` where exact 24-hour steps are required |
| `remainingDays`, `passedDays`, `daysDifferenceTo`, `isTomorrow`, `isYesterday` count calendar days | Drop off-by-one compensation around DST |
| `roundTo`/`floorTo`/`ceilTo` align to the receiver's wall clock; whole-day steps match `startOfDay` | Matters in half-hour zones, around clock changes, and for pre-1970 dates |
| `httpDateFormat` takes every field from UTC | Drop manual `toUtc()` workarounds |
| `isDOCX` is only .docx, `isDOC` only .doc, `isXLSX` only .xlsx | Use `isWord` / `isExcel` to accept either format |
| `String?.isValidPhoneNumber` uses the same permissive check as `String` | For the old strict pattern use `patternValidPhoneNumber` |
| `Debouncer.executionHistory` is `List<DebouncerExecutionRecord>` | `record['success']` becomes `record.success`; `toMap()` gives the old map |
| `DebouncerState` no longer extends `Equatable` | Code using `props` or `is Equatable` needs editing; `==` is unchanged |
| `bufferCount`/`rateLimit` keep per-subscription state; `rateLimit` subscribes lazily | Tests that relied on events before `listen` must listen first |
| `TimeUtils` and `NumbersHelper` are `abstract final` | Subclasses or mocks that `implements` them no longer compile |
| Re-exported stringo 3 behavior | `'Hello World'.truncate(5)` is `'He...'`; `mask`/`insert` on `String?` return `String?` (append `?? ''`) |

Removed duplicates need no action in normal code: `DateTime.copyWith`
(dart:core has it), `int.gcd`, non-null `num.isNegative` (SDK members), and
`num?.asBool` (convert_object has the same rule) still resolve. Only an
explicit extension override of them, such as `DHUDateExtensions(d).copyWith`,
needs the override removed.

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
