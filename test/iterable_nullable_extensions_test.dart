import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

class _CustomType {
  const _CustomType(this.value);

  final int value;
}

void main() {
  group('Nullable list extensions', () {
    test('tryRemoveAt removes element safely', () {
      final list = <int>[1, 2, 3];
      list.tryRemoveAt(1);
      expect(list, [1, 3]);
      list.tryRemoveAt(10);
      expect(list, [1, 3]);
    });

    test('tryRemoveWhere removes matching elements', () {
      final list = <int>[1, 2, 3, 4];
      list.tryRemoveWhere((element) => element.isEven);
      expect(list, [1, 3]);
    });

    test('indexOfOrNull and indexWhereOrNull', () {
      final list = <int>[1, 2, 3];
      expect(list.indexOfOrNull(2), 1);
      expect(list.indexOfOrNull(null), isNull);
      expect(list.indexWhereOrNull((e) => e == 3), 2);
      final empty = <int>[];
      expect(empty.indexWhereOrNull((e) => e == 1), isNull);
    });
  });

  group('Nullable iterable extensions', () {
    test('of returns null for out of range', () {
      final list = <int>[1, 2];
      expect(list.of(1), 2);
      expect(list.of(10), isNull);
    });

    test('isEmptyOrNull and isNotEmptyOrNull', () {
      List<int>? list;
      expect(list.isEmptyOrNull, isTrue);
      expect(list.isNotEmptyOrNull, isFalse);
      list = [1];
      expect(list.isEmptyOrNull, isFalse);
      expect(list.isNotEmptyOrNull, isTrue);
    });

    test('firstOrDefault and lastOrDefault', () {
      final list = <int>[1, 2, 3];
      expect(list.firstOrDefault(9), 1);
      expect(list.lastOrDefault(9), 3);
      List<int>? empty;
      expect(empty.firstOrDefault(9), 9);
      expect(empty.lastOrDefault(9), 9);
    });

    test('tryGetRandom is deterministic with seed', () {
      final list = <int>[1, 2, 3, 4];
      final first = list.tryGetRandom(42);
      final second = list.tryGetRandom(42);
      expect(first, second);
    });

    test('isPrimitive and isEqual', () {
      expect([1, 2, 3].isPrimitive(), isTrue);
      expect([const _CustomType(1)].isPrimitive(), isFalse);
      expect([1, 2].isEqual([1, 2]), isTrue);
      expect([1, 2].isEqual([2, 1]), isFalse);
      List<int>? left;
      expect(left.isEqual([1]), isFalse);
    });

    test('totalBy sums values', () {
      final list = <int>[1, 2, 3];
      expect(list.totalBy((e) => e), 6);
      List<int>? empty;
      expect(empty.totalBy((e) => e), 0);
    });
  });

  group('Nullable set extensions', () {
    test('isEmptyOrNull and isNotEmptyOrNull', () {
      Set<int>? set;
      expect(set.isEmptyOrNull, isTrue);
      set = {1};
      expect(set.isNotEmptyOrNull, isTrue);
    });
  });
}
