/// Validates the AI coding-assistant plugin tree against this repository.
///
/// Deterministic checks (no network, no AI):
/// - the three manifests: the Agent Plugins 1.0 `plugin.json` at the plugin
///   root (read by Codex, Antigravity, and other Agent Plugins clients),
///   `.claude-plugin/plugin.json` (Claude Code), and the legacy
///   `.codex-plugin/plugin.json` (older Codex releases) agree on their shared
///   metadata, and their version is the `pubspec.yaml` version;
/// - the Codex interface is identical in both places Codex reads it, and the
///   icon is a square PNG that the plugin directories accept;
/// - both catalogs, kebab-case identifiers, skill frontmatter (Agent Skills
///   fields and size limits), self-contained skill references, and no
///   absolute, escaping, or secret-looking content;
/// - every eval case has a prompt and graders, and its skill graders name
///   skills that exist;
/// - README.md and the plugin README show the install commands that the
///   catalogs actually support, and the manifests' homepage anchor exists;
/// - pub archive exclusions in `.pubignore`.
///
/// `tool/verify_agent_hosts.dart` complements this by installing the plugin
/// in the real host CLIs.
///
/// Run from the repository root: `dart run tool/validate_agent_plugin.dart`.
/// Exits non-zero when any check fails; prints every failure, not just the
/// first.
library;

import 'dart:convert';
import 'dart:io';

const _pluginRoot = 'tooling/ai/dart-helper-utils';
const _rootManifestPath = '$_pluginRoot/plugin.json';
const _claudeManifestPath = '$_pluginRoot/.claude-plugin/plugin.json';
const _codexManifestPath = '$_pluginRoot/.codex-plugin/plugin.json';
const _claudeCatalogPath = '.claude-plugin/marketplace.json';
const _codexCatalogPath = '.agents/plugins/marketplace.json';
const _skillsDir = '$_pluginRoot/skills';
const _evalsDir = '$_pluginRoot/evals';
const _pluginReadmePath = '$_pluginRoot/README.md';
const _agentPluginsSchema =
    'https://agent-plugins.org/schemas/1.0.0/plugin.schema.json';

/// Metadata every manifest repeats; they must agree.
const _sharedFields = [
  'name',
  'version',
  'description',
  'author',
  'homepage',
  'repository',
  'license',
  'keywords',
];

/// The closed top-level field set of an Agent Plugins 1.0 manifest.
const _agentPluginsFields = {r'$schema', ..._sharedFields, 'extensions'};

/// Agent Skills frontmatter fields (agentskills.io).
const _skillFields = {
  'name',
  'description',
  'license',
  'compatibility',
  'metadata',
  'allowed-tools',
};

final _kebabCase = RegExp(r'^[a-z0-9]+(-[a-z0-9]+)*$');
final _agentPluginsName = RegExp(
  r'^(?!.*(?:--|\.\.))[a-z0-9](?:[a-z0-9.-]*[a-z0-9])?$',
);
final _errors = <String>[];

void _fail(String message) => _errors.add(message);

String? _readPubspecVersion() {
  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    _fail('pubspec.yaml not found (run from the repository root).');
    return null;
  }
  final match = RegExp(
    r'^version:\s*(\S+)\s*$',
    multiLine: true,
  ).firstMatch(pubspec.readAsStringSync());
  if (match == null) {
    _fail('pubspec.yaml has no version line.');
    return null;
  }
  return match.group(1);
}

Map<String, dynamic>? _readJson(String path) {
  final file = File(path);
  if (!file.existsSync()) {
    _fail('$path: missing file.');
    return null;
  }
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      _fail('$path: top-level JSON value must be an object.');
      return null;
    }
    return decoded;
  } on FormatException catch (e) {
    _fail('$path: invalid JSON (${e.message}).');
    return null;
  }
}

void _checkSourcePath(String path, String owner) {
  if (!path.startsWith('./')) {
    _fail('$owner: source path "$path" must start with "./".');
  }
  if (path.contains('..')) {
    _fail('$owner: source path "$path" must not contain "..".');
  }
  final resolved = path.startsWith('./') ? path.substring(2) : path;
  if (!Directory(resolved).existsSync()) {
    _fail('$owner: source path "$path" does not exist in the repository.');
  }
}

