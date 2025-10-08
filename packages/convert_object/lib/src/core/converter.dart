import '../exceptions/conversion_exception.dart';
import '../utils/json.dart';
import 'convert_object_impl.dart';

typedef DynamicConverter<T> = T Function(Object? value);

class Converter {
  const Converter(
    this._value, {
    Object? defaultValue,
    DynamicConverter<dynamic>? customConverter,
  })  : _defaultValue = defaultValue,
        _customConverter = customConverter;
  final Object? _value;
  final Object? _defaultValue;
  final DynamicConverter<dynamic>? _customConverter;

  // Options -----------------------------------------------------------
  Converter withDefault(Object? value) =>
      Converter(_value, defaultValue: value, customConverter: _customConverter);

  Converter withConverter(DynamicConverter<dynamic> converter) =>
      Converter(_value,
          defaultValue: _defaultValue, customConverter: converter);

  // Navigation --------------------------------------------------------
  Converter fromMap(Object? key) {
    final v = _value;
    if (v is Map) {
      return Converter(v[key],
          defaultValue: _defaultValue, customConverter: _customConverter);
    }
    if (v is String) {
      final decoded = v.tryDecode();
      if (decoded is Map) {
        return Converter(decoded[key],
            defaultValue: _defaultValue, customConverter: _customConverter);
      }
    }
    return Converter(null,
        defaultValue: _defaultValue, customConverter: _customConverter);
  }

  Converter fromList(int index) {
    final v = _value;
    if (v is List) {
      return Converter(index >= 0 && index < v.length ? v[index] : null,
          defaultValue: _defaultValue, customConverter: _customConverter);
    }
    if (v is String) {
      final decoded = v.tryDecode();
      if (decoded is List) {
        return Converter(
            index >= 0 && index < decoded.length ? decoded[index] : null,
            defaultValue: _defaultValue,
            customConverter: _customConverter);
      }
    }
    return Converter(null,
        defaultValue: _defaultValue, customConverter: _customConverter);
  }

  Converter get decoded {
    final v = _value;
    if (v is String) {
      final dv = v.tryDecode();
      return Converter(dv,
          defaultValue: _defaultValue, customConverter: _customConverter);
    }
    return this;
  }

  // Generic -----------------------------------------------------------
  T to<T>() {
    if (_customConverter != null) {
      try {
        return _customConverter!.call(_value) as T;
      } catch (e, s) {
        throw ConversionException(
          error: e,
          context: {
            'method': 'to<$T>',
            'object': _value,
            'converter': _customConverter.runtimeType.toString(),
          },
          stackTrace: s,
        );
      }
    }
    return ConvertObjectImpl.toType<T>(_value);
  }

  T? toOrNull<T>() {
    if (_value == null) return null;
    try {
      return to<T>();
    } catch (_) {
      return null;
    }
  }

  T toOr<T>(T defaultValue) {
    try {
      final v = to<T>();
      return v;
    } catch (_) {
      return defaultValue;
    }
  }

  // Primitive shortcuts ----------------------------------------------
  String toText() =>
      ConvertObjectImpl.toText(_value, defaultValue: _defaultValue as String?);

  String? tryToText() => ConvertObjectImpl.tryToText(_value,
      defaultValue: _defaultValue as String?);

  String toTextOr(String defaultValue) => tryToText() ?? defaultValue;

  num toNum() =>
      ConvertObjectImpl.toNum(_value, defaultValue: _defaultValue as num?);

  num? tryToNum() =>
      ConvertObjectImpl.tryToNum(_value, defaultValue: _defaultValue as num?);

  num toNumOr(num defaultValue) => tryToNum() ?? defaultValue;

  int toInt() =>
      ConvertObjectImpl.toInt(_value, defaultValue: _defaultValue as int?);

  int? tryToInt() =>
      ConvertObjectImpl.tryToInt(_value, defaultValue: _defaultValue as int?);

  int toIntOr(int defaultValue) => tryToInt() ?? defaultValue;

  double toDouble() => ConvertObjectImpl.toDouble(_value,
      defaultValue: _defaultValue as double?);

  double? tryToDouble() => ConvertObjectImpl.tryToDouble(_value,
      defaultValue: _defaultValue as double?);

  double toDoubleOr(double defaultValue) => tryToDouble() ?? defaultValue;

  bool toBool() =>
      ConvertObjectImpl.toBool(_value, defaultValue: _defaultValue as bool?);

  bool? tryToBool() =>
      ConvertObjectImpl.tryToBool(_value, defaultValue: _defaultValue as bool?);

  bool toBoolOr(bool defaultValue) => tryToBool() ?? defaultValue;

  BigInt toBigInt() => ConvertObjectImpl.toBigInt(_value,
      defaultValue: _defaultValue as BigInt?);

  BigInt? tryToBigInt() => ConvertObjectImpl.tryToBigInt(_value,
      defaultValue: _defaultValue as BigInt?);

  BigInt toBigIntOr(BigInt defaultValue) => tryToBigInt() ?? defaultValue;

  DateTime toDateTime() => ConvertObjectImpl.toDateTime(_value,
      defaultValue: _defaultValue as DateTime?);

  DateTime? tryToDateTime() => ConvertObjectImpl.tryToDateTime(_value,
      defaultValue: _defaultValue as DateTime?);

  DateTime toDateTimeOr(DateTime defaultValue) =>
      tryToDateTime() ?? defaultValue;

  Uri toUri() =>
      ConvertObjectImpl.toUri(_value, defaultValue: _defaultValue as Uri?);

  Uri? tryToUri() =>
      ConvertObjectImpl.tryToUri(_value, defaultValue: _defaultValue as Uri?);

  Uri toUriOr(Uri defaultValue) => tryToUri() ?? defaultValue;

  // Collections -------------------------------------------------------
  List<T> toList<T>({DynamicConverter<T>? elementConverter}) =>
      ConvertObjectImpl.toList<T>(_value, elementConverter: elementConverter);

  List<T>? tryToList<T>({DynamicConverter<T>? elementConverter}) =>
      ConvertObjectImpl.tryToList<T>(_value,
          elementConverter: elementConverter);

  Set<T> toSet<T>({DynamicConverter<T>? elementConverter}) =>
      ConvertObjectImpl.toSet<T>(_value, elementConverter: elementConverter);

  Set<T>? tryToSet<T>({DynamicConverter<T>? elementConverter}) =>
      ConvertObjectImpl.tryToSet<T>(_value, elementConverter: elementConverter);

  Map<K, V> toMap<K, V>(
          {DynamicConverter<K>? keyConverter,
          DynamicConverter<V>? valueConverter}) =>
      ConvertObjectImpl.toMap<K, V>(_value,
          keyConverter: keyConverter, valueConverter: valueConverter);

  Map<K, V>? tryToMap<K, V>(
          {DynamicConverter<K>? keyConverter,
          DynamicConverter<V>? valueConverter}) =>
      ConvertObjectImpl.tryToMap<K, V>(_value,
          keyConverter: keyConverter, valueConverter: valueConverter);
}
