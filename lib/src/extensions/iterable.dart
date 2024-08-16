import 'dart:collection';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:dart_helper_utils/src/other_utils/global_functions.dart' as gf;

/* SUGGESTIONS:
When designing utility extensions for a language like Dart, which is used extensively in Flutter development, it’s crucial to consider both the common use cases and the pain points that developers might encounter. Here are some suggestions to consider adding to your `ListExtensions` class, which might provide additional value to users of your `dart_helper_utils` package:

1. **Safe Element Replacement:**
   - A null-safe version of the `replaceRange` method could be beneficial. It could replace a range of elements with other elements without throwing an exception if the range is out of bounds.

2. **Batching:**
   - A method to divide the list into batches of a specified size could be very useful when dealing with pagination or processing large datasets in chunks.

3. **Null-Safe Concatenation:**
   - Extending the idea of `concatWithSingleList` and `concatWithMultipleList`, you could provide a null-safe concatenation that ignores null lists instead of considering them empty lists.

4. **Shuffling:**
   - A null-safe `shuffle` method that shuffles the list in place, but only if the list is not null or empty.

5. **Mapping with Index:**
   - A version of `map` that provides the index along with the element could be useful for operations that require the element's position within the list.

6. **Null-Safe Sort:**
   - Null-safe `sort` and `sortBy` extensions that sort the list based on a comparator or by a specific key. It won't perform the operation if the list is null or contains null values that can't be compared.

7. **Deep Equality Check:**
   - A method to check if two lists are deeply equal, i.e., they contain the same elements in the same order.

8. **Finding Sublists:**
   - Methods for finding sublists within a list, either by matching a sequence of elements or by a specific condition.

9. **Null-Safe Accumulate/Reduce:**
   - Accumulate or reduce the list to a single value in a null-safe way, with an option to specify a default value if the list is null or empty.

10. **Partition:**
    - A `partition` function that divides the list into two lists based on a predicate: one list for items that match the predicate and another for items that don't.

11. **Folding with Index:**
    - A version of the `fold` method that includes the index of the element along with the accumulator and the element itself.

Remember that when adding new functionality, it’s essential to ensure that it doesn’t clash with existing methods and that it adheres to the idiomatic practices of the language and the framework it’s used with. Also, consider the performance implications of adding more complex operations, especially for large lists.

Would you like any specific implementation details or examples for any of these suggestions?
*/

typedef IndexedPredicate<T> = bool Function(int index, T);
typedef Predicate<T> = bool Function(T);

extension DHUNullableListExtensions<E> on List<E>? {
  /// same behavior as [removeAt] but it is null safe which means
  /// it do nothing when [List] return [isEmptyOrNull] to true.
  void tryRemoveAt(int index) {
    try {
      if (isNotEmptyOrNull) this!.removeAt(index);
    } catch (_) {}
  }

  /// same behavior as [indexOf] but it is null safe which means
  /// it do nothing when [List] return [isEmptyOrNull] to true.
  int? indexOfOrNull(E? element) =>
      isEmptyOrNull || element == null ? null : this!.indexOf(element);

  /// same behavior as [indexWhere] but it is null safe which means
  /// it do nothing when [List] return [isEmptyOrNull] to true.
  int? indexWhereOrNull(Predicate<E> test, [int start = 0]) {
    if (isEmptyOrNull) return null;
    try {
      return this!.indexWhere(test, start);
    } catch (e, s) {
      dev.log('$e', stackTrace: s);
      return null;
    }
  }

  /// same behavior as [removeWhere] but it is null safe which means
  /// it do nothing when [List] return [isEmptyOrNull] to true.
  void tryRemoveWhere(int element) =>
      isEmptyOrNull ? null : this!.removeWhere((element) => false);
}

extension DHUCollectionsExtensionsNS<E> on Iterable<E>? {
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

  /// get the first element return null
  E? get firstOrNull => of(0);

  /// get the last element if the list is not empty or return null
  E? get lastOrNull => isNotEmptyOrNull ? this!.last : null;

  E? firstWhereOrNull(Predicate<E> predicate) {
    if (isEmptyOrNull) return null;
    for (final element in this!) {
      if (predicate(element)) return element;
    }
    return null;
  }

