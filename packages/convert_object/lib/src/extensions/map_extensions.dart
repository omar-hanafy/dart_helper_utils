import 'package:collection/collection.dart';

import '../core/convert_object_impl.dart';

extension MapConversionX<K, V> on Map<K, V> {
  V? _firstValueForKeys(K key, {List<K>? alternativeKeys}) {
    var value = this[key];
    if (value == null &&
        alternativeKeys != null &&
        alternativeKeys.isNotEmpty) {
      final altKey = alternativeKeys.firstWhereOrNull(containsKey);
      if (altKey != null) value = this[altKey];
    }
    return value;
  }

  String getString(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          String? defaultValue}) =>
      ConvertObjectImpl.toText(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  int getInt(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          int? defaultValue,
          String? format,
          String? locale}) =>
      ConvertObjectImpl.toInt(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        format: format,
        locale: locale,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  double getDouble(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          double? defaultValue,
          String? format,
          String? locale}) =>
      ConvertObjectImpl.toDouble(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        format: format,
        locale: locale,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  num getNum(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          num? defaultValue,
          String? format,
          String? locale,
          ElementConverter<num>? converter}) =>
      ConvertObjectImpl.toNum(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  bool getBool(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          bool? defaultValue}) =>
      ConvertObjectImpl.toBool(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  List<T> getList<T>(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          List<T>? defaultValue}) =>
      ConvertObjectImpl.toList<T>(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  Set<T> getSet<T>(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          Set<T>? defaultValue}) =>
      ConvertObjectImpl.toSet<T>(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  Map<K2, V2> getMap<K2, V2>(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          Map<K2, V2>? defaultValue}) =>
      ConvertObjectImpl.toMap<K2, V2>(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  BigInt getBigInt(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          BigInt? defaultValue}) =>
      ConvertObjectImpl.toBigInt(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  DateTime getDateTime(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          String? format,
          String? locale,
          bool autoDetectFormat = false,
          bool useCurrentLocale = false,
          bool utc = false,
          DateTime? defaultValue}) =>
      ConvertObjectImpl.toDateTime(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  Uri getUri(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          Uri? defaultValue}) =>
      ConvertObjectImpl.toUri(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  T getEnum<T extends Enum>(K key,
          {required T Function(dynamic) parser,
          List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          T? defaultValue}) =>
      ConvertObjectImpl.toEnum<T>(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        parser: parser,
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  // Parsing helpers (non-nullable map)
  T parse<T, K2, V2>(K key, T Function(Map<K2, V2> json) converter) {
    final raw = this[key];
    final map = ConvertObjectImpl.toMap<K2, V2>(raw);
    return converter.call(map);
  }

  T? tryParse<T, K2, V2>(K key, T Function(Map<K2, V2> json) converter) {
    final raw = this[key];
    final map = ConvertObjectImpl.tryToMap<K2, V2>(raw);
    if (map == null) return null;
    return converter.call(map);
  }
}

extension NullableMapConversionX<K, V> on Map<K, V>? {
  V? _firstValueForKeys(K key, {List<K>? alternativeKeys}) {
    final map = this;
    if (map == null) return null;
    var value = map[key];
    if (value == null &&
        alternativeKeys != null &&
        alternativeKeys.isNotEmpty) {
      final altKey = alternativeKeys.firstWhereOrNull(map.containsKey);
      if (altKey != null) value = map[altKey];
    }
    return value;
  }

  String? tryGetString(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          String? defaultValue}) =>
      ConvertObjectImpl.tryToText(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  int? tryGetInt(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          int? defaultValue,
          String? format,
          String? locale}) =>
      ConvertObjectImpl.tryToInt(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        format: format,
        locale: locale,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  double? tryGetDouble(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          double? defaultValue,
          String? format,
          String? locale}) =>
      ConvertObjectImpl.tryToDouble(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        format: format,
        locale: locale,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  num? tryGetNum(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          num? defaultValue,
          String? format,
          String? locale,
          ElementConverter<num>? converter}) =>
      ConvertObjectImpl.tryToNum(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  bool? tryGetBool(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          bool? defaultValue}) =>
      ConvertObjectImpl.tryToBool(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  List<T>? tryGetList<T>(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          List<T>? defaultValue}) =>
      ConvertObjectImpl.tryToList<T>(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  Set<T>? tryGetSet<T>(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          Set<T>? defaultValue}) =>
      ConvertObjectImpl.tryToSet<T>(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  Map<K2, V2>? tryGetMap<K2, V2>(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          Map<K2, V2>? defaultValue}) =>
      ConvertObjectImpl.tryToMap<K2, V2>(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  BigInt? tryGetBigInt(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          BigInt? defaultValue}) =>
      ConvertObjectImpl.tryToBigInt(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  DateTime? tryGetDateTime(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          String? format,
          String? locale,
          bool autoDetectFormat = false,
          bool useCurrentLocale = false,
          bool utc = false,
          DateTime? defaultValue}) =>
      ConvertObjectImpl.tryToDateTime(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  Uri? tryGetUri(K key,
          {List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          Uri? defaultValue}) =>
      ConvertObjectImpl.tryToUri(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );

  T? tryGetEnum<T extends Enum>(K key,
          {required T Function(dynamic) parser,
          List<K>? alternativeKeys,
          dynamic innerKey,
          int? innerListIndex,
          T? defaultValue}) =>
      ConvertObjectImpl.tryToEnum<T>(
        _firstValueForKeys(key, alternativeKeys: alternativeKeys),
        parser: parser,
        mapKey: innerKey,
        listIndex: innerListIndex,
        defaultValue: defaultValue,
        debugInfo: {
          'key': key,
          if (alternativeKeys != null && alternativeKeys.isNotEmpty)
            'altKeys': alternativeKeys,
        },
      );
}
