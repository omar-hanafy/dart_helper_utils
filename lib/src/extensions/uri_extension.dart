import 'package:dart_helper_utils/dart_helper_utils.dart';

/// Extensions for nullable [String] to convert to [Uri]
extension DHUNullSafeURIExtensions on String? {
  /// converts a string? to a uri
  Uri? get toUri => this == null ? null : Uri.tryParse(this!.clean);

  /// converts a string? to a phone uri
  Uri? get toPhoneUri => this == null
      ? null
      : Uri.parse(this!.startsWith('tel://') ? this! : 'tel://${this!.clean}');
}

/// Extensions for [String] to convert to [Uri]
extension DHUURIExtensions on String {
  /// converts a string to a uri
  Uri get toUri => Uri.parse(clean);

  /// converts a string to a phone uri
  Uri get toPhoneUri =>
      Uri.parse(startsWith('tel://') ? clean : 'tel://$clean');
}

/// Extensions for [Uri] utils and manipulation.
extension DHUUriEx on Uri {
  /// Extracts the domain name from a URL.
  /// Supports URLs with or without 'www' and different TLDs.
  String get domainName {
    // Split the URL by '.'
    var parts = host.split('.');

    // Remove 'www' if it exists
    if (parts.isNotEmpty && parts[0] == 'www') {
      parts = parts.sublist(1);
    }

    // Return the first part as the domain name, or an empty string if not found
    return parts.isNotEmpty ? parts[0] : host;
  }
}
