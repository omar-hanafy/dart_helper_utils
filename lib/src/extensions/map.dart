import 'dart:convert';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:dart_helper_utils/src/other_utils/global_functions.dart' as gf;

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

  /// uses the [toString] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [String].
  String getString(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toString1(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toNum] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [num].
  num getNum(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      ConvertObject.toNum(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toInt] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [int].
  int getInt(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      ConvertObject.toInt(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [BigInt].
  BigInt getBigInt(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toBigInt(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [double].
  double getDouble(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      ConvertObject.toDouble(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toBool] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [bool].
  bool getBool(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toBool(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toDateTime] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [DateTime].
  DateTime getDateTime(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
  }) =>
      ConvertObject.toDateTime(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
      );

  /// uses the [toUri] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Uri].
  Uri getUri(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toUri(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toMap] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Map].
  Map<K2, V2> getMap<K2, V2>(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toMap(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toSet] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Set].
  Set<T> getSet<T>(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toSet(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toList] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [List].
  List<T> getList<T>(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toList(
        this[key],
        mapKey: innerKey,
        listIndex: innerListIndex,
      );
}

extension DHUMapNullableExtension<K, V> on Map<K, V>? {
  /// uses the [tryToString] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [String] or return null.
  String? tryGetString(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToString(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToNum] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [num] or return null.
  num? tryGetNum(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToNum(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToInt] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [int] or return null.
  int? tryGetInt(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToInt(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [BigInt] or return null.
  BigInt? tryGetBigInt(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToBigInt(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [double] or return null.
  double? tryGetDouble(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToDouble(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToBool] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [bool] or return null.
  bool? tryGetBool(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToBool(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToDateTime] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [DateTime] or return null.
  DateTime? tryGetDateTime(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToDateTime(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
              format: format,
              locale: locale,
              autoDetectFormat: autoDetectFormat,
              useCurrentLocale: useCurrentLocale,
              utc: utc,
            );

  /// uses the [tryToUri] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Uri] or return null.
  Uri? tryGetUri(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToUri(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToMap] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Map] or return null.
  Map<K2, V2>? tryGetMap<K2, V2>(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToMap(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToSet] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Set] or return null.
  Set<T>? tryGetSet<T>(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToSet(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToList] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [List] or return null.
  List<T>? tryGetList<T>(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToList(
              this![key],
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// Compares two maps for element-by-element equality.
  ///
  /// Returns true if the maps are both null, or if they are both non-null, have
  /// the same length, and contain the same keys associated with the same values.
  /// Returns false otherwise.
  bool isEqual(Map<K, V>? b) {
    final a = this;
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !gf.isEqual(a[key], b[key])) return false;
    }
    return true;
  }

  /// checks if every Key and Value is a [primitive type](https://dart.dev/language/built-in-types).
  bool isPrimitive() {
    if (this == null) return false;
    return (isTypePrimitive<K>() || this!.keys.every(isValuePrimitive)) &&
        (isTypePrimitive<V>() || this!.values.every(isValuePrimitive));
  }

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
