import 'dart:developer';

import 'package:meta/meta.dart';

import '../exceptions/conversion_exception.dart';
import '../utils/bools.dart';
import '../utils/dates.dart';
import '../utils/json.dart';
import '../utils/numbers.dart';
import '../utils/strings.dart';
import '../utils/uri.dart';

typedef ElementConverter<T> = T Function(Object? element);

abstract class ConvertObjectImpl {
  static Map<String, dynamic> buildContext({
    required String method,
    dynamic object,
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    bool? autoDetectFormat,
    bool? useCurrentLocale,
    bool? utc,
    dynamic defaultValue,
    dynamic converter,
    Type? targetType,
    Map<String, dynamic>? debugInfo,
  }) {
    final args = <String, dynamic>{
      'method': method,
      'object': object,
      'objectType': object?.runtimeType.toString(),
    };
    if (targetType != null) args['targetType'] = targetType.toString();
    if (mapKey != null) args['mapKey'] = mapKey;
    if (listIndex != null) args['listIndex'] = listIndex;
    if (format != null) args['format'] = format;
    if (locale != null) args['locale'] = locale;
    if (autoDetectFormat != null) args['autoDetectFormat'] = autoDetectFormat;
    if (useCurrentLocale != null) args['useCurrentLocale'] = useCurrentLocale;
    if (utc != null) args['utc'] = utc;
    if (defaultValue != null) args['defaultValue'] = defaultValue;
    if (converter != null) args['converter'] = converter.runtimeType.toString();
    if (debugInfo != null && debugInfo.isNotEmpty) args.addAll(debugInfo);
    return args;
  }

