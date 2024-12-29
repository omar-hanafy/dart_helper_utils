import 'dart:math';

/// Algorithms you can use for comparing string similarity.
enum SimilarityAlgorithm {
  /// Dice Coefficient algorithm.
  ///
  /// Measures the similarity between two strings based on the number of common bigrams.
  diceCoefficient,

  /// Levenshtein Distance algorithm.
  ///
  /// Calculates the minimum number of single-character edits (insertions, deletions, substitutions) required to change one string into the other.
  levenshteinDistance,

  /// Jaro similarity algorithm.
  ///
  /// Measures the similarity between two strings based on the number and order of matching characters.
  jaro,

  /// Jaro-Winkler similarity algorithm.
  ///
  /// An extension of the Jaro algorithm that gives more weight to matches at the beginning of the strings.
  jaroWinkler,

  /// Cosine similarity algorithm.
  ///
  /// Measures the cosine of the angle between two vectors of word frequencies, treating the strings as bags of words.
  cosine,
}

/// Configuration for string normalization and processing
///
/// By default, the config removes spaces, lowercases the strings,
/// and performs overall normalization.
class StringSimilarityConfig {
  /// Creates a new configuration with the specified settings.
  const StringSimilarityConfig({
    this.normalize = true,
    this.removeSpaces = true,
    this.toLowerCase = true,
  });

  /// Whether to normalize the strings before comparison.
  final bool normalize;

  /// Whether to remove spaces from the strings.
  final bool removeSpaces;

  /// Whether to lowercase the strings.
  final bool toLowerCase;
}

/// A utility class that offers methods for measuring how similar two strings are.
class StringSimilarity {
  // Private constructor to prevent instantiation.
  const StringSimilarity._();

  /// Normalizes the input string according to the provided configuration.
  /// By default, it removes all spaces and lowercases the string.
  static String _normalizeString(String input, StringSimilarityConfig config) {
    if (!config.normalize) return input;

    var result = input;
    if (config.removeSpaces) {
      result = result.replaceAll(RegExp(r'\s+'), '');
    }
    if (config.toLowerCase) {
      result = result.toLowerCase();
    }
    return result;
  }

  /// Creates a map of bigrams (pairs of consecutive characters) from a string.
  /// Each entry in the map tracks how many times that particular bigram appears.
  static Map<String, int> _createBigrams(String input) {
    if (input.length < 2) return {};

    final bigramCounts = List.generate(input.length - 1, (i) {
      return input.substring(i, i + 2);
    }).fold<Map<String, int>>({}, (map, bigram) {
      map[bigram] = (map[bigram] ?? 0) + 1;
      return map;
    });

    return Map.fromEntries(bigramCounts.entries);
  }

  /// Computes the Dice Coefficient for two strings.
  /// Returns a value between 0 and 1, where 1 means identical strings.
  ///
  /// This version normalizes both strings (by default) and uses bigrams for each,
  /// then counts the overlap.
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

    final firstBigrams = _createBigrams(s1);
    final secondBigrams = _createBigrams(s2);

    var intersectionSize = 0;
    for (final entry in firstBigrams.entries) {
      final countInSecond = secondBigrams[entry.key] ?? 0;
      intersectionSize += min(entry.value, countInSecond);
    }

