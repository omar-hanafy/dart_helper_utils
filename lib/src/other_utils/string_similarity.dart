// ignore_for_file: avoid_returning_this
import 'dart:async';
import 'dart:math';

// TODO(OMAR): Write test code for this file.
/// Custom exception for string similarity issues.
class StringSimilarityError implements Exception {
  /// Creates a [StringSimilarityError] with the given error [message].
  StringSimilarityError(this.message);

  /// The error message describing the issue.
  final String message;

  @override
  String toString() => 'StringSimilarityError: $message';
}

/// Exception for invalid configuration settings related to string similarity.
class InvalidConfigurationError extends StringSimilarityError {
  /// Creates an [InvalidConfigurationError] with the given error [message].
  InvalidConfigurationError(super.message);
}

/// A generic Least Recently Used (LRU) cache to store computed values (e.g. bigrams).
///
/// This cache evicts the least recently used entry once the capacity is reached.
class LRUCache<K, V> {
  /// Creates an [LRUCache] with the given maximum [capacity].
  LRUCache(this.capacity);

  /// The maximum number of entries the cache can hold.
  final int capacity;

  final _cache = <K, V>{};

  /// Returns the value associated with [key] if present.
  ///
  /// If the key exists, this method marks the entry as recently used.
  /// Returns `null` if the key is not found.
  V? get(K key) {
    if (!_cache.containsKey(key)) return null;
    // Mark the entry as recently used.
    final value = _cache.remove(key);
    if (value != null) _cache[key] = value;
    return value;
  }

  /// Inserts the [key] and [value] into the cache.
  ///
  /// If the key already exists, its value is updated and its usage refreshed.
  /// If the cache is at capacity, the least recently used entry is removed.
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= capacity) {
      // Remove the least recently used entry.
      _cache.remove(_cache.keys.first);
    }
    _cache[key] = value;
  }

  /// Returns `true` if the cache contains an entry for the given [key].
  bool containsKey(K key) => _cache.containsKey(key);

  /// Clears all entries from the cache.
  void clear() => _cache.clear();
}

/// Configuration class for string similarity operations.
///
/// This includes normalization options, caching options, algorithm-specific parameters,
/// locale settings, and hooks for custom pre- and post-processing.
class StringSimilarityConfig {
  /// Creates a [StringSimilarityConfig] with the specified settings.
  ///
  /// The [jaroPrefixScale] must be between 0 and 0.25.
  const StringSimilarityConfig({
    this.normalize = true,
    this.removeSpaces = true,
    this.toLowerCase = true,
    this.removeSpecialChars = false,
    this.removeAccents = false,
    this.trimWhitespace = true,
    this.locale,
    this.enableCache = true,
    this.cacheCapacity = 1000,
    this.swMatchScore = 2,
    this.swMismatchScore = -1,
    this.swGapScore = -1,
    this.jaroPrefixScale = 0.1,
    this.preProcessor,
    this.postProcessor,
  }) : assert(
          jaroPrefixScale >= 0 && jaroPrefixScale <= 0.25,
          'jaroPrefixScale must be between 0 and 0.25',
        );

  // Normalization options.

  /// Whether to normalize the string before processing.
  final bool normalize;

  /// Whether to remove spaces during normalization.
  final bool removeSpaces;

  /// Whether to convert strings to lower case.
  final bool toLowerCase;

  /// Whether to remove special characters during normalization.
  final bool removeSpecialChars;

  /// Whether to remove accent marks from characters.
  final bool removeAccents;

  /// Whether to trim whitespace from the beginning and end of the string.
  final bool trimWhitespace;

  /// The locale to use for locale-specific normalization.
  final String? locale;

  // Caching options.

  /// Whether caching is enabled for similarity computations.
  final bool enableCache;

  /// The capacity of the cache.
  final int cacheCapacity;

  // Algorithm-specific parameters.

  /// The score to assign for a match in the Smith-Waterman algorithm.
  final int swMatchScore;

  /// The score to assign for a mismatch in the Smith-Waterman algorithm.
  final int swMismatchScore;

  /// The score to assign for a gap in the Smith-Waterman algorithm.
  final int swGapScore;

