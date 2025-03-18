import 'dart:math';

import 'package:dart_helper_utils/dart_helper_utils.dart';

/// Determines whether a given value is of a primitive type for JSON serialization.
///
/// This function checks if the provided [value] is a type that can be directly
/// serialized into JSON. The types considered as primitives for this purpose are:
/// `num` (which includes both `int` and `double`), `bool`, `String`, `BigInt`,
/// `DateTime`, and `Uint8List`. Additionally, collections (lists, sets) exclusively
/// containing primitives are also considered primitive.
///
/// Returns `true` if [value] is a primitive type or a collection of primitives, and
/// `false` otherwise.
///
/// Example:
/// ```dart
/// bool isNumPrimitive = isPrimitiveType(10); // true
/// bool isStringPrimitive = isPrimitiveType('Hello'); // true
/// bool isComplexObjectPrimitive = isPrimitiveType(MyCustomClass()); // false
/// ```
bool isValuePrimitive(dynamic value) => value is Object && value.isPrimitive();

///
bool isTypePrimitive<T>() => switch (T) {
      const (num) ||
      const (int) ||
      const (double) ||
      const (bool) ||
      const (String) ||
      const (BigInt) ||
      const (DateTime) =>
        true,
      _ => false,
    };

///
bool isEqual(dynamic a, dynamic b) {
  if (a is Map && b is Map) return a.isEqual(b);
  if (a is Iterable && b is Iterable) return a.isEqual(b);
  return a == b;
}

/// Returns the current time in milliseconds since the Unix epoch.
int get currentMillisecondsSinceEpoch => DateTime.now().millisecondsSinceEpoch;

/// Returns the current time.
DateTime get now => DateTime.now();

/// returns random bool.
bool randomBool([int? seed]) => Random(seed).nextBool();

/// returns random int.
int randomInt(int max, [int? seed]) => Random(seed).nextInt(max);

/// returns random double.
double randomDouble([int? seed]) => Random(seed).nextDouble();
