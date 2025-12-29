import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Iterable extensions (non-nullable)', () {
    test('concat helpers', () {
      final list = [1, 2];
      expect(list.concatWithSingleList([3]), [1, 2, 3]);
      expect(list.concatWithSingleList([]), [1, 2]);
      expect(<int>[].concatWithSingleList([3]), [3]);
      expect(
        list.concatWithMultipleList([
          [3],
          [4, 5],
        ]),
        [1, 2, 3, 4, 5],
      );
      expect(list.concatWithMultipleList([]), [1, 2]);
      expect(
        <int>[].concatWithMultipleList([
          [3],
          [4],
        ]),
        [3, 4],
      );
    });

    test('filter and filterNot skip nulls', () {
      final list = <int?>[1, null, 2, 3];
      final filtered = list.filter((e) => e?.isEven ?? false);
      final filteredNot = list.filterNot((e) => e?.isEven ?? false);
      expect(filtered, [2]);
      expect(filteredNot, [1, 3]);
    });

    test('halfLength, takeOnly, and drop', () {
      final list = [1, 2, 3, 4, 5];
      expect(list.halfLength, 2);
      expect(list.takeOnly(2), [1, 2]);
      expect(list.drop(2), [3, 4, 5]);
      expect(list.takeOnly(10), list);
      expect(list.drop(10), isEmpty);
    });

    test('chunks validates size', () {
      expect(() => [1, 2].chunks(0), throwsArgumentError);
      expect([1, 2, 3, 4].chunks(2), [
        [1, 2],
        [3, 4],
      ]);
    });

    test('firstHalf and secondHalf', () {
      final list = [1, 2, 3, 4];
      expect(list.firstHalf(), [1, 2]);
      expect(list.secondHalf(), [3, 4]);
    });

    test('swap swaps elements', () {
      final list = [1, 2, 3];
      expect(list.swap(0, 2), [3, 2, 1]);
    });

    test('getRandom is deterministic with seed', () {
      final list = [1, 2, 3, 4, 5];
      final first = list.getRandom(10);
      final second = list.getRandom(10);
      expect(first, second);
    });

    test('getRandom throws on empty iterable', () {
      expect(() => <int>[].getRandom(), throwsStateError);
    });

    test('containsAll checks membership', () {
      final list = [1, 2, 3, 4];
      expect(list.containsAll([2, 4]), isTrue);
      expect(list.containsAll([2, 5]), isFalse);
    });

    test('distinctBy keeps first unique elements', () {
      final list = ['a', 'aa', 'bbb', 'cc'];
      final distinct = list.distinctBy((e) => e.length);
      expect(distinct, ['a', 'aa', 'bbb']);
    });

    test('subtract returns set difference', () {
      final list = [1, 2, 3, 4];
      expect(list.subtract([2, 4]), {1, 3});
    });

    test('find returns first matching element', () {
      final list = [1, 2, 3, 4];
      expect(list.find((e) => e.isEven), 2);
      expect(list.find((e) => e > 10), isNull);
    });
  });
}
