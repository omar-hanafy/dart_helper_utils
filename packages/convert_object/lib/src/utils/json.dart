import 'dart:convert';

extension StringJsonX on String {
  /// Tries to decode JSON; on failure, returns the original string.
  Object? tryDecode() {
    final s = trim();
    if (s.isEmpty) return this;
    try {
      return jsonDecode(s);
    } catch (_) {
      return this;
    }
  }

  /// Tries to decode JSON; on failure, returns the original string.
  dynamic decode() => jsonDecode(this);
}
