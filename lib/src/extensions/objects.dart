///
extension DHUObjectNullableExtensions on Object? {
  /// Checks if this object is null.
  bool get isNull => this == null;

  /// Checks if this object is not null.
  bool get isNotNull => this != null;

  /// Checks if this object is a primitive type.
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
