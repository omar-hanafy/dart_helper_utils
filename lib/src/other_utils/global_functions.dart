import 'dart:math';

import 'package:collection/collection.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';

/// Returns `true` when [value] is a primitive value or a collection of primitives.
///
/// Primitive values include `num`, `bool`, `String`, `BigInt`, and `DateTime`.
/// Iterables and maps are considered primitive when all elements are primitive.
///
/// Example:
/// ```dart
/// final ok = isValuePrimitive(10); // true
/// final nope = isValuePrimitive(Object()); // false
/// ```
bool isValuePrimitive(dynamic value) => value is Object && value.isPrimitive();

/// Returns `true` when the static type [T] is a primitive type.
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

/// Returns `true` when [a] and [b] are deeply equal.
bool isEqual(dynamic a, dynamic b) =>
    const DeepCollectionEquality().equals(a, b);

/// Returns the current time in milliseconds since the Unix epoch.
int get currentMillisecondsSinceEpoch => DateTime.now().millisecondsSinceEpoch;

/// Returns the current time.
DateTime get now => DateTime.now();

/// Returns a random boolean value.
bool randomBool([int? seed]) => Random(seed).nextBool();

/// Returns a random integer in the range `0 <= value < max`.
int randomInt(int max, [int? seed]) => Random(seed).nextInt(max);

/// Returns a random double in the range `0.0 <= value < 1.0`.
double randomDouble([int? seed]) => Random(seed).nextDouble();
