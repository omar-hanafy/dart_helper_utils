import 'dart:developer';

import 'package:dart_helper_utils/src/src.dart';
import 'package:meta/meta.dart';

/// A callback function that converts an element to a specific type.
typedef ElementConverter<T> = T Function(Object? element);

/// A utility class for converting objects to different types.
abstract class ConvertObject {
  /// Builds standardized argument maps for ParsingException.
  ///
  /// Collects all arguments passed to conversion methods for comprehensive
  /// error reporting. Merges standard parameters with optional debug info.
  ///
  /// The [debugInfo] parameter allows passing additional context without
  /// breaking the API. Extension methods can use this to provide context
  /// like which map key or list index was being accessed.
  ///
  /// Example:
  /// ```dart
  /// // From a Map extension method:
  /// ConvertObject.toInt(
  ///   someValue,
  ///   debugInfo: {'key': 'userId', 'altKeys': ['user_id', 'uid']},
  /// );
  /// ```
  @visibleForTesting
  static Map<String, dynamic> buildParsingInfo({
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

    // Add optional parameters only if they're provided
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

    // Merge any additional debug info
    if (debugInfo != null && debugInfo.isNotEmpty) {
      args.addAll(debugInfo);
    }

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
    if (listIndex != null && object is List<dynamic>) {
      return _convertObject(object[listIndex], converter: converter);
    }
    if (mapKey != null && object is Map<dynamic, dynamic>) {
      return _convertObject(object[mapKey], converter: converter);
    }
    if (object is T) return object;
    try {
      return object as T;
    } catch (_) {}
    if (decodeInput && object is String) {
      return _convertObject(
        object.tryDecode(),
        mapKey: mapKey,
        listIndex: listIndex,
        converter: converter,
      );
    }

    try {
      return converter?.call(object);
    } catch (e, s) {
      log('Unsupported object type ($T): $e', stackTrace: s, error: e);
      return null;
    }
  }

  /// Converts any object to a string if the object is not `null`.
  ///
  /// - Converts various object types to their string representation.
  /// - If the object is `null`, throws a [ParsingException] with a `nullObject` error.
  /// - If the conversion to string fails, throws a [ParsingException].
  ///
  /// [object] The object to be converted to a string.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a string if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails or the object is `null`.
  @optionalTypeArgs
  static String toString1(
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
      converter: converter ?? ((object) => object.toString()),
    );

    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
          method: 'toString1',
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

  /// Converts any object to a string, or returns `null` if the object is `null`.
  ///
  /// - Converts various object types to their string representation.
  /// - If the conversion to string fails, logs an error and returns `null`.
  ///
  /// [object] The object to be converted to a string.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a string if conversion is successful, otherwise `null`.
  @optionalTypeArgs
  static String? tryToString(
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
          converter: converter ?? ((object) => object.toString()),
        ) ??
        defaultValue;
  }

  /// Converts an object to a [num].
  ///
  /// - Converts numeric types and strings that represent valid numbers to [num].
  /// - If the object is `null`, throws a [ParsingException] with a `nullObject` error.
  /// - If the conversion to [num] fails, throws a [ParsingException].
  ///
  /// [object] The object to be converted to a [num].
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [num] if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails or the object is `null`.
  @optionalTypeArgs
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
          ((object) {
            if (format.isNotBlank) {
              return '$object'.toNumFormatted(format, locale);
            }
            return '$object'.toNum;
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to a [num], or returns `null` if the object is `null` or conversion fails.
  ///
  /// - Converts numeric types and strings that represent valid numbers to [num].
  /// - If the conversion to [num] fails (e.g., non-numeric string), logs an error and returns `null`.
  ///
  /// [object] The object to be converted to a [num].
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [num] if conversion is successful, otherwise `null`.
  @optionalTypeArgs
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
          ((object) {
            if (format.isNotBlank) {
              return '$object'.toNumFormatted(format, locale);
            }
            return '$object'.tryToNum;
          }),
    );
  }

  /// Converts an object to an [int].
  ///
  /// - Converts numeric types and strings that represent valid integers to [int].
  /// - If the conversion to [int] fails (e.g., non-integer string), throws a [ParsingException].
  ///
  /// [object] The object to be converted to an [int].
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns an [int] if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails.
  @optionalTypeArgs
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
          ((object) {
            if (format.isNotBlank) {
              return '$object'.toIntFormatted(format, locale);
            }
            if (object is num) return object.toInt();
            return '$object'.toInt;
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to an [int], or returns `null` if the object is `null` or conversion fails.
  ///
  /// - Converts numeric types and strings that represent valid integers to [int].
  /// - If the conversion to [int] fails (e.g., non-integer string), logs an error and returns `null`.
  ///
  /// [object] The object to be converted to an [int].
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns an [int] if conversion is successful, otherwise `null`.
  @optionalTypeArgs
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
              ((object) {
                if (format.isNotBlank) {
                  return '$object'.tryToIntFormatted(format, locale);
                }
                if (object is num) return object.toInt();
                return '$object'.tryToInt;
              }),
        ) ??
        defaultValue;
  }

  /// Converts an object to a [BigInt].
  ///
  /// - Converts numeric types and strings that represent valid large integers to [BigInt].
  /// - IMPORTANT: BigInt operations can be computationally expensive, especially for very large integers.
  ///   Use BigInt only when necessary, and be mindful of performance implications.
  /// - If the conversion to [BigInt] fails or the object is `null`, throws a [ParsingException].
  ///
  /// [object] The object to be converted to a [BigInt].
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [BigInt] if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails or the object is `null`.
  @optionalTypeArgs
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
          ((object) {
            if (object is num) return BigInt.from(object);
            return BigInt.parse('$object');
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to a [BigInt], or returns `null` if the object is `null` or conversion fails.
  ///
  /// - Converts numeric types and strings that represent valid large integers to [BigInt].
  /// - IMPORTANT: BigInt operations can be computationally expensive, especially for very large integers.
  ///   Use BigInt only when necessary, and be mindful of performance implications.
  /// - If the conversion to [BigInt] fails (e.g., non-numeric string), logs an error and returns `null`.
  ///
  /// [object] The object to be converted to a [BigInt].
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [BigInt] if conversion is successful, otherwise `null`.
  @optionalTypeArgs
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
              ((object) {
                if (object is num) return BigInt.from(object);
                return BigInt.tryParse('$object');
              }),
        ) ??
        defaultValue;
  }

