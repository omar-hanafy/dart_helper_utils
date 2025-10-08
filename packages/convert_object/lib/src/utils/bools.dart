extension BoolParsingX on Object? {
  /// Convert any value to a boolean with explicit, predictable semantics.
  ///
  /// Rules (merged from legacy DHU + this package):
  /// - null -> false
  /// - bool -> value
  /// - num -> value > 0
  /// - String: case-insensitive
  ///   - truthy: 'true', '1', 'yes', 'y', 'on', 'ok', 't'
  ///   - falsy:  'false', '0', 'no',  'n', 'off', 'f'
  ///   - numeric strings -> parsed and treated like numbers
  ///   - anything else -> false (be conservative)
  bool get asBool {
    final v = this;
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v > 0;

    final s = v.toString().trim().toLowerCase();
    if (s.isEmpty) return false;

    // Numeric strings
    final n = double.tryParse(s);
    if (n != null) return n > 0;

    const truthy = {'true', '1', 'yes', 'y', 'on', 'ok', 't'};
    const falsy = {'false', '0', 'no', 'n', 'off', 'f'};
    if (truthy.contains(s)) return true;
    if (falsy.contains(s)) return false;

    return false;
  }
}
