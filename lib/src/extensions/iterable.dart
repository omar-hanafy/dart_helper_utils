import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:dart_helper_utils/src/other_utils/global_functions.dart' as gf;

/// A type alias representing a predicate function that takes an index and a value of type [T]
/// and returns a boolean value.
///
/// Used for filtering and testing conditions on elements with their indices.
///
/// Example:
/// ```dart
/// IndexedPredicate<int> isEvenIndex = (int index, int n) => index % 2 == 0 && n % 2 == 0;
/// ```
typedef IndexedPredicate<T> = bool Function(int index, T);

/// A type alias representing a predicate function that takes a value of type [T]
/// and returns a boolean value.
///
/// Used for filtering and testing conditions on elements.
///
/// Example:
/// ```dart
/// Predicate<int> isEven = (int n) => n % 2 == 0;
/// ```
typedef Predicate<T> = bool Function(T);

/// Extension methods for nullable [Set] collections.
///
/// Provides utility methods that can be used on [Set] objects that may be null.
/// These extensions help handle null cases gracefully while working with sets.
///
/// Example usage:
/// ```dart
/// Set<int>? nullableSet = {1, 2, 3};
/// nullableSet.someUtilityMethod();
/// ```
extension DHUNullableSetExtensions<E> on Set<E>? {
  /// If a direct conversion fails, it attempts element-wise conversion using `toType`, ensuring
  /// a smooth conversion process without the risk of runtime errors.
  ///
  /// Example usage:
  /// ```dart
  /// Set<dynamic> set = {1, 2, '3'};
  /// Set<int> intSet = set.convertTo<int>(); // Tries to convert all elements to int.
  /// ```
  Set<R> convertTo<R>() => ConvertObject.toSet<R>(this);

  /// Checks if the iterable is either `null` or empty.
  ///
  /// Returns `true` if the iterable is `null` or empty, otherwise `false`.
  ///
  /// Example:
  /// ```dart
  /// List<int>? list = null;
  /// print(list.isEmptyOrNull); // true
  ///
  /// list = [];
  /// print(list.isEmptyOrNull); // true
  ///
  /// list = [1, 2, 3];
  /// print(list.isEmptyOrNull); // false
  /// ```
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  /// Checks if the iterable is neither `null` nor empty.
  ///
  /// Returns `true` if the iterable is not `null` and not empty, otherwise `false`.
  ///
  /// Example:
  /// ```dart
  /// List<int>? list = null;
  /// print(list.isNotEmptyOrNull); // false
  ///
  /// list = [];
  /// print(list.isNotEmptyOrNull); // false
  ///
  /// list = [1, 2, 3];
  /// print(list.isNotEmptyOrNull); // true
  /// ```
  bool get isNotEmptyOrNull => !isEmptyOrNull;
}

/// Enhanced documentation for nullable List extensions.
extension DHUNullableListExtensions<E> on List<E>? {
  /// Safely removes the element at the specified [index] if the list is non-null and non-empty.
  ///
  /// Parameter:
  /// • [index]: The position of the element to remove.
  void tryRemoveAt(int index) {
    try {
      if (isNotEmptyOrNull) this!.removeAt(index);
    } catch (_) {}
  }

  /// Returns the index of [element] or null if the list is null/empty or [element] is null.
  int? indexOfOrNull(E? element) =>
      isEmptyOrNull || element == null ? null : this!.indexOf(element);

  /// Searches for an element that satisfies the [test] predicate, starting at [start], and returns
  /// its index. Returns null if no such element is found or if the list is null/empty.
  int? indexWhereOrNull(Predicate<E> test, [int start = 0]) {
    if (isEmptyOrNull) return null;
    try {
      return this!.indexWhere(test, start);
    } catch (e, s) {
      dev.log('$e', stackTrace: s);
      return null;
    }
  }

  /// Safely attempts to remove elements (currently a placeholder) when called.
  /// Note: The parameter [element] is used only to match the method signature.
  void tryRemoveWhere(int element) =>
      isEmptyOrNull ? null : this!.removeWhere((element) => false);

  /// Converts the list to a different type [R] using custom conversion logic.
  ///
  /// Example:
  /// ```dart
  /// List <dynamic> list = [1, 2, '3'];
  /// List <int> intList = list.convertTo<int>();
  /// ```
  List<R> convertTo<R>() => ConvertObject.toList<R>(this);
}

