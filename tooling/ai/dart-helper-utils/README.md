# dart-helper-utils agent plugin

Package-specific AI coding-assistant support for the
[dart_helper_utils](https://pub.dev/packages/dart_helper_utils) Dart package,
installable in Claude Code and OpenAI Codex from this repository. It ships
skills only - no hooks, no MCP servers, no telemetry, no network access.

## Capabilities

| Skill | Use it for |
|---|---|
| `use-dart-helper-utils` | Correct member names and semantics across the utility surface (maps, strings, casing, MIME, collections, numbers, dates, intl, URI) plus the one-import re-export model |
| `async-with-dart-helper-utils` | Debouncer/throttle lifecycle, stream transformers (rateLimit, bufferCount, asPausable, retry), Future minWait/timeoutOrNull/retry, bounded concurrency, and their ordering/disposal traps |
| `migrate-dart-helper-utils-v5-to-v6` | The v6 breaking migration (conversion moved to convert_object, renames, removals, silent behavior changes) |
| `upgrade-dart-helper-utils` | Version detection and hop sequencing for any upgrade (v2/v3/v4/v5/v6, patch bumps) |

## Install in Claude Code

```
/plugin marketplace add omar-hanafy/dart_helper_utils
/plugin install dart-helper-utils@dart-helper-utils-tools
```

Skills auto-trigger on relevant work; invoke one explicitly with
`/dart-helper-utils:use-dart-helper-utils` (same pattern for the others).

## Install in OpenAI Codex (CLI)

```
codex plugin marketplace add omar-hanafy/dart_helper_utils
codex plugin add dart-helper-utils@dart-helper-utils-tools
```

Start a NEW Codex session afterwards; bundled skills load at session start.
The Codex IDE extension does not support plugins; there, ask the
`$skill-installer` skill to install the skills from this repository's
`tooling/ai/dart-helper-utils/skills/` directory instead.

## Example prompts

- "Debounce this search field with dart_helper_utils and make sure nothing
  leaks when the widget is disposed."
- "Read `db.pool.size` from this nested config map, defaulting to 10."
- "We are upgrading dart_helper_utils from 5.4.2 to 6.x - audit the repo and
  do the migration."

## Updating and uninstalling

- Claude Code: `/plugin marketplace update dart-helper-utils-tools`, and
  uninstall with `/plugin uninstall dart-helper-utils@dart-helper-utils-tools`
  (or remove the marketplace with
  `/plugin marketplace remove dart-helper-utils-tools`).
- Codex: `codex plugin marketplace update dart-helper-utils-tools`, remove
  with `codex plugin remove dart-helper-utils@dart-helper-utils-tools`
  (removing the marketplace also removes its plugins).

## Permissions and trust

The plugin contains markdown skills only. Skills instruct the agent to run
ordinary Dart tooling (`dart analyze`, `dart test`, `grep`) in YOUR project
with your normal approval flow; the plugin itself executes nothing and
phones home to nothing.

## Compatibility

- Documents dart_helper_utils 6.x (plugin version tracks the package
  version). The migration/upgrade skills additionally cover 1.x-5.x
  codebases.
- Claude Code with plugin support; Codex CLI 0.44+ (plugin + marketplace
  commands).

## Maintainers

- One canonical skills tree (`skills/`) is shared by both manifests
  (`.claude-plugin/plugin.json`, `.codex-plugin/plugin.json`); both
  manifest versions MUST equal the `pubspec.yaml` version.
- `dart run tool/validate_agent_plugin.dart` (from the repo root) enforces
  manifest/catalog/frontmatter consistency and runs in CI.
- Validate locally against Claude:
  `claude plugin validate .claude-plugin/marketplace.json --strict` (root)
  and `claude plugin validate tooling/ai/dart-helper-utils --strict`.
- Skill facts must match the source; when changing behavior in `lib/`,
  update the affected skill/reference files in the same PR.
- Any future BREAKING package release must ship its migration hop (a new
  `migrate-dart-helper-utils-vX-to-vY` skill or an upgrade-skill hop entry)
  before tagging.
