/// Enforces repository rules that neither lints nor tests can express.
///
/// Checks (deterministic, no network):
/// - no em-dash character (U+2014) in tracked text files (AGENTS.md);
/// - CHANGELOG.md has a `## <version>` section for the pubspec version, and
///   its first section is either that version or `## Unreleased`;
/// - nothing under `lib/` imports a platform-specific `dart:` library, so
///   the package keeps supporting every platform, including the web;
/// - every `@Deprecated` under `lib/` names its removal version as
///   "removed in X.0.0", and none survives into that major version.
///
/// Run from the repository root: `dart run tool/check_repo.dart`.
/// Exits non-zero when any check fails; prints every failure.
library;

import 'dart:io';

final _errors = <String>[];

void main() {
  final version = _pubspecVersion();
  _checkEmDashes();
  if (version != null) {
    _checkChangelog(version);
    _checkDeprecations(version);
  }
  _checkPlatformImports();

  if (_errors.isEmpty) {
    stdout.writeln('Repository checks passed.');
    return;
  }
  stderr.writeln('Repository checks failed:');
  for (final error in _errors) {
    stderr.writeln('  - $error');
  }
  exitCode = 1;
}

String? _pubspecVersion() {
  final match = RegExp(
    r'^version:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(File('pubspec.yaml').readAsStringSync());
  if (match == null) _errors.add('pubspec.yaml has no version line.');
  return match?.group(1);
}

List<String> _trackedFiles() {
  final result = Process.runSync('git', ['ls-files', '-z']);
  if (result.exitCode != 0) {
    _errors.add('git ls-files failed: ${result.stderr}');
    return const [];
  }
  return (result.stdout as String)
      .split('\u0000')
      .where((path) => path.isNotEmpty && File(path).existsSync())
      .toList();
}

void _checkEmDashes() {
  for (final path in _trackedFiles()) {
    final String text;
    try {
      text = File(path).readAsStringSync();
    } on FileSystemException {
      continue; // binary or unreadable as UTF-8
    } on FormatException {
      continue;
    }
    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains('\u2014')) {
        _errors.add("$path:${i + 1}: em-dash character; use '-' instead.");
      }
    }
  }
}

void _checkChangelog(String version) {
  final headings = RegExp(r'^## (.+?)\s*$', multiLine: true)
      .allMatches(File('CHANGELOG.md').readAsStringSync())
      .map((m) => m.group(1)!)
      .toList();
  if (!headings.contains(version)) {
    _errors.add('CHANGELOG.md has no "## $version" section.');
  }
  if (headings.isNotEmpty &&
      headings.first != version &&
      headings.first != 'Unreleased') {
    _errors.add(
      'CHANGELOG.md starts with "## ${headings.first}"; the first section '
      'must be "## $version" or "## Unreleased".',
    );
  }
}

void _checkPlatformImports() {
  const platformOnly = {
    'dart:io',
    'dart:ffi',
    'dart:html',
    'dart:isolate',
    'dart:js',
    'dart:js_interop',
    'dart:js_util',
    'dart:mirrors',
  };
  final directive = RegExp(r'''^\s*(?:import|export)\s+['"](dart:[a-z_]+)''');
  for (final file in _dartFilesUnder('lib')) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      final library = directive.firstMatch(lines[i])?.group(1);
      if (library != null && platformOnly.contains(library)) {
        _errors.add(
          '${file.path}:${i + 1}: $library is platform-specific; '
          'lib/ must run on every platform.',
        );
      }
    }
  }
}

void _checkDeprecations(String version) {
  final major = int.tryParse(version.split('.').first);
  final annotation = RegExp(r'@Deprecated\(');
  final removal = RegExp(r'removed in (\d+)\.0\.0');
  for (final file in _dartFilesUnder('lib')) {
    final lines = file.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      if (!annotation.hasMatch(lines[i])) continue;
      // The message may wrap onto the next lines of the annotation.
      final text = lines.skip(i).take(4).join(' ');
      final target = removal.firstMatch(text);
      final where = '${file.path}:${i + 1}';
      if (target == null) {
        _errors.add('$where: @Deprecated must say "removed in X.0.0".');
      } else if (major != null && int.parse(target.group(1)!) <= major) {
        _errors.add(
          '$where: deprecated for removal in ${target.group(1)}.0.0, but '
          'the package is at $version. Delete it and its dart fix shim test.',
        );
      }
    }
  }
}

Iterable<File> _dartFilesUnder(String directory) =>
    Directory(directory)
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
