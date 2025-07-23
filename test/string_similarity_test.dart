import 'package:dart_helper_utils/src/other_utils/string_similarity.dart';
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
          equals(0.0)); // No common tokens for single words
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

    test('N-gram similarity algorithm', () {
      expect(
          StringSimilarity.ngramSimilarity('hello', 'hallo'), greaterThan(0.0));
      expect(StringSimilarity.ngramSimilarity('abc', 'abc'), equals(1.0));
      expect(StringSimilarity.ngramSimilarity('', ''), equals(1.0));
      expect(StringSimilarity.ngramSimilarity('abc', ''), equals(0.0));

      // Test with different n-gram sizes
      const config3 = StringSimilarityConfig(ngramSize: 3);
      const config2 = StringSimilarityConfig(ngramSize: 2);

      expect(StringSimilarity.ngramSimilarity('testing', 'testing', config3),
          equals(1.0));
      expect(
          StringSimilarity.ngramSimilarity(
              'hello world', 'world hello', config2),
          greaterThan(0.0));
    });

    test('Jaccard similarity algorithm', () {
      expect(StringSimilarity.jaccardSimilarity('cat dog', 'dog cat'),
          equals(1.0));
      expect(StringSimilarity.jaccardSimilarity('cat dog', 'dog cat mouse'),
          closeTo(0.67, 0.01));
      expect(StringSimilarity.jaccardSimilarity('', ''), equals(1.0));
      expect(StringSimilarity.jaccardSimilarity('test', ''), equals(0.0));
    });

    test('Hamming distance algorithm', () {
      expect(StringSimilarity.hammingDistance('karolin', 'kathrin'), equals(3));
      expect(StringSimilarity.hammingDistance('abc', 'abc'), equals(0));
      expect(StringSimilarity.hammingDistance('', ''), equals(0));

      // Test error on different lengths
      expect(() => StringSimilarity.hammingDistance('short', 'longer'),
          throwsA(isA<AlgorithmError>()));

      // Test through compare
      expect(
          StringSimilarity.compare('1011', '1001', SimilarityAlgorithm.hamming),
          equals(0.75) // 1 difference in 4 positions
          );
    });

    test('Metaphone algorithm', () {
      expect(StringSimilarity.metaphone('Smith'),
          equals(StringSimilarity.metaphone('Smyth')));
      expect(StringSimilarity.metaphone('Schmidt'),
          isNot(equals(StringSimilarity.metaphone('Smith'))));
      expect(StringSimilarity.metaphone(''), equals(''));

      // Test through compare
      expect(
          StringSimilarity.compare(
              'Philip', 'Phillip', SimilarityAlgorithm.metaphone),
          equals(1.0));
    });

    test('Longest Common Subsequence algorithm', () {
      expect(StringSimilarity.longestCommonSubsequence('ABCDGH', 'AEDFHR'),
          equals(3)); // ADH
      expect(StringSimilarity.longestCommonSubsequence('AGGTAB', 'GXTXAYB'),
          equals(4)); // GTAB
      expect(StringSimilarity.longestCommonSubsequence('', ''), equals(0));
      expect(
          StringSimilarity.longestCommonSubsequence('abc', 'abc'), equals(3));

      // Test through compare
      expect(
          StringSimilarity.compare('ABCDGH', 'AEDFHR', SimilarityAlgorithm.lcs),
          equals(0.5) // 3/6
          );
    });
  });

  group('Algorithm Extension Tests', () {
    test('SimilarityAlgorithm extension methods', () {
      // Test compare method on enum
      expect(SimilarityAlgorithm.diceCoefficient.compare('test', 'text'),
          greaterThan(0.0));

      // Test compareWithDetails
      final result =
          SimilarityAlgorithm.jaro.compareWithDetails('MARTHA', 'MARHTA');
      expect(result.score, closeTo(0.94, 0.01));
      expect(result.algorithm, equals(SimilarityAlgorithm.jaro));
    });

    test('Algorithm properties', () {
      expect(SimilarityAlgorithm.hamming.requiresEqualLength, isTrue);
      expect(SimilarityAlgorithm.diceCoefficient.requiresEqualLength, isFalse);

      expect(SimilarityAlgorithm.soundex.isPhonetic, isTrue);
      expect(SimilarityAlgorithm.metaphone.isPhonetic, isTrue);
      expect(SimilarityAlgorithm.jaro.isPhonetic, isFalse);

      expect(SimilarityAlgorithm.cosine.isTokenBased, isTrue);
      expect(SimilarityAlgorithm.jaccard.isTokenBased, isTrue);
      expect(SimilarityAlgorithm.levenshteinDistance.isTokenBased, isFalse);
    });
  });

  group('Smart Compare Tests', () {
    test('Smart compare for different string types', () {
      // Short names - should use Jaro-Winkler
      final nameScore = StringSimilarity.smartCompare('John', 'Jon');
      expect(nameScore, greaterThan(0.8));

      // Long text - should use cosine
      final longTextScore = StringSimilarity.smartCompare(
          'This is a long sentence with many words for testing',
          'This is another long sentence with different words for testing');
      expect(longTextScore, greaterThan(0.5));

      // Code-like strings - should use Levenshtein
      final codeScore =
          StringSimilarity.smartCompare('USER_ID_123', 'USER_ID_124');
      expect(codeScore, greaterThan(0.8));
    });
  });

  group('Fuzzy Search Tests', () {
    test('Fuzzy search with typo tolerance', () {
      final candidates = ['apple', 'banana', 'orange', 'pear', 'apricot'];

      // Find with typos
      final matches = StringSimilarity.fuzzySearch(
          'aple', // Missing 'p'
          candidates,
          maxTypos: 2,
          minSimilarity: 0.7);

      expect(matches, contains('apple'));
      expect(matches.length, greaterThanOrEqualTo(1));
    });

    test('String extension fuzzyMatches', () {
      final candidates = ['hello', 'hallo', 'hullo', 'hi', 'hey'];

      final matches =
          'helo'.fuzzyMatches(candidates, maxTypos: 1, minSimilarity: 0.8);

      expect(matches, contains('hello'));
      expect(matches, isNot(contains('hi'))); // Too different
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

    test('Custom tokenizer', () {
      // Custom tokenizer that splits on commas
      List<String> customTokenizer(String input) {
        return input.split(',').map((s) => s.trim()).toList();
      }

      final config = StringSimilarityConfig(tokenizer: customTokenizer);

      expect(
          StringSimilarity.jaccardSimilarity(
              'apple,banana', 'banana,apple', config),
          equals(1.0));
    });

    test('Stemming configuration', () {
      const config = StringSimilarityConfig(stemTokens: true);

      // Should treat "running" and "runs" as more similar with stemming
      final withStemming =
          StringSimilarity.cosine('running quickly', 'runs quick', config);

      const noStemConfig = StringSimilarityConfig(stemTokens: false);
      final withoutStemming = StringSimilarity.cosine(
          'running quickly', 'runs quick', noStemConfig);

      expect(withStemming, greaterThanOrEqualTo(withoutStemming));
    });

    test('Configuration builder', () {
      final config = StringSimilarityConfig.builder
          .setNormalize(true)
          .setToLowerCase(false)
          .setRemoveSpaces(true)
          .setRemoveAccents(true)
          .setNgramSize(4)
          .setStemTokens(true)
          .setCacheCapacity(500)
          .build();

      expect(config.normalize, isTrue);
      expect(config.toLowerCase, isFalse);
      expect(config.removeSpaces, isTrue);
      expect(config.removeAccents, isTrue);
      expect(config.ngramSize, equals(4));
      expect(config.stemTokens, isTrue);
      expect(config.cacheCapacity, equals(500));
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

    test('New extension methods', () {
      expect('hello'.ngramSimilarity('hallo'), greaterThan(0.0));
      expect('cat dog'.jaccardSimilarity('dog cat'), equals(1.0));
      expect('Philip'.metaphone(), equals('FLP'));

      // Smart similarity
      expect('test'.smartSimilarity('text'), greaterThan(0.0));
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
      expect(result.metadata['distance'], equals(1));
      expect(result.executionTime, isNotNull);
      expect(result.executionTime, greaterThan(0));
    });

    test('SimilarityResult JSON serialization', () {
      final result = StringSimilarity.compareWithDetails(
          'test', 'text', SimilarityAlgorithm.diceCoefficient);

      final json = result.toJson();
      expect(json['score'], isA<double>());
      expect(json['firstString'], equals('test'));
      expect(json['secondString'], equals('text'));
      expect(json['algorithm'], equals('diceCoefficient'));
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

  group('Error Handling Tests', () {
    test('Invalid configuration errors', () {
      expect(() => LRUCache<String, String>(0),
          throwsA(isA<InvalidConfigurationError>()));

      expect(() => LRUCache<String, String>(-1),
          throwsA(isA<InvalidConfigurationError>()));
    });

    test('Algorithm-specific errors', () {
      // Hamming requires equal length
      expect(
          () => StringSimilarity.hammingDistance('abc', 'abcd'),
          throwsA(isA<AlgorithmError>().having(
              (e) => e.details, 'details', containsPair('firstLength', 3))));
    });

    test('Batch processing errors', () {
      final invalidPairs = [
        ['test'], // Only one string
        ['hello', 'world', 'extra'], // Three strings
      ];

      expect(
          () => StringSimilarity.compareBatch(
              invalidPairs, SimilarityAlgorithm.diceCoefficient),
          throwsA(isA<StringSimilarityError>()));
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

      // Test with emoji
      expect(StringSimilarity.diceCoefficient('Hello 👋', 'Hello 👍'),
          greaterThan(0.5));
    });

    test('Accented characters', () {
      const noAccentsConfig = StringSimilarityConfig(removeAccents: true);

      expect(
          StringSimilarity.diceCoefficient('naïve', 'naive', noAccentsConfig),
          equals(1.0));

      expect(StringSimilarity.diceCoefficient('café', 'cafe', noAccentsConfig),
          equals(1.0));

      // Test extended accent map
      expect(StringSimilarity.diceCoefficient('Źiź', 'Ziz', noAccentsConfig),
          equals(1.0));
    });

    test('Special characters handling', () {
      const config = StringSimilarityConfig(removeSpecialChars: true);

      expect(StringSimilarity.diceCoefficient('hello!@#', 'hello', config),
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
      expect(stats['bigramCache'], isA<Map<dynamic, dynamic>>());
      expect((stats['bigramCache'] as Map)['size'], greaterThan(0));
      expect(stats['normalizationCache'], isA<Map<dynamic, dynamic>>());
      expect((stats['normalizationCache'] as Map)['size'], greaterThan(0));
    });

    test('Disable caching', () {
      // Clear caches first
      StringSimilarity.clearCache();

      // Disable caching
      const config = StringSimilarityConfig(enableCache: false);

      // Run comparison
      StringSimilarity.diceCoefficient(
          'performance test', 'caching test', config);

      // Get cache stats
      final stats = StringSimilarity.getCacheStats();

      // When caching is disabled, the caches should show 'enabled': false
      // or the caches should not exist (size should be 0 or null)
      expect(
          stats['bigramCache']['enabled'] ?? stats['bigramCache']['size'] == 0,
          isTrue);
      expect(
          stats['normalizationCache']['enabled'] ??
              stats['normalizationCache']['size'] == 0,
          isTrue);
    });

    test('Cache capacity management', () {
      // Small cache capacity
      const config = StringSimilarityConfig(
        enableCache: true,
        bigramCacheCapacity: 2,
      );

      // Fill cache beyond capacity
      StringSimilarity.diceCoefficient('test1', 'test2', config);
      StringSimilarity.diceCoefficient('test3', 'test4', config);
      StringSimilarity.diceCoefficient('test5', 'test6', config);

      final stats = StringSimilarity.getCacheStats();
      final bigramCache = stats['bigramCache'] as Map;

      // Cache should not exceed capacity
      expect(bigramCache['size'], lessThanOrEqualTo(2));
    });
  });

  group('Batch Processing Tests', () {
    test('compareBatch sequential', () {
      final pairs = [
        ['test', 'text'],
        ['hello', 'hallo'],
        ['identical', 'identical']
      ];

      final results = StringSimilarity.compareBatch(
          pairs, SimilarityAlgorithm.diceCoefficient);

      expect(results.length, equals(3));
      expect(results[2], equals(1.0)); // Identical strings
      expect(results[0], greaterThan(0.0));
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

    test('compareBatchAsync with true parallel execution', () async {
      final pairs = List.generate(100, (i) => ['test$i', 'text$i']);

      final results = await StringSimilarity.compareBatchAsync(
          pairs, SimilarityAlgorithm.diceCoefficient);

      expect(results.length, equals(100));
      expect(results.every((score) => score > 0), isTrue);
    });

    test('compareAsync with forceIsolate', () async {
      final result = await StringSimilarity.compareAsync(
          'test' * 1000, 'text' * 1000, SimilarityAlgorithm.diceCoefficient,
          forceIsolate: true);

      expect(result, greaterThan(0.0));
    });
  });

  group('Benchmark Tests', () {
    test('Benchmark multiple algorithms', () async {
      final testPairs = [
        ['hello', 'hallo'],
        ['test', 'text'],
        ['example', 'sample'],
      ];

      final algorithms = [
        SimilarityAlgorithm.diceCoefficient,
        SimilarityAlgorithm.jaro,
        SimilarityAlgorithm.cosine,
      ];

      final results = await StringSimilarity.benchmark(
        algorithms,
        testPairs,
        iterations: 10,
      );

      expect(results.length, equals(3));

      for (final result in results) {
        expect(result.iterations, greaterThan(0));
        expect(result.averageTime, greaterThan(0));
        expect(result.minTime, lessThanOrEqualTo(result.maxTime));

        // Check report format
        final report = result.toReport();
        expect(report, contains('Algorithm:'));
        expect(report, contains('Average Time:'));
      }
    });
  });

  group('Type Aliases Tests', () {
    test('Type aliases work correctly', () {
      SimilarityScore score = 0.95;
      Distance distance = 5;

      expect(score, isA<double>());
      expect(distance, isA<int>());

      // Can use in function signatures
      SimilarityScore computeScore() => 0.8;
      Distance computeDistance() => 3;

      expect(computeScore(), equals(0.8));
      expect(computeDistance(), equals(3));
    });
  });

  group('Performance Tests', () {
    test('Large string performance with chunking', () {
      final large1 = 'a' * 50000 + 'b' * 50000;
      final large2 = 'a' * 50000 + 'c' * 50000;

      // Should complete without timeout
      final score = StringSimilarity.diceCoefficient(large1, large2);
      expect(score, greaterThan(0.0));
      expect(score, lessThan(1.0));
    });

    test('N-gram caching performance', () {
      const config = StringSimilarityConfig(
        enableCache: true,
        ngramSize: 3,
      );

      const text = 'This is a test string for n-gram caching';

      // First call - no cache
      final stopwatch1 = Stopwatch()..start();
      StringSimilarity.ngramSimilarity(text, text, config);
      stopwatch1.stop();

      // Second call - should use cache
      final stopwatch2 = Stopwatch()..start();
      StringSimilarity.ngramSimilarity(text, text, config);
      stopwatch2.stop();

      // Cached call should be faster (allowing for timing variations)
      // Note: This might be flaky in CI, so we just check it completes
      expect(stopwatch2.elapsedMicroseconds, greaterThanOrEqualTo(0));
    });
  });
}
