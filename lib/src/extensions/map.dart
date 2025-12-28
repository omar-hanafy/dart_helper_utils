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
    if (this[key] == null) return this[key] = value;
    return this[key]!;
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
  /// checks if every Key and Value is a [primitive type](https://dart.dev/language/built-in-types).
  bool isPrimitive() {
    if (this == null) return false;
    return (isTypePrimitive<K>() || this!.keys.every(isValuePrimitive)) &&
        (isTypePrimitive<V>() || this!.values.every(isValuePrimitive));
  }

  ///
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  ///
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
    final visited = HashSet.identity();

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
}
