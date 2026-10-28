# dart_helper_utils - agent guide (maintainers)

Pure-Dart utility package (no Flutter dependency). Public API is
`lib/dart_helper_utils.dart`, which re-exports ALL of `package:collection`,
ALL of `package:convert_object`, ALL of `package:stringo`, five intl symbols
(`Bidi`, `BidiFormatter`, `DateFormat`, `Intl`, `NumberFormat`), and this
package's own `lib/src/` tree (extensions, Debouncer/TimeUtils, raw_data
constants).

## Validation gates (run before claiming any change done)

```bash
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos .               # every lint is a gate
dart fix test_fixes --compare-to-golden    # dart fix migrations stay valid
dart run tool/check_repo.dart              # em-dash, changelog, platform, deprecation rules
dart run tool/validate_agent_plugin.dart   # AI plugin/marketplace consistency
# After plugin changes (needs the claude, codex, and agy CLIs on PATH):
dart run tool/verify_agent_hosts.dart --require claude,codex,agy
dart test
for z in America/New_York Asia/Kolkata Africa/Cairo Australia/Lord_Howe \
         Atlantic/Azores America/St_Johns Antarctica/Troll Antarctica/Casey \
         Pacific/Chatham; do
  TZ=$z dart test test/date_extension_test.dart \
    test/date_extension_additional_test.dart test/date_time_zone_test.dart \
    test/readme_test.dart
done
for z in America/New_York Australia/Lord_Howe; do
  TZ=$z dart test --platform node test/date_time_zone_test.dart
done
dart pub publish --dry-run                 # must stay at 0 warnings
```

CI runs all of these except the host check, which the Agent plugin workflow
runs on plugin changes and weekly. CI also adds a lowest-dependency run on
the minimum SDK and requires a PERFECT pana score on PRs ("CI / Pana" is a
required check, pinned pana version, `--exit-code-threshold 0`). Avoid
changes that cost points (missing doc comments, dependency issues, format
drift).

`analysis_options.yaml` is strict (strict-casts/inference/raw-types and 80
validated rules); `test/` and `example/` relax only doc and API-shape rules.
Never weaken a rule to get a green run; fix the code, or add an
`// ignore:` whose preceding comment says why (`document_ignores` enforces
the reason, `unnecessary_ignore` removes stale ones).

## Conventions

- Conversion logic lives in the `convert_object` package, NOT here; do not
  add conversion features to this repo (contribute upstream instead). The
  same applies to string similarity (`string_search_algorithms`), linked
  lists (`doubly_linked_list`), and - since 6.1.0 - string text
  transformations (`stringo`: case conversion, slugify, truncate, mask,
  whitespace, blank/character checks).
- The `stringo` split follows one rule: `stringo` transforms text, this
  package judges domain formats. Validators (`isValidEmail`, `isUuid`,
  `isValidIp4`), MIME checks, and `parseDuration` stay here.
- **The partition rule.** No extension member here may share its name with
  an extension member of `convert_object`, `stringo`, `collection`, or the
  SDK on an overlapping type. On the same type it is an ambiguity compile
  error for every user; on related types (`List` vs `Iterable`, `String` vs
  `String?`) the receiver's static type silently picks the implementation,
  which shipped as real bugs (`swap`, `isValidPhoneNumber`).
  `test/api_surface_guard_test.dart` enforces this and also fails when an
  instance member of the extended type makes a member unreachable. An
  exception needs an allowlist entry whose reason proves the two can never
  disagree (for example, a null-safe member that delegates to the other).
- **Date semantics.** Helpers that build a date keep the receiver's time zone
  (UTC in, UTC out). Day-based arithmetic moves by calendar days and keeps
  the wall-clock time across daylight-saving changes; on a change day a
  skipped time moves forward by the jump and a repeated time resolves to its
  first occurrence, unless the receiver is itself the repeat. Hours and
  smaller add exact durations; day counts project both dates onto UTC
  midnights. `floorTo`/`ceilTo` return the latest/earliest instant whose wall
  clock shows an aligned time (a skipped aligned time counts at the jump);
  whole-day steps count calendar dates, so `floorTo(1 day) == startOfDay`.
  Offset arithmetic reads offsets from the wall-clock fields, because the
  web rounds `timeZoneOffset` to whole minutes; `daysInMonth` entries are
  each date's `startOfDay`. `test/date_time_zone_test.dart` checks
  all of this against expectations built from the clock changes of whatever
  zone it runs in; CI runs it in nine zones and on Node because the runners
  use UTC, where these bugs cannot appear.
- Any public API change needs matching tests in the flat `test/` directory
  (one file per domain) and doc comments on every public member. A bug fix
  needs a regression test that fails on the old code.
- Every Dart block in README.md is copied verbatim into
  `test/readme_test.dart`, which runs it and checks each
  `print(...); // output` comment. Edit an example in both places; the test
  fails when a README block has no copy.
