import 'package:dart_helper_utils/dart_helper_utils.dart';

extension DHUNullSafeURIExtensions on String? {
  /// Converts the string to a [Uri] object in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'https://example.com'.tryToUri; // Uri.parse('https://example.com')
  /// ```
  Uri? tryToUri() => this == null ? null : Uri.tryParse(this!.clean);

  /// Converts the string to a phone [Uri] with the 'tel' scheme in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// '+1 (555) 123-4567'.tryToPhoneUri; // Uri(scheme: 'tel', path: '+15551234567')
  /// ```
  Uri? tryToPhoneUri() => this?.toPhoneUri();

  /// Converts the string to an email [Uri] with optional subject and body in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'user@example.com'.tryToEmailUri(subject: 'Hello', body: 'How are you?');
  /// // Uri(scheme: 'mailto', path: 'user@example.com', queryParameters: {'subject': 'Hello', 'body': 'How are you?'})
  /// ```
  Uri? tryToEmailUri({String? subject, String? body}) =>
      this?.toEmailUri(subject: subject, body: body);

  /// Converts the string to a WhatsApp [Uri] for sending messages in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// '+1234567890'.tryToWhatsAppUri(message: 'Hello');
  /// // Uri(scheme: 'https', host: 'wa.me', path: '1234567890', queryParameters: {'text': 'Hello'})
  /// ```
  Uri? tryToWhatsAppUri({String? message}) =>
      this?.toWhatsAppUri(message: message);

  /// Converts the string to an SMS [Uri] with an optional body in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// '+1234567890'.tryToSMSUri(body: 'Hello');
  /// // Uri(scheme: 'sms', path: '+1234567890', queryParameters: {'body': 'Hello'})
  /// ```
  Uri? tryToSMSUri({String? body}) => this?.toSMSUri(body: body);

  /// Converts the string to a Maps [Uri] for location queries in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// '1600 Amphitheatre Parkway, Mountain View, CA'.tryToMapLocationUri();
  /// // Uri(scheme: 'geo', path: '0,0', queryParameters: {'q': '1600 Amphitheatre Parkway, Mountain View, CA'})
  /// ```
  Uri? tryToMapLocationUri() => this?.toMapLocationUri();

  /// Converts the string to a web [Uri], adding 'https://' if missing, in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'example.com'.tryToWebUri();
  /// // Uri.parse('https://example.com')
  /// ```
  Uri? tryToWebUri() => this?.toWebUri();

  /// Converts a file path to a 'file:' URI in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// '/path/to/file.txt'.tryToFileUri();
  /// // Uri.file('/path/to/file.txt')
  /// ```
  Uri? tryToFileUri() => this?.toFileUri();

  /// Converts the string to a Telegram [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'username'.tryToTelegramUri();
  /// // Uri(scheme: 'tg', host: 'resolve', queryParameters: {'domain': 'username'})
  /// ```
  Uri? tryToTelegramUri({bool useAppScheme = true}) =>
      this?.toTelegramUri(useAppScheme: useAppScheme);

  /// Converts the string to a YouTube [Uri] for a video ID in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'dQw4w9WgXcQ'.tryToYouTubeUri();
  /// // Uri.parse('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
  /// ```
  Uri? tryToYouTubeUri({bool useAppScheme = false}) =>
      this?.toYouTubeUri(useAppScheme: useAppScheme);

  /// Converts the string to a Twitter [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'jack'.tryToTwitterUri();
  /// // Uri.parse('https://X.com/jack')
  /// ```
  Uri? tryToTwitterUri({bool useAppScheme = false}) =>
      this?.toTwitterUri(useAppScheme: useAppScheme);

  /// Converts the string to a LinkedIn [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'john-doe-123456'.tryToLinkedInUri();
  /// // Uri.parse('https://www.linkedin.com/in/john-doe-123456')
  /// ```
  Uri? tryToLinkedInUri() => this?.toLinkedInUri();

  /// Converts the string to a Facebook [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'zuck'.tryToFacebookUserUri();
  /// // Uri.parse('https://www.facebook.com/zuck')
  /// ```
  Uri? tryToFacebookUserUri({bool useAppScheme = false}) =>
      this?.toFacebookUserUri(useAppScheme: useAppScheme);