  @optionalTypeArgs
  static T? _convertObject<T>(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    bool decodeInput = false,
    T Function(dynamic)? converter,
  }) {
    if (object == null) return null;
    if (object is T) return object;
    try {
      return object as T;
    } catch (_) {}

    // decode input if requested
    if (decodeInput && object is String) {
      final decoded = object.tryDecode();
      if (!identical(decoded, object)) {
        return _convertObject<T>(
          decoded,
          mapKey: mapKey,
          listIndex: listIndex,
          decodeInput: decodeInput,
          converter: converter,
        );
      }
    }

    // List index
    if (listIndex != null && object is List) {
      try {
        final elem = (listIndex >= 0 && listIndex < object.length)
            ? object[listIndex]
            : null;
        return _convertObject<T>(
          elem,
          decodeInput: decodeInput,
          converter: converter,
        );
      } catch (_) {
        return null;
      }
    }

    // Map key
    if (mapKey != null && object is Map) {
      try {
        return _convertObject<T>(
          object[mapKey],
          decodeInput: decodeInput,
          converter: converter,
        );
      } catch (_) {
        return null;
      }
    }

    try {
      return converter?.call(object);
    } catch (e, s) {
      log(
        'Unsupported object type ($T) [objectType: ${object.runtimeType}, mapKey: $mapKey, listIndex: $listIndex, decodeInput: $decodeInput]: $e',
        stackTrace: s,
        error: e,
      );
      return null;
    }
  }

  // Primitives ---------------------------------------------------------

  static String toText(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    String? defaultValue,
    ElementConverter<String>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<String>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: converter ?? ((o) => o.toString()),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toText',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          defaultValue: defaultValue,
          converter: converter,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static String? tryToText(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    String? defaultValue,
    ElementConverter<String>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<String>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: converter ?? ((o) => o.toString()),
        ) ??
        defaultValue;
  }

  static num toNum(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    num? defaultValue,
    ElementConverter<num>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<num>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: converter ??
          ((o) {
            if (format.isNotBlank) return '$o'.toNumFormatted(format!, locale);
            return '$o'.toNum();
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toNum',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          format: format,
          locale: locale,
          defaultValue: defaultValue,
          converter: converter,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static num? tryToNum(
    dynamic object, {
    dynamic mapKey,
    String? format,
    String? locale,
    int? listIndex,
    num? defaultValue,
    ElementConverter<num>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<num?>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: converter ??
              ((o) {
                if (format.isNotBlank) {
                  return '$o'.tryToNumFormatted(format!, locale);
                }
                return '$o'.tryToNum();
              }),
        ) ??
        defaultValue;
  }

  static int toInt(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    int? defaultValue,
    ElementConverter<int>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<int>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: converter ??
          ((o) {
            if (format.isNotBlank) return '$o'.toIntFormatted(format!, locale);
            if (o is num) return o.toInt();
            return '$o'.toInt();
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toInt',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          format: format,
          locale: locale,
          defaultValue: defaultValue,
          converter: converter,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static int? tryToInt(
    dynamic object, {
    dynamic mapKey,
    String? format,
    String? locale,
    int? listIndex,
    int? defaultValue,
    ElementConverter<int>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<int?>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: converter ??
              ((o) {
                if (format.isNotBlank) {
                  return '$o'.tryToIntFormatted(format!, locale);
                }
                if (o is num) return o.toInt();
                return '$o'.tryToInt();
              }),
        ) ??
        defaultValue;
  }

  static BigInt toBigInt(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    BigInt? defaultValue,
    ElementConverter<BigInt>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<BigInt>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: converter ??
          ((o) {
            if (o is num) return BigInt.from(o);
            return BigInt.parse('$o');
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toBigInt',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          defaultValue: defaultValue,
          converter: converter,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static BigInt? tryToBigInt(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    BigInt? defaultValue,
    ElementConverter<BigInt>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<BigInt?>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: converter ??
              ((o) {
                if (o is num) return BigInt.from(o);
                return BigInt.tryParse('$o');
              }),
        ) ??
        defaultValue;
  }

  static double toDouble(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    double? defaultValue,
    ElementConverter<double>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<double>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: converter ??
          ((o) {
            if (format.isNotBlank) {
              return '$o'.toDoubleFormatted(format!, locale);
            }
            if (o is num) return o.toDouble();
            return '$o'.toDouble();
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toDouble',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          format: format,
          locale: locale,
          defaultValue: defaultValue,
          converter: converter,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static double? tryToDouble(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    double? defaultValue,
    ElementConverter<double>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<double?>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: converter ??
              ((o) {
                if (format.isNotBlank) {
                  return '$o'.tryToDoubleFormatted(format!, locale);
                }
                if (o is num) return o.toDouble();
                return '$o'.tryToDouble();
              }),
        ) ??
        defaultValue;
  }

  static bool toBool(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    bool? defaultValue,
    ElementConverter<bool>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<bool?>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: converter ?? ((o) => (o as Object?).asBool),
    );
    return data ?? defaultValue ?? false;
  }

  static bool? tryToBool(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    bool? defaultValue,
    ElementConverter<bool>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<bool?>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: converter ?? ((o) => (o as Object?).asBool),
        ) ??
        defaultValue;
  }

  static DateTime toDateTime(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
    DateTime? defaultValue,
    ElementConverter<DateTime>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<DateTime>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: converter ??
          ((o) {
            if (o is num) {
              // treat as ms or s since epoch
              final v = o.toInt();
              final dt = v > 1000000000000 ?
                  DateTime.fromMillisecondsSinceEpoch(v, isUtc: utc) :
                  DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: utc);
              return utc ? dt.toUtc() : dt.toLocal();
            }
            if (format != null) {
              return '$o'.toDateFormatted(format, locale, utc: utc);
            }
            if (autoDetectFormat) {
              return '$o'.toDateAutoFormat(
                locale: locale,
                useCurrentLocale: useCurrentLocale,
                utc: utc,
              );
            }
            return '$o'.toDateTime();
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toDateTime',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          format: format,
          locale: locale,
          autoDetectFormat: autoDetectFormat,
          useCurrentLocale: useCurrentLocale,
          utc: utc,
          defaultValue: defaultValue,
          converter: converter,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static DateTime? tryToDateTime(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
    DateTime? defaultValue,
    ElementConverter<DateTime>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<DateTime?>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: converter ??
              ((o) {
                if (o is num) {
                  final v = o.toInt();
                  final dt = v > 1000000000000 ?
                      DateTime.fromMillisecondsSinceEpoch(v, isUtc: utc) :
                      DateTime.fromMillisecondsSinceEpoch(v * 1000, isUtc: utc);
                  return utc ? dt.toUtc() : dt.toLocal();
                }
                if (format != null) {
                  return '$o'.tryToDateFormatted(format, locale, utc: utc);
                }
                if (autoDetectFormat) {
                  return '$o'.tryToDateAutoFormat(
                    locale: locale,
                    useCurrentLocale: useCurrentLocale,
                    utc: utc,
                  );
                }
                return '$o'.tryToDateTime();
              }),
        ) ??
        defaultValue;
  }

  static Uri toUri(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    Uri? defaultValue,
    ElementConverter<Uri>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<Uri>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: converter ??
          ((o) {
            final s = o.toString();
            if (s.isValidPhoneNumber) return s.toPhoneUri;
            if (s.isEmailAddress) return s.toMailUri;
            return s.toUri;
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toUri',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          defaultValue: defaultValue,
          converter: converter,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static Uri? tryToUri(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    Uri? defaultValue,
    ElementConverter<Uri>? converter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<Uri?>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: converter ??
              ((o) {
                final s = o.toString();
                if (s.isValidPhoneNumber) return s.toPhoneUri;
                if (s.isEmailAddress) return s.toMailUri;
                return s.toUri;
              }),
        ) ??
        defaultValue;
  }

  // Enums -------------------------------------------------------------

  static T toEnum<T extends Enum>(
    dynamic object, {
    required T Function(dynamic) parser,
    dynamic mapKey,
    int? listIndex,
    T? defaultValue,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<T>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: parser,
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toEnum<$T>',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          defaultValue: defaultValue,
          converter: parser,
          targetType: T,
          debugInfo: {
            ...?debugInfo,
            'reason': 'enum parse failed',
            'enumType': T.toString(),
          },
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static T? tryToEnum<T extends Enum>(
    dynamic object, {
    required T Function(dynamic) parser,
    dynamic mapKey,
    int? listIndex,
    T? defaultValue,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<T?>(
          object,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: parser,
        ) ??
        defaultValue;
  }

  // Collections --------------------------------------------------------

  static Map<K, V> toMap<K, V>(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    Map<K, V>? defaultValue,
    ElementConverter<K>? keyConverter,
    ElementConverter<V>? valueConverter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<Map<K, V>>(
      object,
      decodeInput: true,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: (o) {
        if (o is Map && o.isEmpty) return <K, V>{};
        if (o is Map<K, V>) return o;
        return (o as Map).map(
          (key, value) => MapEntry(
            keyConverter?.call(key) ?? key as K,
            valueConverter?.call(value) ?? value as V,
          ),
        );
      },
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toMap<$K, $V>',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          defaultValue: defaultValue,
          converter:
              keyConverter != null || valueConverter != null ? 'custom' : null,
          targetType: Map<K, V>,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static Map<K, V>? tryToMap<K, V>(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    Map<K, V>? defaultValue,
    ElementConverter<K>? keyConverter,
    ElementConverter<V>? valueConverter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<Map<K, V>?>(
          object,
          decodeInput: true,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: (o) {
            if (o is Map && o.isEmpty) return <K, V>{};
            if (o is Map<K, V>?) return o;
            return (o as Map).map(
              (key, value) => MapEntry(
                keyConverter?.call(key) ?? key as K,
                valueConverter?.call(value) ?? value as V,
              ),
            );
          },
        ) ??
        defaultValue;
  }

  static Set<T> toSet<T>(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    Set<T>? defaultValue,
    ElementConverter<T>? elementConverter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<Set<T>>(
      object,
      decodeInput: true,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: (o) {
        if (o is Iterable && o.isEmpty) return <T>{};
        if (o is Set<T>) return o;
        if (o is T) return <T>{o};
        if (o is Map<dynamic, T>) return o.values.toSet();
        return (o as Iterable).map(
          (tmp) => elementConverter != null ? elementConverter(tmp) : (tmp is T ? tmp : toType<T>(tmp)),
        ).toSet();
      },
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toSet<$T>',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          defaultValue: defaultValue,
          converter: elementConverter,
          targetType: Set<T>,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static Set<T>? tryToSet<T>(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    Set<T>? defaultValue,
    ElementConverter<T>? elementConverter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<Set<T>?>(
          object,
          decodeInput: true,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: (o) {
            if (o is Iterable && o.isEmpty) return <T>{};
            if (o is Set<T>?) return o;
            if (o is T) return <T>{o};
            if (o is Map<dynamic, T>) return o.values.toSet();
            return (o as Iterable).map(
              (tmp) => elementConverter != null ? elementConverter(tmp) : (tmp is T ? tmp : toType<T>(tmp)),
            ).toSet();
          },
        ) ??
        defaultValue;
  }

  static List<T> toList<T>(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    List<T>? defaultValue,
    ElementConverter<T>? elementConverter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<List<T>>(
      object,
      decodeInput: true,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: (o) {
        if (o is Iterable && o.isEmpty) return <T>[];
        if (o is List<T>) return o;
        if (o is T) return <T>[o];
        if (o is Set<T>) return o.toList();
        if (o is Map<dynamic, T>) return o.values.toList();
        if (o is Iterable) {
          return o.map(
            (tmp) => elementConverter != null ? elementConverter(tmp) : (tmp is T ? tmp : toType<T>(tmp)),
          ).toList();
        }
        // Single value fallback: convert to T and wrap
        final single = toType<T>(o);
        return <T>[single];
      },
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ConversionException.nullObject(
        context: buildContext(
          method: 'toList<$T>',
          object: object,
          mapKey: mapKey,
          listIndex: listIndex,
          defaultValue: defaultValue,
          converter: elementConverter,
          targetType: List<T>,
          debugInfo: debugInfo,
        ),
        stackTrace: StackTrace.current,
      );
    }
    return data;
  }

  static List<T>? tryToList<T>(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    List<T>? defaultValue,
    ElementConverter<T>? elementConverter,
    Map<String, dynamic>? debugInfo,
  }) {
    return _convertObject<List<T>?>(
          object,
          decodeInput: true,
          mapKey: mapKey,
          listIndex: listIndex,
          converter: (o) {
            if (o is Iterable && o.isEmpty) return <T>[];
            if (o is List<T>?) return o;
            if (o is T) return <T>[o];
            if (o is Set<T>) return o.toList();
            if (o is Map<dynamic, T>) return o.values.toList();
            if (o is Iterable) {
              return o.map(
                (element) => elementConverter != null ? elementConverter(element) : (element is T ? element : toType<T>(element)),
              ).toList();
            }
            return null;
          },
        ) ??
        defaultValue;
  }

  // Top-level generic routing ----------------------------------------

  static T toType<T>(dynamic object) {
    if (object is T) return object;
    if (object == null) {
      throw ConversionException.nullObject(
        context: {
          'method': 'toType<$T>',
          'object': object,
          'objectType': 'null',
          'targetType': '$T',
        },
        stackTrace: StackTrace.current,
      );
    }
    try {
      if (T == bool) return ConvertObjectImpl.toBool(object) as T;
      if (T == int) return ConvertObjectImpl.toInt(object) as T;
      if (T == double) return ConvertObjectImpl.toDouble(object) as T;
      if (T == num) return ConvertObjectImpl.toNum(object) as T;
      if (T == BigInt) return ConvertObjectImpl.toBigInt(object) as T;
      if (T == String) return ConvertObjectImpl.toText(object) as T;
      if (T == DateTime) return ConvertObjectImpl.toDateTime(object) as T;
      if (T == Uri) return ConvertObjectImpl.toUri(object) as T;
    } catch (e, s) {
      throw ConversionException(
        error: e,
        context: {
          'method': 'toType<$T>',
          'object': object,
          'objectType': object.runtimeType.toString(),
          'targetType': '$T',
        },
        stackTrace: s,
      );
    }
    try {
      return object as T;
    } catch (_) {}
    throw ConversionException(
      error:
          'Unsupported type detected. Please ensure that the type you are attempting to convert to is either a primitive type or a valid data type: $T.',
      context: {
        'method': 'toType<$T>',
        'object': object,
        'objectType': object.runtimeType.toString(),
        'targetType': '$T',
      },
      stackTrace: StackTrace.current,
    );
  }

  static T? tryToType<T>(dynamic object) {
    if (object is T) return object;
    if (object == null) return null;
    try {
      if (T == bool) return ConvertObjectImpl.tryToBool(object) as T?;
      if (T == int) return ConvertObjectImpl.tryToInt(object) as T?;
      if (T == BigInt) return ConvertObjectImpl.tryToBigInt(object) as T?;
      if (T == double) return ConvertObjectImpl.tryToDouble(object) as T?;
      if (T == num) return ConvertObjectImpl.tryToNum(object) as T?;
      if (T == String) return ConvertObjectImpl.tryToText(object) as T?;
      if (T == DateTime) return ConvertObjectImpl.tryToDateTime(object) as T?;
      if (T == Uri) return ConvertObjectImpl.tryToUri(object) as T?;
    } catch (e, s) {
      throw ConversionException(
        error: e,
        context: {
          'method': 'tryToType<$T>',
          'object': object,
          'objectType': object.runtimeType.toString(),
          'targetType': '$T',
        },
        stackTrace: s,
      );
    }
    try {
      return object as T;
    } catch (_) {}
    throw ConversionException(
      error: 'Unsupported type: $T',
      context: {
        'method': 'tryToType<$T>',
        'object': object,
        'objectType': object.runtimeType.toString(),
        'targetType': '$T',
      },
      stackTrace: StackTrace.current,
    );
  }
}
