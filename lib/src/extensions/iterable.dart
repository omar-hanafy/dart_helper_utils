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
    if (isNotEmptyOrNull) this!.removeAt(index);
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

  /// uses the [tryToString] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [String] or return null.
  String? tryGetString(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToString(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToNum] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [num] or return null.
  num? tryGetNum(
    int index, {
    Object? innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToNum(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [int] or return null.
  int? tryGetInt(
    int index, {
    Object? innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToInt(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [BigInt] or return null.
  BigInt? tryGetBigInt(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToBigInt(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [double] or return null.
  double? tryGetDouble(
    int index, {
    Object? innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToDouble(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToBool] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [bool] or return null.
  bool? tryGetBool(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToBool(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToDateTime] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [DateTime] or return null.
  DateTime? tryGetDateTime(
    int index, {
    Object? innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToDateTime(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
              format: format,
              locale: locale,
            );

  /// uses the [tryToUri] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Uri] or return null.
  Uri? tryGetUri(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToUri(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToMap] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Map] or return null.
  Map<K2, V2>? tryGetMap<K2, V2>(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToMap(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToSet] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Set] or return null.
  Set<T>? tryGetSet<T>(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToSet(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
            );

  /// uses the [tryToList] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [List] or return null.
  List<T>? tryGetList<T>(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      isEmptyOrNull
          ? null
          : ConvertObject.tryToList(
              this!.elementAt(index),
              mapKey: innerKey,
              listIndex: innerListIndex,
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

  /// Returns `true` if all elements match the given predicate.
  /// Example:
  /// [5, 19, 2].all(isEven), isFalse)
  /// [6, 12, 2].all(isEven), isTrue)
  bool all(Predicate<E>? predicate) {
    for (final e in this) {
      if (!predicate!(e)) return false;
    }
    return true;
  }

  /// Returns a list containing only the elements from given collection having distinct keys.
  ///
  /// Basically it's just like distinct function but with a predicate
  /// example:
  /// [
  ///    User(22, "Sasha"),
  ///    User(23, "Mika"),
  ///    User(23, "Miryam"),
  ///    User(30, "Josh"),
  ///    User(36, "Ran"),
  ///  ].distinctBy((u) => u.age).forEach((user) {
  ///    print("${user.age} ${user.name}");
  ///  });
  ///
  /// result:
  /// 22 Sasha
  /// 23 Mika
  /// 30 Josh
  /// 36 Ran
  // ignore: inference_failure_on_function_return_type
  List<E> distinctBy(Predicate<E> predicate) {
    // ignore: inference_failure_on_instance_creation
    final set = HashSet();
    final list = <E>[];
    this.toList().forEach((e) {
      if (set.add(predicate(e))) {
        list.add(e);
      }
    });
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
    Object? innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toString1(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toNum] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [num].
  num getNum(
    int index, {
    Object? innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      ConvertObject.toNum(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [int].
  int getInt(
    int index, {
    Object? innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      ConvertObject.toInt(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toBigInt] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [BigInt].
  BigInt getBigInt(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toBigInt(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toDouble] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [double].
  double getDouble(
    int index, {
    Object? innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      ConvertObject.toDouble(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toBool] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [bool].
  bool getBool(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toBool(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toDateTime] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [DateTime].
  DateTime getDateTime(
    int index, {
    Object? innerKey,
    int? innerListIndex,
    String? format,
    String? locale,
  }) =>
      ConvertObject.toDateTime(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
        format: format,
        locale: locale,
      );

  /// uses the [toUri] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Uri].
  Uri getUri(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toUri(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toMap] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Map].
  Map<K2, V2> getMap<K2, V2>(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toMap(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toSet] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [Set].
  Set<T> getSet<T>(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toSet(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
      );

  /// uses the [toList] defined in the [ConvertObject] class to convert a
  /// specific element by [index] in that Iterable to [List].
  List<T> getList<T>(
    int index, {
    Object? innerKey,
    int? innerListIndex,
  }) =>
      ConvertObject.toList(
        elementAt(index),
        mapKey: innerKey,
        listIndex: innerListIndex,
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
