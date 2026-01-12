import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'dart:collection';

///  DHUMapExtension
extension DHUMapExtension<K, V> on Map<K, V> {
  /// Swaps the keys with values in the map.
  /// Note: If there are duplicate values, the last key-value pair will be kept.
  Map<V, K> swapKeysWithValues() => map((key, value) => MapEntry(value, key));

  /// Inserts a key-value pair into the map if the key does not already exist.
  ///
  /// If the key exists, its associated value is returned; otherwise,
  /// the new value is inserted and then returned.
  V setIfMissing(K key, V value) {
    if (!containsKey(key)) {
      this[key] = value;
      return value;
    }
    return this[key] as V;
  }

  /// Returns an iterable of keys where the associated values satisfy the given condition.
  ///
  /// The `condition` function is applied to each value to determine whether its corresponding key
  /// should be included in the result.
  Iterable<K> keysWhere(bool Function(V) condition) => entries
      .where((entry) => condition(entry.value))
      .map((entry) => entry.key);

  /// Transforms the values in this map using the given function.
  ///
  /// A new map is returned with the same keys but with values transformed by the `transform` function.
  Map<K, V2> mapValues<V2>(V2 Function(V) transform) =>
      map((key, value) => MapEntry(key, transform(value)));

  /// Filters the map, retaining only entries that satisfy the given predicate.
  ///
  /// The `predicate` function is applied to each key-value pair. If it returns true, the entry is
  /// included in the resulting map.
  Map<K, V> filter(bool Function(K key, V value) predicate) {
    return Map.fromEntries(
      entries.where((entry) => predicate(entry.key, entry.value)),
    );
  }
}

/// DHUMapNullableExtension
extension DHUMapNullableExtension<K, V> on Map<K, V>? {
  /// Returns `true` when every key and value is a primitive value.
  bool isPrimitive() {
    if (this == null) return false;
    return (isTypePrimitive<K>() || this!.keys.every(isValuePrimitive)) &&
        (isTypePrimitive<V>() || this!.values.every(isValuePrimitive));
  }

  /// Returns `true` when the map is `null` or empty.
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  /// Returns `true` when the map is non-null and not empty.
  bool get isNotEmptyOrNull => !isEmptyOrNull;
}

/// DHUMapExt
extension DHUMapExt<K extends String, V> on Map<K, V> {
  /// Flattens a nested map into a single-level map.
  ///
  /// - By default, flattens arrays (with '0', '1', etc. keys).
  /// - Handles circular references to prevent infinite loops.
  /// - Customizable:
  ///   - `delimiter`: Adjusts how nested keys are separated.
  ///   - `excludeArrays`: Prevents flattening of arrays.
  Map<String, Object?> flatMap({
    String delimiter = '.',
    bool excludeArrays = false,
  }) {
    final result = <String, Object?>{};
    final visited = HashSet<Object>.identity();

    void flattenAny(Object? value, String key) {
      if (value is Map) {
        if (!visited.add(value)) return;
        value.forEach((k, v) {
          final childKey = k.toString();
          flattenAny(v, '$key$delimiter$childKey');
        });
        return;
      }

      if (value is List && !excludeArrays) {
        if (!visited.add(value)) return;
        for (var i = 0; i < value.length; i++) {
          flattenAny(value[i], '$key$delimiter$i');
        }
        return;
      }

      result[key] = value;
    }

    forEach((k, v) => flattenAny(v, k));
    return result;
  }

  /// Deep merges this map with [other] and returns a new map.
  ///
  /// When both maps contain a nested map for the same key, those maps are
  /// merged recursively. Otherwise, the value from [other] overwrites this one.
  Map<String, Object?> deepMerge(Map<String, Object?> other) {
    final base = _toObjectMapFromEntries(entries);
    return _deepMergeMaps(base, other);
  }

  /// Rebuilds a nested map from a flattened map.
  ///
  /// Keys are split by [delimiter] to create nested structures.
  /// Numeric segments are treated as list indices when [parseIndices] is true.
  Map<String, Object?> unflatten({
    String delimiter = '.',
    bool parseIndices = true,
  }) {
    final result = <String, Object?>{};
    for (final entry in entries) {
      final segments = _splitPathSegments(
        entry.key,
        delimiter,
        parseIndices: parseIndices,
      );
      if (segments.isEmpty) continue;
      _setPathSegments(
        result,
        segments,
        entry.value,
        parseIndices: parseIndices,
      );
    }
    return result;
  }