  /// Converts an object to a [double].
  ///
  /// - Converts numeric types and strings that represent valid numbers to [double].
  /// - If the conversion to [double] fails (e.g., non-numeric string), throws a [ParsingException].
  ///
  /// [object] The object to be converted to a [double].
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [double] if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails.
  @optionalTypeArgs
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
          ((object) {
            if (format.isNotBlank) {
              return '$object'.toDoubleFormatted(format, locale);
            }
            if (object is num) return object.toDouble();
            return '$object'.toDouble;
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to a [double], or returns `null` if the object is `null` or conversion fails.
  ///
  /// - Converts numeric types and strings that represent valid numbers to [double].
  /// - If the conversion to [double] fails (e.g., non-numeric string), logs an error and returns `null`.
  ///
  /// [object] The object to be converted to a [double].
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [double] if conversion is successful, otherwise `null`.
  @optionalTypeArgs
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
              ((object) {
                if (format.isNotBlank) {
                  return '$object'.tryToDoubleFormatted(format, locale);
                }
                if (object is num) return object.toDouble();
                return '$object'.tryToDouble;
              }),
        ) ??
        defaultValue;
  }

  /// Converts an object to a `bool`.
  ///
  /// - Returns `true` if the object is a `bool` and equal to `true`.
  /// - Returns `true` if the object is a `String` and equal to 'yes' or 'true' (case-insensitive).
  /// - Returns `true` if the object is a `num`, `int`, or `double` and is larger than zero.
  /// - Returns `false` for other types or if the object is `null`.
  ///
  /// [object] The object to be converted to a `bool`.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a `bool`, with a default value of `false`.
  @optionalTypeArgs
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
      converter: converter ?? ((object) => (object as Object?).asBool),
    );
    return data ?? defaultValue ?? false;
  }

  /// Attempts to convert an object to a `bool`, or returns `null` if the object is `null` or conversion is not applicable.
  ///
  /// - Returns `true` if the object is a `bool` and equal to `true`.
  /// - Returns `true` if the object is a `String` and equal to 'yes' or 'true' (case-insensitive).
  /// - Returns `null` for other types or if the object is `null`.
  ///
  /// [object] The object to be converted to a `bool`.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a `bool` if conversion is applicable, otherwise `null`.
  @optionalTypeArgs
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
          converter: converter ?? ((object) => (object as Object?).asBool),
        ) ??
        defaultValue;
  }

  /// Converts an object to a [DateTime].
  ///
  /// - If the object is a string representing a valid DateTime, it converts it to a [DateTime] object.
  /// - If the object is already a [DateTime], it is returned as-is.
  /// - If the object is `null`, throws a [ParsingException] with a `nullObject` error.
  /// - If the conversion to [DateTime] fails (e.g., invalid format), throws a [ParsingException].
  ///
  /// [object] The object to be converted to a [DateTime].
  /// [format] (Optional) Specify the format if the object is a string representing a DateTime.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [DateTime] if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails or the object is `null`.
  @optionalTypeArgs
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
          ((object) {
            if (format != null) {
              return '$object'.toDateFormatted(format, locale, utc);
            }
            if (autoDetectFormat) {
              return '$object'.toDateAutoFormat(
                locale: locale,
                useCurrentLocale: useCurrentLocale,
                utc: utc,
              );
            }
            return '$object'.toDateTime;
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to a [DateTime], or returns `null` if the object is `null` or conversion fails.
  ///
  /// - If the object is a string representing a valid DateTime, it converts it to a [DateTime] object.
  /// - If the object is already a [DateTime], it is returned as-is.
  /// - If the conversion to [DateTime] fails (e.g., invalid format), logs an error and returns `null`.
  ///
  /// [object] The object to be converted to a [DateTime].
  /// [format] (Optional) Specify the format if the object is a string representing a DateTime.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [DateTime] if conversion is successful, otherwise `null`.
  @optionalTypeArgs
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
              ((object) {
                if (format != null) {
                  return '$object'.tryToDateFormatted(format, locale, utc);
                }
                if (autoDetectFormat) {
                  return '$object'.tryToDateAutoFormat(
                    locale: locale,
                    useCurrentLocale: useCurrentLocale,
                    utc: utc,
                  );
                }
                return '$object'.tryToDateTime;
              }),
        ) ??
        defaultValue;
  }

  /// Converts an object to a [Uri].
  ///
  /// - If the object is a string representing a valid URI, it converts it to a [Uri] object.
  /// - If the object is `null`, throws a [ParsingException] with a `nullObject` error.
  /// - If the conversion to [Uri] fails (e.g., if the string is not a valid URI), throws a [ParsingException].
  ///
  /// [object] The object to be converted to a [Uri]. Expected to be a string representing a URI.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [Uri] if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails or the object is null.
  @optionalTypeArgs
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
          ((object) {
            final ob = object.toString();
            if (ob.isValidPhoneNumber) return ob.toPhoneUri;
            return ob.toUri;
          }),
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to a [Uri], or returns `null` if the object is `null` or conversion fails.
  ///
  /// - If the object is a string representing a valid URI, it converts it to a [Uri] object.
  /// - If the conversion to [Uri] fails (e.g., if the string is not a valid URI), it logs an error and returns `null`.
  /// - If the object is null, returns null.
  ///
  /// [object] The object to be converted to a [Uri]. Expected to be a string representing a URI.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [Uri] if conversion is successful, otherwise null.
  @optionalTypeArgs
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
              ((object) {
                final ob = object.toString();
                if (ob.isValidPhoneNumber) return ob.toPhoneUri;
                return ob.toUri;
              }),
        ) ??
        defaultValue;
  }

  /// Converts an object to a [Map] with keys of type `K` and values of type `V`.
  ///
  /// - If the object is already a [Map] with the correct key and value types, it is returned as-is.
  /// - If the object is an empty [Map], an empty [Map] is returned.
  /// - If the object is null, throws a [ParsingException] with a `nullObject` error.
  /// - If the object cannot be converted to a [Map] with the specified types, throws a [ParsingException].
  ///
  /// [object] The object to be converted to a [Map] with keys of type `K` and values of type `V`.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [Map<K, V>] if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails.
  @optionalTypeArgs
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
      converter: (object) {
        if (object is Map && object.isEmpty) return <K, V>{};
        if (object is Map<K, V>) return object;

        return (object as Map).map(
          (key, value) {
            return MapEntry(
              keyConverter?.call(key) ?? key as K,
              valueConverter?.call(value) ?? value as V,
            );
          },
        );
      },
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to a [Map] with keys of type `K` and values of type `V`.
  ///
  /// - If the object is already a [Map] with the correct key and value types, it is returned as-is.
  /// - If the object is an empty [Map], an empty [Map] is returned.
  /// - If the object is null, returns null.
  /// - If the object cannot be converted to a [Map] with the specified types, logs an error and returns null.
  ///
  /// [object] The object to be converted to a [Map] with keys of type `K` and values of type `V`.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [Map<K, V>] if conversion is successful, otherwise null.
  @optionalTypeArgs
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
          converter: (object) {
            if (object is Map && object.isEmpty) return <K, V>{};
            if (object is Map<K, V>?) return object;

            return (object as Map).map(
              (key, value) {
                return MapEntry(
                  keyConverter?.call(key) ?? key as K,
                  valueConverter?.call(value) ?? value as V,
                );
              },
            );
          },
        ) ??
        defaultValue;
  }

  /// Converts an object to a [Set] of type `T`.
  ///
  /// - If the object is already a [Set] of type `T`, it is returned as-is.
  /// - If the object is an [Iterable], it converts it to a [Set] of type `T`.
  /// - If the object is null, throws a [ParsingException] with a `nullObject` error.
  /// - If the object cannot be converted to a [Set] of type `T`, throws a [ParsingException].
  ///
  /// [object] The object to be converted to a [Set] of type `T`.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [Set] of type `T` if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails.
  @optionalTypeArgs
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
      converter: (object) {
        if (object is Iterable && object.isEmpty) return <T>{};
        if (object is Set<T>) return object;
        if (object is T) return <T>{object};
        if (object is Map<dynamic, T>) return object.values.toSet();
        return (object as Iterable).map(
          (tmp) {
            if (elementConverter != null) return elementConverter(tmp);
            return tmp is T ? tmp : toType<T>(tmp);
          },
        ).toSet();
      },
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to a [Set] of type `T`, or returns null if conversion is not possible.
  ///
  /// - If the object is already a [Set] of type `T`, it is returned as-is.
  /// - If the object is an [Iterable], it converts it to a [Set] of type `T`.
  /// - If the object is null, returns null.
  /// - If the object cannot be converted to a [Set] of type `T`, logs an error and returns null.
  ///
  /// [object] The object to be converted to a [Set] of type `T`.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [Set] of type `T` if conversion is successful, otherwise null.
  @optionalTypeArgs
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
          converter: (object) {
            if (object is Iterable && object.isEmpty) return <T>{};
            if (object is Set<T>?) return object;
            if (object is T) return <T>{object};
            if (object is Map<dynamic, T>) return object.values.toSet();
            return (object as Iterable).map(
              (tmp) {
                if (elementConverter != null) return elementConverter(tmp);
                return tmp is T ? tmp : toType<T>(tmp);
              },
            ).toSet();
          },
        ) ??
        defaultValue;
  }

  /// Converts an object to a [List] of type `T`.
  ///
  /// - If the object is already a [List] of type `T`, it is returned as-is.
  /// - If the object is a single instance of type `T`, it returns a [List] containing that object.
  /// - If the object is a [Map], and `mapKey` is provided, it returns a [List] of the values for that key across all map entries.
  /// - If the object is a [Map] with values of type `T` and no `mapKey` is provided, it returns a [List] of all the map's values.
  /// - If the object is a [List], and `listIndex` is provided, it attempts to return a [List] containing the element at that index from each list in the original list.
  /// - If the object cannot be converted to a [List] of type `T`, a [ParsingException] is thrown.
  ///
  /// [object] The object to be converted to a [List] of type `T`.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [List] of type `T` if conversion is successful.
  /// Throws a [ParsingException] if the conversion fails.
  @optionalTypeArgs
  static List<T> toList<T>(
    dynamic object, {
    dynamic mapKey,
    int? listIndex,
    List<T>? defaultValue,
    ElementConverter<T>? elementConverter,
    Map<String, dynamic>? debugInfo,
  }) {
    final data = _convertObject<List<T>?>(
      object,
      decodeInput: true,
      mapKey: mapKey,
      listIndex: listIndex,
      converter: (object) {
        if (object is Iterable && object.isEmpty) return <T>[];
        if (object is List<T>) return object;
        if (object is T) return <T>[object];
        if (object is Map<dynamic, T>) return object.values.toList();

        return (object as Iterable).map(
          (tmp) {
            if (elementConverter != null) return elementConverter(tmp);
            return tmp is T ? tmp : toType<T>(tmp);
          },
        ).toList();
      },
    );
    if (data == null) {
      if (defaultValue != null) return defaultValue;
      throw ParsingException.nullObject(
        parsingInfo: buildParsingInfo(
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

  /// Attempts to convert an object to a [List] of type `T`, or returns `null` if conversion is not possible.
  ///
  /// - If the object is already a [List] of type `T`, it is returned as-is.
  /// - If the object is a single instance of type `T`, it returns a [List] containing that object.
  /// - If the object is a [Map], and `mapKey` is provided, it returns a [List] of the values for that key across all map entries.
  /// - If the object is a [Map] with values of type `T` and no `mapKey` is provided, it returns a [List] of all the map's values.
  /// - If the object is a [List], and `listIndex` is provided, it attempts to return a [List] containing the element at that index from each list in the original list.
  /// - If the object cannot be converted to a [List] of type `T`, an error is logged, and `null` is returned.
  ///
  /// [object] The object to be converted to a [List] of type `T`.
  /// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
  /// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
  ///
  /// Returns a [List] of type `T` if conversion is successful, otherwise `null`.
  @optionalTypeArgs
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
          converter: (object) {
            if (object is Iterable && object.isEmpty) return <T>[];
            if (object is List<T>?) return object;
            if (object is T) return <T>[object];
            if (object is Map<dynamic, T>) return object.values.toList();

            return (object as Iterable).map((element) {
              if (elementConverter != null) return elementConverter(element);
              return element is T ? element : toType<T>(element);
            }).toList();
          },
        ) ??
        defaultValue;
  }
}

/// Extension method that uses [ConvertObject] on Iterables
@optionalTypeArgs
extension ConvertObjectIterableEx<E> on Iterable<E> {
  /// uses the [toString] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [String].
  String getString(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? defaultValue,
    ElementConverter<String>? converter,
  }) =>
      ConvertObject.toString1(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        converter: converter,
        debugInfo: {'index': index},
      );

  /// uses the [toNum] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [num].
  num getNum(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    num? defaultValue,
    ElementConverter<num>? converter,
  }) =>
      ConvertObject.toNum(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {'index': index},
      );

  /// uses the [toInt] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [int].
  int getInt(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    int? defaultValue,
    ElementConverter<int>? converter,
  }) =>
      ConvertObject.toInt(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {'index': index},
      );

  /// uses the [toBigInt] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [BigInt].
  BigInt getBigInt(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    BigInt? defaultValue,
    ElementConverter<BigInt>? converter,
  }) =>
      ConvertObject.toBigInt(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        converter: converter,
        debugInfo: {'index': index},
      );

  /// uses the [toDouble] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [double].
  double getDouble(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    double? defaultValue,
    ElementConverter<double>? converter,
  }) =>
      ConvertObject.toDouble(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {'index': index},
      );

  /// uses the [toBool] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [bool].
  bool getBool(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    bool? defaultValue,
    ElementConverter<bool>? converter,
  }) =>
      ConvertObject.toBool(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        converter: converter,
        debugInfo: {'index': index},
      );

  /// uses the [toDateTime] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [DateTime].
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
      ConvertObject.toDateTime(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
        converter: converter,
        debugInfo: {'index': index},
      );

  /// uses the [toUri] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [Uri].
  Uri getUri(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    Uri? defaultValue,
    ElementConverter<Uri>? converter,
  }) =>
      ConvertObject.toUri(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        converter: converter,
        debugInfo: {'index': index},
      );

  /// uses the [toMap] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [Map].
  Map<K2, V2> getMap<K2, V2>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    Map<K2, V2>? defaultValue,
    ElementConverter<K2>? keyConverter,
    ElementConverter<V2>? valueConverter,
  }) =>
      ConvertObject.toMap(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        keyConverter: keyConverter,
        valueConverter: valueConverter,
        debugInfo: {'index': index},
      );

  /// uses the [toSet] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [Set].
  Set<T> getSet<T>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    Set<T>? defaultValue,
    ElementConverter<T>? elementConverter,
  }) =>
      ConvertObject.toSet(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        elementConverter: elementConverter,
        debugInfo: {'index': index},
      );

  /// uses the [toList] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [index] in that Iterable to [List].
  List<T> getList<T>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    List<T>? defaultValue,
    ElementConverter<T>? elementConverter,
  }) =>
      ConvertObject.toList(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        elementConverter: elementConverter,
        debugInfo: {'index': index},
      );
}

