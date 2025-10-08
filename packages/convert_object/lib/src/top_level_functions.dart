import 'core/convert_object.dart';

// String
String toString1(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? defaultValue,
  String Function(Object?)? converter,
}) =>
    ConvertObject.toString1(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

String? tryToString(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? defaultValue,
  String Function(Object?)? converter,
}) =>
    ConvertObject.tryToString(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

// Numbers
num toNum(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  num? defaultValue,
  num Function(Object?)? converter,
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

num? tryToNum(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  num? defaultValue,
  num Function(Object?)? converter,
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

int toInt(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  int? defaultValue,
  int Function(Object?)? converter,
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

int? tryToInt(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  int? defaultValue,
  int Function(Object?)? converter,
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

double toDouble(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  double? defaultValue,
  double Function(Object?)? converter,
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

double? tryToDouble(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  double? defaultValue,
  double Function(Object?)? converter,
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

// BigInt
BigInt toBigInt(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  BigInt? defaultValue,
  BigInt Function(Object?)? converter,
}) =>
    ConvertObject.toBigInt(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

BigInt? tryToBigInt(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  BigInt? defaultValue,
  BigInt Function(Object?)? converter,
}) =>
    ConvertObject.tryToBigInt(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

// Bool
bool toBool(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  bool? defaultValue,
  bool Function(Object?)? converter,
}) =>
    ConvertObject.toBool(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

bool? tryToBool(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  bool? defaultValue,
  bool Function(Object?)? converter,
}) =>
    ConvertObject.tryToBool(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

// DateTime
DateTime toDateTime(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  bool autoDetectFormat = false,
  bool useCurrentLocale = false,
  bool utc = false,
  DateTime? defaultValue,
  DateTime Function(Object?)? converter,
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

DateTime? tryToDateTime(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  String? format,
  String? locale,
  bool autoDetectFormat = false,
  bool useCurrentLocale = false,
  bool utc = false,
  DateTime? defaultValue,
  DateTime Function(Object?)? converter,
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

// Uri
Uri toUri(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Uri? defaultValue,
  Uri Function(Object?)? converter,
}) =>
    ConvertObject.toUri(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

Uri? tryToUri(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Uri? defaultValue,
  Uri Function(Object?)? converter,
}) =>
    ConvertObject.tryToUri(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      converter: converter,
    );

// Collections
Map<K, V> toMap<K, V>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Map<K, V>? defaultValue,
  K Function(Object?)? keyConverter,
  V Function(Object?)? valueConverter,
}) =>
    ConvertObject.toMap<K, V>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      keyConverter: keyConverter,
      valueConverter: valueConverter,
    );

Map<K, V>? tryToMap<K, V>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Map<K, V>? defaultValue,
  K Function(Object?)? keyConverter,
  V Function(Object?)? valueConverter,
}) =>
    ConvertObject.tryToMap<K, V>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      keyConverter: keyConverter,
      valueConverter: valueConverter,
    );

Set<T> toSet<T>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Set<T>? defaultValue,
  T Function(Object?)? elementConverter,
}) =>
    ConvertObject.toSet<T>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      elementConverter: elementConverter,
    );

Set<T>? tryToSet<T>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  Set<T>? defaultValue,
  T Function(Object?)? elementConverter,
}) =>
    ConvertObject.tryToSet<T>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      elementConverter: elementConverter,
    );

List<T> toList<T>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  List<T>? defaultValue,
  T Function(Object?)? elementConverter,
}) =>
    ConvertObject.toList<T>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      elementConverter: elementConverter,
    );

List<T>? tryToList<T>(
  dynamic object, {
  Object? mapKey,
  int? listIndex,
  List<T>? defaultValue,
  T Function(Object?)? elementConverter,
}) =>
    ConvertObject.tryToList<T>(
      object,
      mapKey: mapKey,
      listIndex: listIndex,
      defaultValue: defaultValue,
      elementConverter: elementConverter,
    );

// Generic
T toType<T>(dynamic object) => ConvertObject.toType<T>(object);
T? tryToType<T>(dynamic object) => ConvertObject.tryToType<T>(object);

