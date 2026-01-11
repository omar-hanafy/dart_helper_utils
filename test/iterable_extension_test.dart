import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('takeOnly', () {
    test('returns first n elements', () {
      expect([1, 2, 3, 4, 5].takeOnly(3), [1, 2, 3]);
    });

    test('returns all elements when n > length', () {
      expect([1, 2].takeOnly(5), [1, 2]);
    });

    test('returns empty list when n is 0', () {
      expect([1, 2, 3].takeOnly(0), <int>[]);
    });

    test('returns empty list when n is negative', () {
      expect([1, 2, 3].takeOnly(-1), <int>[]);
    });

    test('works with empty list', () {
      expect(<int>[].takeOnly(3), <int>[]);
    });
  });

  group('drop', () {
    test('drops first n elements', () {
      expect([1, 2, 3, 4, 5].drop(2), [3, 4, 5]);
    });

    test('returns all elements when n is 0', () {
      expect([1, 2, 3].drop(0), [1, 2, 3]);
    });

    test('returns all elements when n is negative', () {
      expect([1, 2, 3].drop(-1), [1, 2, 3]);
    });

    test('returns empty list when n >= length', () {
      expect([1, 2].drop(5), <int>[]);
      expect([1, 2].drop(2), <int>[]);
    });

    test('works with empty list', () {
      expect(<int>[].drop(3), <int>[]);
    });
  });

  group('intersect', () {
    test('returns common elements', () {
      expect([1, 2, 3, 4].intersect([3, 4, 5, 6]), {3, 4});
    });

    test('returns empty set when no common elements', () {
      expect([1, 2].intersect([3, 4]), <int>{});
    });

    test('works with identical lists', () {
      expect([1, 2, 3].intersect([1, 2, 3]), {1, 2, 3});
    });

    test('works with empty lists', () {
      expect(<int>[].intersect([1, 2]), <int>{});
      expect([1, 2].intersect(<int>[]), <int>{});
    });
  });

  group('subtract', () {
    test('returns elements not in other', () {
      expect([1, 2, 3, 4, 5, 6].subtract([4, 5, 6]), {1, 2, 3});
    });

    test('returns all elements when other is empty', () {
      expect([1, 2, 3].subtract(<int>[]), {1, 2, 3});
    });

    test('returns empty set when all elements in other', () {
      expect([1, 2].subtract([1, 2, 3]), <int>{});
    });

    test('works with strings', () {
      expect(['a', 'b', 'c'].subtract(['b']), {'a', 'c'});
    });

    test('returns correct type (Set<E>)', () {
      final result = [1, 2, 3].subtract([2]);
      expect(result, isA<Set<int>>());
      expect(result, {1, 3});
    });
  });

  group('groupBy', () {
    test('groups elements by key', () {
      final numbers = [1, 2, 3, 4, 5, 6];
      final grouped = numbers.groupBy((n) => n.isEven ? 'even' : 'odd');

      expect(grouped['even'], [2, 4, 6]);
      expect(grouped['odd'], [1, 3, 5]);
    });

    test('preserves element order within groups', () {
      final words = ['apple', 'banana', 'apricot', 'blueberry'];
      final grouped = words.groupBy((w) => w[0]);

      expect(grouped['a'], ['apple', 'apricot']);
      expect(grouped['b'], ['banana', 'blueberry']);
    });

    test('works with empty iterable', () {
      final result = <int>[].groupBy((n) => n);
      expect(result, <int, List<int>>{});
    });

    test('is type-safe', () {
      final items = [1, 2, 3];
      final grouped = items.groupBy((n) => n % 2);

      expect(grouped, isA<Map<int, List<int>>>());
    });
  });

  group('tryRemoveWhere', () {
    test('removes elements matching predicate', () {
      final numbers = <int>[1, 2, 3, 4, 5];
      expect(numbers..tryRemoveWhere((n) => n.isEven), [1, 3, 5]);
    });

    test('does nothing on null list', () {
      const List<int>? numbers = null;
      expect(numbers..tryRemoveWhere((n) => n.isEven), isNull);
    });

    test('does nothing on empty list', () {
      final numbers = <int>[];
      expect(numbers..tryRemoveWhere((n) => n.isEven), <int>[]);
    });

    test('removes all matching elements', () {
      final words = <String>['a', 'bb', 'ccc', 'dddd'];
      expect(words..tryRemoveWhere((w) => w.length > 2), ['a', 'bb']);
    });
  });

  group('distinctBy', () {
    group('basic functionality', () {
      test('keeps first occurrence per key', () {
        final input = [1, 2, 2, 3, 1];
        final result = input.distinctBy((e) => e);
        expect(result, [1, 2, 3]);
      });

      test('returns empty list for empty input', () {
        final result = <int>[].distinctBy((e) => e);
        expect(result, <int>[]);
      });

      test('returns single element for single-element input', () {
        final result = [42].distinctBy((e) => e);
        expect(result, [42]);
      });

      test('preserves order of first occurrences', () {
        final input = ['a', 'b', 'a', 'c', 'b', 'd'];
        final result = input.distinctBy((e) => e);
        expect(result, ['a', 'b', 'c', 'd']);
      });

      test('works with different key types', () {
        final input = [1, 2, 3, 4, 5, 6];
        final result = input.distinctBy((n) => n % 3);
        expect(result, [1, 2, 3]); // keys: 1, 2, 0
      });
    });

    group('isValidKey filtering (Issue #5 fix)', () {
      test('skips elements with invalid keys', () {
        final input = ['a', '', 'b', ''];
        final result = input.distinctBy(
          (e) => e,
          isValidKey: (k) => k.isNotEmpty,
        );
        expect(result, ['a', 'b']);
      });

      test('handles nullable keys with validation', () {
        final input = <String?>['a', null, 'b', null, 'a'];
        final result = input.distinctBy(
          (e) => e,
          isValidKey: (k) => k != null,
        );
        expect(result, ['a', 'b']);
      });

      test('invalid keys do not affect uniqueness tracking', () {
        // Invalid keys should be completely ignored, not tracked
        final input = ['valid1', '', 'valid2', '', 'valid1'];
        final result = input.distinctBy(
          (e) => e,
          isValidKey: (k) => k.isNotEmpty,
        );
        // 'valid1' appears twice but only first is kept
        // empty strings are excluded entirely
        expect(result, ['valid1', 'valid2']);
      });

      test('isValidKey is now type-safe (Issue #5 type safety fix)', () {
        final input = [1, 2, 3, 4, 5];
        // isValidKey now accepts int, not dynamic
        final result = input.distinctBy(
          (e) => e,
          isValidKey: (int k) => k > 2,
        );
        expect(result, [3, 4, 5]);
      });
    });

    group('custom equality/hashCode', () {
      test('case-insensitive string comparison', () {
        final input = ['Alice', 'bob', 'ALICE', 'Bob'];
        final result = input.distinctBy(
          (e) => e,
          equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
          hashCode: (k) => k.toLowerCase().hashCode,
        );
        expect(result, ['Alice', 'bob']);
      });

      test('throws if only equals provided', () {
        final input = ['a', 'b'];
        expect(
          () => input.distinctBy((e) => e, equals: (a, b) => a == b),
          throwsArgumentError,
        );
      });

      test('throws if only hashCode provided', () {
        final input = ['a', 'b'];
        expect(
          () => input.distinctBy((e) => e, hashCode: (k) => k.hashCode),
          throwsArgumentError,
        );
      });

      test('works with both equals and hashCode', () {
        final input = [1, -1, 2, -2, 3];
        final result = input.distinctBy(
          (e) => e,
          equals: (a, b) => a.abs() == b.abs(),
          hashCode: (k) => k.abs().hashCode,
        );
        expect(result, [1, 2, 3]);
      });
    });

    group('combined isValidKey with custom equality', () {
      test('filters invalid keys with custom equality', () {
        final input = ['Alice', '', 'ALICE', 'bob', ''];
        final result = input.distinctBy(
          (e) => e,
          equals: (a, b) => a.toLowerCase() == b.toLowerCase(),
          hashCode: (k) => k.toLowerCase().hashCode,
          isValidKey: (k) => k.isNotEmpty,
        );
        expect(result, ['Alice', 'bob']);
      });
    });

    group('edge cases', () {
      test('works with lazy iterables', () {
        final lazy = [1, 2, 2, 3, 3, 3].where((e) => e > 0);
        final result = lazy.distinctBy((e) => e);
        expect(result, [1, 2, 3]);
      });

      test('handles all duplicates', () {
        final input = [1, 1, 1, 1, 1];
        final result = input.distinctBy((e) => e);
        expect(result, [1]);
      });

      test('handles no duplicates', () {
        final input = [1, 2, 3, 4, 5];
        final result = input.distinctBy((e) => e);
        expect(result, [1, 2, 3, 4, 5]);
      });
    });
  });
}
