import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

class _CustomType {
  const _CustomType(this.value);

  final int value;
}

void main() {
  group('Map extensions (basic)', () {
    test('swapKeysWithValues swaps entries', () {
      final map = {'a': 1, 'b': 2};
      expect(map.swapKeysWithValues(), {1: 'a', 2: 'b'});
    });

    test('setIfMissing inserts only when absent', () {
      final map = <String, int>{};
      expect(map.setIfMissing('a', 1), 1);
      expect(map['a'], 1);
      expect(map.setIfMissing('a', 2), 1);
      expect(map['a'], 1);
    });

    test('setIfMissing respects null values when key exists', () {
      final map = <String, int?>{'a': null};
      expect(map.setIfMissing('a', 2), isNull);
      expect(map['a'], isNull);
    });

    test('keysWhere, mapValues, and filter', () {
      final map = {'a': 1, 'b': 2, 'c': 3};
      expect(map.keysWhere((value) => value.isEven), ['b']);
      expect(map.mapValues((value) => value * 2), {'a': 2, 'b': 4, 'c': 6});
      expect(map.filter((key, value) => value >= 2), {'b': 2, 'c': 3});
    });
  });

  group('Map nullable helpers', () {
    test('isPrimitive, isEmptyOrNull, and isNotEmptyOrNull', () {
      Map<String, int>? map;
      expect(map.isEmptyOrNull, isTrue);
      map = {'a': 1};
      expect(map.isNotEmptyOrNull, isTrue);
      expect(map.isPrimitive(), isTrue);
      final nonPrimitive = {'a': const _CustomType(1)};
      expect(nonPrimitive.isPrimitive(), isFalse);
    });
  });

  group('Map flatMap', () {
    test('flattens nested maps and lists', () {
      final map = <String, Object?>{
        'a': {'b': 1},
        'items': [10, 20],
      };
      final result = map.flatMap();
      expect(result['a.b'], 1);
      expect(result['items.0'], 10);
      expect(result['items.1'], 20);
    });

    test('handles self-referential maps safely', () {
      final map = <String, Object?>{};
      map['self'] = map;
      expect(() => map.flatMap(), returnsNormally);
    });
  });
}
