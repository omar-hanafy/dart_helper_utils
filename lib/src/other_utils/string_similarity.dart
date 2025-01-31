import 'dart:collection';
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

  /// Hamming Distance algorithm.
  ///
  /// Measures the number of positions at which the corresponding symbols are different.
  hammingDistance,

  /// Smith-Waterman algorithm.
  ///
  /// Performs local sequence alignment; it compares segments of all possible lengths and optimizes the similarity measure.
  smithWaterman,

  /// Soundex algorithm.
  ///
  /// Encodes words into a phonetic representation to compare how they sound.
  soundex,
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
    this.removeSpecialChars = false,
    this.removeAccents = false,
    this.trimWhitespace = true,
  });

  /// Whether to normalize the strings before comparison.
  final bool normalize;

  /// Whether to remove spaces from the strings.
  final bool removeSpaces;

  /// Whether to lowercase the strings.
  final bool toLowerCase;

  /// Whether to remove special characters from the strings.
  final bool removeSpecialChars;

  /// Whether to remove accents from the strings.
  final bool removeAccents;

  /// Whether to trim whitespace from the strings.
  final bool trimWhitespace;
}

/// A utility class that offers methods for measuring how similar two strings are.
class StringSimilarity {
  // Private constructor to prevent instantiation.
  const StringSimilarity._();

  static final _cache = HashMap<String, Map<String, int>>();

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

  static String _normalizeString(String input, StringSimilarityConfig config) {
    if (!config.normalize) return input;

    var result = input;
    if (config.trimWhitespace) {
      result = result.trim();
    }
    if (config.removeSpaces) {
      result = result.replaceAll(RegExp(r'\s+'), '');
    }
    if (config.toLowerCase) {
      result = result.toLowerCase();
    }
    if (config.removeSpecialChars) {
      result = result.replaceAll(RegExp(r'[^\w\s]'), '');
    }
    if (config.removeAccents) {
      result = result.replaceAllMapped(
        RegExp('[àáâãäçèéêëìíîïñòóôõöùúûüýÿ]'),
        (Match m) => _accentMap[m[0]] ?? m[0]!,
      );
    }
    return result;
  }

  static Map<String, int> _createBigrams(String input) {
    // Check cache first
    if (_cache.containsKey(input)) {
      return Map.from(_cache[input]!);
    }

    if (input.length < 2) return {};

    final bigramCounts = <String, int>{};
    for (var i = 0; i < input.length - 1; i++) {
      final bigram = input.substring(i, i + 2);
      bigramCounts[bigram] = (bigramCounts[bigram] ?? 0) + 1;
    }

    // Cache the result
    _cache[input] = Map.from(bigramCounts);
    return bigramCounts;
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

  /// Computes the Hamming Distance between two strings.
  /// Returns the number of positions at which the corresponding symbols are different.
  /// Throws an [ArgumentError] if the strings are of different lengths.
  static int hammingDistance(
    String s1,
    String s2, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str1 = _normalizeString(s1, config);
    final str2 = _normalizeString(s2, config);

    if (str1.length != str2.length) {
      throw ArgumentError('Strings must be of equal length');
    }

    var distance = 0;
    for (var i = 0; i < str1.length; i++) {
      if (str1[i] != str2[i]) distance++;
    }
    return distance;
  }

  /// Smith-Waterman Algorithm for local sequence alignment
  static double smithWaterman(
    String s1,
    String s2, [
    StringSimilarityConfig config = const StringSimilarityConfig(),
  ]) {
    final str1 = _normalizeString(s1, config);
    final str2 = _normalizeString(s2, config);

    if (str1.isEmpty || str2.isEmpty) return 0;

    const matchScore = 2;
    const mismatchScore = -1;
    const gapScore = -1;

    final matrix = List.generate(
      str1.length + 1,
      (i) => List.filled(str2.length + 1, 0),
    );

    var maxScore = 0;

    for (var i = 1; i <= str1.length; i++) {
      for (var j = 1; j <= str2.length; j++) {
        final match = matrix[i - 1][j - 1] +
            (str1[i - 1] == str2[j - 1] ? matchScore : mismatchScore);
        final delete = matrix[i - 1][j] + gapScore;
        final insert = matrix[i][j - 1] + gapScore;

        matrix[i][j] = max(0, max(match, max(delete, insert)));
        maxScore = max(maxScore, matrix[i][j]);
      }
    }

    // Normalize the score
    final maxPossible = matchScore * min(str1.length, str2.length);
    return maxPossible == 0 ? 0 : maxScore / maxPossible;
  }

  /// Computes the Soundex encoding for a given string.
  /// Returns a four-character code representing the phonetic sound of the string.
  ///
  /// This version normalizes the string (by default) and then applies the Soundex algorithm.
  /// The resulting code consists of the first letter of the string followed by three digits.
  /// If the string is too short, it is padded with zeros.
  ///
  /// Example:
  /// ```dart
  /// final soundexCode = StringSimilarity.soundex('example');
  /// print(soundexCode); // E251
  /// ```
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
      case SimilarityAlgorithm.hammingDistance:
        try {
          final distance = hammingDistance(first, second, config);
          return 1 - (distance / first.length);
        } catch (e) {
          return 0; // Return 0 if strings are of different lengths
        }
      case SimilarityAlgorithm.smithWaterman:
        return smithWaterman(first, second, config);
      case SimilarityAlgorithm.soundex:
        return soundex(first, config) == soundex(second, config) ? 1.0 : 0.0;
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