/// Checks the three manifests and returns the root one for later checks.
Map<String, dynamic>? _checkManifests(String? pubspecVersion) {
  final manifests = <String, Map<String, dynamic>>{};
  for (final path in [
    _rootManifestPath,
    _claudeManifestPath,
    _codexManifestPath,
  ]) {
    final manifest = _readJson(path);
    if (manifest == null) continue;
    manifests[path] = manifest;
    final name = manifest['name'];
    if (name is! String || !_kebabCase.hasMatch(name)) {
      _fail('$path: "name" must be a kebab-case string, got "$name".');
    }
    final version = manifest['version'];
    if (pubspecVersion != null && version != pubspecVersion) {
      _fail(
        '$path: version "$version" does not match pubspec.yaml '
        'version "$pubspecVersion".',
      );
    }
    for (final field in ['description', 'license', 'repository', 'homepage']) {
      if (manifest[field] is! String || (manifest[field] as String).isEmpty) {
        _fail('$path: "$field" must be a non-empty string.');
      }
    }
  }

  final root = manifests[_rootManifestPath];
  if (root != null) _checkAgentPluginsManifest(root);

  // The shared metadata must not drift between hosts.
  if (root != null) {
    for (final MapEntry(key: path, value: manifest) in manifests.entries) {
      if (path == _rootManifestPath) continue;
      for (final field in _sharedFields) {
        if (jsonEncode(manifest[field]) != jsonEncode(root[field])) {
          _fail(
            '$path: "$field" differs from $_rootManifestPath; keep the '
            'shared metadata identical in every manifest.',
          );
        }
      }
    }
  }

  final claude = manifests[_claudeManifestPath];
  if (claude != null) {
    final icon = claude['icon'];
    if (icon is String) {
      _checkIcon(icon, '$_claudeManifestPath "icon"');
    } else {
      _fail('$_claudeManifestPath: "icon" must name the plugin icon.');
    }
  }

  final codex = manifests[_codexManifestPath];
  if (codex != null) {
    if (codex['skills'] != './skills/') {
      _fail('$_codexManifestPath: "skills" must be "./skills/".');
    }
    final legacy = codex['interface'];
    final openai = root?['extensions'] is Map
        ? (root!['extensions'] as Map)['com.openai']
        : null;
    final current = openai is Map ? openai['interface'] : null;
    if (legacy is! Map<String, dynamic>) {
      _fail('$_codexManifestPath: "interface" must be an object.');
    } else {
      _checkInterface(legacy, '$_codexManifestPath "interface"');
      // Codex uses the root extension when present and ignores this copy,
      // which only older releases read, so the two must stay identical.
      if (jsonEncode(legacy) != jsonEncode(current)) {
        _fail(
          '$_codexManifestPath: "interface" differs from '
          'extensions["com.openai"].interface in $_rootManifestPath.',
        );
      }
    }
  }
  return root;
}

void _checkAgentPluginsManifest(Map<String, dynamic> root) {
  const path = _rootManifestPath;
  if (root[r'$schema'] != _agentPluginsSchema) {
    _fail('$path: "\$schema" must be "$_agentPluginsSchema".');
  }
  for (final field in root.keys) {
    if (!_agentPluginsFields.contains(field)) {
      _fail(
        '$path: "$field" is not an Agent Plugins 1.0 field; put '
        'client-specific data under "extensions".',
      );
    }
  }
  final name = root['name'];
  if (name is! String ||
      name.length > 64 ||
      !_agentPluginsName.hasMatch(name)) {
    _fail('$path: "name" breaks the Agent Plugins naming rule.');
  }
  final author = root['author'];
  if (author is! Map ||
      author.keys.any((key) => !const {'name', 'email', 'url'}.contains(key))) {
    _fail('$path: "author" must be an object with name, email, or url only.');
  }
  final extensions = root['extensions'];
  if (extensions is! Map || extensions.values.any((value) => value is! Map)) {
    _fail('$path: "extensions" must map namespaces to objects.');
  } else if (extensions['com.openai'] is! Map ||
      (extensions['com.openai'] as Map)['interface'] is! Map) {
    _fail('$path: extensions["com.openai"].interface is required for Codex.');
  }
}

