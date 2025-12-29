import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Map JSON helpers', () {
    test('deepMerge merges nested maps', () {
      final base = <String, Object?>{
        'a': {'b': 1, 'c': 2},
        'list': [1],
      };
      final other = <String, Object?>{
        'a': {'c': 3, 'd': 4},
        'e': 5,
        'list': [2],
      };

      final merged = base.deepMerge(other);
      final mergedA = merged['a'] as Map;
      final baseA = base['a'] as Map;

      expect(mergedA['b'], 1);
      expect(mergedA['c'], 3);
      expect(mergedA['d'], 4);
      expect(merged['e'], 5);
      expect(merged['list'], [2]);
      expect(baseA['c'], 2);
    });

    test('getPath reads nested values', () {
      final map = <String, Object?>{
        'a': {
          'b': {'c': 1},
        },
        'list': [
          {'id': 'x'},
        ],
      };

      expect(map.getPath('a.b.c'), 1);
      expect(map.getPath('list.0.id'), 'x');
      expect(map.getPath('list[0].id'), 'x');
      expect(map.getPath('missing'), null);
    });

    test('setPath writes nested values', () {
      final map = <String, Object?>{};
      final success = map.setPath('a.b.c', 1);

      expect(success, isTrue);
      expect(map.getPath('a.b.c'), 1);

      map.setPath('items.0.id', 'x');
      expect(map.getPath('items.0.id'), 'x');
    });

    test('setPath supports bracketed indices', () {
      final map = <String, Object?>{};
      map.setPath('items[0].id', 'x');
      expect(map.getPath('items.0.id'), 'x');
    });

    test('setPath returns false for invalid list index', () {
      final map = <String, Object?>{'list': <Object?>[]};

      expect(map.setPath('list.foo', 'x'), isFalse);
    });

    test('unflatten rebuilds nested maps and lists', () {
      final flat = <String, Object?>{
        'a.b': 1,
        'a.c': 2,
        'items.0.id': 'x',
        'items.1.id': 'y',
      };

      final nested = flat.unflatten();
      final nestedA = nested['a'] as Map;
      final items = nested['items'] as List;

      expect(nestedA['b'], 1);
      expect(nestedA['c'], 2);
      expect((items[0] as Map)['id'], 'x');
      expect((items[1] as Map)['id'], 'y');
    });

    test('unflatten can keep indices as map keys', () {
      final flat = <String, Object?>{'items.0.id': 'x'};

      final nested = flat.unflatten(parseIndices: false);
      final items = nested['items'] as Map;
      final indexEntry = items['0'] as Map;

      expect(indexEntry['id'], 'x');
    });
  });
}
