import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('NumbersHelper stats', () {
    test('mean, median, and mode', () {
      final values = [1, 2, 3, 3];
      expect(NumbersHelper.mean(values), 2.25);
      expect(NumbersHelper.median(values), 2.5);
      expect(NumbersHelper.mode(values), [3]);
    });

    test('variance and standardDeviation', () {
      final values = [1, 2, 3];
      expect(NumbersHelper.variance(values), closeTo(2 / 3, 0.0001));
      expect(NumbersHelper.standardDeviation(values), closeTo(0.8164, 0.01));
    });

    test('percentile uses 0-100 range', () {
      final values = [0, 10, 20, 30, 40];
      expect(NumbersHelper.percentile(values, 50), 20);
      expect(NumbersHelper.percentile(values, 100), 40);
      expect(() => NumbersHelper.percentile(values, -1), throwsArgumentError);
    });
  });

  group('Iterable stats extensions', () {
    test('num stats', () {
      final values = <num>[1, 2, 3];
      expect(values.mean, 2);
      expect(values.median, 2);
      expect(values.mode, [1, 2, 3]);
      expect(values.percentile(50), 2);
    });

    test('int stats', () {
      final values = <int>[1, 2, 3];
      expect(values.mean, 2);
      expect(values.median, 2);
      expect(values.mode, [1, 2, 3]);
      expect(values.percentile(100), 3);
    });

    test('double stats', () {
      final values = <double>[1.5, 2.5, 3.5];
      expect(values.mean, 2.5);
      expect(values.median, 2.5);
      expect(values.percentile(0), 1.5);
    });
  });

  group('7.0.0 integer statistics are exact', () {
    test('mean, median, variance, and standardDeviation are not truncated', () {
      final values = [1, 2];
      expect(values.mean, 1.5);
      expect(values.median, 1.5);
      expect(values.variance, 0.25);
      expect(values.standardDeviation, 0.5);
    });

    test('the num statistics return doubles', () {
      final values = <num>[1, 2, 4];
      expect(values.mean, isA<double>());
      expect(values.variance, isA<double>());
      expect(values.standardDeviation, isA<double>());
    });

    test('mode and percentile stay integral', () {
      final values = [3, 1, 3, 2, 1];
      expect(values.mode, [3, 1]);
      expect(values.percentile(50), 2);
    });

    test('statistics on an empty iterable throw ArgumentError', () {
      expect(() => <int>[].mean, throwsArgumentError);
      expect(() => <int>[].mode, throwsArgumentError);
      expect(() => <double>[].median, throwsArgumentError);
    });
  });
}
