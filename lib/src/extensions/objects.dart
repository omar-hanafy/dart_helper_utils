/// Extensions for nullable objects and primitive checks.
extension DHUObjectNullableExtensions on Object? {
  /// Checks if this object is a primitive type.
  bool isPrimitive() {
    bool isPrimitiveValue(Object? value) {
      if (value == null) return false;
      if (value is num ||
          value is bool ||
          value is String ||
          value is BigInt ||
          value is DateTime) {
        return true;
      }
      if (value is Iterable) {
        return value.every(isPrimitiveValue);
      }
      if (value is Map) {
        return value.keys.every(isPrimitiveValue) &&
            value.values.every(isPrimitiveValue);
      }
      return false;
    }

    return isPrimitiveValue(this);
  }
}