/// Extension method that uses [ConvertObject] on Nullable Iterables
@optionalTypeArgs
extension ConvertObjectIterableNEx<E> on Iterable<E>? {
  /// Helper function to get the element from the list using the provided primary index or alternative indexes.
  E? firstElementForIndices(
    int index, {
    List<int>? alternativeIndices,
  }) {
    if (this == null || index < 0) return null;

    try {
      return this!.elementAt(index);
    } catch (_) {}

    if (alternativeIndices != null) {
      for (final altIndex in alternativeIndices) {
        try {
          return this!.elementAt(altIndex);
        } catch (_) {}
      }
    }

    return null;
  }

  /// uses the [tryToString] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [String] or return null.
  @optionalTypeArgs
  String? tryGetString(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    String? defaultValue,
    ElementConverter<String>? converter,
  }) =>
      ConvertObject.tryToString(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        converter: converter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToNum] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [num] or return null.
  @optionalTypeArgs
  num? tryGetNum(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    num? defaultValue,
    ElementConverter<num>? converter,
  }) =>
      ConvertObject.tryToNum(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [int] or return null.
  @optionalTypeArgs
  int? tryGetInt(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    int? defaultValue,
    ElementConverter<int>? converter,
  }) =>
      ConvertObject.tryToInt(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [BigInt] or return null.
  @optionalTypeArgs
  BigInt? tryGetBigInt(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    BigInt? defaultValue,
    ElementConverter<BigInt>? converter,
  }) =>
      ConvertObject.tryToBigInt(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        converter: converter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [double] or return null.
  @optionalTypeArgs
  double? tryGetDouble(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    double? defaultValue,
    ElementConverter<double>? converter,
  }) =>
      ConvertObject.tryToDouble(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToBool] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [bool] or return null.
  @optionalTypeArgs
  bool? tryGetBool(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    bool? defaultValue,
    ElementConverter<bool>? converter,
  }) =>
      ConvertObject.tryToBool(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        converter: converter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToDateTime] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [DateTime] or return null.
  @optionalTypeArgs
  DateTime? tryGetDateTime(
    int index, {
    List<int>? altIndexes,
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
      ConvertObject.tryToDateTime(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
        converter: converter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToUri] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Uri] or return null.
  @optionalTypeArgs
  Uri? tryGetUri(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    Uri? defaultValue,
    ElementConverter<Uri>? converter,
  }) =>
      ConvertObject.tryToUri(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        converter: converter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToMap] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Map] or return null.
  @optionalTypeArgs
  Map<K2, V2>? tryGetMap<K2, V2>(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    Map<K2, V2>? defaultValue,
    ElementConverter<K2>? keyConverter,
    ElementConverter<V2>? valueConverter,
  }) =>
      ConvertObject.tryToMap(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        keyConverter: keyConverter,
        valueConverter: valueConverter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToSet] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Set] or return null.
  @optionalTypeArgs
  Set<T>? tryGetSet<T>(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    Set<T>? defaultValue,
    ElementConverter<T>? elementConverter,
  }) =>
      ConvertObject.tryToSet(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        elementConverter: elementConverter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );

  /// uses the [tryToList] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [List] or return null.
  @optionalTypeArgs
  List<T>? tryGetList<T>(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    List<T>? defaultValue,
    ElementConverter<T>? elementConverter,
  }) =>
      ConvertObject.tryToList(
        firstElementForIndices(index, alternativeIndices: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        elementConverter: elementConverter,
        debugInfo: {
          'index': index,
          if (altIndexes != null && altIndexes.isNotEmpty)
            'altIndexes': altIndexes,
        },
      );
}

