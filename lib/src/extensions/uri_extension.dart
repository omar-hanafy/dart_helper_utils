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
    // Initialize replacement variables with null to indicate "no change"
    String? newScheme;
    String? newUserInfo;
    String? newHost;
    int? newPort;
    String? newPath;
    List<String>? newPathSegments;
    String? newQuery;
    Map<String, String>? newQueryParameters;
    String? newFragment;

    // Apply builder functions if provided
    if (schemeBuilder != null) {
      newScheme = schemeBuilder(scheme);
    }

    if (userInfoBuilder != null) {
      newUserInfo = userInfoBuilder(userInfo);
    }

    if (hostBuilder != null) {
      newHost = hostBuilder(host);
    }

    if (portBuilder != null) {
      newPort = portBuilder(port);
    }

    if (pathBuilder != null) {
      newPath = pathBuilder(path);
    }

    if (pathSegmentsBuilder != null) {
      final segments = pathSegmentsBuilder(pathSegments);
      if (segments != null) {
        newPathSegments = segments.toList();
      }
    }

    if (queryBuilder != null) {
      newQuery = queryBuilder(query);
    }

    if (queryParametersBuilder != null) {
      // Convert Map<String, String> to Map<String, dynamic>
      final dynamicQueryParams = Map<String, dynamic>.from(queryParameters);

      // Apply the builder
      final resultParams = queryParametersBuilder(dynamicQueryParams);

      // Convert back to Map<String, String> if a new value was returned
      if (resultParams != null) {
        newQueryParameters = {};
        resultParams.forEach((key, value) {
          // Convert value to string (if not null)
          newQueryParameters![key] = value?.toString() ?? '';
        });
      }
    }

    if (fragmentBuilder != null) {
      newFragment = fragmentBuilder(fragment);
    }

    // Create a new Uri with the modified components
    return replace(
      scheme: newScheme,
      userInfo: newUserInfo,
      host: newHost,
      port: newPort,
      path: newPath,
      pathSegments: newPathSegments,
      query: newQuery,
      queryParameters: newQueryParameters,
      fragment: newFragment,
    );
  }
}
