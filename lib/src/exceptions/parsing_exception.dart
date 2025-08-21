import '../extensions/map.dart';

/// Represents a parsing exception with comprehensive debugging information.
class ParsingException implements Exception {
  /// Creates a parsing exception with detailed argument information.
  ///
  /// [error] - The error that occurred during parsing
  /// [parsingInfo] - Map containing all arguments passed to the conversion method
  /// [stackTrace] - Optional stack trace, defaults to current if not provided
  ParsingException({
    required this.error,
    required Map<String, dynamic> parsingInfo,
    StackTrace? stackTrace,
  })  : parsingInfo = Map.unmodifiable(parsingInfo),
        stackTrace = stackTrace ?? StackTrace.current;

  /// Factory for null object exceptions with comprehensive context.
  factory ParsingException.nullObject({
    required StackTrace stackTrace,
    required Map<String, dynamic> parsingInfo,
  }) {
    return ParsingException(
      error: 'object is unsupported or null',
      parsingInfo: parsingInfo,
      stackTrace: stackTrace,
    );
  }

  /// Complete parsing information including all arguments.
  ///
  /// Contains all arguments passed to the conversion method, including:
  /// - method: The conversion method name (e.g., 'toInt', 'toString1')
  /// - object: The original object being converted (may be large)
  /// - mapKey: If extracting from a map
  /// - listIndex: If extracting from a list
  /// - format, locale, defaultValue, etc.: Method-specific parameters
  final Map<String, dynamic> parsingInfo;

  /// The error that occurred.
  final Object? error;

  /// The stack trace of the error.
  final StackTrace stackTrace;

  /// Checks if a value is potentially large and should be filtered from default output.
  bool _isHeavyValue(dynamic value) {
    if (value == null) return false;
    if (value is Map && value.length > 10) return true;
    if (value is List && value.length > 10) return true;
    if (value is Set && value.length > 10) return true;
    if (value is String && value.length > 500) return true;
    return false;
  }

  /// Creates a filtered version of parsingInfo for cleaner default output.
  /// Returns a map with heavy values replaced by descriptive placeholders.
  Map<String, dynamic> _getFilteredInfo() {
    final filtered = <String, dynamic>{};

    parsingInfo.forEach((key, value) {
      if (value == null) {
        // Skip null values for cleaner output
        return;
      }

      if (key == 'object' || _isHeavyValue(value)) {
        // Replace heavy values with descriptive placeholders
        if (value is Map) {
          filtered[key] = '<Map with ${value.length} entries>';
        } else if (value is List) {
          filtered[key] = '<List with ${value.length} items>';
        } else if (value is Set) {
          filtered[key] = '<Set with ${value.length} items>';
        } else if (value is String && value.length > 500) {
          filtered[key] = '<String with ${value.length} characters>';
        } else {
          filtered[key] = '<${value.runtimeType}>';
        }
      } else if (value is Function) {
        // Show that a converter was provided without printing the function
        filtered[key] = '<Function: ${value.runtimeType}>';
      } else {
        filtered[key] = value;
      }
    });

    return filtered;
  }

  /// Returns the complete parsing information as formatted JSON.
  ///
  /// Use this method when you need full debugging information including
  /// large objects that are filtered from the default toString() output.
  String fullReport() {
    // Import will be handled at the top of the file
    final encodableInfo = parsingInfo.map((key, value) {
      if (value is Function) {
        return MapEntry(key, 'Function: ${value.runtimeType}');
      }
      return MapEntry(key, value);
    });

    // We'll use the encodedJsonString extension from map.dart
    return '''
ParsingException (Full Report) {
  error: $error,
  parsingInfo:
${encodableInfo.encodedJsonString},
  stackTrace: $stackTrace
}
''';
  }

  @override
  String toString() {
    final filtered = _getFilteredInfo();

    // Use encodedJsonString for pretty JSON output
    return '''
ParsingException {
  error: $error,
  parsingInfo:
${filtered.encodedJsonString},
  stackTrace: $stackTrace
}
''';
  }
}