- Behavior quirks are load-bearing: `Iterable.intersect` (from
  convert_object) merges (union) on purpose, `waitConcurrency` and
  `mapConcurrent` return completion order unless `preserveOrder: true`,
  `daysInMonth` returns a padded calendar grid. Do not "fix" these without
  a major release and a migration entry.
- Never use the em-dash character in this repo's files; use '-' instead
  (`tool/check_repo.dart` enforces it).

## Breaking changes and `dart fix`

- Every rename or removal ships a transform in `lib/fix_data.yaml` and a
  fixture pair in `test_fixes/` (`<case>.dart` compiles against the previous
  release, `<case>.dart.expect` is the hand-written result). Keep every
  transform from earlier releases.
- Extension members match by the receiver's static type, so each rename
  needs an `inClass: <type>` transform (ordinary calls) and an
  `inExtension: <Extension>` transform (explicit overrides).
- `dart fix` cannot act on two diagnostics: a removed getter on a nullable
  receiver (`unchecked_use_of_nullable_value`) and a removed method through
  an explicit extension override (`undefined_extension_method`). For those,
  keep a `@Deprecated` forwarding alias for one major so the usage raises
  `deprecated_member_use`, which `dart fix` handles. Skip the alias when the
  rewritten explicit form would not compile (as for `Iterable.find`).
- Every `@Deprecated` message says "removed in X.0.0"; `tool/check_repo.dart`
  fails once the package reaches that major, so the aliases cannot outlive
  their release. Delete them together with `test/deprecated_aliases_test.dart`
  entries.
- Prove a migration with the dart-tools data-driven-fixes verifier
  (`verify_fixes.py . --baseline <previous version>`): fixtures compile
  against the baseline, and a separate consumer reaches every golden with no
  errors left.

## Release process

1. Version bump lands via PR to `main` (branch protection requires checks
   "CI / Test on stable", "CI / Pana", "pub-dry-run / dry-run"; no direct
   pushes).
2. `CHANGELOG.md` entry + `pubspec.yaml` version in the same PR.
3. Merge -> auto-release workflow creates tag
   `dart_helper_utils-vX.Y.Z` + GitHub release when the version VALUE
   changed; the tag triggers trusted publishing to pub.dev (OIDC, no manual
   credentials). Never re-use or overwrite an existing tag.
4. Breaking releases must update `migration_guides.md`, ship `dart fix`
   data for every rename (see above), AND ship the corresponding migration
   hop in the AI plugin (see below) before tagging.

## AI assistant plugin (Claude Code, Codex, Antigravity)

- Canonical tree: `tooling/ai/dart-helper-utils/` with one shared `skills/`
  set, `assets/icon.png`, an `evals/` suite for `claude plugin eval`, and
  three manifests: `plugin.json` (Agent Plugins 1.0, read by Codex,
  Antigravity, and other Agent Plugins clients), `.claude-plugin/plugin.json`
  (Claude Code), and `.codex-plugin/plugin.json` (legacy, for older Codex
  releases). Catalogs: `.claude-plugin/marketplace.json` and
  `.agents/plugins/marketplace.json` at the repo root; Antigravity has no
  third-party marketplace and installs the plugin folder by its GitHub
  `tree/main/...` URL.
- All three manifests' `version` must equal the `pubspec.yaml` version, and
  their shared metadata must match; the Codex interface appears in
  `plugin.json` (`extensions["com.openai"].interface`) and in the legacy
  manifest, identically. `tool/validate_agent_plugin.dart` enforces this,
  plus the icon, the skill frontmatter, the eval layout, and the install
  commands in both READMEs.
- `tool/verify_agent_hosts.dart` installs the plugin in throwaway Claude
  Code, Codex, and Antigravity profiles (never the real ones) and requires
  the pubspec version and byte-identical skills; `--github <ref>` installs
  from GitHub the way users do. The Agent plugin workflow runs it on plugin
  pull requests and weekly with each host's current release; a weekly
  failure usually means a host changed its plugin contract. The plugin
  README's "Keeping it current" section is the refresh checklist.
- Skill facts must match the source; when changing behavior in `lib/`,
  update the affected skill/reference files in the same PR.
  `test/agent_skill_claims_test.dart` asserts the skills' factual claims
  against the API, including return types; extend it when a skill gains a
  claim.
- Any future BREAKING release must ship a migration hop in the plugin
  (a dedicated `migrate-dart-helper-utils-vX-to-vY` skill for large
  migrations, or a hop entry in `upgrade-dart-helper-utils`) before tagging.
- The plugin tree, catalogs, `tool/`, and this file are excluded from the
  pub.dev archive via `.pubignore` - keep the archive free of partial
  plugin content. `migration_guides.md` stays IN the archive (linked from
  the README).
- The sibling `convert_object` repository hosts its own plugin
  (`convert-object@convert-object-tools`) covering the conversion surface;
  keep cross-references between the two consistent.
