import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Iterable windowed', () {
    test('creates sliding windows with default step', () {
      final data = [1, 2, 3, 4, 5];
      final windows = data.windowed(3);
      expect(windows, [
        [1, 2, 3],
        [2, 3, 4],
        [3, 4, 5],
      ]);
    });

    test('respects custom step', () {
      final data = [1, 2, 3, 4, 5];
      final windows = data.windowed(3, step: 2);
      expect(windows, [
        [1, 2, 3],
        [3, 4, 5],
      ]);
    });

    test('step greater than size still advances correctly', () {
      final data = [1, 2, 3, 4, 5];
      final windows = data.windowed(2, step: 3);
      expect(windows, [
        [1, 2],
        [4, 5],
      ]);
    });

    test('includes partial windows when enabled', () {
      final data = [1, 2, 3, 4, 5];
      final windows = data.windowed(3, step: 2, partials: true);
      expect(windows, [
        [1, 2, 3],
        [3, 4, 5],
        [5],
      ]);
    });

    test('returns empty for empty iterable', () {
      final windows = <int>[].windowed(2);
      expect(windows, isEmpty);
    });
  });

  group('Iterable pairwise', () {
    test('creates consecutive pairs', () {
      final data = [1, 2, 3, 4];
      final pairs = data.pairwise();
      expect(pairs, [(1, 2), (2, 3), (3, 4)]);
    });

    test('returns empty for single item', () {
      expect([1].pairwise(), isEmpty);
    });

    test('returns empty for empty iterable', () {
      expect(<int>[].pairwise(), isEmpty);
    });
  });
}