  /// The scaling factor used for the Jaro-Winkler prefix adjustment.
  final double jaroPrefixScale;

  // Hooks for custom processing.

  /// A function to preprocess the string before similarity computation.
  final String Function(String)? preProcessor;

  /// A function to postprocess the string after similarity computation.
  final String Function(String)? postProcessor;

  /// Returns a builder instance to configure a [StringSimilarityConfig] more flexibly.
  static StringSimilarityBuilder get builder => StringSimilarityBuilder();
}

/// Builder for [StringSimilarityConfig].
///
/// This builder allows step-by-step configuration of string similarity settings.
class StringSimilarityBuilder {
  /// Whether to normalize the string.
  bool normalize = true;

  /// Whether to remove spaces during normalization.
  bool removeSpaces = true;

  /// Whether to convert strings to lower case.
  bool toLowerCase = true;

  /// Whether to remove special characters.
  bool removeSpecialChars = false;

  /// Whether to remove accent marks from characters.
  bool removeAccents = false;

  /// Whether to trim whitespace from the string.
  bool trimWhitespace = true;

  /// The locale to use for locale-specific normalization.
  String? locale;

  /// Whether caching is enabled.
  bool enableCache = true;

  /// The capacity of the cache.
  int cacheCapacity = 1000;

  /// The match score for the Smith-Waterman algorithm.
  int swMatchScore = 2;

  /// The mismatch score for the Smith-Waterman algorithm.
  int swMismatchScore = -1;

  /// The gap score for the Smith-Waterman algorithm.
  int swGapScore = -1;

  /// The scaling factor used for the Jaro-Winkler prefix adjustment.
  double jaroPrefixScale = 0.1;

  /// A function to preprocess the string before similarity computation.
  String Function(String)? preProcessor;

  /// A function to postprocess the string after similarity computation.
  String Function(String)? postProcessor;

  /// Sets whether to normalize the string.
  StringSimilarityBuilder setNormalize(bool value) {
    normalize = value;
    return this;
  }

  /// Sets whether to remove spaces during normalization.
  StringSimilarityBuilder setRemoveSpaces(bool value) {
    removeSpaces = value;
    return this;
  }

  /// Sets whether to convert strings to lower case.
  StringSimilarityBuilder setToLowerCase(bool value) {
    toLowerCase = value;
    return this;
  }

  /// Sets whether to remove special characters.
  StringSimilarityBuilder setRemoveSpecialChars(bool value) {
    removeSpecialChars = value;
    return this;
  }

  /// Sets whether to remove accent marks from characters.
  StringSimilarityBuilder setRemoveAccents(bool value) {
    removeAccents = value;
    return this;
  }

  /// Sets whether to trim whitespace.
  StringSimilarityBuilder setTrimWhitespace(bool value) {
    trimWhitespace = value;
    return this;
  }

  /// Sets the locale for locale-specific normalization.
  StringSimilarityBuilder setLocale(String value) {
    locale = value;
    return this;
  }

  /// Sets whether to enable caching.
  StringSimilarityBuilder setEnableCache(bool value) {
    enableCache = value;
    return this;
  }

  /// Sets the capacity of the cache.
  StringSimilarityBuilder setCacheCapacity(int value) {
    cacheCapacity = value;
    return this;
  }

  /// Sets the match score for the Smith-Waterman algorithm.
  StringSimilarityBuilder setSwMatchScore(int value) {
    swMatchScore = value;
    return this;
  }

  /// Sets the mismatch score for the Smith-Waterman algorithm.
  StringSimilarityBuilder setSwMismatchScore(int value) {
    swMismatchScore = value;
    return this;
  }

  /// Sets the gap score for the Smith-Waterman algorithm.
  StringSimilarityBuilder setSwGapScore(int value) {
    swGapScore = value;
    return this;
  }

  /// Sets the Jaro-Winkler prefix scaling factor.
  StringSimilarityBuilder setJaroPrefixScale(double value) {
    jaroPrefixScale = value;
    return this;
  }

  /// Sets a custom preprocessor function to modify strings before computation.
  StringSimilarityBuilder setPreProcessor(String Function(String) func) {
    preProcessor = func;
    return this;
  }

