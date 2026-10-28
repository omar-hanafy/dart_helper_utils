/// Installs the AI plugin into throwaway profiles of the agent hosts on PATH
/// (Claude Code, Codex, and Antigravity) and checks what each one installed.
///
/// `validate_agent_plugin.dart` checks the files; this checks the hosts. For
/// each host it adds the marketplace (Antigravity has none, so it installs
/// the plugin folder), installs `dart-helper-utils`, and requires the
/// pubspec version and a byte-identical copy of every skill file. Claude Code
/// and Antigravity also run their own strict validators.
///
/// Real profiles are never touched: each host runs with its configuration
/// pointed at a temporary directory (`CLAUDE_CONFIG_DIR`, `CODEX_HOME`, and
/// `HOME` for `agy`), and only local plugin commands run, so no sign-in is
/// needed and nothing is sent to a model.
///
/// Run from the repository root:
///
/// ```bash
/// dart run tool/verify_agent_hosts.dart              # hosts found on PATH
/// dart run tool/verify_agent_hosts.dart --require claude,codex,agy
/// dart run tool/verify_agent_hosts.dart --github main  # the published install
/// ```
///
/// `--github <ref>` installs from this repository on GitHub at `<ref>`, the
/// way the README tells users to, and compares the result with the local
/// checkout, so run it on a checkout of that ref. `--keep` keeps the
/// temporary profiles for inspection. Set `CLAUDE_BIN`, `CODEX_BIN`, or
/// `AGY_BIN` to test a specific executable.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

const _repository = 'omar-hanafy/dart_helper_utils';
const _pluginPath = 'tooling/ai/dart-helper-utils';
const _pluginName = 'dart-helper-utils';
const _marketplaceName = 'dart-helper-utils-tools';
const _pluginId = '$_pluginName@$_marketplaceName';
const _hosts = ['claude', 'codex', 'agy'];

