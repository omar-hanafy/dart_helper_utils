/// Represents a range exception.
class RException implements Exception {
  /// Represents a range exception.
  const RException(this.message);

  /// Represents a range exception for steps.
  RException.steps() : message = 'The range must be more than 0';

  /// Represents message of the exception.
  final String? message;

  @override
  String toString() {
    return 'RException: ${message ?? ''}';
  }
}
