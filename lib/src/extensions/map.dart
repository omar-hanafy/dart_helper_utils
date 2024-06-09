import 'dart:convert';

dynamic _makeValueEncodable(dynamic value) {
  if (value is String ||
      value is int ||
      value is double ||
      value is bool ||
      value == null) {
    return value;
  } else if (value is Enum) {
    return value.name;
  } else if (value is List) {
    return value.map(_makeValueEncodable).toList();
  } else if (value is Set) {
    return value.map(_makeValueEncodable).toList();
  } else if (value is Map) {
    return value.encodableCopy;
  } else {
    return value.toString();
  }
}

extension DHUMapExtension<K, V> on Map<K, V> {
  /// Returns a new map with converted dynamic keys and values to a map with string keys and JSON-encodable values.
  ///
  /// This is useful for preparing data for JSON serialization, where keys must be strings.
  Map<String, dynamic> get encodableCopy {
    final result = <String, dynamic>{};
    forEach((key, value) {
      result[key.toString()] = _makeValueEncodable(value);
    });
    return result;
  }

  /// Converts a map with potentially complex data types to a formatted JSON string.
  ///
  /// The resulting JSON is indented for readability.
  String get encodedJsonString =>
      const JsonEncoder.withIndent('  ').convert(encodableCopy);

  /// Inserts a key-value pair into the map if the key does not already exist.
  ///
  /// If the key exists, its associated value is returned; otherwise,
  /// the new value is inserted and then returned.
  V setIfMissing(K key, V value) {
    if (this[key] == null) return this[key] = value;
    return this[key]!;
  }

  /// Updates the value associated with the given key if it exists.
  ///
  /// The `updater` function is used to modify the existing value. If the key does not exist,
  /// the map remains unchanged.
  void update(K key, V Function(V value) updater) {
    if (containsKey(key)) this[key] = updater(this[key] as V);
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
        entries.where((entry) => predicate(entry.key, entry.value)));
  }

  /// Returns a list containing all the values in the map.
  List<V> get valuesList => values.toList();

  /// Returns a list containing all the keys in the map.
  List<K> get keysList => keys.toList();

  /// Returns a set containing all the values in the map.
  Set<V> get valuesSet => values.toSet();

  /// Returns a set containing all the keys in the map.
  Set<K> get keysSet => keys.toSet();
}

extension DHUMapNullableExtension<K, V> on Map<K, V>? {
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  bool get isNotEmptyOrNull => !isEmptyOrNull;
}

extension DHUMapExt<K extends String, V> on Map<K, V> {
  /// Flattens a nested map into a single-level map.
  ///
  /// - By default, flattens arrays (with '0', '1', etc. keys).
  /// - Handles circular references to prevent infinite loops.
  /// - Customizable:
  ///   - `delimiter`: Adjusts how nested keys are separated.
  ///   - `excludeArrays`: Prevents flattening of arrays.
  Map<String, dynamic> flatMap({
    String delimiter = '.',
    bool excludeArrays = false,
  }) {
    final result = <String, dynamic>{};
    final visited = <Object, Object>{};

    void flatten(Map<String, dynamic> obj, String? parentKey) {
      obj.forEach((key, value) {
        final newKey = parentKey == null ? key : '$parentKey$delimiter$key';
        if (value is Map<String, dynamic>) {
          if (!visited.containsKey(value)) {
            // Circular reference check
            visited[value] = value;
            flatten(value, newKey);
          }
        } else if (value is List && !excludeArrays) {
          for (var i = 0; i < value.length; i++) {
            final listKey = '$newKey$delimiter$i';
            final item = value[i];
            if (item is Map<String, dynamic>) {
              flatten(item, listKey);
            } else {
              result[listKey] = item;
            }
          }
        } else {
          result[newKey] = value;
        }
      });
    }

    flatten(this, null);
    return result;
  }
}