/// Extension method that uses [ConvertObject] on Nullable Sets
@optionalTypeArgs
extension ConvertObjectSetNEx<E> on Set<E>? {
  /// If a direct conversion fails, it attempts element-wise conversion using `toType`, ensuring
  /// a smooth conversion process without the risk of runtime errors.
  ///
  /// Example usage:
  /// ```dart
  /// Set<dynamic> set = {1, 2, '3'};
  /// Set<int> intSet = set.convertTo<int>(); // Tries to convert all elements to int.
  /// ```
  @optionalTypeArgs
  Set<R> convertTo<R>() => ConvertObject.toSet<R>(this);
}

/// Extension method that uses [ConvertObject] on Nullable List
@optionalTypeArgs
extension ConvertObjectListNEx<E> on List<E>? {
  /// Converts the list to a different type [R] using custom conversion logic.
  ///
  /// Example:
  /// ```dart
  /// List <dynamic> list = [1, 2, '3'];
  /// List <int> intList = list.convertTo<int>();
  /// ```
  List<R> convertTo<R>() => ConvertObject.toList<R>(this);
}

/// Extension method that uses [ConvertObject] on Maps
@optionalTypeArgs
extension ConvertObjectMapEx<K, V> on Map<K, V> {
  /// uses the [toString] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [String].
  String getString(
    K key, {
    dynamic innerKey,
    List<K>? altKeys,
    int? innerListIndex,
    String? defaultValue,
    ElementConverter<String>? converter,
  }) =>
      ConvertObject.toString1(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toNum] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [num].
  num getNum(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    List<K>? altKeys,
    String? locale,
    num? defaultValue,
    ElementConverter<num>? converter,
  }) =>
      ConvertObject.toNum(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toInt] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [int].
  int getInt(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    List<K>? altKeys,
    String? locale,
    int? defaultValue,
    ElementConverter<int>? converter,
  }) =>
      ConvertObject.toInt(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toBigInt] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [BigInt].
  BigInt getBigInt(
    K key, {
    dynamic innerKey,
    List<K>? altKeys,
    int? innerListIndex,
    BigInt? defaultValue,
    ElementConverter<BigInt>? converter,
  }) =>
      ConvertObject.toBigInt(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toDouble] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [double].
  double getDouble(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    List<K>? altKeys,
    String? locale,
    double? defaultValue,
    ElementConverter<double>? converter,
  }) =>
      ConvertObject.toDouble(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toBool] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [bool].
  bool getBool(
    K key, {
    dynamic innerKey,
    List<K>? altKeys,
    int? innerListIndex,
    bool? defaultValue,
    ElementConverter<bool>? converter,
  }) =>
      ConvertObject.toBool(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toDateTime] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [DateTime].
  DateTime getDateTime(
    K key, {
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    List<K>? altKeys,
    bool utc = false,
    DateTime? defaultValue,
    ElementConverter<DateTime>? converter,
  }) =>
      ConvertObject.toDateTime(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toUri] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [Uri].
  Uri getUri(
    K key, {
    dynamic innerKey,
    List<K>? altKeys,
    int? innerListIndex,
    Uri? defaultValue,
    ElementConverter<Uri>? converter,
  }) =>
      ConvertObject.toUri(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toMap] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [Map].
  Map<K2, V2> getMap<K2, V2>(
    K key, {
    dynamic innerKey,
    List<K>? altKeys,
    int? innerListIndex,
    Map<K2, V2>? defaultValue,
    ElementConverter<K2>? keyConverter,
    ElementConverter<V2>? valueConverter,
  }) =>
      ConvertObject.toMap(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        keyConverter: keyConverter,
        valueConverter: valueConverter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toSet] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [Set].
  Set<T> getSet<T>(
    K key, {
    dynamic innerKey,
    List<K>? altKeys,
    int? innerListIndex,
    Set<T>? defaultValue,
    ElementConverter<T>? elementConverter,
  }) =>
      ConvertObject.toSet(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        elementConverter: elementConverter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [toList] defined in the [ConvertObject] class to convert a
  @optionalTypeArgs

  /// specific element by [key] in that Iterable to [List].
  List<T> getList<T>(
    K key, {
    dynamic innerKey,
    List<K>? altKeys,
    int? innerListIndex,
    List<T>? defaultValue,
    ElementConverter<T>? elementConverter,
  }) =>
      ConvertObject.toList(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        elementConverter: elementConverter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// Extracts a value from the map by the given [key] and attempts to
  /// construct an object of type [T] using the provided [fromJson] function.
  T parse<T, K2, V2>(K key, T Function(Map<K2, V2> json) converter) {
    final map = getMap<K2, V2>(key);
    return converter.call(map);
  }
}

/// Extension method that uses [ConvertObject] on nullable Maps
@optionalTypeArgs
extension ConvertObjectMapNEx<K, V> on Map<K, V>? {
  /// Retrieves a value from the map using the provided primary key or alternative keys.
  ///
  /// [key] The primary key to search for.
  /// [alternativeKeys] An optional list of alternative keys to search if the primary key is not found.
  ///
  /// Returns the value associated with the first found key, or null if no key is found.
  V? firstValueForKeys(
    K key, {
    List<K>? alternativeKeys,
  }) {
    final map = this;
    if (map == null) return null;

    // Get the value using primary key
    var value = map[key];

    // If value is not found and alternative keys are provided, search in them
    if (value == null &&
        alternativeKeys != null &&
        alternativeKeys.isNotEmpty) {
      final altKey = alternativeKeys.firstWhereOrNull(map.containsKey);
      if (altKey != null) value = map[altKey];
    }

    return value;
  }

  /// uses the [tryToString] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [String] or return null.
  @optionalTypeArgs
  String? tryGetString(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    String? defaultValue,
    ElementConverter<String>? converter,
  }) =>
      ConvertObject.tryToString(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToNum] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [num] or return null.
  @optionalTypeArgs
  num? tryGetNum(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
    num? defaultValue,
    ElementConverter<num>? converter,
  }) =>
      ConvertObject.tryToNum(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToInt] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [int] or return null.
  @optionalTypeArgs
  int? tryGetInt(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
    int? defaultValue,
    ElementConverter<int>? converter,
  }) =>
      ConvertObject.tryToInt(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [BigInt] or return null.
  @optionalTypeArgs
  BigInt? tryGetBigInt(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    BigInt? defaultValue,
    ElementConverter<BigInt>? converter,
  }) =>
      ConvertObject.tryToBigInt(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [double] or return null.
  @optionalTypeArgs
  double? tryGetDouble(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
    double? defaultValue,
    ElementConverter<double>? converter,
  }) =>
      ConvertObject.tryToDouble(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToBool] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [bool] or return null.
  @optionalTypeArgs
  bool? tryGetBool(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    bool? defaultValue,
    ElementConverter<bool>? converter,
  }) =>
      ConvertObject.tryToBool(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToDateTime] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [DateTime] or return null.
  @optionalTypeArgs
  DateTime? tryGetDateTime(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
    DateTime? defaultValue,
    ElementConverter<DateTime>? converter,
  }) =>
      ConvertObject.tryToDateTime(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToUri] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Uri] or return null.
  @optionalTypeArgs
  Uri? tryGetUri(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    Uri? defaultValue,
    ElementConverter<Uri>? converter,
  }) =>
      ConvertObject.tryToUri(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        converter: converter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToMap] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Map] or return null.
  @optionalTypeArgs
  Map<K2, V2>? tryGetMap<K2, V2>(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    Map<K2, V2>? defaultValue,
    ElementConverter<K2>? keyConverter,
    ElementConverter<V2>? valueConverter,
  }) =>
      ConvertObject.tryToMap(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        keyConverter: keyConverter,
        valueConverter: valueConverter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToSet] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [Set] or return null.
  @optionalTypeArgs
  Set<T>? tryGetSet<T>(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    Set<T>? defaultValue,
    ElementConverter<T>? elementConverter,
  }) =>
      ConvertObject.tryToSet(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        elementConverter: elementConverter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// uses the [tryToList] defined in the [ConvertObject] class to convert a
  /// specific element by [key] in that Iterable to [List] or return null.
  @optionalTypeArgs
  List<T>? tryGetList<T>(
    K key, {
    List<K>? altKeys,
    dynamic innerKey,
    int? innerListIndex,
    List<T>? defaultValue,
    ElementConverter<T>? elementConverter,
  }) =>
      ConvertObject.tryToList(
        firstValueForKeys(key, alternativeKeys: altKeys),
        defaultValue: defaultValue,
        mapKey: innerKey,
        listIndex: innerListIndex,
        elementConverter: elementConverter,
        debugInfo: {
          'key': key,
          if (altKeys != null && altKeys.isNotEmpty) 'altKeys': altKeys,
        },
      );

  /// Tries to extracts a value from the map by the given [key] and attempts to
  /// construct an object of type [T] using the provided [fromJson] function.
  /// returns null if failed or key is not exists or contains null value.
  @optionalTypeArgs
  T? tryParse<T, K2, V2>(K key, T Function(Map<K2, V2> json) converter) {
    if (this == null) return null;
    final map = tryGetMap<K2, V2>(key);
    if (map == null) return null;
    return converter.call(map);
  }
}