/// Enhanced documentation for nullable Iterable extensions.
extension DHUCollectionsExtensionsNS<E> on Iterable<E>? {
  /// Creates a [DoublyLinkedList] from this iterable if it's non-null; otherwise returns an empty one.
  DoublyLinkedList<E> toDoublyLinkedList() => DoublyLinkedList(this);

  /// similar to list[index] but it is null safe.
  E? of(int index) {
    if (isNotEmptyOrNull && index >= 0 && this!.length > index) {
      return this!.elementAt(index);
    }
    return null;
  }

  ///Returns [true] if this nullable iterable is either null or empty.
  bool get isEmptyOrNull => isNull || this!.isEmpty;

  ///Returns [false] if this nullable iterable is either null or empty.
  bool get isNotEmptyOrNull => !isEmptyOrNull;

  /// Returns the first element if available; otherwise, returns null.
  E? get firstOrNull => of(0);

  /// Returns the last element if the iterable is not empty; otherwise, returns null.
  E? get lastOrNull => isNotEmptyOrNull ? this!.last : null;

  ///
  E? firstWhereOrNull(Predicate<E> predicate) {
    if (isEmptyOrNull) return null;
    for (final element in this!) {
      if (predicate(element)) return element;
    }
    return null;
  }

  /// Returns the last element or provides [defaultValue] if the iterable is empty or null.
  E? lastOrDefault(E defaultValue) => lastOrNull ?? defaultValue;

  /// Returns the first element or provides [defaultValue] if no element exists.
  E firstOrDefault(E defaultValue) => firstOrNull ?? defaultValue;

  /// Retrieves a random element or null if the iterable is null.
  ///
  /// Optional:
  /// • [seed]: Seed for reproducible randomness.
  E? tryGetRandom([int? seed]) {
    final iterable = this;
    if (iterable == null) return null;
    final generator = Random(seed);
    final index = generator.nextInt(iterable.length);
    return iterable.toList()[index];
  }

  /// checks if every element is a [primitive type](https://dart.dev/language/built-in-types).
  bool isPrimitive() {
    if (this == null) return false;
    return isTypePrimitive<E>() || this!.every(isValuePrimitive);
  }

  /// Compares two lists for element-by-element equality.
  ///
  /// Returns true if the lists are both null, or if they are both non-null, have
  /// the same length, and contain the same members in the same order. Returns
  /// false otherwise.
  bool isEqual(Iterable<E>? other) {
    final curr = this;
    if (identical(curr, other)) return true;
    if (curr == null || other == null) return false;
    if (curr.length != other.length) return false;

    final iterA = curr.iterator;
    final iterB = other.iterator;
    while (iterA.moveNext() && iterB.moveNext()) {
      if (!gf.isEqual(iterA.current, iterB.current)) return false;
    }
    return true;
  }

  /// Returns the sum of values calculated by [valueSelector] function for each element.
  ///
  /// The [valueSelector] function is applied to each non-null element in the list.
  /// If the list is null or empty, returns `0`.
  num totalBy(num? Function(E) valueSelector) {
    if (isEmptyOrNull) return 0;
    num sum = 0;
    for (final element in this!) {
      sum += valueSelector(element) ?? 0;
    }
    return sum;
  }

  /// Helper function to get the element from the list using the provided primary index or alternative indexes.
  E? _getElementAtIndex(
    int index, {
    List<int>? altIndexes,
  }) {
    if (this == null || index < 0) return null;

    try {
      return this!.elementAt(index);
    } catch (_) {}

    if (altIndexes != null) {
      for (final altIndex in altIndexes) {
        try {
          return this!.elementAt(altIndex);
        } catch (_) {}
      }
    }

    return null;
  }

