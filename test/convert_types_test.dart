import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('ConvertObject Bug Repro', () {
    test(
        'getMap should respect innerKey even if the intermediate object is a Map',
        () {
      final map = {
        'mainOrganizer': {
          'id': 4028,
          'user': {'id': 8357, 'name': 'John'}
        }
      };

      // The user wants to extract 'user' from 'mainOrganizer'.
      // map.getMap('mainOrganizer') returns the whole map.
      // map.getMap('mainOrganizer', innerKey: 'user') should return the inner 'user' map.

      final result = map.getMap('mainOrganizer', innerKey: 'user');

      expect(result, equals({'id': 8357, 'name': 'John'}));
    });

    test(
        'getList should respect innerKey even if the intermediate object is a List',
        () {
      // Similar scenario for Lists to ensure consistency
      final map = {
        'items': {
          'list': [1, 2, 3],
          'meta': 'data'
        }
      };

      // map.getList('items') would try to convert the map to a list (values probably).
      // map.getList('items', innerKey: 'list') should return [1, 2, 3].

      final result = map.getList('items', innerKey: 'list');

      expect(result, equals([1, 2, 3]));
    });

    test('getString should respect innerKey', () {
      final map = {
        'wrapper': {'target': 'success'}
      };
      final result = map.getString('wrapper', innerKey: 'target');
      expect(result, 'success');
    });
  });
}
