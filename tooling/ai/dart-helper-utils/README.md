# dart-helper-utils agent plugin

Teaches AI coding agents the
[dart_helper_utils](https://pub.dev/packages/dart_helper_utils) Dart
package: the exact 7.x member names and what they do, the lifecycle rules of
its async tools, and how to upgrade a project from any older release. It
installs in Claude Code, Codex, and Google Antigravity from this repository.

The plugin contains skills only: markdown instructions, with no hooks, MCP
servers, scripts, or network access.

## Skills

| Skill | Loads for requests about |
|---|---|
| `use-dart-helper-utils` | Member names and semantics across maps, strings, casing, MIME checks, collections, numbers, dates, durations, intl, and URIs, plus the one-import re-export model |
| `async-with-dart-helper-utils` | `Debouncer` and throttle lifecycles, stream transformers (`rateLimit`, `bufferCount`, `asPausable`, `retry`), Future `minWait`, `timeoutOrNull`, and `retry`, bounded concurrency, and their ordering and disposal traps |
| `migrate-dart-helper-utils-v6-to-v7` | The 7.0 upgrade: `dart fix --apply` for the renames, then the behavior checklist (UTC and daylight-saving date rules, exact `int` statistics, MIME precision, typed debouncer history, stringo 3) |
| `migrate-dart-helper-utils-v5-to-v6` | The 6.0 upgrade: conversion moved to convert_object, renames, removals, and silent behavior changes |
| `upgrade-dart-helper-utils` | Finding the installed version and ordering the hops for any upgrade, from 2.x through 7.x |

An agent loads a skill when a request matches it. In Claude Code you can also
call one directly, for example `/dart-helper-utils:use-dart-helper-utils`.

## Install, update, and remove

### Claude Code

In a session:

```text
/plugin marketplace add omar-hanafy/dart_helper_utils
/plugin install dart-helper-utils@dart-helper-utils-tools
```

Or from a shell:

```bash
claude plugin marketplace add omar-hanafy/dart_helper_utils
claude plugin install dart-helper-utils@dart-helper-utils-tools
```

Run `/reload-plugins` or start a new session to load it.

- Update: `claude plugin marketplace update dart-helper-utils-tools`, then
  `claude plugin update dart-helper-utils@dart-helper-utils-tools`. Claude
  Code leaves automatic updates off for third-party marketplaces; to turn
  them on, run `/plugin`, open **Marketplaces**, select
  `dart-helper-utils-tools`, and choose **Enable auto-update**.
- Remove: `claude plugin uninstall dart-helper-utils@dart-helper-utils-tools`,
  or `claude plugin marketplace remove dart-helper-utils-tools` to remove the
  marketplace and its plugin together.

### Codex

```bash
codex plugin marketplace add omar-hanafy/dart_helper_utils
codex plugin add dart-helper-utils@dart-helper-utils-tools
```

Start a new Codex session; an open session does not pick up new skills.

- Update: `codex plugin marketplace upgrade dart-helper-utils-tools`
  refreshes the marketplace and the installed copy.
- Remove: `codex plugin remove dart-helper-utils@dart-helper-utils-tools`.
  To drop the marketplace as well, run
  `codex plugin marketplace remove dart-helper-utils-tools` afterwards; on
  its own, that command leaves the plugin installed.

Where a Codex surface has no plugin support, its `$skill-installer` skill can
install the folders under `tooling/ai/dart-helper-utils/skills/` directly.

### Google Antigravity

```bash
agy plugin install https://github.com/omar-hanafy/dart_helper_utils/tree/main/tooling/ai/dart-helper-utils
```

The command installs the plugin into `~/.gemini/config/plugins/`, which the
`agy` CLI, the Antigravity IDE, and the desktop app all read. Start a new
session to load it. Use the full URL above: the plugin lives in a subfolder,
so the bare repository URL finds nothing to install.

- Update: run the same install command again; it replaces the installed copy.
  Antigravity has no third-party marketplace yet, so nothing updates on its
  own.
- Remove: `agy plugin uninstall dart-helper-utils`.

### Other agents

The plugin has an [Agent Plugins 1.0](https://agent-plugins.org/) manifest
(`plugin.json`), and each skill is a standard
[Agent Skills](https://agentskills.io/) folder, so agents that read either
format can load this folder directly. Only the three hosts above are tested.

## Example prompts

- "Upgrade this project from dart_helper_utils 6.1.0 to 7 and check the
  behavior changes that affect us."
- "Debounce this search field with dart_helper_utils and make sure nothing
  leaks when the widget is disposed."
- "Read `db.pool.size` from this nested config map with dart_helper_utils,
  defaulting to 10."
- "Upload these files with at most 4 at a time and keep the results in input
  order."

## Permissions and trust

The skills tell the agent to run ordinary Dart tooling in your project, such
as `dart pub get`, `dart fix --dry-run`, `dart analyze`, `dart test`, and
`grep`, through your agent's usual approval prompts. The plugin itself runs
nothing and sends nothing anywhere.

## Compatibility

- Documents dart_helper_utils 7.x; the plugin version always equals the
  package version it documents. The migration skills also cover projects on
  1.x through 6.x.
- Installation is tested with Claude Code 2.1.312, Codex 0.165.0, and the
  Antigravity CLI 1.3.3 and 1.4.9 (October 2026). A weekly CI job repeats
  the test with each host's current release.

## For maintainers

```text
tooling/ai/dart-helper-utils/
  plugin.json                  Agent Plugins 1.0 manifest: Codex, Antigravity, other clients
  .claude-plugin/plugin.json   Claude Code manifest
  .codex-plugin/plugin.json    legacy manifest for Codex releases before Agent Plugins
  assets/icon.png              icon for all three manifests
  skills/<skill>/SKILL.md      one folder per skill
  evals/<case>/                cases for claude plugin eval
```

The marketplace catalogs live at the repository root:
`.claude-plugin/marketplace.json` for Claude Code and
`.agents/plugins/marketplace.json` for Codex. Antigravity installs the plugin
folder itself.

Rules:

- The three manifests share their metadata, and their `version` equals the
  `pubspec.yaml` version; bump them together.
- Codex reads its interface (display name, prompts, icons) from
  `extensions["com.openai"].interface` in `plugin.json`, and older releases
  read the legacy manifest's `interface`; keep the two identical.
- Skill facts must match the source. Change a skill in the same pull request
  as the behavior it describes; `test/agent_skill_claims_test.dart` checks
  the claims against the API.
- A breaking package release ships its migration hop, as a new
  `migrate-dart-helper-utils-vX-to-vY` skill or an entry in
  `upgrade-dart-helper-utils`, before it is tagged.

Checks, run from the repository root:

| Check | Command | Where it runs |
|---|---|---|
| Files, manifests, catalogs, and README commands | `dart run tool/validate_agent_plugin.dart` | CI on every pull request |
| Install in each host, plus each host's strict validator | `dart run tool/verify_agent_hosts.dart --require claude,codex,agy` | Agent plugin workflow: pull requests and pushes to `main` that touch the plugin, weekly, and on demand |
| Install from GitHub the way users do | `dart run tool/verify_agent_hosts.dart --github main` | Agent plugin workflow on `main`: pushes that touch the plugin, weekly, and on demand |
| Skill behavior against a no-plugin baseline | `claude plugin eval tooling/ai/dart-helper-utils --no-publish` | By hand; it calls the model on your account |

The host check uses throwaway profiles, so it never touches your own Claude
Code, Codex, or Antigravity setup and needs no sign-in. Without `--require`,
it skips any host that is not on PATH.

### Keeping it current

Hosts and their plugin formats change every few weeks. When the weekly
Agent plugin workflow fails, and before each package release:

1. Read what changed in each host since the versions listed under
   Compatibility (`agy changelog` prints Antigravity's notes), and check
   [agent-plugins.org](https://agent-plugins.org/) and
   [agentskills.io](https://agentskills.io/) for new spec versions.
2. Run the three checks above, and
   `claude plugin details dart-helper-utils@dart-helper-utils-tools` after a
   local install to see the always-on token cost (about 690 tokens at 7.0.0).
3. Run the eval suite and compare it with the last run. At 7.0.0, all five
   cases pass with the plugin, and the four package cases score 0.5 to 1.0
   higher than without it.
4. Update the tested versions under Compatibility and in the package README.
