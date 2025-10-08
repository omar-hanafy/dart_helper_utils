import '../core/convert_object_impl.dart';

extension IterableConversionX<E> on Iterable<E> {
  // Get-as helpers with inner selection and defaults
  String getString(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? defaultValue,
    ElementConverter<String>? converter,
  }) =>
      ConvertObjectImpl.toText(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {'index': index},
      );

  int getInt(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    int? defaultValue,
    ElementConverter<int>? converter,
  }) =>
      ConvertObjectImpl.toInt(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {'index': index},
      );

  double getDouble(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    double? defaultValue,
    ElementConverter<double>? converter,
  }) =>
      ConvertObjectImpl.toDouble(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {'index': index},
      );

  num getNum(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    num? defaultValue,
    ElementConverter<num>? converter,
  }) =>
      ConvertObjectImpl.toNum(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {'index': index},
      );

  bool getBool(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    bool? defaultValue,
    ElementConverter<bool>? converter,
  }) =>
      ConvertObjectImpl.toBool(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {'index': index},
      );

  BigInt getBigInt(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    BigInt? defaultValue,
    ElementConverter<BigInt>? converter,
  }) =>
      ConvertObjectImpl.toBigInt(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {'index': index},
      );

  DateTime getDateTime(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
    DateTime? defaultValue,
    ElementConverter<DateTime>? converter,
  }) =>
      ConvertObjectImpl.toDateTime(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {'index': index},
      );

  Uri getUri(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    Uri? defaultValue,
    ElementConverter<Uri>? converter,
  }) =>
      ConvertObjectImpl.toUri(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {'index': index},
      );

  List<T> getList<T>(int index,
          {dynamic innerMapKey, int? innerIndex, List<T>? defaultValue}) =>
      ConvertObjectImpl.toList<T>(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        debugInfo: {'index': index},
      );

  Set<T> getSet<T>(int index,
          {dynamic innerMapKey, int? innerIndex, Set<T>? defaultValue}) =>
      ConvertObjectImpl.toSet<T>(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        debugInfo: {'index': index},
      );

  Map<K2, V2> getMap<K2, V2>(int index,
          {dynamic innerMapKey, int? innerIndex, Map<K2, V2>? defaultValue}) =>
      ConvertObjectImpl.toMap<K2, V2>(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        debugInfo: {'index': index},
      );

  T getEnum<T extends Enum>(int index,
          {required T Function(dynamic) parser,
          dynamic innerMapKey,
          int? innerIndex,
          T? defaultValue}) =>
      ConvertObjectImpl.toEnum<T>(
        elementAt(index),
        parser: parser,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        debugInfo: {'index': index},
      );

  // Convert all
  List<T> convertAll<T>() =>
      map((e) => ConvertObjectImpl.toType<T>(e)).toList();
}

extension NullableIterableConversionX<E> on Iterable<E>? {
  E? _firstForIndices(int index, {List<int>? alternativeIndices}) {
    final it = this;
    if (it == null || index < 0) return null;
    try {
      return it.elementAt(index);
    } catch (_) {}
    if (alternativeIndices != null) {
      for (final i in alternativeIndices) {
        try {
          return it.elementAt(i);
        } catch (_) {}
      }
    }
    return null;
  }

  String? getStringOrNull(
    int index, {
    List<int>? alternativeIndices,
    dynamic innerMapKey,
    int? innerIndex,
    String? defaultValue,
    ElementConverter<String>? converter,
  }) =>
      ConvertObjectImpl.tryToText(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  int? getIntOrNull(
    int index, {
    List<int>? alternativeIndices,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    int? defaultValue,
    ElementConverter<int>? converter,
  }) =>
      ConvertObjectImpl.tryToInt(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  double? getDoubleOrNull(
    int index, {
    List<int>? alternativeIndices,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    double? defaultValue,
    ElementConverter<double>? converter,
  }) =>
      ConvertObjectImpl.tryToDouble(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  bool? getBoolOrNull(
    int index, {
    List<int>? alternativeIndices,
    dynamic innerMapKey,
    int? innerIndex,
    bool? defaultValue,
    ElementConverter<bool>? converter,
  }) =>
      ConvertObjectImpl.tryToBool(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  num? getNumOrNull(
    int index, {
    List<int>? alternativeIndices,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    num? defaultValue,
    ElementConverter<num>? converter,
  }) =>
      ConvertObjectImpl.tryToNum(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  BigInt? getBigIntOrNull(
    int index, {
    List<int>? alternativeIndices,
    dynamic innerMapKey,
    int? innerIndex,
    BigInt? defaultValue,
    ElementConverter<BigInt>? converter,
  }) =>
      ConvertObjectImpl.tryToBigInt(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  DateTime? getDateTimeOrNull(
    int index, {
    List<int>? alternativeIndices,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
    DateTime? defaultValue,
    ElementConverter<DateTime>? converter,
  }) =>
      ConvertObjectImpl.tryToDateTime(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  Uri? getUriOrNull(
    int index, {
    List<int>? alternativeIndices,
    dynamic innerMapKey,
    int? innerIndex,
    Uri? defaultValue,
    ElementConverter<Uri>? converter,
  }) =>
      ConvertObjectImpl.tryToUri(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        converter: converter,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  List<T>? tryGetList<T>(int index,
          {List<int>? alternativeIndices,
          dynamic innerMapKey,
          int? innerIndex,
          List<T>? defaultValue}) =>
      ConvertObjectImpl.tryToList<T>(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  Set<T>? tryGetSet<T>(int index,
          {List<int>? alternativeIndices,
          dynamic innerMapKey,
          int? innerIndex,
          Set<T>? defaultValue}) =>
      ConvertObjectImpl.tryToSet<T>(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  Map<K2, V2>? tryGetMap<K2, V2>(int index,
          {List<int>? alternativeIndices,
          dynamic innerMapKey,
          int? innerIndex,
          Map<K2, V2>? defaultValue}) =>
      ConvertObjectImpl.tryToMap<K2, V2>(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );

  T? tryGetEnum<T extends Enum>(int index,
          {required T Function(dynamic) parser,
          List<int>? alternativeIndices,
          dynamic innerMapKey,
          int? innerIndex,
          T? defaultValue}) =>
      ConvertObjectImpl.tryToEnum<T>(
        _firstForIndices(index, alternativeIndices: alternativeIndices),
        parser: parser,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'index': index,
          if (alternativeIndices != null && alternativeIndices.isNotEmpty)
            'altIndexes': alternativeIndices,
        },
      );
}

extension SetConvertToX<E> on Set<E>? {
  Set<R> convertTo<R>() => ConvertObjectImpl.toSet<R>(this);
}
