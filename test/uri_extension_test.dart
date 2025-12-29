import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Uri extensions', () {
    test('domainName strips www', () {
      final uri = Uri.parse('https://www.example.co.uk/path');
      expect(uri.domainName, 'example');
    });

    test('withQueryParameters replaces existing parameters', () {
      final uri = Uri.parse('https://example.com/api?foo=1&bar=2');
      final updated = uri.withQueryParameters({
        'a': 'b',
        'n': 1,
        'list': ['1', '2'],
        'nil': null,
      });

      expect(updated.queryParameters['a'], 'b');
      expect(updated.queryParameters['n'], '1');
      expect(updated.queryParametersAll['list'], ['1', '2']);
      expect(updated.queryParameters.containsKey('foo'), isFalse);
      expect(updated.queryParameters.containsKey('nil'), isFalse);
    });

    test('mergeQueryParameters merges and replaces duplicates', () {
      final uri = Uri.parse('https://example.com/api?foo=1&bar=2');
      final updated = uri.mergeQueryParameters({'bar': '3', 'baz': '4'});

      expect(updated.queryParameters['foo'], '1');
      expect(updated.queryParameters['bar'], '3');
      expect(updated.queryParameters['baz'], '4');
    });

    test('removeQueryParameters removes keys', () {
      final uri = Uri.parse('https://example.com/api?foo=1&bar=2');
      final updated = uri.removeQueryParameters(['bar']);

      expect(updated.queryParameters.containsKey('foo'), isTrue);
      expect(updated.queryParameters.containsKey('bar'), isFalse);
    });

    test('removeQueryParameters handles repeated keys', () {
      final uri = Uri.parse('https://example.com/api?a=1&a=2&b=3');
      final updated = uri.removeQueryParameters(['a']);

      expect(updated.queryParametersAll.containsKey('a'), isFalse);
      expect(updated.queryParameters['b'], '3');
    });

    test('appendPathSegment appends to existing path', () {
      final uri = Uri.parse('https://example.com/api/v1/');
      final updated = uri.appendPathSegment('users');

      expect(updated.path, '/api/v1/users');
    });

    test('appendPathSegment ignores empty segment', () {
      final uri = Uri.parse('https://example.com/api');
      final updated = uri.appendPathSegment('');

      expect(updated.path, '/api');
    });

    test('appendPathSegments appends multiple segments', () {
      final uri = Uri.parse('https://example.com');
      final updated = uri.appendPathSegments(['a', 'b']);

      expect(updated.path, '/a/b');
    });

    test('normalizeTrailingSlash adds and removes trailing slash', () {
      final uri = Uri.parse('https://example.com/api');
      final withSlash = uri.normalizeTrailingSlash();
      final withoutSlash = withSlash.normalizeTrailingSlash(
        trailingSlash: false,
      );

      expect(withSlash.path, '/api/');
      expect(withoutSlash.path, '/api');
    });

    test('rebuild updates selected components', () {
      final uri = Uri.parse('https://example.com/api?foo=1');
      final updated = uri.rebuild(
        schemeBuilder: (_) => 'http',
        hostBuilder: (_) => 'api.example.com',
        queryParametersBuilder: (params) => {...params, 'bar': 2},
      );

      expect(updated.scheme, 'http');
      expect(updated.host, 'api.example.com');
      expect(updated.queryParameters['foo'], '1');
      expect(updated.queryParameters['bar'], '2');
    });

    test(
      'rebuild prefers pathSegments and queryParameters when both provided',
      () {
        final uri = Uri.parse('https://example.com/api?foo=1');

        final updated = uri.rebuild(
          pathBuilder: (_) => '/should-not-win',
          pathSegmentsBuilder: (_) => ['v1', 'users'],
          queryBuilder: (_) => 'raw=1',
          queryParametersBuilder: (params) => {...params, 'bar': '2'},
        );

        expect(updated.path, '/v1/users');
        expect(updated.queryParameters.containsKey('raw'), isFalse);
        expect(updated.queryParameters['foo'], '1');
        expect(updated.queryParameters['bar'], '2');
      },
    );
  });
}