  /// Converts the string to an Instagram [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'instagram'.tryToInstagramUserUri();
  /// // Uri.parse('https://www.instagram.com/instagram')
  /// ```
  Uri? tryToInstagramUserUri({bool useAppScheme = false}) =>
      this?.toInstagramUserUri(useAppScheme: useAppScheme);

  /// Converts the string to a TikTok [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// '@charlidamelio'.tryToTikTokUserUri();
  /// // Uri.parse('https://www.tiktok.com/@charlidamelio')
  /// ```
  Uri? tryToTikTokUserUri() => this?.toTikTokUserUri();

  /// Converts the string to a GitHub user profile [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'octocat'.tryToGitHubUserUri();
  /// // Uri.parse('https://github.com/octocat')
  /// ```
  Uri? tryToGitHubUserUri() => this?.toGitHubUserUri();

  /// Converts the string to a GitHub repository [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'octocat/Hello-World'.tryToGitHubRepoUri();
  /// // Uri.parse('https://github.com/octocat/Hello-World')
  /// ```
  Uri? tryToGitHubRepoUri() => this?.toGitHubRepoUri();

  /// Converts the string to a Google Maps directions [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'New York, NY'.tryToGoogleMapsDirectionsUri(destination: 'Los Angeles, CA');
  /// // Uri(scheme: 'https', host: 'www.google.com', path: '/maps/dir/', queryParameters: {'api': '1', 'origin': 'New York, NY', 'destination': 'Los Angeles, CA'})
  /// ```
  Uri? tryToGoogleMapsDirectionsUri({required String destination}) =>
      this?.toGoogleMapsDirectionsUri(destination: destination);

  /// Converts the string to a Google Maps search [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'coffee shops near me'.tryToGoogleMapsSearchUri();
  /// // Uri(scheme: 'https', host: 'www.google.com', path: '/maps/search/', queryParameters: {'api': '1', 'query': 'coffee shops near me'})
  /// ```
  Uri? tryToGoogleMapsSearchUri() => this?.toGoogleMapsSearchUri();

  /// Converts the string to a Reddit user profile [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'spez'.tryToRedditUserUri();
  /// // Uri.parse('https://www.reddit.com/user/spez')
  /// ```
  Uri? tryToRedditUserUri() => this?.toRedditUserUri();

  /// Converts the string to a Reddit subreddit [Uri] in a null-safe manner.
  ///
  /// Example:
  /// ```dart
  /// 'dartlang'.tryToRedditSubredditUri();
  /// // Uri.parse('https://www.reddit.com/r/dartlang')
  /// ```
  Uri? tryToRedditSubredditUri() => this?.toRedditSubredditUri();
}

extension DHUURIExtensions on String {
  /// Converts the string to a [Uri] object.
  ///
  /// Example:
  /// ```dart
  /// 'https://example.com'.toUri; // Uri.parse('https://example.com')
  /// ```
  Uri toUri() => Uri.parse(clean);

