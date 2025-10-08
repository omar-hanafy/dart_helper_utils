extension NullableStringX on String? {
  bool get isNotBlank => this != null && this!.trim().isNotEmpty;
  bool get isBlank => !isNotBlank;
}

