/// A set of extensions on the `bool` type to provide more functionality.
extension DHUBoolEx on bool {
  /// Returns the inverse of this value.
  bool get toggled => !this;
}

/// A set of extensions on the nullable `bool` type to provide more functionality.
extension DHUBoolNullablelEx on bool? {
  /// Gets a boolean value indicating whether the nullable boolean is true.
  ///
  /// Returns `true` if the value is non-null and true, otherwise returns `false`.
  bool get isTrue => val;

  /// A helper getter to return the non-nullable boolean value.
  ///
  /// Returns the current boolean value if it's not null; otherwise, returns `false` by default.
  bool get val => this ?? false;

  /// Gets a boolean value indicating whether the nullable boolean is false.
  ///
  /// Returns `true` if the value is not null and false, otherwise returns `false`.
  bool get isFalse => !(this ?? true);

  /// Converts the nullable boolean to its binary representation as an integer.
  ///
  /// Returns `1` if the value is non-null and true, otherwise returns `0`.
  int get binary => (this ?? false) ? 1 : 0;

  /// Converts the nullable boolean to its binary representation as a string.
  ///
  /// Returns `'1'` if the value is non-null and true, otherwise returns `'0'`.
  String get binaryText => (this ?? false) ? '1' : '0';

  /// Returns the inverse of this value, or `null` when the value is `null`.
  bool? get toggled => this == null ? null : !this!;
}