  /// Converts the string to a phone [Uri] with the 'tel' scheme.
  ///
  /// Example:
  /// ```dart
  /// '+1 (555) 123-4567'.toPhoneUri; // tel:+15551234567
  /// ```
  Uri toPhoneUri() {
    final phone = clean.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      throw const FormatException('Invalid phone number');
    }
    return Uri(
      scheme: 'tel',
      path: '+$phone',
    );
  }

  /// Converts the string to an email [Uri] with optional subject and body.
  ///
  /// Example:
  /// ```dart
  /// 'user@example.com'.toEmailUri(subject: 'Hello', body: 'How are you?');
  /// // mailto:user@example.com?subject=Hello&body=How%20are%20you%3F
  /// ```
  Uri toEmailUri({String? subject, String? body}) {
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(clean)) {
      throw const FormatException('Invalid email address');
    }
    return Uri(
      scheme: 'mailto',
      path: clean,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
  }

  /// Converts the string to a WhatsApp [Uri] for sending messages.
  ///
  /// Example:
  /// ```dart
  /// '+1234567890'.toWhatsAppUri(message: 'Hello');
  /// // https://wa.me/1234567890?text=Hello
  /// ```
  Uri toWhatsAppUri({String? message}) {
    final phone = clean.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      throw const FormatException('Invalid phone number');
    }
    final queryParameters = message != null ? {'text': message} : null;
    return Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phone,
      queryParameters: queryParameters,
    );
  }

  /// Converts the string to an SMS [Uri] with an optional body.
  ///
  /// Example:
  /// ```dart
  /// '+1234567890'.toSMSUri(body: 'Hello');
  /// // sms:+1234567890?body=Hello
  /// ```
  Uri toSMSUri({String? body}) {
    final phone = clean.replaceAll(RegExp(r'\D'), '');
    if (phone.isEmpty) {
      throw const FormatException('Invalid phone number');
    }
    return Uri(
      scheme: 'sms',
      path: '+$phone',
      queryParameters: {
        if (body != null) 'body': body,
      },
    );
  }

  /// Converts the string to a Maps [Uri] for location queries.
  ///
  /// Example:
  /// ```dart
  /// '1600 Amphitheatre Parkway, Mountain View, CA'.toMapLocationUri();
  /// // geo:0,0?q=1600%20Amphitheatre%20Parkway%2C%20Mountain%20View%2C%20CA
  /// ```
  Uri toMapLocationUri() {
    if (clean.isEmpty) {
      throw const FormatException('Invalid location');
    }
    return Uri(
      scheme: 'geo',
      path: '0,0',
      queryParameters: {'q': clean},
    );
  }

  /// Converts the string to a web [Uri], adding 'https://' if missing.
  ///
  /// Example:
  /// ```dart
  /// 'example.com'.toWebUri;
  /// // https://example.com
  /// ```
  Uri toWebUri([int start = 0, int? end]) {
    final uriString =
        clean.startsWith(RegExp('https?://')) ? clean : 'https://$clean';
    return Uri.parse(uriString, start, end);
  }

  /// Converts a file path to a 'file:' URI.
  ///
  /// Example:
  /// ```dart
  /// '/path/to/file.txt'.toFileUri;
  /// // file:///path/to/file.txt
  /// ```
  Uri toFileUri({bool? windows}) => Uri.file(
        clean,
        windows: windows,
      );

  /// Converts the string to a Telegram [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'username'.toTelegramUri();
  /// // https://t.me/username
  /// ```
  Uri toTelegramUri({bool useAppScheme = true}) {
    if (clean.isEmpty) {
      throw const FormatException('Invalid Telegram username');
    }
    if (useAppScheme) {
      return Uri(
        scheme: 'tg',
        host: 'resolve',
        queryParameters: {'domain': clean},
      );
    } else {
      return Uri.parse('https://t.me/$clean');
    }
  }

  /// Converts the string to a YouTube [Uri] for a video ID.
  ///
  /// Example:
  /// ```dart
  /// 'dQw4w9WgXcQ'.toYouTubeUri();
  /// // https://www.youtube.com/watch?v=dQw4w9WgXcQ
  /// ```
  Uri toYouTubeUri({bool useAppScheme = false}) {
    if (clean.isEmpty) {
      throw const FormatException('Invalid YouTube video ID');
    }
    if (useAppScheme) {
      return Uri(
        scheme: 'vnd.youtube',
        path: clean,
      );
    } else {
      return Uri.parse('https://www.youtube.com/watch?v=$clean');
    }
  }

  /// Converts the string to a Twitter [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'jack'.toTwitterUri();
  /// // https://X.com/jack
  /// ```
  Uri toTwitterUri({bool useAppScheme = false}) {
    if (clean.isEmpty) {
      throw const FormatException('Invalid Twitter handle');
    }
    if (useAppScheme) {
      return Uri(
        scheme: 'X',
        host: 'user',
        queryParameters: {'screen_name': clean},
      );
    } else {
      return Uri.parse('https://X.com/$clean');
    }
  }

  /// Converts the string to a LinkedIn [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'john-doe-123456'.toLinkedInUri();
  /// // https://www.linkedin.com/in/john-doe-123456
  /// ```
  Uri toLinkedInUri() {
    if (clean.isEmpty) {
      throw const FormatException('Invalid LinkedIn profile');
    }
    return Uri.parse('https://www.linkedin.com/in/$clean');
  }

  /// Converts the string to a Facebook [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'zuck'.toFacebookUri();
  /// // https://www.facebook.com/zuck
  /// ```
  Uri toFacebookUserUri({bool useAppScheme = false}) {
    if (clean.isEmpty) {
      throw const FormatException('Invalid Facebook profile');
    }
    if (useAppScheme) {
      // Note: The Facebook app URI schemes are not officially documented and may change.
      return Uri(
        scheme: 'fb',
        host: 'profile',
        path: clean,
      );
    } else {
      return Uri.parse('https://www.facebook.com/$clean');
    }
  }

  /// Converts the string to an Instagram [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'instagram'.toInstagramUserUri();
  /// // https://www.instagram.com/instagram
  /// ```
  Uri toInstagramUserUri({bool useAppScheme = false}) {
    if (clean.isEmpty) {
      throw const FormatException('Invalid Instagram username');
    }
    if (useAppScheme) {
      // Instagram app may not support user profiles via URI scheme.
      return Uri.parse('instagram://user?username=$clean');
    } else {
      return Uri.parse('https://www.instagram.com/$clean');
    }
  }

  /// Converts the string to a TikTok [Uri].
  ///
  /// Example:
  /// ```dart
  /// '@charlidamelio'.toTikTokUserUri();
  /// // https://www.tiktok.com/@charlidamelio
  /// ```
  Uri toTikTokUserUri() {
    if (clean.isEmpty) {
      throw const FormatException('Invalid TikTok username');
    }
    final username = clean.startsWith('@') ? clean : '@$clean';
    return Uri.parse('https://www.tiktok.com/$username');
  }

  /// Converts the string to a GitHub user profile [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'octocat'.toGitHubUserUri();
  /// // https://github.com/octocat
  /// ```
  Uri toGitHubUserUri() {
    if (clean.isEmpty) {
      throw const FormatException('Invalid GitHub username');
    }
    return Uri.parse('https://github.com/$clean');
  }

  /// Converts the string to a GitHub repository [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'octocat/Hello-World'.toGitHubRepoUri();
  /// // https://github.com/octocat/Hello-World
  /// ```
  Uri toGitHubRepoUri() {
    if (!clean.contains('/')) {
      throw const FormatException(
          'Invalid GitHub repository format. Use "owner/repo".');
    }
    return Uri.parse('https://github.com/$clean');
  }

  /// Converts the string to a Google Maps directions [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'New York, NY'.toGoogleMapsDirectionsUri(destination: 'Los Angeles, CA');
  /// // https://www.google.com/maps/dir/?api=1&origin=New%20York%2C%20NY&destination=Los%20Angeles%2C%20CA
  /// ```
  Uri toGoogleMapsDirectionsUri({required String destination}) {
    if (clean.isEmpty || destination.trim().isEmpty) {
      throw const FormatException(
          'Invalid origin or destination for Google Maps directions');
    }
    return Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/dir/',
      queryParameters: {
        'api': '1',
        'origin': clean,
        'destination': destination.trim(),
      },
    );
  }

  /// Converts the string to a Google Maps search [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'coffee shops near me'.toGoogleMapsSearchUri();
  /// // https://www.google.com/maps/search/?api=1&query=coffee%20shops%20near%20me
  /// ```
  Uri toGoogleMapsSearchUri() {
    if (clean.isEmpty) {
      throw const FormatException('Invalid search query for Google Maps');
    }
    return Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/search/',
      queryParameters: {
        'api': '1',
        'query': clean,
      },
    );
  }

  /// Converts the string to a Reddit user profile [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'spez'.toRedditUserUri();
  /// // https://www.reddit.com/user/spez
  /// ```
  Uri toRedditUserUri() {
    if (clean.isEmpty) {
      throw const FormatException('Invalid Reddit username');
    }
    return Uri.parse('https://www.reddit.com/user/$clean');
  }

  /// Converts the string to a Reddit subreddit [Uri].
  ///
  /// Example:
  /// ```dart
  /// 'dartlang'.toRedditSubredditUri();
  /// // https://www.reddit.com/r/dartlang
  /// ```
  Uri toRedditSubredditUri() {
    if (clean.isEmpty) {
      throw const FormatException('Invalid subreddit name');
    }
    return Uri.parse('https://www.reddit.com/r/$clean');
  }
}

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