  /// get the last element or provider default
  /// example:
  /// var name = [danny, ronny, james].lastOrDefault["jack"]; // james
  /// var name = [].lastOrDefault["jack"]; // jack
  E? lastOrDefault(E defaultValue) => lastOrNull ?? defaultValue;

  /// get the first element or provider default
  /// example:
  /// var name = [danny, ronny, james].firstOrDefault["jack"]; // danny
  /// var name = [].firstOrDefault["jack"]; // jack
  E firstOrDefault(E defaultValue) => firstOrNull ?? defaultValue;

  ////// gets random element from the list or return null. uses the
  E? tryGetRandom() {
    final iterable = this;
    if (iterable == null) return null;
    final generator = Random();
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

  /// uses the [tryToString] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [String] or return null.
  String? tryGetString(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToString(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
            );

  /// uses the [tryToNum] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [num] or return null.
  num? tryGetNum(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToNum(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [int] or return null.
  int? tryGetInt(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToInt(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [BigInt] or return null.
  BigInt? tryGetBigInt(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToBigInt(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
            );

  /// uses the [tryToDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [double] or return null.
  double? tryGetDouble(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToDouble(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToBool] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [bool] or return null.
  bool? tryGetBool(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToBool(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
            );

  /// uses the [tryToDateTime] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [DateTime] or return null.
  DateTime? tryGetDateTime(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
    String? format,
    String? locale,
    bool autoDetectFormat = false,
    bool useCurrentLocale = false,
    bool utc = false,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToDateTime(
              this!.elementAt(index),
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
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToUri(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
            );

  /// uses the [tryToMap] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Map] or return null.
  Map<K2, V2>? tryGetMap<K2, V2>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToMap(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
            );

  /// uses the [tryToSet] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Set] or return null.
  Set<T>? tryGetSet<T>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToSet(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
            );

  /// uses the [tryToList] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [List] or return null.
  List<T>? tryGetList<T>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToList(
              this!.elementAt(index),
              mapKey: innerMapKey,
              listIndex: innerIndex,
            );
}

extension DHUCollectionsExtensions<E> on Iterable<E> {
  /// Returns this Iterable if it's not `null` and the empty list otherwise.
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

// return the half size of a list
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

  // Returns map operation as a List
  List<E2> mapList<E2>(E2 Function(E e) f) => map(f).toList();

  // Takes the first half of a list
  List<E> firstHalf() => take(halfLength).toList();

  // Takes the second half of a list
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

  E getRandom() {
    final generator = Random();
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

  String get encodedJson => json.encode(this);

  /// uses the [toString] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [String].
  String getString(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      ConvertObject.toString1(
        elementAt(index),
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
  }) =>
      ConvertObject.toNum(
        elementAt(index),
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
  }) =>
      ConvertObject.toInt(
        elementAt(index),
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
  }) =>
      ConvertObject.toBigInt(
        elementAt(index),
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
  }) =>
      ConvertObject.toDouble(
        elementAt(index),
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
  }) =>
      ConvertObject.toBool(
        elementAt(index),
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
  }) =>
      ConvertObject.toDateTime(
        elementAt(index),
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
  }) =>
      ConvertObject.toUri(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toMap] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Map].
  Map<K2, V2> getMap<K2, V2>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      ConvertObject.toMap(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toSet] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Set].
  Set<T> getSet<T>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      ConvertObject.toSet(
        elementAt(index),
        mapKey: innerMapKey,
        listIndex: innerIndex,
      );

  /// uses the [toList] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [List].
  List<T> getList<T>(
    int index, {
    dynamic innerMapKey,
    int? innerIndex,
  }) =>
      ConvertObject.toList(
        elementAt(index),
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

extension DHUIterableNumExtensionsNS on Iterable<num?>? {
  num get total {
    if (isEmptyOrNull) return 0;
    num sum = 0;
    for (final current in this!) {
      sum += current ?? 0;
    }
    return sum;
  }
}

extension DHUIterableIntExtensionsNS on Iterable<int?>? {
  int get total {
    if (isEmptyOrNull) return 0;
    var sum = 0;
    for (final current in this!) {
      sum += current ?? 0;
    }
    return sum;
  }
}

extension DHUIterableDoubleExtensionsNS on Iterable<double?>? {
  double get total {
    if (isEmptyOrNull) return 0;
    var sum = 0.0;
    for (final current in this!) {
      sum += current ?? 0.0;
    }
    return sum;
  }
}
