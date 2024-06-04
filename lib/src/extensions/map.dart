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
    return value.makeEncodable;
  } else {
    return value.toString();
  }
}

extension DHUMapExtension<K, V> on Map<K, V> {
  /// Converts a map with dynamic keys and values to a map with string keys and JSON-encodable values.
  Map<String, dynamic> get makeEncodable {
    final result = <String, dynamic>{};
    forEach((key, value) {
      result[key.toString()] = _makeValueEncodable(value);
    });
    return result;
  }

  /// Converts a map with potentially complex data types to a formatted JSON string.
  String get safelyEncodedJson =>
      const JsonEncoder.withIndent('  ').convert(makeEncodable);
}

extension DHUMapNullableExtension<K, V> on Map<K, V>? {
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  bool get isNotEmptyOrNull => !isEmptyOrNull;
}

extension DHUMapExt<K extends String, V> on Map<K, V> {
  /// Flatten a nested Map into a single level map
  ///
  /// If you don't want to flatten arrays (with 0, 1,... indexes),
  /// use [safe] mode.
  ///
  /// To avoid circular reference issues or huge calculations,
  /// you can specify the [maxDepth] the function will traverse.
  Map<String, dynamic> flatJson({
    String delimiter = '.',
    bool safe = false,
    int? maxDepth,
  }) {
    final result = <String, dynamic>{};
    void step(
      Map<String, dynamic> obj, [
      String? previousKey,
      int currentDepth = 1,
    ]) {
      obj.forEach((key, value) {
        final newKey = previousKey != null ? '$previousKey$delimiter$key' : key;

        if (maxDepth != null && currentDepth >= maxDepth) {
          result[newKey] = value;
          return;
        }

        if (value is Map<String, dynamic>) {
          return step(value, newKey, currentDepth + 1);
        }
        if (value is List && !safe) {
          return step(
            _listToMap(value as List<Object>),
            newKey,
            currentDepth + 1,
          );
        }
        result[newKey] = value;
      });
    }

    step(this);

    return result;
  }

  Map<String, T> _listToMap<T>(List<T> list) =>
      list.asMap().map((key, value) => MapEntry(key.toString(), value));
}