Future<void> main(List<String> arguments) async {
  final options = _Options.parse(arguments);
  if (options == null) {
    exitCode = 64;
    return;
  }

  final version = RegExp(
    r'^version:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(File('pubspec.yaml').readAsStringSync())?.group(1);
  final skills = _skillFiles(Directory('$_pluginPath/skills'));
  if (version == null || skills.isEmpty) {
    stderr.writeln(
      'Run from the repository root: pubspec.yaml needs a version and '
      '$_pluginPath/skills needs skills.',
    );
    exitCode = 1;
    return;
  }

  final scratch = Directory.systemTemp.createTempSync('agent-hosts-');
  final failures = <String>[];
  try {
    for (final host in _hosts) {
      final executable = _which(
        Platform.environment['${host.toUpperCase()}_BIN'] ?? host,
      );
      if (executable == null) {
        final message = '$host: not found on PATH';
        if (options.required.contains(host)) {
          failures.add(message);
          stdout.writeln('FAIL $message');
        } else {
          stdout.writeln('SKIP $message');
        }
        continue;
      }
      final check = _HostCheck(
        host: host,
        executable: executable,
        profile: Directory('${scratch.path}/$host')..createSync(),
        githubRef: options.githubRef,
        version: version,
        skills: skills,
      );
      await check.run();
      failures.addAll(check.failures.map((failure) => '$host: $failure'));
      final label = '$host ${check.hostVersion}';
      if (check.failures.isEmpty) {
        stdout.writeln(
          'PASS $label: $_pluginName $version with ${check.skillCount} skills',
        );
      } else {
        stdout.writeln('FAIL $label');
        for (final failure in check.failures) {
          stdout.writeln('  - $failure');
        }
      }
    }
  } finally {
    if (options.keep) {
      stdout.writeln('Kept the temporary profiles in ${scratch.path}');
    } else {
      scratch.deleteSync(recursive: true);
    }
  }
  if (failures.isNotEmpty) exitCode = 1;
}

final class _Options {
  const _Options({
    required this.required,
    required this.githubRef,
    required this.keep,
  });

  final Set<String> required;
  final String? githubRef;
  final bool keep;

  static _Options? parse(List<String> arguments) {
    final required = <String>{};
    String? githubRef;
    var keep = false;
    for (var i = 0; i < arguments.length; i++) {
      final argument = arguments[i];
      final hasValue = i + 1 < arguments.length;
      if (argument == '--keep') {
        keep = true;
      } else if (argument == '--require' && hasValue) {
        required.addAll(arguments[++i].split(',').map((h) => h.trim()));
      } else if (argument == '--github' && hasValue) {
        githubRef = arguments[++i];
      } else {
        stderr.writeln(
          'Usage: dart run tool/verify_agent_hosts.dart '
          '[--require claude,codex,agy] [--github <ref>] [--keep]',
        );
        return null;
      }
    }
    final unknown = required.difference(_hosts.toSet());
    if (unknown.isNotEmpty) {
      stderr.writeln('Unknown hosts in --require: ${unknown.join(', ')}');
      return null;
    }
    return _Options(required: required, githubRef: githubRef, keep: keep);
  }
}

final class _HostCheck {
  _HostCheck({
    required this.host,
    required this.executable,
    required this.profile,
    required this.githubRef,
    required this.version,
    required this.skills,
  });

  final String host;
  final String executable;
  final Directory profile;
  final String? githubRef;
  final String version;

  /// Skill files relative to `skills/`, with their expected bytes.
  final Map<String, List<int>> skills;

  final failures = <String>[];
  String hostVersion = '';
  int skillCount = 0;

  Future<void> run() async {
    hostVersion = (await _run(['--version'])).stdout.trim();
    switch (host) {
      case 'claude':
        await _checkClaude();
      case 'codex':
        await _checkCodex();
      case 'agy':
        await _checkAntigravity();
    }
  }

  Map<String, String> get _environment => switch (host) {
    'claude' => {'CLAUDE_CONFIG_DIR': profile.path},
    'codex' => {'CODEX_HOME': profile.path},
    _ => {
      'HOME': profile.path,
      'XDG_CONFIG_HOME': '${profile.path}/.config',
      'XDG_CACHE_HOME': '${profile.path}/.cache',
      'XDG_DATA_HOME': '${profile.path}/.local/share',
    },
  };

  Future<void> _checkClaude() async {
    if (githubRef == null) {
      await _expectSuccess(['plugin', 'validate', '.', '--strict']);
      await _expectSuccess(['plugin', 'validate', _pluginPath, '--strict']);
    }
    final source = githubRef == null
        ? Directory.current.path
        : '$_repository#$githubRef';
    if (!await _expectSuccess([
      'plugin',
      'marketplace',
      'add',
      source,
      '--scope',
      'user',
    ])) {
      return;
    }
    if (!await _expectSuccess([
      'plugin',
      'install',
      '--scope',
      'user',
      _pluginId,
    ])) {
      return;
    }
    final installed = _entries(await _json(['plugin', 'list', '--json']));
    final entry = installed.where((e) => e['id'] == _pluginId).firstOrNull;
    if (entry == null) {
      failures.add('claude plugin list does not show $_pluginId');
      return;
    }
    _expectEqual('installed version', entry['version'], version);
    _expectEqual('enabled', entry['enabled'], true);
    _compareSkills(entry['installPath']);
  }

  Future<void> _checkCodex() async {
    final add = githubRef == null
        ? [Directory.current.path]
        : [_repository, '--ref', githubRef!];
    final added = await _json(['plugin', 'marketplace', 'add', ...add]);
    _expectEqual(
      'marketplace name',
      _field(added, 'marketplaceName'),
      _marketplaceName,
    );
    final available = _field(
      await _json(['plugin', 'list', '--available']),
      'available',
    );
    final offered = _entries(available)
        .where((e) => e['pluginId'] == _pluginId)
        .firstOrNull;
    if (offered == null) {
      failures.add('codex plugin list --available does not offer $_pluginId');
      return;
    }
    _expectEqual('offered version', offered['version'], version);
    final installed = await _json(['plugin', 'add', _pluginId]);
    _expectEqual('installed version', _field(installed, 'version'), version);
    final listed = _entries(
      _field(await _json(['plugin', 'list']), 'installed'),
    ).where((e) => e['pluginId'] == _pluginId).firstOrNull;
    _expectEqual('enabled', listed?['enabled'], true);
    _compareSkills(_field(installed, 'installedPath'));
  }

  Future<void> _checkAntigravity() async {
    if (githubRef == null) {
      // agy 1.4 added --strict; older releases read it as the plugin path.
      final strict = await _run([
        'plugin',
        'validate',
        '--strict',
        _pluginPath,
      ]);
      final unsupported = strict.output.contains('stat --strict');
      final result = unsupported
          ? await _run(['plugin', 'validate', _pluginPath])
          : strict;
      if (result.exitCode != 0) {
        failures.add('agy plugin validate failed:\n${result.output.trim()}');
      }
    }
    final target = githubRef == null
        ? Directory(_pluginPath).absolute.path
        : 'https://github.com/$_repository/tree/$githubRef/$_pluginPath';
    if (!await _expectSuccess(['plugin', 'install', target])) return;
    final manifests = profile
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) => f.path.endsWith('/plugins/$_pluginName/plugin.json'))
        .toList();
    if (manifests.length != 1) {
      failures.add(
        'expected one installed $_pluginName/plugin.json under the profile, '
        'found ${manifests.length}',
      );
      return;
    }
    final manifest = jsonDecode(manifests.single.readAsStringSync());
    _expectEqual('installed version', _field(manifest, 'version'), version);
    _compareSkills(manifests.single.parent.path);

    // agy 1.4 lists the skills its loader accepted; 1.3 printed its import
    // manifest instead, an object that says nothing about loading.
    final listing = await _run(['plugin', 'list', '--json']);
    Object? decoded;
    if (listing.exitCode == 0) {
      try {
        decoded = jsonDecode(listing.stdout);
      } on FormatException {
        decoded = null;
      }
    }
    if (decoded is Map) return;
    if (decoded is! List<Object?>) {
      failures.add(
        'agy plugin list --json exited ${listing.exitCode} without a plugin '
        'list:\n${listing.output.trim()}',
      );
      return;
    }
    final entry = _entries(decoded)
        .where((e) => e['name'] == _pluginName)
        .firstOrNull;
    _expectEqual('enabled', entry?['enabled'], true);
    final loaded = entry?['skills'];
    final expected = skills.keys
        .where((path) => path.endsWith('/SKILL.md'))
        .map((path) => path.split('/').first)
        .toSet();
    final names = loaded is List<Object?> ? loaded.toSet() : const <Object?>{};
    for (final skill in expected.difference(names)) {
      failures.add('agy plugin list does not load the "$skill" skill');
    }
  }

  void _compareSkills(Object? installPath) {
    if (installPath is! String) {
      failures.add('the host did not report where it installed the plugin');
      return;
    }
    final installed = _skillFiles(Directory('$installPath/skills'));
    skillCount = installed.keys.where((p) => p.endsWith('/SKILL.md')).length;
    for (final MapEntry(key: path, value: bytes) in skills.entries) {
      final copy = installed[path];
      if (copy == null) {
        failures.add('skills/$path is missing from the installed copy');
      } else if (!_sameBytes(copy, bytes)) {
        failures.add('skills/$path differs from the repository');
      }
    }
    for (final path in installed.keys.where((p) => !skills.containsKey(p))) {
      failures.add('skills/$path is installed but not in the repository');
    }
  }

  void _expectEqual(String what, Object? actual, Object expected) {
    if (actual != expected) {
      failures.add('$what is "$actual", expected "$expected"');
    }
  }

  Future<bool> _expectSuccess(List<String> arguments) async {
    final result = await _run(arguments);
    if (result.exitCode == 0) return true;
    failures.add(
      '$host ${arguments.join(' ')} exited ${result.exitCode}:\n'
      '${result.output.trim()}',
    );
    return false;
  }

  /// Runs a command with `--json` and decodes its last JSON line, which is
  /// where Claude Code prints its machine-readable result.
  Future<Object?> _json(List<String> arguments) async {
    final withJson = arguments.contains('--json')
        ? arguments
        : [...arguments, '--json'];
    final result = await _run(withJson);
    if (result.exitCode != 0) {
      failures.add(
        '$host ${withJson.join(' ')} exited ${result.exitCode}:\n'
        '${result.output.trim()}',
      );
      return null;
    }
    final text = result.stdout.trim();
    try {
      return jsonDecode(text);
    } on FormatException {
      final lines = const LineSplitter().convert(text);
      try {
        return jsonDecode(lines.lastWhere((l) => l.trimLeft().startsWith('{')));
      } on Object {
        failures.add('$host ${withJson.join(' ')} printed no JSON:\n$text');
        return null;
      }
    }
  }

  Future<_Result> _run(List<String> arguments) async {
    final process = await Process.start(
      executable,
      arguments,
      environment: {..._environment, 'NO_COLOR': '1'},
    );
    final stdoutText = process.stdout.transform(utf8.decoder).join();
    final stderrText = process.stderr.transform(utf8.decoder).join();
    final code = await process.exitCode.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        process.kill();
        return -1;
      },
    );
    return _Result(code, await stdoutText, await stderrText);
  }
}

final class _Result {
  const _Result(this.exitCode, this.stdout, this.stderr);

  final int exitCode;
  final String stdout;
  final String stderr;

  String get output => '$stdout\n$stderr';
}

Object? _field(Object? json, String key) =>
    json is Map<String, Object?> ? json[key] : null;

Iterable<Map<String, Object?>> _entries(Object? json) =>
    json is List<Object?> ? json.whereType<Map<String, Object?>>() : const [];

/// Every file under [root], keyed by its path relative to [root].
Map<String, List<int>> _skillFiles(Directory root) {
  if (!root.existsSync()) return {};
  final prefix = '${root.path}/';
  return {
    for (final file
        in root
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => !f.path.endsWith('.DS_Store')))
      file.path.substring(prefix.length): file.readAsBytesSync(),
  };
}

bool _sameBytes(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

String? _which(String command) {
  if (command.contains('/')) {
    return File(command).existsSync() ? command : null;
  }
  final result = Process.runSync('which', [command]);
  final path = (result.stdout as String).trim();
  return result.exitCode == 0 && path.isNotEmpty ? path : null;
}