/// A pair of Kotlin-inspired `let` helpers for fluent, functional pipelines.
///
/// ## Examples
/// ```dart
/// // Non-nullable:
/// final doubled = '123'.let((s) => int.parse(s) * 2); // 246
///
/// // Null-aware:
/// final wrap = json.tryGetString('wordWrap')
///     ?.let((w) => WordWrap.values.firstWhere(
///           (e) => e.name == w,
///           orElse: () => WordWrap.off,
///         ))                     // returns WordWrap?
///     ?? WordWrap.off;           // provide fallback
/// ```
extension LetExtension<T extends Object> on T {
  /// Executes [block] with `this` as its argument and returns the result.
  ///
  /// Think of it as a lightweight map/transform that works on any object.
  R let<R>(R Function(T it) block) => block(this);
}

/// A null-aware version: the callback only runs when the value isn’t `null`.
extension LetExtensionNullable<T extends Object> on T? {
  /// If `this` is non-null, calls [block] with the non-null value and returns
  /// its result; otherwise returns `null`.
  R? let<R>(R? Function(T? it) block) => this == null ? null : block(this);
}

/// Converts any object to a string if the object is not `null`.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts various object types to their string representation.
/// - If the object is `null`, throws a [ParsingException] with a `nullObject` error.
/// - If the conversion to string fails, throws a [ParsingException].
///
/// [object] The object to be converted to a string.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a string if conversion is successful.
/// Throws a [ParsingException] if the conversion fails or the object is `null`.
@optionalTypeArgs
String toString1(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? defaultValue,
  ElementConverter<String>? converter,
}) =>
    ConvertObject.toString1(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Converts any object to a string, or returns `null` if the object is `null`.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts various object types to their string representation.
/// - If the conversion to string fails, logs an error and returns `null`.
///
/// [object] The object to be converted to a string.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a string if conversion is successful, otherwise `null`.
@optionalTypeArgs
String? tryToString(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? defaultValue,
  ElementConverter<String>? converter,
}) =>
    ConvertObject.tryToString(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Converts an object to a [num].
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts numeric types and strings that represent valid numbers to [num].
/// - If the object is `null`, throws a [ParsingException] with a `nullObject` error.
/// - If the conversion to [num] fails, throws a [ParsingException].
///
/// [object] The object to be converted to a [num].
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [num] if conversion is successful.
/// Throws a [ParsingException] if the conversion fails or the object is `null`.
@optionalTypeArgs
num toNum(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  num? defaultValue,
  ElementConverter<num>? converter,
}) =>
    ConvertObject.toNum(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Attempts to convert an object to a [num], or returns `null` if the object is `null` or conversion fails.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts numeric types and strings that represent valid numbers to [num].
/// - If the conversion to [num] fails (e.g., non-numeric string), logs an error and returns `null`.
///
/// [object] The object to be converted to a [num].
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [num] if conversion is successful, otherwise `null`.
@optionalTypeArgs
num? tryToNum(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  num? defaultValue,
  ElementConverter<num>? converter,
}) =>
    ConvertObject.tryToNum(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Converts an object to an [int].
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts numeric types and strings that represent valid integers to [int].
/// - If the conversion to [int] fails (e.g., non-integer string), throws a [ParsingException].
///
/// [object] The object to be converted to an [int].
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns an [int] if conversion is successful.
/// Throws a [ParsingException] if the conversion fails.
@optionalTypeArgs
int toInt(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  int? defaultValue,
  ElementConverter<int>? converter,
}) =>
    ConvertObject.toInt(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Attempts to convert an object to an [int], or returns `null` if the object is `null` or conversion fails.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts numeric types and strings that represent valid integers to [int].
/// - If the conversion to [int] fails (e.g., non-integer string), logs an error and returns `null`.
///
/// [object] The object to be converted to an [int].
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns an [int] if conversion is successful, otherwise `null`.
@optionalTypeArgs
int? tryToInt(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  int? defaultValue,
  ElementConverter<int>? converter,
}) =>
    ConvertObject.tryToInt(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Converts an object to a [BigInt].
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts numeric types and strings that represent valid large integers to [BigInt].
/// - IMPORTANT: BigInt operations can be computationally expensive, especially for very large integers.
///   Use BigInt only when necessary, and be mindful of performance implications.
/// - If the conversion to [BigInt] fails or the object is `null`, throws a [ParsingException].
///
/// [object] The object to be converted to a [BigInt].
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [BigInt] if conversion is successful.
/// Throws a [ParsingException] if the conversion fails or the object is `null`.
@optionalTypeArgs
BigInt toBigInt(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  BigInt? defaultValue,
  ElementConverter<BigInt>? converter,
}) =>
    ConvertObject.toBigInt(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Attempts to convert an object to a [BigInt], or returns `null` if the object is `null` or conversion fails.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts numeric types and strings that represent valid large integers to [BigInt].
/// - IMPORTANT: BigInt operations can be computationally expensive, especially for very large integers.
///   Use BigInt only when necessary, and be mindful of performance implications.
/// - If the conversion to [BigInt] fails (e.g., non-numeric string), logs an error and returns `null`.
///
/// [object] The object to be converted to a [BigInt].
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [BigInt] if conversion is successful, otherwise `null`.
@optionalTypeArgs
BigInt? tryToBigInt(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  BigInt? defaultValue,
  ElementConverter<BigInt>? converter,
}) =>
    ConvertObject.tryToBigInt(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Converts an object to a [double].
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts numeric types and strings that represent valid numbers to [double].
/// - If the conversion to [double] fails (e.g., non-numeric string), throws a [ParsingException].
///
/// [object] The object to be converted to a [double].
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [double] if conversion is successful.
/// Throws a [ParsingException] if the conversion fails.
@optionalTypeArgs
double toDouble(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  double? defaultValue,
  ElementConverter<double>? converter,
}) =>
    ConvertObject.toDouble(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Attempts to convert an object to a [double], or returns `null` if the object is `null` or conversion fails.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Converts numeric types and strings that represent valid numbers to [double].
/// - If the conversion to [double] fails (e.g., non-numeric string), logs an error and returns `null`.
///
/// [object] The object to be converted to a [double].
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [double] if conversion is successful, otherwise `null`.
@optionalTypeArgs
double? tryToDouble(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  double? defaultValue,
  ElementConverter<double>? converter,
}) =>
    ConvertObject.tryToDouble(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Converts an object to a `bool`.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Returns `true` if the object is a `bool` and equal to `true`.
/// - Returns `true` if the object is a `String` and equal to 'yes' or 'true' (case-insensitive).
/// - Returns `true` if the object is a `num`, `int`, or `double` and is larger than zero.
/// - Returns `false` for other types or if the object is `null`.
///
/// [object] The object to be converted to a `bool`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a `bool`, with a default value of `false`.
@optionalTypeArgs
bool toBool(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  bool? defaultValue,
  ElementConverter<bool>? converter,
}) =>
    ConvertObject.toBool(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Attempts to convert an object to a `bool`, or returns `null` if the object is `null` or conversion is not applicable.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Returns `true` if the object is a `bool` and equal to `true`.
/// - Returns `true` if the object is a `String` and equal to 'yes' or 'true' (case-insensitive).
/// - Returns `null` for other types or if the object is `null`.
///
/// [object] The object to be converted to a `bool`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a `bool` if conversion is applicable, otherwise `null`.
@optionalTypeArgs
bool? tryToBool(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  bool? defaultValue,
  ElementConverter<bool>? converter,
}) =>
    ConvertObject.tryToBool(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Attempts to convert an object to a `bool`, or returns `null` if the object is `null` or conversion is not applicable.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - Returns `true` if the object is a `bool` and equal to `true`.
/// - Returns `true` if the object is a `String` and equal to 'yes' or 'true' (case-insensitive).
/// - Returns `null` for other types or if the object is `null`.
///
/// [object] The object to be converted to a `bool`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a `bool` if conversion is applicable, otherwise `null`.
@optionalTypeArgs
DateTime toDateTime(
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
}) =>
    ConvertObject.toDateTime(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      autoDetectFormat: autoDetectFormat,
      useCurrentLocale: useCurrentLocale,
      utc: utc,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Attempts to convert an object to a [DateTime], or returns `null` if the object is `null` or conversion fails.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is a string representing a valid DateTime, it converts it to a [DateTime] object.
/// - If the object is already a [DateTime], it is returned as-is.
/// - If the conversion to [DateTime] fails (e.g., invalid format), logs an error and returns `null`.
///
/// [object] The object to be converted to a [DateTime].
/// [format] (Optional) Specify the format if the object is a string representing a DateTime.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [DateTime] if conversion is successful, otherwise `null`.
@optionalTypeArgs
DateTime? tryToDateTime(
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
}) =>
    ConvertObject.tryToDateTime(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      format: format,
      locale: locale,
      autoDetectFormat: autoDetectFormat,
      useCurrentLocale: useCurrentLocale,
      utc: utc,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Converts an object to a [Uri].
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is a string representing a valid URI, it converts it to a [Uri] object.
/// - If the object is `null`, throws a [ParsingException] with a `nullObject` error.
/// - If the conversion to [Uri] fails (e.g., if the string is not a valid URI), throws a [ParsingException].
///
/// [object] The object to be converted to a [Uri]. Expected to be a string representing a URI.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [Uri] if conversion is successful.
/// Throws a [ParsingException] if the conversion fails or the object is null.
@optionalTypeArgs
Uri toUri(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Uri? defaultValue,
  ElementConverter<Uri>? converter,
}) =>
    ConvertObject.toUri(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Attempts to convert an object to a [Uri], or returns `null` if the object is `null` or conversion fails.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is a string representing a valid URI, it converts it to a [Uri] object.
/// - If the conversion to [Uri] fails (e.g., if the string is not a valid URI), it logs an error and returns `null`.
/// - If the object is null, returns null.
///
/// [object] The object to be converted to a [Uri]. Expected to be a string representing a URI.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [Uri] if conversion is successful, otherwise null.
@optionalTypeArgs
Uri? tryToUri(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Uri? defaultValue,
  ElementConverter<Uri>? converter,
}) =>
    ConvertObject.tryToUri(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

/// Converts an object to a [Map] with keys of type `K` and values of type `V`.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is already a [Map] with the correct key and value types, it is returned as-is.
/// - If the object is an empty [Map], an empty [Map] is returned.
/// - If the object is null, throws a [ParsingException] with a `nullObject` error.
/// - If the object cannot be converted to a [Map] with the specified types, throws a [ParsingException].
///
/// [object] The object to be converted to a [Map] with keys of type `K` and values of type `V`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [Map<K, V>] if conversion is successful.
/// Throws a [ParsingException] if the conversion fails.
@optionalTypeArgs
Map<K, V> toMap<K, V>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Map<K, V>? defaultValue,
  ElementConverter<K>? keyConverter,
  ElementConverter<V>? valueConverter,
}) =>
    ConvertObject.toMap(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      keyConverter: keyConverter,
      valueConverter: valueConverter,
    );