  /// uses the [tryToString] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [String] or return null.
  String? tryGetString(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    String? defaultValue,
  }) =>
      ConvertObject.tryToString(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [tryToNum] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [num] or return null.
  num? tryGetNum(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    num? defaultValue,
  }) =>
      ConvertObject.tryToNum(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
      );

  /// uses the [tryToInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [int] or return null.
  int? tryGetInt(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    int? defaultValue,
  }) =>
      ConvertObject.tryToInt(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
      );

  /// uses the [tryToBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [BigInt] or return null.
  BigInt? tryGetBigInt(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    BigInt? defaultValue,
  }) =>
      ConvertObject.tryToBigInt(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [tryToDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [double] or return null.
  double? tryGetDouble(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    double? defaultValue,
  }) =>
      ConvertObject.tryToDouble(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
      );

  /// uses the [tryToBool] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [bool] or return null.
  bool? tryGetBool(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    bool? defaultValue,
  }) =>
      ConvertObject.tryToBool(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [tryToDateTime] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [DateTime] or return null.
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
  }) =>
      ConvertObject.tryToDateTime(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
        autoDetectFormat: autoDetectFormat,
        useCurrentLocale: useCurrentLocale,
        utc: utc,
      );

  /// uses the [tryToUri] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Uri] or return null.
  Uri? tryGetUri(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    Uri? defaultValue,
  }) =>
      ConvertObject.tryToUri(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [tryToMap] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Map] or return null.
  Map<K2, V2>? tryGetMap<K2, V2>(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    Map<K2, V2>? defaultValue,
  }) =>
      ConvertObject.tryToMap(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [tryToSet] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Set] or return null.
  Set<T>? tryGetSet<T>(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    Set<T>? defaultValue,
  }) =>
      ConvertObject.tryToSet(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [tryToList] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [List] or return null.
  List<T>? tryGetList<T>(
    int index, {
    List<int>? altIndexes,
    dynamic innerMapKey,
    int? innerIndex,
    List<T>? defaultValue,
  }) =>
      ConvertObject.tryToList(
        _getElementAtIndex(index, altIndexes: altIndexes),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );
}

/// Enhanced documentation for non-nullable Iterable extensions.
extension DHUCollectionsExtensions<E> on Iterable<E> {
  /// Converts this iterable to a list of type [R] using custom conversion logic.
  List<R> toListConverted<R>() => this.toList().convertTo<R>();

  /// Converts this iterable to a set of type [R] using custom conversion logic.
  Set<R> toSetConverted<R>() => this.toSet().convertTo<R>();

  /// Returns this iterable (as is) if it is non-null; otherwise, returns an empty iterable.
  Iterable<E> orEmpty() => this;

  /// Returns `true` if at least one element matches the given [predicate].
  bool any(Predicate<E> predicate) {
    if (isEmptyOrNull) return false;
    for (final element in orEmpty()) {
      if (predicate(element)) return true;
    }
    return false;
  }

  /// Return a list concatenates the output of the current list and another [iterable]
  List<E> concatWithSingleList(Iterable<E> iterable) {
    if (isEmptyOrNull || iterable.isEmptyOrNull) return [];

    return <E>[...orEmpty(), ...iterable];
  }

  /// Return a list concatenates the output of the current list and multiple [iterables]
  List<E> concatWithMultipleList(List<Iterable<E>> iterables) {
    if (isEmptyOrNull || iterables.isEmptyOrNull) return [];
    final list = iterables.toList(growable: false).expand((i) => i);
    return <E>[...orEmpty(), ...list];
  }

  /// Convert iterable to set
  Set<E> toMutableSet() => Set.from(this);

  /// Returns a set containing all elements that are contained
  /// by both this set and the specified collection.
  Set<E> intersect(Iterable<E> other) => toMutableSet()..addAll(other);

  /// Groups the elements in values by the value returned by key.
  ///
  /// Returns a map from keys computed by key to a list of all values for which
  /// key returns that key. The values appear in the list in the same
  /// relative order as in values.
  // ignore: avoid_shadowing_type_parameters
  Map<K, List<T>> groupBy<T, K>(K Function(T e) key) {
    final map = <K, List<T>>{};
    for (final element in this) {
      map.putIfAbsent(key(element as T), () => []).add(element);
    }
    return map;
  }

  /// Returns a list containing only elements matching the given [predicate].
  List<E> filter(Predicate<E> test) {
    final result = <E>[];
    forEach((e) {
      if (e != null && test(e)) {
        result.add(e);
      }
    });
    return result;
  }

  /// Returns a list containing all elements not matching the given [predicate] and will filter nulls as well.
  List<E> filterNot(Predicate<E> test) {
    final result = <E>[];
    forEach((e) {
      if (e != null && !test(e)) {
        result.add(e);
      }
    });
    return result;
  }

  /// return the half size of a list
  int get halfLength => (length / 2).floor();