void _checkInterface(Map<String, dynamic> interface, String owner) {
  for (final field in [
    'displayName',
    'shortDescription',
    'longDescription',
    'developerName',
    'category',
  ]) {
    final value = interface[field];
    if (value is! String || value.trim().isEmpty) {
      _fail('$owner: "$field" must be a non-blank string.');
    }
  }
  final prompts = interface['defaultPrompt'];
  if (prompts is! List ||
      prompts.isEmpty ||
      prompts.length > 3 ||
      prompts.any((p) => p is! String || p.trim().isEmpty || p.length > 128)) {
    _fail(
      '$owner: "defaultPrompt" must list one to three non-blank prompts of '
      'at most 128 characters.',
    );
  }
  final website = interface['websiteURL'];
  if (website is! String || !website.startsWith('https://')) {
    _fail('$owner: "websiteURL" must be an https URL.');
  }
  final color = interface['brandColor'];
  if (color is! String || !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(color)) {
    _fail('$owner: "brandColor" must be a #RRGGBB color.');
  }
  for (final field in ['composerIcon', 'logo']) {
    final value = interface[field];
    if (value is String) {
      _checkIcon(value, '$owner "$field"');
    } else {
      _fail('$owner: "$field" must name the plugin icon.');
    }
  }
}

/// Requires a square PNG inside the plugin, 512 to 2048 pixels on a side and
/// under 2 MB: the strictest of the hosts' icon rules.
void _checkIcon(String relativePath, String owner) {
  if (!relativePath.startsWith('./') || relativePath.contains('..')) {
    _fail('$owner: "$relativePath" must be a "./" path inside the plugin.');
    return;
  }
  final file = File('$_pluginRoot/${relativePath.substring(2)}');
  if (!file.existsSync()) {
    _fail('$owner: "$relativePath" does not exist.');
    return;
  }
  final bytes = file.readAsBytesSync();
  const signature = [137, 80, 78, 71, 13, 10, 26, 10];
  if (bytes.length < 24 ||
      List.generate(8, (i) => bytes[i]).join(',') != signature.join(',')) {
    _fail('$owner: "$relativePath" is not a PNG file.');
    return;
  }
  int readInt(int offset) =>
      bytes[offset] << 24 |
      bytes[offset + 1] << 16 |
      bytes[offset + 2] << 8 |
      bytes[offset + 3];
  final width = readInt(16);
  final height = readInt(20);
  if (width != height || width < 512 || width > 2048) {
    _fail(
      '$owner: "$relativePath" is ${width}x$height; it must be square and '
      '512 to 2048 pixels on a side.',
    );
  }
  if (bytes.length >= 2 * 1024 * 1024) {
    _fail('$owner: "$relativePath" must be under 2 MB.');
  }
}