/// Attempts to convert an object to a [Map] with keys of type `K` and values of type `V`.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is already a [Map] with the correct key and value types, it is returned as-is.
/// - If the object is an empty [Map], an empty [Map] is returned.
/// - If the object is null, returns null.
/// - If the object cannot be converted to a [Map] with the specified types, logs an error and returns null.
///
/// [object] The object to be converted to a [Map] with keys of type `K` and values of type `V`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [Map<K, V>] if conversion is successful, otherwise null.
@optionalTypeArgs
Map<K, V>? tryToMap<K, V>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Map<K, V>? defaultValue,
  ElementConverter<K>? keyConverter,
  ElementConverter<V>? valueConverter,
}) =>
    ConvertObject.tryToMap(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      keyConverter: keyConverter,
      valueConverter: valueConverter,
    );

/// Converts an object to a [Set] of type `T`.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is already a [Set] of type `T`, it is returned as-is.
/// - If the object is an [Iterable], it converts it to a [Set] of type `T`.
/// - If the object is null, throws a [ParsingException] with a `nullObject` error.
/// - If the object cannot be converted to a [Set] of type `T`, throws a [ParsingException].
///
/// [object] The object to be converted to a [Set] of type `T`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [Set] of type `T` if conversion is successful.
/// Throws a [ParsingException] if the conversion fails.
@optionalTypeArgs
Set<T> toSet<T>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Set<T>? defaultValue,
  ElementConverter<T>? elementConverter,
}) =>
    ConvertObject.toSet(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      elementConverter: elementConverter,
    );

