---
name: upgrade-dart-helper-utils
description: Use when bumping the dart_helper_utils package version in a project or auditing an upgrade's impact - detecting the installed version, sequencing migration hops across v2/v3/v4/v5/v6, patch-level 6.0.x bumps, or answering "is it safe to upgrade dart_helper_utils".
---

# Upgrade dart_helper_utils across versions

Version-aware audit. Determine the CURRENT resolved version first, apply
only the hops that cross it, and verify with the project's own tests.

## Step 1: Detect versions

```bash
grep -n "dart_helper_utils" pubspec.yaml     # declared constraint
grep -A2 "  dart_helper_utils:" pubspec.lock # resolved version
```

If the resolved version already equals the target: report "no migration
needed" and stop (do not invent work).

## Hop table (apply in order, oldest first)

| From | To | Size | What changes |
|---|---|---|---|
| 1.x | 2.x | small | `toDateWithFormat` to `toDateFormatted`; `dateFormat` became a method with optional locale; `firstDayOfWeek`/`lastDayOfWeek` became methods with `startOfWeek:`; `flatJson` to `flatMap`; `makeEncodable`/`safelyEncodedJson` to `encodableCopy`/`encodedJsonString` |
| 2.x | 3.x | small | removed deprecated `String.toDateTime` (use `toDate`/`toDateFormatted`) and `DateTime.format` (use `formatted`) |
| 3.x | 4.x | medium | paginators rebuilt on `BasePaginator` (lifecycle, transform caching, `CancelableOperation`); generic `delay()` replaced by unit methods (`2.secondsDelay()`); disposal became no-op instead of throwing |
| 4.x/5.x | 6.x | LARGE | use the dedicated migrate-dart-helper-utils-v5-to-v6 skill (conversion moved to convert_object, renames, removals, behavior changes) |
| 6.0.x | 6.0.y | none | patch releases are docs/tooling unless the CHANGELOG says otherwise - read it first |

Shortcut when crossing several majors: paginator work in the 3-to-4 hop is
WASTED if the target is 6.x (paginators were removed in v6) - go straight
to choosing a pagination replacement. The same applies to
`encodableCopy`/`encodedJsonString` (renamed again in v6 to
`toJsonSafe`/`toJsonString`).

## Step 2: Execute

1. Update the pubspec constraint; `dart pub get` (or
   `dart pub upgrade dart_helper_utils`).
2. Work through ONLY the hops crossed, oldest first, using the hop table
   and (for the v6 hop) the dedicated migration skill.
3. `dart analyze` and run the full test suite; compare failures against the
   pre-upgrade baseline (record it first).

## Failure handling

- Solver conflict: 6.x needs SDK `^3.10.0` and `convert_object ^1.1.0`;
  a direct dependency pinning `convert_object <1.1` (or an old SDK) blocks
  resolution.
- Behavior differences that survive a clean compile (bool parsing,
  `alternativeKeys`, percentile range) are catalogued in the
  migrate-dart-helper-utils-v5-to-v6 skill's behavior-changes section.
- If the installed or target version is NEWER than 6.0.x, this skill may
  predate it: read the package CHANGELOG for entries above 6.0.2 and treat
  any "breaking" bullet as its own hop.