/// Checks both catalogs and returns the marketplace name and plugin path.
({String? marketplace, String? pluginPath}) _checkCatalogs() {
  final claude = _readJson(_claudeCatalogPath);
  final codex = _readJson(_codexCatalogPath);
  String? claudeName;
  String? codexName;
  String? pluginPath;
  final claudePlugins = <String>[];
  final codexPlugins = <String>[];
  // Plugin name to the folder each catalog installs it from.
  final claudeSources = <String, String>{};
  final codexSources = <String, String>{};

  if (claude != null) {
    claudeName = _stringOrNull(claude['name']);
    if (claudeName == null || !_kebabCase.hasMatch(claudeName)) {
      _fail('$_claudeCatalogPath: marketplace "name" must be kebab-case.');
    }
    if (claude['owner'] is! Map || (claude['owner'] as Map)['name'] == null) {
      _fail('$_claudeCatalogPath: "owner.name" is required.');
    }
    final plugins = claude['plugins'];
    if (plugins is! List || plugins.isEmpty) {
      _fail('$_claudeCatalogPath: "plugins" must be a non-empty array.');
    } else {
      for (final plugin in plugins) {
        if (plugin is! Map<String, dynamic>) {
          _fail('$_claudeCatalogPath: each "plugins" entry must be an object.');
          continue;
        }
        final name = _stringOrNull(plugin['name']);
        if (name == null || !_kebabCase.hasMatch(name)) {
          _fail('$_claudeCatalogPath: plugin "name" must be kebab-case.');
        } else if (claudePlugins.contains(name)) {
          _fail('$_claudeCatalogPath: duplicate plugin name "$name".');
        } else {
          claudePlugins.add(name);
        }
        final source = plugin['source'];
        if (source is String) {
          _checkSourcePath(source, '$_claudeCatalogPath ($name)');
          pluginPath ??= source.replaceFirst('./', '');
          if (name != null) claudeSources[name] = source;
        } else {
          _fail(
            '$_claudeCatalogPath ($name): expected a relative-path string '
            'source for a repo-hosted plugin.',
          );
        }
        if (plugin.containsKey('version')) {
          _fail(
            '$_claudeCatalogPath ($name): do not set "version" in the '
            'catalog entry; plugin.json is the single version source.',
          );
        }
      }
    }
  }

  if (codex != null) {
    codexName = _stringOrNull(codex['name']);
    if (codexName == null || !_kebabCase.hasMatch(codexName)) {
      _fail('$_codexCatalogPath: marketplace "name" must be kebab-case.');
    }
    final plugins = codex['plugins'];
    if (plugins is! List || plugins.isEmpty) {
      _fail('$_codexCatalogPath: "plugins" must be a non-empty array.');
    } else {
      for (final plugin in plugins) {
        if (plugin is! Map<String, dynamic>) {
          _fail('$_codexCatalogPath: each "plugins" entry must be an object.');
          continue;
        }
        final name = _stringOrNull(plugin['name']);
        if (name == null || !_kebabCase.hasMatch(name)) {
          _fail('$_codexCatalogPath: plugin "name" must be kebab-case.');
        } else {
          codexPlugins.add(name);
        }
        final source = plugin['source'];
        if (source is Map<String, dynamic>) {
          if (source['source'] != 'local') {
            _fail(
              '$_codexCatalogPath ($name): expected {"source": "local"} for '
              'a repo-hosted plugin.',
            );
          }
          final path = source['path'];
          if (path is String) {
            _checkSourcePath(path, '$_codexCatalogPath ($name)');
            if (name != null) codexSources[name] = path;
          } else {
            _fail('$_codexCatalogPath ($name): "source.path" is required.');
          }
        } else {
          _fail('$_codexCatalogPath ($name): "source" must be an object.');
        }
        final policy = plugin['policy'];
        if (policy is! Map ||
            policy['installation'] is! String ||
            policy['authentication'] is! String ||
            plugin['category'] is! String) {
          _fail(
            '$_codexCatalogPath ($name): "policy.installation", '
            '"policy.authentication", and "category" are required.',
          );
        }
      }
    }
  }

  if (claudeName != null && codexName != null && claudeName != codexName) {
    _fail(
      'Marketplace names differ between catalogs: "$claudeName" (Claude) vs '
      '"$codexName" (Codex). Keep them identical so install docs stay true.',
    );
  }
  if (claude != null &&
      codex != null &&
      claudePlugins.join(',') != codexPlugins.join(',')) {
    _fail('The two catalogs must list the same plugins in the same order.');
  }
  for (final MapEntry(key: name, value: path) in codexSources.entries) {
    final claudeSource = claudeSources[name];
    if (claudeSource != null && _folder(claudeSource) != _folder(path)) {
      _fail(
        'The catalogs install "$name" from different folders: '
        '"$claudeSource" (Claude) vs "$path" (Codex).',
      );
    }
  }
  return (marketplace: claudeName, pluginPath: pluginPath);
}

String? _stringOrNull(Object? value) => value is String ? value : null;

/// [path] without its leading `./` or trailing `/`.
String _folder(String path) =>
    path.replaceFirst(RegExp(r'^\./'), '').replaceFirst(RegExp(r'/+$'), '');

/// Returns the top-level frontmatter keys plus `name` and `description`.
({Set<String> keys, String? name, String? description}) _parseFrontmatter(
  String path,
  String content,
) {
  final lines = const LineSplitter().convert(content);
  if (lines.isEmpty || lines.first.trim() != '---') {
    _fail('$path: missing YAML frontmatter opening "---".');
    return (keys: const {}, name: null, description: null);
  }
  final end = lines.indexWhere((l) => l.trim() == '---', 1);
  if (end == -1) {
    _fail('$path: frontmatter never closes with "---".');
    return (keys: const {}, name: null, description: null);
  }
  final keys = <String>{};
  String? name;
  String? description;
  for (final line in lines.sublist(1, end)) {
    final key = RegExp(r'^([A-Za-z][\w-]*):').firstMatch(line)?.group(1);
    if (key != null) keys.add(key);
    if (line.startsWith('name:')) {
      name = line.substring('name:'.length).trim();
    } else if (line.startsWith('description:')) {
      description = line.substring('description:'.length).trim();
    }
  }
  return (keys: keys, name: name, description: description);
}

