extension DHUNullableSetExt<E> on Set<E>? {
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  bool get isNotEmptyOrNull => !isEmptyOrNull;
}
