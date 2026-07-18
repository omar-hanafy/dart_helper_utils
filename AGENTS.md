# dart_helper_utils - agent guide (maintainers)

Pure-Dart utility package (no Flutter dependency). Public API is
`lib/dart_helper_utils.dart`, which re-exports ALL of `package:collection`,
ALL of `package:convert_object`, five intl symbols (`Bidi`, `BidiFormatter`,
`DateFormat`, `Intl`, `NumberFormat`), and this package's own
`lib/src/` tree (extensions, Debouncer/TimeUtils, raw_data constants).

## Validation gates (run before claiming any change done)

```bash
dart format --output=none --set-exit-if-changed .
dart analyze .                        # public_member_api_docs is enforced
dart test
dart run tool/validate_agent_plugin.dart   # AI plugin/marketplace consistency
dart pub publish --dry-run            # must stay at 0 warnings
```

CI requires a PERFECT pana score on PRs ("CI / Pana" is a required check);
avoid changes that cost points (missing doc comments, dependency issues,
format drift).

## Conventions

- Conversion logic lives in the `convert_object` package, NOT here; do not
  add conversion features to this repo (contribute upstream instead). The
  same applies to string similarity (`string_search_algorithms`) and linked
  lists (`doubly_linked_list`).
- Any public API change needs matching tests in the flat `test/` directory
  (one file per domain) and doc comments on every public member.
- Behavior quirks are load-bearing: `Iterable.intersect` merges (union) on
  purpose, `waitConcurrency`/`mapConcurrent` return completion order,
  `daysInMonth` returns a padded calendar grid. Do not "fix" these without
  a major release and a migration entry.
- Never use the em-dash character in this repo's files; use '-' instead.

## Release process

1. Version bump lands via PR to `main` (branch protection requires checks
   "CI / Test on stable", "CI / Pana", "pub-dry-run / dry-run"; no direct
   pushes).
2. `CHANGELOG.md` entry + `pubspec.yaml` version in the same PR.
3. Merge -> auto-release workflow creates tag
   `dart_helper_utils-vX.Y.Z` + GitHub release; the tag triggers trusted
   publishing to pub.dev (OIDC, no manual credentials). Never re-use or
   overwrite an existing tag.
4. Breaking releases must update `migration_guides.md` AND ship the
   corresponding migration hop in the AI plugin (see below) before tagging.

## AI assistant plugin (Claude Code + Codex)

- Canonical tree: `tooling/ai/dart-helper-utils/` (one shared `skills/`
  set; manifests `.claude-plugin/plugin.json` + `.codex-plugin/plugin.json`).
  Catalogs: `.claude-plugin/marketplace.json` and
  `.agents/plugins/marketplace.json` at the repo root.
- Both plugin manifests' `version` must equal the `pubspec.yaml` version -
  bump them together (CI enforces via `tool/validate_agent_plugin.dart`).
- Skill facts must match the source; when changing behavior in `lib/`,
  update the affected skill/reference files in the same PR.
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
