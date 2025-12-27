///
extension DHUObjectNullableExtensions on Object? {
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
}
