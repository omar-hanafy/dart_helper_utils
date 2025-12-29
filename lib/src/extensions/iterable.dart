import 'dart:collection';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:dart_helper_utils/src/other_utils/global_functions.dart' as gf;

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

  /// Safely removes elements that satisfy [predicate].
  void tryRemoveWhere(bool Function(E element) predicate) {
    if (isEmptyOrNull) return;
    try {
      this!.removeWhere(predicate);
    } catch (_) {}
  }
}

/// Utility extensions for nullable iterables.
extension DHUCollectionsExtensionsNS<E> on Iterable<E>? {
  /// Returns the element at [index] or `null` if out of bounds or null.
  E? of(int index) {
    if (isNotEmptyOrNull && index >= 0 && this!.length > index) {
      return this!.elementAt(index);
    }
    return null;
  }

  /// Returns `true` if this nullable iterable is either null or empty.
  bool get isEmptyOrNull => this == null || this!.isEmpty;

  /// Returns `false` if this nullable iterable is either null or empty.
  bool get isNotEmptyOrNull => !isEmptyOrNull;

  /// Returns the last element or [defaultValue] when null or empty.
  E? lastOrDefault(E defaultValue) =>
      isNotEmptyOrNull ? this!.last : defaultValue;

  /// Returns the first element or [defaultValue] when null or empty.
  E firstOrDefault(E defaultValue) =>
      isNotEmptyOrNull ? this!.first : defaultValue;

  /// Retrieves a random element or null if the iterable is null.
  ///
  /// Optional:
  /// • [seed]: Seed for reproducible randomness.
  E? tryGetRandom([int? seed]) {
    if (isEmptyOrNull) return null;
    final iterable = this!;
    final generator = Random(seed);
    if (iterable is List<E>) {
      return iterable[generator.nextInt(iterable.length)];
    }
    return iterable.elementAt(generator.nextInt(iterable.length));
  }

  /// Returns `true` when every element is a primitive value.
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

  /// Returns the sum of values calculated by [valueSelector] for each element.
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
}

/// Utility extensions for non-nullable iterables.
extension DHUCollectionsExtensions<E> on Iterable<E> {
  /// Converts this iterable to a list of type [R] using convert_object logic.
  List<R> toListConverted<R>() => convertToList<R>(this);

  /// Converts this iterable to a set of type [R] using convert_object logic.
  Set<R> toSetConverted<R>() => convertToSet<R>(this);

  /// Returns this iterable (as is) if it is non-null; otherwise, returns an empty iterable.
  Iterable<E> orEmpty() => this;

  /// Returns a list that concatenates this iterable with [iterable].
  ///
  /// If either iterable is empty, the result contains the elements of the
  /// other iterable.
  List<E> concatWithSingleList(Iterable<E> iterable) {
    if (iterable.isEmpty) return toList();
    if (isEmpty) return iterable.toList();

    return <E>[...this, ...iterable];
  }

  /// Returns a list that concatenates this iterable with [iterables].
  ///
  /// If [iterables] is empty, the result contains only this iterable.
  List<E> concatWithMultipleList(List<Iterable<E>> iterables) {
    if (iterables.isEmpty) return toList();
    final list = iterables.toList(growable: false).expand((i) => i);
    if (isEmpty) return list.toList();
    return <E>[...this, ...list];
  }

  /// Returns a list containing elements that satisfy [test].
  ///
  /// Null elements are skipped.
  List<E> filter(Predicate<E> test) {
    final result = <E>[];
    forEach((e) {
      if (e != null && test(e)) {
        result.add(e);
      }
    });
    return result;
  }

  /// Returns a list containing elements that do not satisfy [test].
  ///
  /// Null elements are skipped.
  List<E> filterNot(Predicate<E> test) {
    final result = <E>[];
    forEach((e) {
      if (e != null && !test(e)) {
        result.add(e);
      }
    });
    return result;
  }

  /// Returns half the length (floored).
  int get halfLength => (length / 2).floor();

  /// Returns a list containing the first [n] elements.
  List<E> takeOnly(int n) {
    if (n <= 0) return [];
    if (n >= length) return toList();
    return take(n).toList();
  }

  /// Returns a list containing all elements except the first [n] elements.
  List<E> drop(int n) {
    if (n <= 0) return toList();
    if (n >= length) return [];
    return skip(n).toList();
  }

  /// Splits the iterable into chunks of size [size].
  List<List<E>> chunks(int size) {
    if (size <= 0) throw ArgumentError('Size must be positive');
    final chunks = <List<E>>[];
    final iterator = this.iterator;
    while (iterator.moveNext()) {
      final chunk = <E>[iterator.current];
      for (var i = 1; i < size && iterator.moveNext(); i++) {
        chunk.add(iterator.current);
      }
      chunks.add(chunk);
    }
    return chunks;
  }

