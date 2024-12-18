import 'dart:convert';

import 'package:dart_helper_utils/dart_helper_utils.dart';

extension DHUObjectNullableExtensions on Object? {
  /// Encodes the object into a JSON string.
  ///
  /// This method attempts to encode the current object as a JSON string using Dart's `json.encode` method.
  /// For objects that are not directly encodable to a JSON string (e.g., custom classes), a custom encoding
  /// function can be provided that specifies how to convert such objects into encodable objects.
  ///
  /// Parameters:
  /// - `toEncodable`: A custom function that converts objects that are not directly encodable into objects
  ///   that are encodable to JSON. This function is only called for objects that are not natively encodable
  ///   to a JSON string (like custom classes).
  ///
  /// Returns:
  /// - A JSON string representation of the object. If the object is `null`, it returns the string `"null"`.
  ///
  /// Example Usage:
  /// ```dart
  /// class User {
  ///   final String name;
  ///   final int age;
  ///
  ///   User(this.name, this.age);
  ///
  ///   Map<String, dynamic> toJson() => {'name': name, 'age': age};
  /// }
  ///
  /// var user = User('John Doe', 30);
  /// var jsonString = user.encode(toEncodable: (object) => object.toJson());
  /// print(jsonString); // Output: '{"name":"John Doe","age":30}'
  ///
  /// var nullObject = null;
  /// print(nullObject.encode()); // Output: "null"
  /// ```
  ///
  /// Note:
  /// The `toEncodable` function is crucial for encoding custom objects that do not have a direct representation
  /// in JSON. Without it, attempting to encode such objects will result in a `TypeError`.
  dynamic encode({Object? Function(dynamic object)? toEncodable}) =>
      json.encode(this, toEncodable: toEncodable);

  bool get isNull => this == null;

  bool get isNotNull => this != null;

  /// *Rules*:
  ///  * Object is true only if
  ///    1. Object is bool and true.
  ///    2. Object is num and is greater than zero.
  ///    3. Object is string and is equal to 'yes', 'true', '1', or 'ok'.
  /// * any other conditions including null will return false.
  bool get asBool {
    final self = this;
    if (self == null) return false;
    if (self is bool) return self;
    if (self is num) return self.asBool;
    return self.toString().asBool;
  }

  bool isPrimitive() {
    final value = this;
    if (value is Iterable) return value.isPrimitive();
    if (value is Map) return value.isPrimitive();
    return value is num ||
        value is bool ||
        value is String ||
        value is BigInt ||
        value is DateTime;
  }

  /// Checks if this object can be parsed as a double.
  ///
  /// Examples:
  /// ```dart
  /// 1.toString().isDouble; // true
  /// 1.0.toString().isDouble; // true
  /// '1.23'.isDouble; // true
  /// 'abc'.isDouble; // false
  /// ```
  bool get isDouble => double.tryParse(toString()) != null;

  /// Checks if this object can be parsed as an integer.
  ///
  /// Examples:
  /// ```dart
  /// 1.toString().isInt; // true
  /// 1.0.toString().isInt; // false
  /// '1'.isInt; // true
  /// '1.23'.isInt; // false
  /// 'abc'.isInt; // false
  /// ```
  bool get isInt => int.tryParse(toString()) != null;

  /// Checks if this object can be parsed as a number (either integer or double).
  ///
  /// Examples:
  /// ```dart
  /// 1.toString().isNum; // true
  /// 1.0.toString().isNum; // true
  /// '1'.isNum; // true
  /// '1.23'.isNum; // true
  /// 'abc'.isNum; // false
  /// ```
  bool get isNum => num.tryParse(toString()) != null;
}

extension DHUObjectConvert on Object {
  /// Converting this string into a String using the ConvertObject class.
  String convertToString({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.toString1(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a num using the ConvertObject class.
  num convertToNum({
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
  }) {
    return ConvertObject.toNum(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
    );
  }

  /// Attempting to convert this object into an int using the ConvertObject class.
  int convertToInt({
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
  }) {
    return ConvertObject.toInt(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
    );
  }

  /// Attempting to convert this object into a BigInt using the ConvertObject class.
  BigInt convertToBigInt({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.toBigInt(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a double using the ConvertObject class.
  double convertToDouble({
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
  }) {
    return ConvertObject.toDouble(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
    );
  }

  /// Attempting to convert this object into a bool using the ConvertObject class.
  bool convertToBool({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.toBool(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a DateTime using the ConvertObject class.
  DateTime convertToDateTime({
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    return ConvertObject.toDateTime(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      autoDetectFormat: autoDetectFormat,
      useCurrentLocale: useCurrentLocale,
      utc: utc,
    );
  }

  /// Attempting to convert this object into a Uri using the ConvertObject class.
  Uri convertToUri({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.toUri(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a Map<K, V> using the ConvertObject class.
  Map<K, V> convertToMap<K, V>({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.toMap<K, V>(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a Set<T> using the ConvertObject class.
  Set<T> convertToSet<T>({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.toSet<T>(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a List<T> using the ConvertObject class.
  List<T> convertToList<T>({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.toList<T>(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }
}

extension DHUObjectTryConvert on Object? {
  /// Converting this string into a nullable String using the ConvertObject class.
  String? tryConvertToString({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.tryToString(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a nullable num using the ConvertObject class.
  num? tryConvertToNum({
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
  }) {
    return ConvertObject.tryToNum(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
    );
  }

  /// Attempting to convert this object into a nullable int using the ConvertObject class.
  int? tryConvertToInt({
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
  }) {
    return ConvertObject.tryToInt(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
    );
  }

  /// Attempting to convert this object into a nullable BigInt using the ConvertObject class.
  BigInt? tryConvertToBigInt({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.tryToBigInt(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a nullable double using the ConvertObject class.
  double? tryConvertToDouble({
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
  }) {
    return ConvertObject.tryToDouble(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
    );
  }

  /// Attempting to convert this object into a nullable bool using the ConvertObject class.
  bool? tryConvertToBool({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.tryToBool(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a nullable DateTime using the ConvertObject class.
  DateTime? tryConvertToDateTime({
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
  }) {
    return ConvertObject.tryToDateTime(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      autoDetectFormat: autoDetectFormat,
      useCurrentLocale: useCurrentLocale,
      utc: utc,
    );
  }

  /// Attempting to convert this object into a nullable Uri using the ConvertObject class.
  Uri? tryConvertToUri({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.tryToUri(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a nullable Map<K, V> using the ConvertObject class.
  Map<K, V>? tryConvertToMap<K, V>({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.tryToMap<K, V>(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a nullable Set<T> using the ConvertObject class.
  Set<T>? tryConvertToSet<T>({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.tryToSet<T>(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }

  /// Attempting to convert this object into a nullable List<T> using the ConvertObject class.
  List<T>? tryConvertToList<T>({
    dynamic mapKey,
    int? listIndex,
  }) {
    return ConvertObject.tryToList<T>(
      this,
      mapKey: mapKey,
      listIndex: listIndex,
    );
  }
}
