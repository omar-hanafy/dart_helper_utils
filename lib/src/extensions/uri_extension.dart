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
  ///
  /// If both `pathBuilder` and `pathSegmentsBuilder` return non-null values,
  /// `pathSegmentsBuilder` takes precedence.
  ///
  /// If both `queryBuilder` and `queryParametersBuilder` return non-null values,
  /// `queryParametersBuilder` takes precedence.
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
    Map<String, dynamic>? newQueryParameters;
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

      // Convert back to Map<String, dynamic> allowing Iterables
      if (resultParams != null) {
        newQueryParameters = {};
        resultParams.forEach((key, value) {
          if (value is Iterable) {
            newQueryParameters![key] = value.map((e) => e.toString()).toList();
          } else {
            newQueryParameters![key] = value?.toString() ?? '';
          }
        });
      }
    }

    if (fragmentBuilder != null) {
      newFragment = fragmentBuilder(fragment);
    }

    final effectivePathSegments = newPathSegments;
    final effectivePath = effectivePathSegments == null ? newPath : null;

    final effectiveQueryParameters = newQueryParameters;
    final effectiveQuery = effectiveQueryParameters == null ? newQuery : null;

    // Create a new Uri with the modified components
    return replace(
      scheme: newScheme,
      userInfo: newUserInfo,
      host: newHost,
      port: newPort,
      path: effectivePath,
      pathSegments: effectivePathSegments,
      query: effectiveQuery,
      queryParameters: effectiveQueryParameters,
      fragment: newFragment,
    );
  }

  /// Returns a new [Uri] with query parameters replaced by [queryParameters].
  Uri withQueryParameters(Map<String, Object?> queryParameters) {
    final params = _toQueryParametersAll(queryParameters);
    return replace(query: _toQueryString(params));
  }

  /// Returns a new [Uri] with [queryParameters] merged into existing parameters.
  ///
  /// When keys collide, values from [queryParameters] replace existing ones.
  Uri mergeQueryParameters(Map<String, Object?> queryParameters) {
    final merged = <String, List<String>>{};
    queryParametersAll.forEach((key, value) {
      merged[key] = List<String>.from(value);
    });
    final incoming = _toQueryParametersAll(queryParameters);
    incoming.forEach((key, value) {
      merged[key] = value;
    });
    return replace(query: _toQueryString(merged));
  }

  /// Returns a new [Uri] with the provided [keys] removed from query parameters.
  Uri removeQueryParameters(Iterable<String> keys) {
    final updated = <String, List<String>>{};
    queryParametersAll.forEach((key, value) {
      if (!keys.contains(key)) {
        updated[key] = List<String>.from(value);
      }
    });
    return replace(query: _toQueryString(updated));
  }

  /// Returns a new [Uri] with [segment] appended to the path.
  Uri appendPathSegment(String segment) {
    if (segment.isEmpty) return this;
    final segments = _normalizedPathSegments(this)
      ..addAll(_cleanPathSegments([segment]));
    return replace(pathSegments: segments);
  }

  /// Returns a new [Uri] with [segments] appended to the path.
  Uri appendPathSegments(Iterable<String> segments) {
    final cleaned = _cleanPathSegments(segments);
    if (cleaned.isEmpty) return this;
    final combined = _normalizedPathSegments(this)..addAll(cleaned);
    return replace(pathSegments: combined);
  }

  /// Normalizes the trailing slash in the path.
  ///
  /// If [trailingSlash] is true, ensures the path ends with a slash.
  /// If false, removes any trailing slashes.
  Uri normalizeTrailingSlash({bool trailingSlash = true}) {
    final currentPath = path;
    if (currentPath.isEmpty) return this;

    if (trailingSlash) {
      if (currentPath.endsWith('/')) return this;
      return replace(path: '$currentPath/');
    }

    final normalized = currentPath.replaceAll(RegExp(r'/+$'), '');
    return normalized == currentPath ? this : replace(path: normalized);
  }
}

Map<String, List<String>> _toQueryParametersAll(
  Map<String, Object?> queryParameters,
) {
  final result = <String, List<String>>{};

  queryParameters.forEach((key, value) {
    if (value == null) return;
    if (value is Iterable && value is! String) {
      final values = value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList(growable: false);
      if (values.isNotEmpty) {
        result[key] = values;
      }
      return;
    }
    result[key] = [value.toString()];
  });

  return result;
}

String _toQueryString(Map<String, List<String>> queryParameters) {
  if (queryParameters.isEmpty) return '';
  final pairs = <String>[];

  queryParameters.forEach((key, values) {
    final encodedKey = Uri.encodeQueryComponent(key);
    if (values.isEmpty) {
      pairs.add(encodedKey);
      return;
    }
    for (final value in values) {
      final encodedValue = Uri.encodeQueryComponent(value);
      pairs.add('$encodedKey=$encodedValue');
    }
  });

  return pairs.join('&');
}

List<String> _normalizedPathSegments(Uri uri) {
  final segments = uri.pathSegments.toList();
  if (segments.isNotEmpty && segments.last.isEmpty) {
    segments.removeLast();
  }
  return segments;
}

List<String> _cleanPathSegments(Iterable<String> segments) {
  final cleaned = <String>[];
  for (final segment in segments) {
    if (segment.isNotEmpty) {
      cleaned.add(segment);
    }
  }
  return cleaned;
}
