extension LetExtension<T extends Object> on T {
  R let<R>(R Function(T it) block) => block(this);
}

extension LetExtensionNullable<T extends Object> on T? {
  R? let<R>(R Function(T it) block) => this == null ? null : block(this as T);

  R letOr<R>(R Function(T it) block, {required R defaultValue}) =>
      this == null ? defaultValue : block(this as T);

  // Back-compat: nullable-aware variant where block accepts T?
  R? letNullable<R>(R? Function(T? it) block) => this == null ? null : block(this);
}
