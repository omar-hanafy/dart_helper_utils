import 'dart:convert';

import 'package:dart_helper_utils/dart_helper_utils.dart';

///
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
