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

///  DHUMapExtension
extension PrettyJsonMap<K, V> on Map<K, V> {
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
}
