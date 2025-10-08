import '../exceptions/conversion_exception.dart';

class ConversionResult<T> {
  const ConversionResult._(this._value, this._error);

  factory ConversionResult.success(T value) => ConversionResult._(value, null);

  factory ConversionResult.failure(
    ConversionException error,
  ) =>
      ConversionResult._(null, error);
  final T? _value;
  final ConversionException? _error;

  bool get isSuccess => _error == null;

  bool get isFailure => _error != null;

  T get value {
    if (_error != null) throw _error!;
    return _value as T;
  }

  T? get valueOrNull => _error == null ? _value : null;

  T valueOr(T defaultValue) => _error == null ? (_value as T) : defaultValue;

  ConversionException? get error => _error;

  ConversionResult<R> map<R>(R Function(T value) transform) {
    if (isSuccess) {
      return ConversionResult.success(transform(_value as T));
    }
    return ConversionResult.failure(_error!);
  }

  ConversionResult<R> flatMap<R>(ConversionResult<R> Function(T value) next) {
    if (isSuccess) {
      return next(_value as T);
    }
    return ConversionResult.failure(_error!);
  }

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(ConversionException error) onFailure,
  }) {
    if (isSuccess) return onSuccess(_value as T);
    return onFailure(_error!);
  }
}