/// Attempts to convert an object to a [Set] of type `T`, or returns null if conversion is not possible.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is already a [Set] of type `T`, it is returned as-is.
/// - If the object is an [Iterable], it converts it to a [Set] of type `T`.
/// - If the object is null, returns null.
/// - If the object cannot be converted to a [Set] of type `T`, logs an error and returns null.
///
/// [object] The object to be converted to a [Set] of type `T`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [Set] of type `T` if conversion is successful, otherwise null.
@optionalTypeArgs
Set<T>? tryToSet<T>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Set<T>? defaultValue,
  ElementConverter<T>? elementConverter,
}) =>
    ConvertObject.tryToSet(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      elementConverter: elementConverter,
    );

/// Converts an object to a [List] of type `T`.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is already a [List] of type `T`, it is returned as-is.
/// - If the object is a single instance of type `T`, it returns a [List] containing that object.
/// - If the object is a [Map], and `mapKey` is provided, it returns a [List] of the values for that key across all map entries.
/// - If the object is a [Map] with values of type `T` and no `mapKey` is provided, it returns a [List] of all the map's values.
/// - If the object is a [List], and `listIndex` is provided, it attempts to return a [List] containing the element at that index from each list in the original list.
/// - If the object cannot be converted to a [List] of type `T`, a [ParsingException] is thrown.
///
/// [object] The object to be converted to a [List] of type `T`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [List] of type `T` if conversion is successful.
/// Throws a [ParsingException] if the conversion fails.
@optionalTypeArgs
List<T> toList<T>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  List<T>? defaultValue,
  ElementConverter<T>? elementConverter,
}) =>
    ConvertObject.toList(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      elementConverter: elementConverter,
    );