void _checkSkillLinks(String skillDir, String mdPath, String content) {
  final links = RegExp(r'\[[^\]]*\]\(([^)]+)\)').allMatches(content);
  for (final match in links) {
    final target = match.group(1)!.split('#').first.trim();
    if (target.isEmpty || target.contains('://')) continue;
    if (target.startsWith('/')) {
      _fail('$mdPath: absolute link target "$target" is not portable.');
      continue;
    }
    final normalized = Uri(path: '${File(mdPath).parent.path}/$target')
        .normalizePath()
        .path;
    if (!normalized.startsWith('$skillDir/')) {
      _fail(
        '$mdPath: link "$target" escapes the skill directory; skills must '
        'be self-contained.',
      );
      continue;
    }
    if (!File(normalized).existsSync()) {
      _fail('$mdPath: link target "$target" does not exist.');
    }
  }
}

void _checkTextFile(File md) {
  final text = md.readAsStringSync();
  for (final marker in ['/Users/', '/home/', r'C:\']) {
    if (text.contains(marker)) {
      _fail('${md.path}: contains machine-specific path marker "$marker".');
    }
  }
  for (final marker in ['-----BEGIN', 'ghp_', 'AKIA']) {
    if (text.contains(marker)) {
      _fail('${md.path}: contains secret-like marker "$marker".');
    }
  }
}

/// Checks every skill and returns their names.
Set<String> _checkSkills() {
  final skillsRoot = Directory(_skillsDir);
  if (!skillsRoot.existsSync()) {
    _fail('$_skillsDir: missing skills directory.');
    return const {};
  }
  final skillDirs = skillsRoot.listSync().whereType<Directory>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  if (skillDirs.isEmpty) {
    _fail('$_skillsDir: no skills found.');
    return const {};
  }
  final seen = <String>{};
  for (final dir in skillDirs) {
    final dirName = dir.path.split(Platform.pathSeparator).last;
    final skillPath = '${dir.path}/SKILL.md';
    final skillFile = File(skillPath);
    if (!skillFile.existsSync()) {
      _fail('$skillPath: missing SKILL.md.');
      continue;
    }
    if (!_kebabCase.hasMatch(dirName) || dirName.length > 64) {
      _fail('${dir.path}: skill directory name must be kebab-case, max 64.');
    }
    if (!seen.add(dirName)) {
      _fail('${dir.path}: duplicate skill name.');
    }
    final content = skillFile.readAsStringSync();
    final frontmatter = _parseFrontmatter(skillPath, content);
    if (frontmatter.name != dirName) {
      _fail(
        '$skillPath: frontmatter name "${frontmatter.name}" must equal the '
        'directory name "$dirName" (agentskills.io requirement).',
      );
    }
    for (final key in frontmatter.keys.difference(_skillFields)) {
      _fail(
        '$skillPath: frontmatter "$key" is not an Agent Skills field; '
        'hosts other than the one it was written for ignore or reject it.',
      );
    }
    // Antigravity cuts SKILL.md at 24 KB, and the Agent Skills guidance
    // keeps the body under 500 lines with details in references/.
    if (skillFile.lengthSync() > 24 * 1024) {
      _fail('$skillPath: over 24 KB; move detail into references/.');
    }
    if (const LineSplitter().convert(content).length > 500) {
      _fail('$skillPath: over 500 lines; move detail into references/.');
    }
    final description = frontmatter.description;
    if (description == null || description.isEmpty) {
      _fail('$skillPath: frontmatter "description" is required.');
    } else {
      if (description.length > 1024) {
        _fail(
          '$skillPath: description is ${description.length} chars; the '
          'portable limit is 1024.',
        );
      }
      if (description.contains(': ') && !description.startsWith('"')) {
        _fail(
          '$skillPath: unquoted description contains ": " which breaks the '
          'YAML plain scalar (frontmatter would silently drop). Rephrase or '
          'quote the whole value.',
        );
      }
    }
    for (final md
        in dir
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.md'))) {
      _checkSkillLinks(dir.path, md.path, md.readAsStringSync());
      _checkTextFile(md);
    }
  }
  return seen;
}

/// Checks the `claude plugin eval` suite's layout and skill references.
void _checkEvals(Set<String> skillNames) {
  final root = Directory(_evalsDir);
  if (!root.existsSync()) {
    _fail('$_evalsDir: missing; the plugin ships an eval suite.');
    return;
  }
  final cases = root
      .listSync()
      .whereType<Directory>()
      .where((d) => !d.path.endsWith('/results'))
      .toList();
  if (cases.isEmpty) _fail('$_evalsDir: no eval cases found.');
  for (final dir in cases) {
    if (!File('${dir.path}/prompt.md').existsSync()) {
      _fail('${dir.path}: an eval case needs a prompt.md.');
    }
    final graders = Directory('${dir.path}/graders');
    final graderFiles = graders.existsSync()
        ? graders.listSync().whereType<File>().where(
            (f) => f.path.endsWith('.md'),
          )
        : const <File>[];
    if (graderFiles.isEmpty) {
      _fail('${dir.path}: an eval case needs at least one graders/*.md.');
    }
    for (final file in [File('${dir.path}/prompt.md'), ...graderFiles]) {
      if (file.existsSync()) _checkTextFile(file);
    }
    // A renamed skill would otherwise leave its graders silently unmatched.
    for (final grader in graderFiles) {
      final text = grader.readAsStringSync();
      if (!text.contains('tool: Skill')) continue;
      final named =
          RegExp('[a-z0-9-]*dart-helper-utils[a-z0-9-]*')
              .allMatches(text)
              .map((m) => m.group(0)!)
              .toSet()
            ..remove('dart-helper-utils');
      for (final name in named.difference(skillNames)) {
        _fail('${grader.path}: names skill "$name", which does not exist.');
      }
    }
  }
}

/// Requires the documented install commands to match the catalogs, and the
/// manifests' homepage anchor to exist in README.md.
void _checkReadmes({
  required String? marketplace,
  required String? pluginPath,
  required Map<String, dynamic>? rootManifest,
}) {
  final repository = rootManifest?['repository'];
  final homepage = rootManifest?['homepage'];
  final pluginName = rootManifest?['name'];
  if (marketplace == null ||
      pluginPath == null ||
      repository is! String ||
      pluginName is! String) {
    return; // Already reported by the manifest and catalog checks.
  }
  final slug = repository.replaceFirst('https://github.com/', '');
  final id = '$pluginName@$marketplace';
  final commands = [
    '/plugin marketplace add $slug',
    '/plugin install $id',
    'codex plugin marketplace add $slug',
    'codex plugin add $id',
    'agy plugin install https://github.com/$slug/tree/main/$pluginPath',
  ];
  for (final path in ['README.md', _pluginReadmePath]) {
    final file = File(path);
    if (!file.existsSync()) {
      _fail('$path: missing.');
      continue;
    }
    final text = file.readAsStringSync();
    for (final command in commands) {
      if (!text.contains(command)) {
        _fail('$path: missing the install command "$command".');
      }
    }
  }
  if (homepage is String && homepage.contains('#')) {
    final anchor = homepage.split('#').last;
    final headings = RegExp(r'^#{1,6}\s+(.+)$', multiLine: true)
        .allMatches(File('README.md').readAsStringSync())
        .map(
          (m) => m
              .group(1)!
              .trim()
              .toLowerCase()
              .replaceAll(RegExp('[^a-z0-9 _-]'), '')
              .replaceAll(' ', '-'),
        );
    if (!headings.contains(anchor)) {
      _fail('README.md: no heading for the manifests\' homepage "#$anchor".');
    }
  }
}

void _checkPubignore() {
  final file = File('.pubignore');
  if (!file.existsSync()) {
    _fail('.pubignore: missing; the plugin tree would leak into the archive.');
    return;
  }
  final lines = const LineSplitter()
      .convert(file.readAsStringSync())
      .map((l) => l.trim())
      .toSet();
  for (final required in ['tooling/', 'tool/', 'AGENTS.md', 'CLAUDE.md']) {
    if (!lines.contains(required)) {
      _fail(
        '.pubignore: missing "$required" - the pub.dev archive must not '
        'contain a partial AI plugin or maintainer-only files.',
      );
    }
  }
}

/// Entry point; see the library docs for what is validated.
void main() {
  final pubspecVersion = _readPubspecVersion();
  final rootManifest = _checkManifests(pubspecVersion);
  final catalogs = _checkCatalogs();
  final skills = _checkSkills();
  _checkEvals(skills);
  _checkReadmes(
    marketplace: catalogs.marketplace,
    pluginPath: catalogs.pluginPath,
    rootManifest: rootManifest,
  );
  _checkPubignore();

  if (_errors.isEmpty) {
    stdout.writeln('Agent plugin validation passed.');
    return;
  }
  stderr.writeln('Agent plugin validation FAILED:');
  for (final error in _errors) {
    stderr.writeln('  - $error');
  }
  exitCode = 1;
}