  /// Sets a custom postprocessor function to modify strings after computation.
  StringSimilarityBuilder setPostProcessor(String Function(String) func) {
    postProcessor = func;
    return this;
  }

  /// Builds and returns a [StringSimilarityConfig] with the current settings.
  StringSimilarityConfig build() {
    return StringSimilarityConfig(
      normalize: normalize,
      removeSpaces: removeSpaces,
      toLowerCase: toLowerCase,
      removeSpecialChars: removeSpecialChars,
      removeAccents: removeAccents,
      trimWhitespace: trimWhitespace,
      locale: locale,
      enableCache: enableCache,
      cacheCapacity: cacheCapacity,
      swMatchScore: swMatchScore,
      swMismatchScore: swMismatchScore,
      swGapScore: swGapScore,
      jaroPrefixScale: jaroPrefixScale,
      preProcessor: preProcessor,
      postProcessor: postProcessor,
    );
  }
}

/// Supported similarity algorithms for string comparison.
///
/// This enum can be extended or replaced by a plugin system in the future.
enum SimilarityAlgorithm {
  /// The Dice Coefficient algorithm.
  diceCoefficient,

  /// The Levenshtein Distance algorithm.
  levenshteinDistance,

  /// The Jaro algorithm.
  jaro,

  /// The Jaro-Winkler algorithm.
  jaroWinkler,

  /// The Cosine Similarity algorithm.
  cosine,

  /// The Hamming Distance algorithm.
  hammingDistance,

  /// The Smith-Waterman algorithm.
  smithWaterman,

  /// The Soundex algorithm.
  soundex,
  // Custom algorithms can be added via plugins.
}

/// Main utility class for string similarity calculations, reporting, and batch processing.
class StringSimilarity {
  // Private constructor to prevent instantiation.
  const StringSimilarity._();

  // Optional LRU cache for bigrams.
  static LRUCache<String, Map<String, int>>? _bigramCache;

  /// Clears the current cache.
  static void clearCache() {
    _bigramCache?.clear();
  }

  /// Initializes the cache if caching is enabled.
  static void _initializeCache(StringSimilarityConfig config) {
    if (config.enableCache && _bigramCache == null) {
      _bigramCache = LRUCache(config.cacheCapacity);
    }
  }

