import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('String normalizeWhitespace', () {
    test('collapses whitespace and trims', () {
      expect('  Line   1 \n Line 2  '.normalizeWhitespace(), 'Line 1 Line 2');
    });

    test('returns empty for whitespace only', () {
      expect('   \n\t  '.normalizeWhitespace(), '');
    });
  });

  group('String slugify', () {
    test('converts to lowercase slug', () {
      expect('Hello, World!'.slugify(), 'hello-world');
    });

    test('collapses underscores and spaces', () {
      expect('Foo__Bar  Baz'.slugify(), 'foo-bar-baz');
    });

    test('collapses repeated separators', () {
      expect('Already--slug'.slugify(), 'already-slug');
    });

    test('retains numbers', () {
      expect('Version 2 Update'.slugify(), 'version-2-update');
    });

    test('supports custom separator', () {
      expect('Hello World'.slugify(separator: '_'), 'hello_world');
    });

    test('returns empty when no valid content', () {
      expect('---'.slugify(), '');
    });
  });
}