  /// Returns a list containing first [n] elements.
  List<E> takeOnly(int n) {
    if (n == 0) return [];

    final list = List<E>.empty();
    final thisList = this.toList();
    final resultSize = length - n;
    if (resultSize <= 0) return [];
    if (resultSize == 1) return [last];

    List.generate(n, (index) {
      list.add(thisList[index]);
    });

    return list;
  }

  /// Returns a list containing all elements except first [n] elements.
  List<E> drop(int n) {
    if (n == 0) return [];

    final list = List<E>.empty();
    final originalList = this.toList();
    final resultSize = length - n;
    if (resultSize <= 0) return [];
    if (resultSize == 1) return [last];

    originalList
      ..removeRange(0, n)
      ..forEach(list.add);

    return list;
  }

  /// Returns map operation as a List
  List<E2> mapList<E2>(E2 Function(E e) f) => map(f).toList();

  /// Takes the first half of a list
  List<E> firstHalf() => take(halfLength).toList();

  /// Takes the second half of a list
  List<E> secondHalf() => drop(halfLength).toList();

  /// returns a list with two swapped items
  /// [i] first item
  /// [j] second item
  List<E> swap(int i, int j) {
    final list = this.toList();
    final aux = list[i];
    list[i] = list[j];
    list[j] = aux;
    return list;
  }

  ///
  E getRandom([int? seed]) {
    final generator = Random(seed);
    final index = generator.nextInt(length);
    return this.toList()[index];
  }

  /// Will retrun new [Iterable] with all elements that satisfy the predicate [predicate],
  Iterable<E> whereIndexed(IndexedPredicate<E> predicate) =>
      _IndexedWhereIterable(this, predicate);

  ///
  /// Performs the given action on each element on iterable, providing sequential index with the element.
  /// [item] the element on the current iteration
  /// [index] the index of the current iteration
  ///
  /// example:
  /// ["a","b","c"].forEachIndexed((element, index) {
  ///    print("$element, $index");
  ///  });
  /// result:
  /// a, 0
  /// b, 1
  /// c, 2
  void forEachIndexed(void Function(E element, int index) action) {
    var index = 0;
    for (final element in this) {
      action(element, index++);
    }
  }

  /// Returns a new list with all elements sorted according to descending
  /// natural sort order.
  List<E> sortedDescending() =>
      this.toList()..sort((a, b) => -(a as Comparable).compareTo(b));

  /// Checks if all elements in the specified [collection] are contained in
  /// this collection.
  bool containsAll(Iterable<E> collection) {
    for (final element in collection) {
      if (!contains(element)) return false;
    }
    return true;
  }

  /// Return a number of the existing elements by a specific predicate
  /// example:
  ///  final aboveTwenty = [
  ///    User(33, "chicko"),
  ///    User(45, "ronit"),
  ///    User(19, "amsalam"),
  ///  ].count((user) => user.age > 20); // 2
  int count([Predicate<E>? predicate]) {
    var count = 0;
    if (predicate == null) {
      return length;
    } else {
      for (final current in this) {
        if (predicate(current)) {
          count++;
        }
      }
    }

    return count;
  }