  /// Returns a sliding window of [size] over the iterable.
  ///
  /// [step] controls how far the window moves each time (defaults to 1).
  /// If [partials] is true, the final window will be included even if it is
  /// smaller than [size].
  List<List<E>> windowed(int size, {int step = 1, bool partials = false}) {
    if (size <= 0) throw ArgumentError('Size must be positive');
    if (step <= 0) throw ArgumentError('Step must be positive');
    final list = toList();
    final windows = <List<E>>[];
    if (list.isEmpty) return windows;

    for (var start = 0; start < list.length; start += step) {
      final end = start + size;
      if (end <= list.length) {
        windows.add(list.sublist(start, end));
      } else if (partials) {
        windows.add(list.sublist(start));
      } else {
        break;
      }
    }

    return windows;
  }

  /// Splits the iterable into two lists based on the [predicate].
  (List<E>, List<E>) partition(bool Function(E) predicate) {
    final matching = <E>[];
    final notMatching = <E>[];
    for (final element in this) {
      if (predicate(element)) {
        matching.add(element);
      } else {
        notMatching.add(element);
      }
    }
    return (matching, notMatching);
  }

  /// Returns consecutive pairs from the iterable.
  ///
  /// Example: `[1, 2, 3] => [(1, 2), (2, 3)]`
  List<(E, E)> pairwise() {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return [];
    var previous = iterator.current;
    final pairs = <(E, E)>[];
    while (iterator.moveNext()) {
      final current = iterator.current;
      pairs.add((previous, current));
      previous = current;
    }
    return pairs;
  }

  /// Inserts [element] between every element in the iterable.
  Iterable<E> intersperse(E element) sync* {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield element;
        yield iterator.current;
      }
    }
  }

  /// Converts the iterable to a map using [keySelector] and optional [valueSelector].
  Map<K, V> associate<K, V>(
    K Function(E) keySelector, [
    V Function(E)? valueSelector,
  ]) {
    return {
      for (final e in this)
        keySelector(e): valueSelector != null ? valueSelector(e) : e as V,
    };
  }

  /// Executes [action] on each element with at most [parallelism] concurrent tasks.
  ///
  /// Results are returned in completion order, not input order.
  ///
  /// If any task throws, the returned future completes with that error. Any
  /// in-flight tasks continue running and their errors are handled internally
  /// to avoid unhandled exceptions.
  Future<List<R>> mapConcurrent<R>(
    Future<R> Function(E item) action, {
    int parallelism = 1,
  }) async {
    if (parallelism <= 0) throw ArgumentError('Parallelism must be positive');
    final results = <R>[];
    final active = <Future<void>>{};
    final iterator = this.iterator;

    try {
      while (iterator.moveNext()) {
        while (active.length >= parallelism) {
          await Future.any(active);
        }

        final item = iterator.current;
        late Future<void> task;
        task = action(item)
            .then((result) {
              results.add(result);
            })
            .whenComplete(() {
              active.remove(task);
            });

        active.add(task);
      }

      await Future.wait(active);
    } catch (_) {
      for (final task in active) {
        // ignore: unawaited_futures
        task.catchError((_) {});
      }
      rethrow;
    }
    return results;
  }

  /// Returns the first half of the iterable.
  List<E> firstHalf() => take(halfLength).toList();

  /// Returns the second half of the iterable.
  List<E> secondHalf() => drop(halfLength).toList();

  /// Returns a list with elements at [i] and [j] swapped.
  List<E> swap(int i, int j) {
    final list = toList();
    final aux = list[i];
    list[i] = list[j];
    list[j] = aux;
    return list;
  }

  /// Returns a random element.
  ///
  /// Throws [StateError] if the iterable is empty.
  E getRandom([int? seed]) {
    if (isEmpty) {
      throw StateError('Cannot get a random element from an empty iterable.');
    }
    final generator = Random(seed);
    final index = generator.nextInt(length);
    return toList()[index];
  }

  /// Checks if all elements in the specified [collection] are contained in
  /// this collection.
  bool containsAll(Iterable<E> collection) {
    for (final element in collection) {
      if (!contains(element)) return false;
    }
    return true;
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

  /// Returns a set of elements contained in this collection but not in [other].
  /// The returned set preserves the element iteration order of the original collection.
  ///
  /// Example:
  /// ```dart
  /// final result = [1, 2, 3, 4, 5, 6].subtract([4, 5, 6]);
  /// // result: {1, 2, 3}
  /// ```

  Set<E> subtract(Iterable<E> other) => toSet()..removeAll(other);

  /// Returns the first element matching [predicate], or `null`
  /// if element was not found.
  E? find(Predicate<E> predicate) {
    for (final element in this) {
      if (predicate(element)) {
        return element;
      }
    }

    return null;
  }
}
