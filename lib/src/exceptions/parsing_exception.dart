/// Represents a parsing exception.
class ParsingException implements Exception {
  /// Represents a parsing exception.
  ParsingException({
    required this.error,
    required this.parsingInfo,
    StackTrace? stackTrace,
  }) : stackTrace = stackTrace ?? StackTrace.current;

  /// Represents a parsing exception for null objects.
  factory ParsingException.nullObject({
    required StackTrace stackTrace,
    required String parsingInfo,
  }) {
    return ParsingException(
      error: 'object is unsupported or null',
      parsingInfo: parsingInfo,
      stackTrace: stackTrace,
    );
  }

  /// parsing information.
  final String parsingInfo;

  /// The error that occurred.
  final Object? error;

  /// The stack trace of the error.
  final StackTrace stackTrace;

  @override
  String toString() {
    return '''
ParsingException {
  parsingInfo: $parsingInfo,
  error: $error,
  stackTrace: $stackTrace',
}
''';
  }
}