    final totalBigrams = (s1.length - 1) + (s2.length - 1);
    return (2.0 * intersectionSize) / totalBigrams;
  }

  /// Computes the Levenshtein distance between two strings,
  /// telling you how many single-character edits (insertions, deletions, substitutions)
  /// you need to transform one string into the other.
  ///
  /// Here, it uses a memory-optimized approach that keeps only two rows of the matrix:
  /// the previous row and the current row.
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

      // Swap the rows instead of re-creating them each time.
      final temp = prevRow;
      prevRow = currRow;
      currRow = temp;
    }

    return prevRow[str2.length];
  }

  /// Calculates the Jaro similarity score, which ranges from 0 to 1.
  /// A score of 1 indicates the strings are identical; 0 means they share nothing in common.
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

  /// Helper that finds matching characters within a defined distance,
  /// used for the Jaro similarity calculation.
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

    // Sort matches by the index j in the second string
    matches.sort((a, b) => a.j.compareTo(b.j));
    return matches;
  }

  /// Counts the transpositions for the matched characters.
  /// For Jaro, each pair of non-identical neighboring characters
  /// contributes to the transposition count.
  static int _countTranspositions(List<_Match> matches) {
    var transpositions = 0;
    for (var i = 0; i < matches.length - 1; i++) {
      if (matches[i].char != matches[i + 1].char) {
        transpositions++;
      }
    }
    return transpositions ~/ 2;
  }

  /// Calculates Jaro-Winkler similarity, which builds on Jaro by giving
  /// extra weight to matching prefixes at the start of the strings.
  /// [prefixScale] defaults to 0.1 and must stay between 0 and 0.25.
  static double jaroWinkler(
    String s1,
    String s2, {
    double prefixScale = 0.1,
    StringSimilarityConfig config = const StringSimilarityConfig(),
  }) {
    if (prefixScale < 0 || prefixScale > 0.25) {
      throw ArgumentError('prefixScale must be between 0 and 0.25');
    }

    final jaroScore = jaro(s1, s2, config);
    final prefixLength = _commonPrefixLength(
      _normalizeString(s1, config),
      _normalizeString(s2, config),
    );

    // Winkler modifies the Jaro score based on the length of the common prefix.
    return jaroScore + (prefixLength * prefixScale * (1 - jaroScore));
  }

  /// Counts how many characters from the start of both strings are the same,
  /// up to a maximum of 4. Important for Jaro-Winkler.
  static int _commonPrefixLength(String s1, String s2) {
    var i = 0;
    while (i < min(s1.length, s2.length) && s1[i] == s2[i] && i < 4) {
      i++;
    }
    return i;
  }

  /// Uses the Cosine Similarity measure on two strings by breaking them into words,
  /// counting frequencies, and then computing the cosine of their frequency vectors.
  static double cosine(
    String text1,
    String text2, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str1 = _normalizeString(text1, config);
    final str2 = _normalizeString(text2, config);

    // Split on whitespace and drop empty elements.
    final words1 = str1.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final words2 = str2.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);

    // If both are empty, consider them identical.
    if (words1.isEmpty && words2.isEmpty) return 1;
    // If one is empty while the other is not, they're completely different.
    if (words1.isEmpty || words2.isEmpty) return 0;

    final freq1 = _createFrequencyMap(words1);
    final freq2 = _createFrequencyMap(words2);
    final allWords = {...freq1.keys, ...freq2.keys};

    var dotProduct = 0.0;
    var magnitude1 = 0.0;
    var magnitude2 = 0.0;

    for (final word in allWords) {
      final f1 = freq1[word] ?? 0;
      final f2 = freq2[word] ?? 0;

      dotProduct += f1 * f2;
      magnitude1 += f1 * f1;
      magnitude2 += f2 * f2;
    }

    final magnitude = sqrt(magnitude1) * sqrt(magnitude2);
    return magnitude == 0 ? 0.0 : dotProduct / magnitude;
  }

  /// Builds a map of word frequencies for an Iterable of words.
  static Map<String, int> _createFrequencyMap(Iterable<String> words) {
    return words.fold<Map<String, int>>({}, (map, word) {
      map[word] = (map[word] ?? 0) + 1;
      return map;
    });
  }

  /// A convenience method that compares two strings using the specified algorithm.
  /// For algorithms that produce a distance (like Levenshtein),
  /// it's normalized to a 0-1 similarity range (1 means identical).
  static double compare(
    String first,
    String second,
    SimilarityAlgorithm algorithm, {
    double prefixScale = 0.1,
    StringSimilarityConfig config = const StringSimilarityConfig(),
  }) {
    switch (algorithm) {
      case SimilarityAlgorithm.diceCoefficient:
        return diceCoefficient(first, second, config);
      case SimilarityAlgorithm.levenshteinDistance:
        final distance = levenshteinDistance(first, second, config);
        final maxLength = max(first.length, second.length);
        // Convert distance to a similarity score, 0 means different, 1 identical.
        return 1 - (distance / maxLength);
      case SimilarityAlgorithm.jaro:
        return jaro(first, second, config);
      case SimilarityAlgorithm.jaroWinkler:
        return jaroWinkler(
          first,
          second,
          prefixScale: prefixScale,
          config: config,
        );
      case SimilarityAlgorithm.cosine:
        return cosine(first, second, config);
    }
  }
}

/// Internal class used by the Jaro algorithm to record which characters match
/// and their positions in each string.
class _Match {
  const _Match(this.i, this.j, this.char);

  final int i;
  final int j;
  final String char;
}
