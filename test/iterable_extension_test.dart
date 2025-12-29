import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Iterable Extensions', () {
    test('chunks splits list', () {
      final list = [1, 2, 3, 4, 5, 6, 7];
      final chunked = list.chunks(3);
      expect(chunked, [
        [1, 2, 3],
        [4, 5, 6],
        [7],
      ]);
    });

    test('partition splits based on predicate', () {
      final list = [1, 2, 3, 4, 5, 6];
      final (evens, odds) = list.partition((i) => i.isEven);
      expect(evens, [2, 4, 6]);
      expect(odds, [1, 3, 5]);
    });

    test('intersperse adds element between items', () {
      final list = [1, 2, 3];
      final result = list.intersperse(0).toList();
      expect(result, [1, 0, 2, 0, 3]);
    });

    test('associate creates map', () {
      final list = ['a', 'bb', 'ccc'];
      final map = list.associate((s) => s.length);
      expect(map, {1: 'a', 2: 'bb', 3: 'ccc'});
    });

    test('associate with value selector', () {
      final list = ['a', 'bb', 'ccc'];
      final map = list.associate((s) => s.length, (s) => s.toUpperCase());
      expect(map, {1: 'A', 2: 'BB', 3: 'CCC'});
    });

    test('mapConcurrent executes async', () async {
      final list = [1, 2, 3];
      final result = await list.mapConcurrent(
        (i) async => i * 2,
        parallelism: 2,
      );
      expect(result, unorderedEquals([2, 4, 6]));
    });
  });
}
