import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Basic Algorithm Tests', () {
    test('Dice Coefficient algorithm', () {
      expect(StringSimilarity.diceCoefficient('night', 'nacht'),
          closeTo(0.25, 0.01));
      expect(StringSimilarity.diceCoefficient('context', 'contact'),
          closeTo(0.5, 0.01));
      expect(StringSimilarity.diceCoefficient('abc', 'abc'), equals(1.0));
      expect(StringSimilarity.diceCoefficient('', ''), equals(1.0));
      expect(StringSimilarity.diceCoefficient('abc', ''), equals(0.0));
      expect(StringSimilarity.diceCoefficient('a', 'a'), equals(1.0));
    });

    test('Levenshtein Distance algorithm', () {
      expect(
          StringSimilarity.levenshteinDistance('kitten', 'sitting'), equals(3));
      expect(StringSimilarity.levenshteinDistance('abc', 'abc'), equals(0));
      expect(StringSimilarity.levenshteinDistance('', ''), equals(0));
      expect(StringSimilarity.levenshteinDistance('abc', ''), equals(3));
      expect(StringSimilarity.levenshteinDistance('', 'abc'), equals(3));

      // Test the normalized score through compare method
      expect(
          StringSimilarity.compare(
              'kitten', 'sitting', SimilarityAlgorithm.levenshteinDistance),
          closeTo(0.57, 0.01));
    });

    test('Jaro algorithm', () {
      expect(StringSimilarity.jaro('MARTHA', 'MARHTA'), closeTo(0.94, 0.01));
      expect(StringSimilarity.jaro('DIXON', 'DICKSONX'), closeTo(0.77, 0.01));
      expect(StringSimilarity.jaro('abc', 'abc'), equals(1.0));
      expect(StringSimilarity.jaro('', ''), equals(1.0));
      expect(StringSimilarity.jaro('abc', ''), equals(0.0));
    });

    test('Jaro-Winkler algorithm', () {
      expect(StringSimilarity.jaroWinkler('MARTHA', 'MARHTA'),
          closeTo(0.96, 0.01));
      expect(StringSimilarity.jaroWinkler('DIXON', 'DICKSONX'),
          closeTo(0.81, 0.01));
      expect(StringSimilarity.jaroWinkler('abc', 'abc'), equals(1.0));
      expect(StringSimilarity.jaroWinkler('', ''), equals(1.0));
      expect(StringSimilarity.jaroWinkler('abc', ''), equals(0.0));

      // Test prefix scaling
      const config = StringSimilarityConfig(jaroPrefixScale: 0.2);
      expect(StringSimilarity.jaroWinkler('program', 'porgram', config: config),
          greaterThan(StringSimilarity.jaroWinkler('program', 'porgram')));
    });

    test('Cosine Similarity algorithm', () {
      expect(StringSimilarity.cosine('this is a test', 'this is a test'),
          equals(1.0));
      expect(StringSimilarity.cosine('this is a test', 'this is another test'),
          closeTo(0.75, 0.01));
      expect(StringSimilarity.cosine('', ''), equals(1.0));
      expect(StringSimilarity.cosine('abc', ''), equals(0.0));

      // Single word behavior for cosine
      expect(StringSimilarity.cosine('test', 'test'), equals(1.0));
      expect(StringSimilarity.cosine('test', 'tent'),
          equals(0.0)); // No common bigrams
    });

    test('Soundex algorithm', () {
      expect(StringSimilarity.soundex('Robert'), equals('R163'));
      expect(StringSimilarity.soundex('Rupert'), equals('R163'));
      expect(StringSimilarity.soundex('Ashcraft'), equals('A261'));
      expect(StringSimilarity.soundex('Ashcroft'), equals('A261'));
      expect(StringSimilarity.soundex(''), equals(''));

      // Test through compare
      expect(
          StringSimilarity.compare(
              'Robert', 'Rupert', SimilarityAlgorithm.soundex),
          equals(1.0));
      expect(
          StringSimilarity.compare(
              'Robert', 'Smith', SimilarityAlgorithm.soundex),
          equals(0.0));
    });
  });

  group('Configuration Tests', () {
    test('Case sensitivity', () {
      // Default is case-insensitive (toLowerCase=true)
      const defaultConfig = StringSimilarityConfig();
      expect(StringSimilarity.diceCoefficient('HELLO', 'hello', defaultConfig),
          equals(1.0));

      // Case-sensitive configuration
      const caseSensitiveConfig = StringSimilarityConfig(toLowerCase: false);
      expect(
          StringSimilarity.diceCoefficient(
              'HELLO', 'hello', caseSensitiveConfig),
          lessThan(1.0));
    });

    test('Remove spaces configuration', () {
      const defaultConfig = StringSimilarityConfig();
      expect(
          StringSimilarity.diceCoefficient(
              'hello world', 'helloworld', defaultConfig),
          lessThan(1.0));

      const removeSpacesConfig = StringSimilarityConfig(removeSpaces: true);
      expect(
          StringSimilarity.diceCoefficient(
              'hello world', 'helloworld', removeSpacesConfig),
          equals(1.0));
    });

    test('Remove accents configuration', () {
      const defaultConfig = StringSimilarityConfig();
      expect(StringSimilarity.diceCoefficient('café', 'cafe', defaultConfig),
          lessThan(1.0));

      const removeAccentsConfig = StringSimilarityConfig(removeAccents: true);
      expect(
          StringSimilarity.diceCoefficient('café', 'cafe', removeAccentsConfig),
          equals(1.0));
    });

    test('Custom pre-processor', () {
      // Custom preprocessor to replace numbers with words
      String preprocessor(String input) {
        return input
            .replaceAll('1', 'one')
            .replaceAll('2', 'two')
            .replaceAll('3', 'three');
      }

      final config = StringSimilarityConfig(preProcessor: preprocessor);

      // Should treat "1" and "one" as identical
      expect(StringSimilarity.diceCoefficient('test 1', 'test one', config),
          equals(1.0));
    });

    test('Diacritic package integration', () {
      // This test demonstrates how to use the diacritic package integration
      // Uncommenting requires adding the diacritic package as a dependency

      /* Uncomment to test with actual diacritic package

      // Simulate the implementation of removeDiacriticsWithPackage with real package
      String withDiacriticPackage(String input) {
        return removeDiacritics(input);
      }

      final config = StringSimilarityConfig(
        removeAccents: false, // Don't use built-in accent removal
        preProcessor: withDiacriticPackage // Use package instead
      );

      expect(
        StringSimilarity.diceCoefficient('café', 'cafe', config),
        equals(1.0)
      );
      */

      // For now, test the fallback implementation
      const config = StringSimilarityConfig(
          removeAccents: false,
          preProcessor: StringSimilarity.removeDiacriticsWithPackage);

      expect(StringSimilarity.diceCoefficient('café', 'cafe', config),
          equals(1.0));
    });
  });

  group('String Extensions Tests', () {
    test('String extension methods', () {
      expect('night'.diceCoefficient('nacht'), closeTo(0.25, 0.01));
      expect('kitten'.levenshteinDistance('sitting'), equals(3));
      expect('MARTHA'.jaro('MARHTA'), closeTo(0.94, 0.01));
      expect('MARTHA'.jaroWinkler('MARHTA'), closeTo(0.96, 0.01));
      expect(
          'this is a test'.cosine('this is another test'), closeTo(0.75, 0.01));
      expect('Robert'.soundex(), equals('R163'));
    });

    test('mostSimilarTo extension', () {
      final candidates = ['apple', 'banana', 'orange', 'pear', 'apricot'];

      expect(
          'appel'
              .mostSimilarTo(candidates, SimilarityAlgorithm.diceCoefficient),
          equals('apple'));

      expect(
          'orang'.mostSimilarTo(
              candidates, SimilarityAlgorithm.levenshteinDistance),
          equals('orange'));
    });

    test('rankByRelevance extension', () {
      final candidates = ['apple', 'banana', 'orange', 'pear', 'apricot'];

      final ranking =
          'appl'.rankByRelevance(candidates, SimilarityAlgorithm.jaroWinkler);

      expect(ranking.length, equals(5));
      expect(ranking.first.key, equals('apple'));
      expect(ranking.last.value, lessThan(ranking.first.value));
    });
  });

  group('Utility Methods Tests', () {
    test('compareWithDetails', () {
      final result = StringSimilarity.compareWithDetails(
          'test', 'tent', SimilarityAlgorithm.levenshteinDistance);

      expect(result.score, closeTo(0.75, 0.01));
      expect(result.firstString, equals('test'));
      expect(result.secondString, equals('tent'));
      expect(result.algorithm, equals(SimilarityAlgorithm.levenshteinDistance));
      expect(result.metadata['levenshteinDistance'], equals(1));
    });

    test('findMatches', () {
      final candidates = ['apple', 'banana', 'orange', 'pear', 'apricot'];

      final matches = StringSimilarity.findMatches(
          'appel', candidates, SimilarityAlgorithm.diceCoefficient,
          threshold: 0.5);

      expect(matches, contains('apple'));
      expect(matches, isNot(contains('banana')));
    });

    test('findBestMatch', () {
      final candidates = ['apple', 'banana', 'orange', 'pear', 'apricot'];

      final bestMatch = StringSimilarity.findBestMatch(
          'appel', candidates, SimilarityAlgorithm.diceCoefficient);

      expect(bestMatch?.key, equals('apple'));
      expect(bestMatch?.value, greaterThanOrEqualTo(0.5));
    });

    test('generateReport', () {
      final report = StringSimilarity.generateReport(
          'test', 'tent', SimilarityAlgorithm.levenshteinDistance);

      expect(report, contains('Similarity Score:'));
      expect(report, contains('test'));
      expect(report, contains('tent'));
      expect(report, contains('levenshteinDistance'));
    });
  });

  group('Edge Cases Tests', () {
    test('Empty strings', () {
      // Both empty
      expect(StringSimilarity.diceCoefficient('', ''), equals(1.0));
      expect(StringSimilarity.levenshteinDistance('', ''), equals(0));
      expect(StringSimilarity.jaro('', ''), equals(1.0));

      // One empty
      expect(StringSimilarity.diceCoefficient('abc', ''), equals(0.0));
      expect(StringSimilarity.levenshteinDistance('abc', ''), equals(3));
      expect(StringSimilarity.jaro('abc', ''), equals(0.0));
    });

    test('Very long strings', () {
      final longStr1 = 'a' * 10000;
      final longStr2 = 'a' * 9990 + 'b' * 10;

      // Should handle long strings without errors
      expect(StringSimilarity.diceCoefficient(longStr1, longStr2),
          closeTo(0.999, 0.001));
    });

    test('Unicode characters', () {
      expect(
          StringSimilarity.diceCoefficient('こんにちは', 'こんばんは'), greaterThan(0.0));
    });

    test('Accented characters', () {
      const noAccentsConfig = StringSimilarityConfig(removeAccents: true);

      expect(
          StringSimilarity.diceCoefficient('naïve', 'naive', noAccentsConfig),
          equals(1.0));

      expect(StringSimilarity.diceCoefficient('café', 'cafe', noAccentsConfig),
          equals(1.0));
    });
  });

  group('Caching Tests', () {
    setUp(StringSimilarity.clearCache);

    test('Cache behavior', () {
      // Enable caching
      const config = StringSimilarityConfig(enableCache: true);

      // First call should populate cache
      StringSimilarity.diceCoefficient(
          'performance test', 'caching test', config);

      // Get cache stats
      final stats = StringSimilarity.getCacheStats();

      // Should have populated caches
      expect(stats['bigramCacheEnabled'], isTrue);
      expect(stats['bigramCacheSize'], greaterThan(0));
      expect(stats['normalizationCacheEnabled'], isTrue);
      expect(stats['normalizationCacheSize'], greaterThan(0));
    });

    test('Disable caching', () {
      // Disable caching
      const config = StringSimilarityConfig(enableCache: false);

      // Run comparison
      StringSimilarity.diceCoefficient(
          'performance test', 'caching test', config);

      // Get cache stats
      final stats = StringSimilarity.getCacheStats();

      // Cache should be empty
      expect(stats['bigramCacheSize'], equals(0));
      expect(stats['normalizationCacheSize'], equals(0));
    });
  });

  group('Batch Processing Tests', () {
    test('compareBatch', () {
      final pairs = [
        ['test', 'text'],
        ['hello', 'hallo'],
        ['identical', 'identical']
      ];

      final results = StringSimilarity.compareBatch(
          pairs, SimilarityAlgorithm.diceCoefficient);

      expect(results.length, equals(3));
      expect(results[2], equals(1.0)); // Identical strings
      expect(results[0],
          greaterThanOrEqualTo(0.33)); // Changed from 0.5 to 0.33 for test/text
    });

    test('compareBatch with parallel flag', () {
      final pairs = [
        ['test', 'text'],
        ['hello', 'hallo'],
        ['identical', 'identical']
      ];

      final results = StringSimilarity.compareBatch(
          pairs, SimilarityAlgorithm.diceCoefficient,
          parallel: true);

      expect(results.length, equals(3));
      expect(results[2], equals(1.0)); // Identical strings
    });

    test('compareAsync', () async {
      final result = await StringSimilarity.compareAsync(
          'test', 'text', SimilarityAlgorithm.diceCoefficient);

      expect(result, greaterThanOrEqualTo(0.33));
    });
  });
}