/// Attempts to convert an object to a [List] of type `T`, or returns `null` if conversion is not possible.
/// mirroring the same static method in the [ConvertObject], providing alternative easy less code usage options.
///
/// - If the object is already a [List] of type `T`, it is returned as-is.
/// - If the object is a single instance of type `T`, it returns a [List] containing that object.
/// - If the object is a [Map], and `mapKey` is provided, it returns a [List] of the values for that key across all map entries.
/// - If the object is a [Map] with values of type `T` and no `mapKey` is provided, it returns a [List] of all the map's values.
/// - If the object is a [List], and `listIndex` is provided, it attempts to return a [List] containing the element at that index from each list in the original list.
/// - If the object cannot be converted to a [List] of type `T`, an error is logged, and `null` is returned.
///
/// [object] The object to be converted to a [List] of type `T`.
/// [mapKey] (Optional) Specifies the key to extract values from a [Map] object.
/// [listIndex] (Optional) Specifies the index to extract elements from a [List] object.
///
/// Returns a [List] of type `T` if conversion is successful, otherwise `null`.
@optionalTypeArgs
List<T>? tryToList<T>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  List<T>? defaultValue,
  ElementConverter<T>? elementConverter,
}) =>
    ConvertObject.tryToList(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      elementConverter: elementConverter,
    );

/// Global function that allow Convert an object to a specified type.
///
/// - If the object is already of type [T], it will be returned.
/// - If the object is null, a [ParsingException] with a `nullObject` error will
///     be thrown. If you want to ensure null safe values, consider using [tryToType] instead.
/// - If the object cannot be converted to the specified type, a [ParsingException] will be thrown.
///
/// - Supported conversion types:
///   - [bool]
///   - [int]
///   - [BigInt]
///   - [double]
///   - [num]
///   - [String]
///   - [DateTime]
///
/// Throws a [ParsingException] if it cannot be converted to the specified type.
@optionalTypeArgs
T toType<T>(dynamic object) {
  if (object is T) return object;
  if (object == null) {
    throw ParsingException.nullObject(
      parsingInfo: {
        'method': 'toType<$T>',
        'object': object,
        'objectType': 'null',
        'targetType': '$T',
      },
      stackTrace: StackTrace.current,
    );
  }
  try {
    if (T == bool) return ConvertObject.toBool(object) as T;
    if (T == int) return ConvertObject.toInt(object) as T;
    if (T == double) return ConvertObject.toDouble(object) as T;
    if (T == num) return ConvertObject.toNum(object) as T;
    if (T == BigInt) return ConvertObject.toBigInt(object) as T;
    if (T == String) return ConvertObject.toString1(object) as T;
    if (T == DateTime) return ConvertObject.toDateTime(object) as T;
  } catch (e, s) {
    throw ParsingException(
      error: e,
      parsingInfo: {
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
  throw ParsingException(
    parsingInfo: {
      'method': 'toType<$T>',
      'object': object,
      'objectType': object.runtimeType.toString(),
      'targetType': '$T',
    },
    error:
        'Unsupported type detected. Please ensure that the type you are attempting to convert to is either a primitive type or a valid data type: $T.',
  );
}

/// Global function that allow Convert an object to a specified type or return null.
///
/// If the object is already of type [T], it will be returned.
/// If the object is null, a null value will be returned. If you want to ensure non-nullable values, consider using [toType] instead.
/// If the object cannot be converted to the specified type, a [ParsingException] will be thrown.
///
/// Supported conversion types:
///   - [bool]
///   - [int]
///   - [BigInt]
///   - [double]
///   - [num]
///   - [String]
///   - [DateTime]
/// Throws a [ParsingException] if the object cannot be converted to the specified type.
@optionalTypeArgs
T? tryToType<T>(dynamic object) {
  if (object is T) return object;
  if (object == null) return null;
  try {
    if (T == bool) return ConvertObject.tryToBool(object) as T?;
    if (T == int) return ConvertObject.tryToInt(object) as T?;
    if (T == BigInt) return ConvertObject.tryToBigInt(object) as T?;
    if (T == double) return ConvertObject.tryToDouble(object) as T?;
    if (T == num) return ConvertObject.tryToNum(object) as T?;
    if (T == String) return ConvertObject.tryToString(object) as T?;
    if (T == DateTime) return ConvertObject.tryToDateTime(object) as T?;
  } catch (e, s) {
    throw ParsingException(
      error: e,
      parsingInfo: {
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
  throw ParsingException(
    error: 'Unsupported type: $T',
    parsingInfo: {
      'method': 'tryToType<$T>',
      'object': object,
      'objectType': object.runtimeType.toString(),
      'targetType': '$T',
    },
  );
}