  /// Reads a value from a nested map using [path] (e.g., "a.b.c").
  ///
  /// Returns `null` if the path does not resolve to a value.
  ///
  /// When [parseIndices] is true (default), bracketed indices are supported
  /// (e.g., `items[0].id`).
  Object? getPath(
    String path, {
    String delimiter = '.',
    bool parseIndices = true,
  }) {
    final segments = _splitPathSegments(
      path,
      delimiter,
      parseIndices: parseIndices,
    );
    if (segments.isEmpty) return null;
    return _getPathSegments(this, segments);
  }

  /// Writes a value into a nested map using [path] (e.g., "a.b.c").
  ///
  /// Returns `true` if the value was set successfully.
  bool setPath(
    String path,
    Object? value, {
    String delimiter = '.',
    bool parseIndices = true,
  }) {
    final segments = _splitPathSegments(
      path,
      delimiter,
      parseIndices: parseIndices,
    );
    if (segments.isEmpty) return false;
    return _setPathSegments(this, segments, value, parseIndices: parseIndices);
  }
}

Map<String, Object?> _toObjectMapFromEntries(
  Iterable<MapEntry<dynamic, dynamic>> entries,
) {
  final result = <String, Object?>{};
  for (final entry in entries) {
    if (entry.key is! String) continue;
    result[entry.key as String] = entry.value;
  }
  return result;
}

Map<String, Object?> _deepMergeMaps(
  Map<String, Object?> base,
  Map<String, Object?> other,
) {
  final result = Map<String, Object?>.from(base);
  for (final entry in other.entries) {
    final key = entry.key;
    final otherValue = entry.value;
    final baseValue = result[key];
    final baseMap = _asStringKeyMap(baseValue);
    final otherMap = _asStringKeyMap(otherValue);
    if (baseMap != null && otherMap != null) {
      result[key] = _deepMergeMaps(baseMap, otherMap);
    } else {
      result[key] = otherValue;
    }
  }
  return result;
}

Map<String, Object?>? _asStringKeyMap(Object? value) {
  if (value is! Map) return null;
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    final key = entry.key;
    if (key is! String) return null;
    result[key] = entry.value;
  }
  return result;
}

List<String> _splitPathSegments(
  String path,
  String delimiter, {
  bool parseIndices = true,
}) {
  final trimmed = path.trim();
  if (trimmed.isEmpty) return const <String>[];
  final normalized = parseIndices
      ? trimmed.replaceAllMapped(
          RegExp(r'\[(\d+)\]'),
          (match) => '$delimiter${match[1]}',
        )
      : trimmed;
  return normalized
      .split(delimiter)
      .where((segment) => segment.isNotEmpty)
      .toList(growable: false);
}

Object? _getPathSegments(Object? root, List<String> segments) {
  var current = root;
  for (final segment in segments) {
    if (current is Map) {
      current = current[segment];
      continue;
    }

    if (current is List) {
      final index = int.tryParse(segment);
      if (index == null || index < 0 || index >= current.length) return null;
      current = current[index];
      continue;
    }

    return null;
  }
  return current;
}

bool _setPathSegments(
  Object? root,
  List<String> segments,
  Object? value, {
  required bool parseIndices,
}) {
  var current = root;
  for (var i = 0; i < segments.length; i++) {
    final segment = segments[i];
    final isLast = i == segments.length - 1;
    final nextSegment = !isLast ? segments[i + 1] : null;
    final nextIsIndex = parseIndices &&
        nextSegment != null &&
        int.tryParse(nextSegment) != null;

    if (current is Map) {
      if (isLast) {
        current[segment] = value;
        return true;
      }

      final existing = current[segment];
      if (existing is Map || existing is List) {
        current = existing;
        continue;
      }

      final created = nextIsIndex ? <Object?>[] : <String, Object?>{};
      current[segment] = created;
      current = created;
      continue;
    }

    if (current is List) {
      final index = int.tryParse(segment);
      if (index == null || index < 0) return false;
      if (!_ensureListLength(current, index + 1)) return false;

      if (isLast) {
        current[index] = value;
        return true;
      }

      final existing = current[index];
      if (existing is Map || existing is List) {
        current = existing;
        continue;
      }

      final created = nextIsIndex ? <Object?>[] : <String, Object?>{};
      current[index] = created;
      current = created;
      continue;
    }

    return false;
  }
  return false;
}

bool _ensureListLength(List<dynamic> list, int length) {
  if (list.length >= length) return true;
  try {
    while (list.length < length) {
      list.add(null);
    }
  } catch (_) {
    return false;
  }
  return true;
}