  /// Returns a new list containing the first occurrence of each distinct element
  /// from the original iterable, as determined by the provided `keySelector` function.
  ///
  /// The `keySelector` is applied to each element, and elements are considered
  /// distinct if their keys are unique. The order of the elements in the resulting
  /// list is the same as their first occurrence in the original iterable.
  ///
  /// Optional parameters allow for custom comparison logic:
  /// - `equals`: A custom equality function for comparing keys. Useful for case-insensitive comparisons or complex objects.
  /// - `hashCode`: A custom hash code function for generating hash codes for keys. Useful for optimizing performance with specific key characteristics.
  /// - `isValidKey`: A custom function to validate keys. Useful for filtering or handling invalid keys.
  ///
  /// Example:
  ///
  /// ```dart
  /// final people = [
  ///   Person('Alice', 25),
  ///   Person('Bob', 30),
  ///   Person('Alice', 28), // Duplicate name
  /// ];
  ///
  /// final uniquePeople = people.distinctBy((p) => p.name);
  /// // Result: [Person('Alice', 25), Person('Bob', 30)]
  ///
  /// // Using custom equality and hash code functions
  /// final uniquePeopleCustom = people.distinctBy(
  ///   (p) => p.name,
  ///   equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
  ///   hashCode: (key) => key.toLowerCase().hashCode,
  /// );
  /// // Result: [Person('Alice', 25), Person('Bob', 30)]
  ///
  /// // Using a custom key validation function
  /// final peopleWithInvalidKeys = [
  ///   Person('Alice', 25),
  ///   Person('Bob', 30),
  ///   Person('', 28), // Invalid key (empty string)
  ///   Person(null, 28), // Invalid key (null)
  /// ];
  ///
  /// final uniquePeopleValid = peopleWithInvalidKeys.distinctBy(
  ///   (p) => p.name,
  ///   isValidKey: (key) => key != null && key.isNotEmpty,
  /// );
  /// // Result: [Person('Alice', 25), Person('Bob', 30)]
  /// ```
  ///
  /// This method is efficient, using a [HashSet] internally to track unique keys.
  List<E> distinctBy<R>(
    R Function(E) keySelector, {
    bool Function(R, R)? equals,
    int Function(R)? hashCode,
    bool Function(dynamic)? isValidKey,
  }) {
    final set = HashSet<R>(
      equals: equals,
      hashCode: hashCode,
      isValidKey: isValidKey,
    );
    final list = <E>[];
    for (final e in this) {
      final key = keySelector(e);
      if (set.add(key)) {
        list.add(e);
      }
    }
    return list;
  }

  /// Returns a set containing all elements that are contained by this collection
  /// and not contained by the specified collection.
  /// The returned set preserves the element iteration order of the original collection.
  ///
  /// example:
  ///
  /// [1,2,3,4,5,6].subtract([4,5,6])
  ///
  /// result:
  /// 1,2,3

  dynamic subtract(Iterable<E> other) => this.toSet()..removeAll(other);

  /// Returns the first element matching the given [predicate], or `null`
  /// if element was not found.
  E? find(Predicate<E> predicate) {
    for (final element in this) {
      if (predicate(element)) {
        return element;
      }
    }

    return null;
  }

  ///
  String get encodedJson => json.encode(this);

  /// uses the [toString] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [String].
  String getString(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? defaultValue,
  }) =>
      ConvertObject.toString1(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toNum] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [num].
  num getNum(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    num? defaultValue,
  }) =>
      ConvertObject.toNum(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [int].
  int getInt(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    int? defaultValue,
  }) =>
      ConvertObject.toInt(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [BigInt].
  BigInt getBigInt(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    BigInt? defaultValue,
  }) =>
      ConvertObject.toBigInt(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [double].
  double getDouble(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    double? defaultValue,
  }) =>
      ConvertObject.toDouble(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toBool] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [bool].
  bool getBool(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    bool? defaultValue,
  }) =>
      ConvertObject.toBool(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toDateTime] defined in the [ConvertObject] class to convert a
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
      );

  /// uses the [toUri] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Uri].
  Uri getUri(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    Uri? defaultValue,
  }) =>
      ConvertObject.toUri(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toMap] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Map].
  Map<K2, V2> getMap<K2, V2>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    Map<K2, V2>? defaultValue,
  }) =>
      ConvertObject.toMap(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toSet] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Set].
  Set<T> getSet<T>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    Set<T>? defaultValue,
  }) =>
      ConvertObject.toSet(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toList] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [List].
  List<T> getList<T>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    List<T>? defaultValue,
  }) =>
      ConvertObject.toList(
        elementAt(index),
        defaultValue: defaultValue,
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );
}

// A lazy [Iterable] skip elements do **NOT** match the predicate [_f].
class _IndexedWhereIterable<E> extends Iterable<E> {
  _IndexedWhereIterable(this._iterable, this._f);

  final Iterable<E> _iterable;
  final IndexedPredicate<E> _f;

  @override
  Iterator<E> get iterator => _IndexedWhereIterator<E>(_iterable.iterator, _f);
}

/// [Iterator] for [_IndexedWhereIterable]
class _IndexedWhereIterator<E> implements Iterator<E> {
  _IndexedWhereIterator(this._iterator, this._f);

  final Iterator<E> _iterator;
  final IndexedPredicate<E> _f;
  int _index = 0;

  @override
  bool moveNext() {
    while (_iterator.moveNext()) {
      if (_f(_index++, _iterator.current)) {
        return true;
      }
    }
    return false;
  }

  @override
  E get current => _iterator.current;
}
