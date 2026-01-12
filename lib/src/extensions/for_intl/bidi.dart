import 'package:intl/intl.dart';

/// Provides extensions for [TextDirection] to support bidirectional text formatting.
extension DHUBidiTDExtensions on TextDirection? {
  /// Creates a BidiFormatter object based on the directionality.
  ///
  /// If [alwaysSpan] is true, a `span` tag is always used, ensuring consistent DOM structure.
  BidiFormatter toBidiFormatter([bool alwaysSpan = false]) =>
      switch (this?.value ?? 'UNKNOWN') {
        'LTR' => BidiFormatter.LTR(alwaysSpan),
        'RTL' => BidiFormatter.RTL(alwaysSpan),
        _ => BidiFormatter.UNKNOWN(alwaysSpan),
      };
}

/// Provides extensions for [String] to support bidirectional text handling and manipulation.
extension DHUBidiStringExtensions on String {
  /// Strips HTML tags from the string if needed, preserving bidirectional text direction.
  String stripHtmlIfNeeded() => Bidi.stripHtmlIfNeeded(this);

  /// Checks if the string starts with left-to-right (LTR) text, optionally considering HTML markup.
  bool startsWithLtr([bool isHtml = false]) => Bidi.startsWithLtr(this, isHtml);

  /// Checks if the string starts with right-to-left (RTL) text, optionally considering HTML markup.
  bool startsWithRtl([bool isHtml = false]) => Bidi.startsWithRtl(this, isHtml);

  /// Checks if the string ends with left-to-right (LTR) text, optionally considering HTML markup.
  bool endsWithLtr([bool isHtml = false]) => Bidi.endsWithLtr(this, isHtml);

  /// Checks if the string ends with right-to-left (RTL) text, optionally considering HTML markup.
  bool endsWithRtl([bool isHtml = false]) => Bidi.endsWithRtl(this, isHtml);

  /// Checks if the string contains any left-to-right (LTR) characters, optionally considering HTML markup.
  bool hasAnyLtr([bool isHtml = false]) => Bidi.hasAnyLtr(this, isHtml);

  /// Checks if the string contains any right-to-left (RTL) characters, optionally considering HTML markup.
  bool hasAnyRtl([bool isHtml = false]) => Bidi.hasAnyRtl(this, isHtml);

  /// Checks if the string represents a right-to-left (RTL) language text.
  ///
  /// If [languageString] is provided, it is used instead of `this`.
  bool isRtlLanguage([String? languageString]) =>
      Bidi.isRtlLanguage(languageString ?? this);

  /// Enforces right-to-left (RTL) directionality in HTML markup.
  String enforceRtlInHtml() => Bidi.enforceRtlInHtml(this);

  /// Enforces right-to-left (RTL) directionality in plain text.
  String enforceRtlIn() => Bidi.enforceRtlInText(this);

  /// Enforces left-to-right (LTR) directionality in HTML markup.
  String enforceLtrInHtml() => Bidi.enforceLtrInHtml(this);

  /// Enforces left-to-right (LTR) directionality in plain text.
  String enforceLtr() => Bidi.enforceLtrInText(this);

  /// Guards brackets in HTML markup to maintain bidirectional text support.
  String guardBracketInHtml([bool? isRtlContext]) =>
      Bidi.guardBracketInHtml(this, isRtlContext);

  /// Guards brackets in plain text to maintain bidirectional text support.
  String guardBracket([bool? isRtlContext]) =>
      Bidi.guardBracketInText(this, isRtlContext);

  /// Guesses the text directionality based on its content, optionally considering HTML markup.
  TextDirection guessDirection({bool isHtml = false}) =>
      Bidi.estimateDirectionOfText(this, isHtml: isHtml);

  /// Detects the predominant text directionality in the string, optionally considering HTML markup.
  bool detectRtlDirectionality({bool isHtml = false}) =>
      Bidi.detectRtlDirectionality(this, isHtml: isHtml);

  /// Wraps the text with a `span` tag and sets the direction attribute (dir) based on the provided or estimated direction.
  ///
  /// If [textDirection] is not provided, it estimates the text direction.
  ///
  /// If [isHtml] is false, the text is HTML-escaped.
  ///
  /// If [resetDir] is true and the overall directionality or the exit directionality of the text is opposite to the context directionality,
  /// a trailing unicode BiDi mark matching the context directionality is appended (LRM or RLM).
  String wrapWithSpan({
    TextDirection textDirection = textDirectionUNKNOWN,
    bool isHtml = false,
    bool resetDir = true,
  }) {
    return textDirection.toBidiFormatter().wrapWithSpan(
          this,
          isHtml: isHtml,
          resetDir: resetDir,
          direction: textDirection,
        );
  }

  /// Wraps the text with unicode BiDi formatting characters based on the provided or estimated direction.
  ///
  /// If [textDirection] is not provided, it estimates the text direction.
  ///
  /// If [isHtml] is false, the text is HTML-escaped.
  ///
  /// If [resetDir] is true and the overall directionality or the exit directionality of the text is opposite to the context directionality,
  /// a trailing unicode BiDi mark matching the context directionality is appended (LRM or RLM).
  String wrapWithUnicode({
    TextDirection textDirection = textDirectionUNKNOWN,
    bool isHtml = false,
    bool resetDir = true,
  }) =>
      textDirection.toBidiFormatter().wrapWithUnicode(
            this,
            isHtml: isHtml,
            resetDir: resetDir,
            direction: textDirection,
          );
}

/// Left-to-right text direction constant.
const TextDirection textDirectionLTR = TextDirection.LTR;

/// Right-to-left text direction constant.
const TextDirection textDirectionRTL = TextDirection.RTL;

/// Unknown text direction constant.
const TextDirection textDirectionUNKNOWN = TextDirection.UNKNOWN;