  // A basic accent mapping for normalization.
  static const _accentMap = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ã': 'a',
    'ä': 'a',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ö': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ý': 'y',
    'ÿ': 'y',
  };

  /// Normalizes a string according to the provided [config].
  /// Applies pre- and post-processing hooks if provided.
  static String _normalizeString(String input, StringSimilarityConfig config) {
    if (!config.normalize) return input;

    // Apply pre-processing hook.
    var result =
        config.preProcessor != null ? config.preProcessor!(input) : input;

    // Unicode normalization – for a robust solution, consider a dedicated library.
    result = _unicodeNormalize(result, config.locale);

    if (config.trimWhitespace) result = result.trim();
    if (config.removeSpaces) result = result.replaceAll(RegExp(r'\s+'), '');
    if (config.toLowerCase) result = result.toLowerCase();
    if (config.removeSpecialChars) {
      result = result.replaceAll(RegExp(r'[^\w\s]'), '');
    }
    if (config.removeAccents) {
      result = result.replaceAllMapped(
        RegExp('[àáâãäçèéêëìíîïñòóôõöùúûüýÿ]'),
        (Match m) => _accentMap[m[0]] ?? m[0]!,
      );
    }

    // Apply post-processing hook.
    if (config.postProcessor != null) result = config.postProcessor!(result);

    return result;
  }

  /// Placeholder for Unicode normalization.
  /// Replace with robust normalization (NFD, NFC, etc.) as needed.
  static String _unicodeNormalize(String input, String? locale) {
    // Locale-specific logic could be implemented here.
    return input;
  }

  /// Generates bigrams from a string.
  /// For very long strings, this loop might be parallelized.
  static Map<String, int> _createBigrams(
      String input, StringSimilarityConfig config) {
    _initializeCache(config);
    if (config.enableCache && _bigramCache != null) {
      final cached = _bigramCache!.get(input);
      if (cached != null) return Map.from(cached);
    }

    if (input.length < 2) return {};

    final bigramCounts = <String, int>{};
    for (var i = 0; i < input.length - 1; i++) {
      final bigram = input.substring(i, i + 2);
      bigramCounts[bigram] = (bigramCounts[bigram] ?? 0) + 1;
    }

    if (config.enableCache && _bigramCache != null) {
      _bigramCache!.put(input, Map.from(bigramCounts));
    }
    return bigramCounts;
  }

  /// Computes the Dice Coefficient between two strings.
  /// Returns a normalized score between 0 and 1.
  static double diceCoefficient(
    String first,
    String second, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final s1 = _normalizeString(first, config);
    final s2 = _normalizeString(second, config);

    if (s1.isEmpty && s2.isEmpty) return 1;
    if (s1.isEmpty || s2.isEmpty) return 0;
    if (s1 == s2) return 1;
    if (s1.length < 2 || s2.length < 2) return 0;

    final firstBigrams = _createBigrams(s1, config);
    final secondBigrams = _createBigrams(s2, config);

    var intersectionSize = 0;
    for (final entry in firstBigrams.entries) {
      final countInSecond = secondBigrams[entry.key] ?? 0;
      intersectionSize += min(entry.value, countInSecond);
    }

    final totalBigrams = (s1.length - 1) + (s2.length - 1);
    return (2.0 * intersectionSize) / totalBigrams;
  }

  /// Computes the Hamming Distance between two strings.
  /// Throws an error if strings are of different lengths.
  static int hammingDistance(
    String s1,
    String s2, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str1 = _normalizeString(s1, config);
    final str2 = _normalizeString(s2, config);

    if (str1.length != str2.length) {
      throw StringSimilarityError(
          'Hamming Distance requires strings of equal length');
    }

    var distance = 0;
    for (var i = 0; i < str1.length; i++) {
      if (str1[i] != str2[i]) distance++;
    }
    return distance;
  }

  /// Smith-Waterman algorithm for local sequence alignment.
  /// Returns a normalized similarity score between 0 and 1.
  static double smithWaterman(
    String s1,
    String s2, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str1 = _normalizeString(s1, config);
    final str2 = _normalizeString(s2, config);

    if (str1.isEmpty || str2.isEmpty) return 0;

    final matchScore = config.swMatchScore;
    final mismatchScore = config.swMismatchScore;
    final gapScore = config.swGapScore;

    final matrix = List.generate(
      str1.length + 1,
      (i) => List.filled(str2.length + 1, 0),
    );

    var maxScore = 0;
    for (var i = 1; i <= str1.length; i++) {
      for (var j = 1; j <= str2.length; j++) {
        final scoreDiag = matrix[i - 1][j - 1] +
            (str1[i - 1] == str2[j - 1] ? matchScore : mismatchScore);
        final scoreUp = matrix[i - 1][j] + gapScore;
        final scoreLeft = matrix[i][j - 1] + gapScore;
        matrix[i][j] = max(0, max(scoreDiag, max(scoreUp, scoreLeft)));
        maxScore = max(maxScore, matrix[i][j]);
      }
    }

    final maxPossible = matchScore * min(str1.length, str2.length);
    return maxPossible == 0 ? 0 : maxScore / maxPossible;
  }

  /// Computes a phonetic signature using the Soundex algorithm.
  /// Returns a four-character code.
  static String soundex(
    String input, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str = _normalizeString(input, config);
    if (str.isEmpty) return '';

    final soundexMap = {
      'b': '1',
      'f': '1',
      'p': '1',
      'v': '1',
      'c': '2',
      'g': '2',
      'j': '2',
      'k': '2',
      'q': '2',
      's': '2',
      'x': '2',
      'z': '2',
      'd': '3',
      't': '3',
      'l': '4',
      'm': '5',
      'n': '5',
      'r': '6',
    };

    final result = StringBuffer(str[0].toUpperCase());
    var previousCode = soundexMap[str[0].toLowerCase()];
    for (var i = 1; i < str.length && result.length < 4; i++) {
      final currentChar = str[i].toLowerCase();
      final currentCode = soundexMap[currentChar];
      if (currentCode != null && currentCode != previousCode) {
        result.write(currentCode);
        previousCode = currentCode;
      }
    }
    while (result.length < 4) {
      result.write('0');
    }
    return result.toString();
  }

  /// Computes the Levenshtein distance (edit distance) between two strings.
  /// Uses a memory-optimized dynamic programming approach.
  static int levenshteinDistance(
    String s1,
    String s2, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str1 = _normalizeString(s1, config);
    final str2 = _normalizeString(s2, config);

    if (str1.isEmpty) return str2.length;
    if (str2.isEmpty) return str1.length;

    var prevRow = List.generate(str2.length + 1, (i) => i);
    var currRow = List<int>.filled(str2.length + 1, 0);

    for (var i = 0; i < str1.length; i++) {
      currRow[0] = i + 1;
      for (var j = 0; j < str2.length; j++) {
        final cost = str1[i] == str2[j] ? 0 : 1;
        currRow[j + 1] = min(
          min(currRow[j] + 1, prevRow[j + 1] + 1),
          prevRow[j] + cost,
        );
      }
      final temp = prevRow;
      prevRow = currRow;
      currRow = temp;
    }
    return prevRow[str2.length];
  }

  /// Computes the Jaro similarity score.
  /// Returns a score between 0 (no similarity) and 1 (exact match).
  static double jaro(
    String s1,
    String s2, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str1 = _normalizeString(s1, config);
    final str2 = _normalizeString(s2, config);

    if (str1.isEmpty && str2.isEmpty) return 1;
    if (str1.isEmpty || str2.isEmpty) return 0;
    if (str1 == str2) return 1;

    final matchDistance = ((max(str1.length, str2.length) / 2) - 1).floor();
    final matches = _findMatches(str1, str2, matchDistance);
    if (matches.isEmpty) return 0;

    final transpositions = _countTranspositions(matches);
    final m = matches.length.toDouble();
    return (m / str1.length + m / str2.length + (m - transpositions) / m) / 3;
  }

  /// Helper: Finds matching characters for Jaro similarity.
  static List<_Match> _findMatches(String s1, String s2, int maxDistance) {
    final matches = <_Match>[];
    final marked1 = List<bool>.filled(s1.length, false);
    final marked2 = List<bool>.filled(s2.length, false);
    for (var i = 0; i < s1.length; i++) {
      final start = max(0, i - maxDistance);
      final end = min(i + maxDistance + 1, s2.length);
      for (var j = start; j < end; j++) {
        if (!marked2[j] && s1[i] == s2[j]) {
          marked1[i] = marked2[j] = true;
          matches.add(_Match(i, j, s1[i]));
          break;
        }
      }
    }
    // Sort by index in second string.
    matches.sort((a, b) => a.j.compareTo(b.j));
    return matches;
  }

  /// Helper: Counts transpositions in the matching characters.
  static int _countTranspositions(List<_Match> matches) {
    var transpositions = 0;
    final s1Matches = matches.map((m) => m.char).toList();
    final s2Matches = matches.map((m) => m.char).toList();

    for (var i = 0; i < s1Matches.length; i++) {
      if (s1Matches[i] != s2Matches[i]) {
        transpositions++;
      }
    }
    return transpositions ~/ 2;
  }

  /// Computes the Jaro-Winkler similarity.
  /// Boosts the score based on common prefixes.
  static double jaroWinkler(
    String s1,
    String s2, {
    StringSimilarityConfig config = const StringSimilarityConfig(),
  }) {
    final baseJaro = jaro(s1, s2, config);
    final prefixLength = _commonPrefixLength(
      _normalizeString(s1, config),
      _normalizeString(s2, config),
    );
    return baseJaro + (prefixLength * config.jaroPrefixScale * (1 - baseJaro));
  }

  /// Helper: Determines the common prefix length (max 4 characters) for Jaro-Winkler.
  static int _commonPrefixLength(String s1, String s2) {
    var i = 0;
    while (i < min(s1.length, s2.length) && s1[i] == s2[i] && i < 4) {
      i++;
    }
    return i;
  }

  /// Computes Cosine similarity by treating strings as bags of words.
  static double cosine(
    String text1,
    String text2, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str1 = _normalizeString(text1, config);
    final str2 = _normalizeString(text2, config);

    // Tokenize based on whitespace.
    final words1 = str1.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final words2 = str2.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);

    if (words1.isEmpty && words2.isEmpty) return 1;
    if (words1.isEmpty || words2.isEmpty) return 0;

    final freq1 = _createFrequencyMap(words1);
    final freq2 = _createFrequencyMap(words2);
    final allWords = {...freq1.keys, ...freq2.keys};

    double dotProduct = 0;
    double magnitude1 = 0;
    double magnitude2 = 0;
    for (final word in allWords) {
      final f1 = freq1[word] ?? 0;
      final f2 = freq2[word] ?? 0;
      dotProduct += f1 * f2;
      magnitude1 += f1 * f1;
      magnitude2 += f2 * f2;
    }
    final magnitude = sqrt(magnitude1) * sqrt(magnitude2);
    return magnitude == 0 ? 0 : dotProduct / magnitude;
  }

  /// Builds a frequency map from a collection of words.
  static Map<String, int> _createFrequencyMap(Iterable<String> words) {
    return words.fold<Map<String, int>>({}, (map, word) {
      map[word] = (map[word] ?? 0) + 1;
      return map;
    });
  }

  /// Compares two strings using the specified [algorithm].
  /// For distance-based algorithms, the score is normalized to [0,1].
  static double compare(
    String first,
    String second,
    SimilarityAlgorithm algorithm, {
    StringSimilarityConfig config = const StringSimilarityConfig(),
  }) {
    switch (algorithm) {
      case SimilarityAlgorithm.diceCoefficient:
        return diceCoefficient(first, second, config);
      case SimilarityAlgorithm.levenshteinDistance:
        final distance = levenshteinDistance(first, second, config);
        final maxLength = max(first.length, second.length);
        return maxLength == 0 ? 1 : 1 - (distance / maxLength);
      case SimilarityAlgorithm.jaro:
        return jaro(first, second, config);
      case SimilarityAlgorithm.jaroWinkler:
        return jaroWinkler(first, second, config: config);
      case SimilarityAlgorithm.cosine:
        return cosine(first, second, config);
      case SimilarityAlgorithm.hammingDistance:
        try {
          final distance = hammingDistance(first, second, config);
          return 1 - (distance / first.length);
        } catch (e) {
          return 0;
        }
      case SimilarityAlgorithm.smithWaterman:
        return smithWaterman(first, second, config);
      case SimilarityAlgorithm.soundex:
        return soundex(first, config) == soundex(second, config) ? 1.0 : 0.0;
    }
  }

  /// Asynchronous version of [compare] for integration in async workflows.
  static Future<double> compareAsync(
    String first,
    String second,
    SimilarityAlgorithm algorithm, {
    StringSimilarityConfig config = const StringSimilarityConfig(),
  }) async {
    // For batch heavy operations, consider isolating to a separate isolate.
    return compare(first, second, algorithm, config: config);
  }

  /// Batch processing: compares a list of string pairs.
  /// Each pair must contain exactly two strings.
  static List<double> compareBatch(
    List<List<String>> pairs,
    SimilarityAlgorithm algorithm, {
    StringSimilarityConfig config = const StringSimilarityConfig(),
  }) {
    return pairs.map((pair) {
      if (pair.length != 2) {
        throw StringSimilarityError(
            'Each pair must contain exactly 2 strings.');
      }
      return compare(pair[0], pair[1], algorithm, config: config);
    }).toList();
  }

  /// Generates a detailed similarity report.
  /// This can be extended to include visualization or confidence metrics.
  static String generateReport(
    String first,
    String second,
    SimilarityAlgorithm algorithm, {
    StringSimilarityConfig config = const StringSimilarityConfig(),
  }) {
    final similarity = compare(first, second, algorithm, config: config);
    return 'Similarity Score: ${similarity.toStringAsFixed(3)}\n'
        'First String: $first\n'
        'Second String: $second\n'
        'Algorithm: $algorithm';
  }
}

/// Internal helper class for the Jaro algorithm to record matching characters.
class _Match {
  const _Match(
    this.i,
    this.j,
    this.char,
  );

  final int i;
  final int j;
  final String char;
}
