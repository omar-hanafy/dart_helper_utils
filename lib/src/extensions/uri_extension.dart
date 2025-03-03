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

  /// Creates a new `Uri` based on this one by applying builder functions
  /// to individual components.
  ///
  /// Each builder, if provided, receives the current value and should
  /// return the new value. If a builder isn't provided, the current value
  /// is retained.
  Uri rebuild({
    String? Function(String current)? schemeBuilder,
    String? Function(String current)? userInfoBuilder,
    String? Function(String current)? hostBuilder,
    int? Function(int current)? portBuilder,
    String? Function(String current)? pathBuilder,
    Iterable<String>? Function(Iterable<String> current)? pathSegmentsBuilder,
    String? Function(String current)? queryBuilder,
    Map<String, dynamic>? Function(Map<String, dynamic> current)?
        queryParametersBuilder,
    String? Function(String current)? fragmentBuilder,
  }) {
    // Determine which path-related parameter to use
    final usePathSegments = pathSegmentsBuilder != null;
    final usePath = pathBuilder != null && !usePathSegments;

    return Uri(
      scheme: schemeBuilder?.call(scheme) ?? scheme,
      userInfo: userInfoBuilder?.call(userInfo) ?? userInfo,
      host: hostBuilder?.call(host) ?? host,
      port: portBuilder?.call(port) ?? port,
      path: usePath ? (pathBuilder.call(path) ?? path) : null,
      pathSegments: usePathSegments
          ? (pathSegmentsBuilder.call(pathSegments) ?? pathSegments)
          : (usePath ? null : pathSegments),
      query: queryBuilder?.call(query) ?? query,
      queryParameters:
          queryParametersBuilder?.call(queryParameters) ?? queryParameters,
      fragment: fragmentBuilder?.call(fragment) ?? fragment,
    );
  }
}
