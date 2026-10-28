// Guards the one rule a lint cannot check: `dart_helper_utils.dart` exports
// this package's extensions together with every extension of convert_object,
// stringo, and collection. Users get all of them from one import, so a member
// name declared twice on overlapping types is either a compile-time ambiguity
// for every caller, or a silent split where the receiver's static type picks
// the implementation. Both have shipped before (`swap`, `isValidPhoneNumber`).
@TestOn('vm')
@Timeout(Duration(minutes: 3))
library;

import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:test/test.dart';

/// Members that deliberately share a name with an extension member of a
/// re-exported package or the SDK, keyed `member: OurExtension/TheirExtension`.
/// Each needs a reason that explains why the two can never disagree.
const _allowedOverlaps = <String, String>{
  'isValidPhoneNumber: DHUNullSafeStringExtensions/UriParsingX':
      "The String? member delegates to convert_object's String member, so "
      'both receivers always agree (string_general_extensions_test.dart).',
};

/// Members of extensions on a nullable type that share a name with an
/// instance member of the non-nullable type, keyed `member: OurExtension`.
const _allowedNullableLifts = <String, String>{
  'isNegative: DHUNullSafeNumExtensions':
      'Delegates to num.isNegative, so null-safe and non-null receivers agree.',
};

const _sdkLibraries = ['dart:core', 'dart:async', 'dart:collection'];

void main() {
  late LibraryElement library;
  late TypeSystem typeSystem;
  late List<ExtensionElement> ours;
  late List<ExtensionElement> theirs;

  setUpAll(() async {
    final entry = File('lib/dart_helper_utils.dart').absolute.path;
    final session = AnalysisContextCollection(includedPaths: [entry])
        .contextFor(entry)
        .currentSession;
    final result = await session.getLibraryByUri(
      'package:dart_helper_utils/dart_helper_utils.dart',
    );
    if (result is! LibraryElementResult) {
      fail('Could not resolve the public library: $result');
    }
    library = result.element;
    typeSystem = library.typeSystem;

    final visible = library.exportNamespace.definedNames2.values
        .whereType<ExtensionElement>()
        .toList();
    for (final uri in _sdkLibraries) {
      final sdk = await session.getLibraryByUri(uri);
      if (sdk is LibraryElementResult) {
        visible.addAll(
          sdk.element.exportNamespace.definedNames2.values
              .whereType<ExtensionElement>(),
        );
      }
    }
    ours = visible.where(_isOurs).toList();
    theirs = visible.where((e) => !_isOurs(e)).toList();
  });

  test('the public library exports this package and its re-exports', () {
    expect(ours, isNotEmpty);
    final packages = theirs.map(_packageOf).toSet();
    expect(
      packages,
      containsAll(<String>['collection', 'convert_object', 'stringo']),
    );
  });

  test('no member name is shared with a re-exported or SDK extension', () {
    final problems = <String>[];
    final used = <String>{};
    for (final mine in ours) {
      for (final member in _instanceMembers(mine)) {
        if (member.metadata.hasDeprecated) continue; // leaving in 8.0.0
        for (final other in theirs) {
          final clash = _instanceMembers(other)
              .any((m) => m.name == member.name);
          if (!clash) continue;
          if (!_overlap(typeSystem, mine.extendedType, other.extendedType)) {
            continue;
          }
          final key = '${member.name}: ${mine.name}/${other.name}';
          if (_allowedOverlaps.containsKey(key)) {
            used.add(key);
            continue;
          }
          problems.add(
            '$key - ${mine.name} on ${mine.extendedType} and '
            '${other.name} on ${other.extendedType} '
            '(${_packageOf(other)}) both declare `${member.name}`.',
          );
        }
      }
    }
    expect(
      problems,
      isEmpty,
      reason:
          'Rename the member, or remove the duplicate if the other package '
          'already provides it. See AGENTS.md "Conventions".',
    );
    expect(
      _allowedOverlaps.keys.toSet().difference(used),
      isEmpty,
      reason: 'Allowlist entries that no longer match must be deleted.',
    );
  });

  test('no member is hidden by an instance member of its own type', () {
    final problems = <String>[];
    final used = <String>{};
    for (final mine in ours) {
      final onType = mine.extendedType;
      final base = typeSystem.promoteToNonNull(onType);
      if (base is! InterfaceType) continue;
      final nullable = typeSystem.isNullable(onType);
      for (final member in _instanceMembers(mine)) {
        final name = member.name!;
        final hit = member is SetterElement
            ? base.lookUpSetter(name, library)
            : base.lookUpGetter(name, library) ??
                  base.lookUpMethod(name, library);
        if (hit == null) continue;
        final key = '$name: ${mine.name}';
        if (nullable && _allowedNullableLifts.containsKey(key)) {
          used.add(key);
          continue;
        }
        problems.add(
          nullable
              ? '$key - non-null receivers use $base.$name instead; '
                    'delegate to it and allowlist the lift.'
              : '$key - unreachable: $base.$name always wins.',
        );
      }
    }
    expect(problems, isEmpty);
    expect(
      _allowedNullableLifts.keys.toSet().difference(used),
      isEmpty,
      reason: 'Allowlist entries that no longer match must be deleted.',
    );
  });
}

bool _isOurs(Element element) => _packageOf(element) == 'dart_helper_utils';

String _packageOf(Element element) {
  final uri = element.library!.uri;
  return uri.isScheme('package') ? uri.pathSegments.first : uri.toString();
}

Iterable<ExecutableElement> _instanceMembers(ExtensionElement extension) =>
    <ExecutableElement>[
      ...extension.getters.where((g) => g.isOriginDeclaration && !g.isStatic),
      ...extension.setters.where((s) => s.isOriginDeclaration && !s.isStatic),
      ...extension.methods.where((m) => !m.isStatic),
    ].where((m) => m.name != null && !m.name!.startsWith('_'));

/// Whether some receiver can match both extension types.
///
/// Conservative: an extension on a type parameter applies to everything.
bool _overlap(TypeSystem typeSystem, DartType a, DartType b) {
  final x = typeSystem.promoteToNonNull(a);
  final y = typeSystem.promoteToNonNull(b);
  if (x is TypeParameterType || y is TypeParameterType) return true;
  if (x is! InterfaceType || y is! InterfaceType) return x == y;
  if (x.element == y.element) return true;
  return x.allSupertypes.any((t) => t.element == y.element) ||
      y.allSupertypes.any((t) => t.element == x.element);
}
