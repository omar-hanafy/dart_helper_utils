/// Extensions for nullable objects and scope-style helpers.
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

/// Scope functions for Kotlin-like fluent API.
extension DHUScopeFunctions<T extends Object> on T {
  /// Calls the specified function [block] with `this` value as its argument and returns its result.
  R let<R>(R Function(T it) block) => block(this);

  /// Calls the specified function [block] with `this` value as its argument and returns `this` value.
  /// Useful for side effects (logging, debugging) without breaking the chain.
  T also(void Function(T it) block) {
    block(this);
    return this;
  }

  /// Returns `this` value if it satisfies the given [predicate] or `null` if it doesn't.
  T? takeIf(bool Function(T it) predicate) => predicate(this) ? this : null;

  /// Returns `this` value if it does NOT satisfy the given [predicate] or `null` if it does.
  T? takeUnless(bool Function(T it) predicate) =>
      !predicate(this) ? this : null;
}
