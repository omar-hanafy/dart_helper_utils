import 'package:intl/intl.dart';

/// Provides extensions for [Map<Object, T>] to support internationalization (i18n) message formatting.
/// IntlMapExtension
extension IntlMapExtension<T> on Map<Object, T> {
  /// Internal: Implements the logic for `select` - use `intlSelect` for
  /// normal messages.
  ///
  /// [choice]: The choice used to select the appropriate message.
  ///
  /// Returns the selected value from the map based on the provided [choice].
  ///
  /// This method is typically used internally for implementing `select` logic.
  T intlSelectLogic(Object choice) => Intl.selectLogic(choice, this);
}

/// Provides extensions for [Map<Object, String>] to support internationalization (i18n) message formatting.
/// IntlMapStringExtension
extension IntlMapStringExtension on Map<Object, String> {
  /// Format a message differently depending on [choice].
  ///
  /// We look up the value
  /// of [choice] in `cases` and return the result, or an empty string if
  /// it is not found. Normally used as part
  /// of an Intl.message message that is to be translated.
  ///
  /// It is possible to use a Dart enum as the choice and as the
  /// key in `cases`, but note that we will process this by truncating
  /// `toString()` of the enum and using just the name part. We will
  /// do this for any class or strings that are passed, since we
  /// can't actually identify if something is an enum or not.
  ///
  /// [choice]: The choice used to select the appropriate message.
  ///
  /// [desc]: A description of the message for translators.
  ///
  /// [examples]: Map of example values for each possible choice to aid translators.
  ///
  /// [locale]: The locale in which the message should be formatted.
  ///
  /// [name]: An optional name to identify this message.
  ///
  /// [args]: Optional list of arguments to be inserted into the message.
  ///
  /// [meaning]: An optional meaning to disambiguate different usages of the same message.
  ///
  /// [skip]: Whether the message should be skipped for translation.
  ///
  /// Returns the formatted message corresponding to the provided [choice], or an empty string if not found.
  ///
  /// Example:
  /// ```dart
  /// final messages = {
  ///   'apples': 'You have $apples apples',
  ///   'oranges': 'You have $oranges oranges',
  ///   'bananas': 'You have $bananas bananas',
  /// };
  ///
  /// final fruitCount = {'apples': 5, 'oranges': 2, 'bananas': 3};
  ///
  /// print(messages.intlSelect('apples', args: [fruitCount['apples']])); // Output: "You have 5 apples"
  /// print(messages.intlSelect('pears')); // Output: ""
  /// ```
  String intlSelect(
    Object choice, {
    String? desc,
    Map<String, Object>? examples,
    String? locale,
    String? name,
    List<Object>? args,
    String? meaning,
    bool? skip,
  }) {
    return Intl.select(
      choice,
      this,
      desc: desc,
      examples: examples,
      locale: locale,
      name: name,
      args: args,
      meaning: meaning,
      skip: skip,
    );
  }
}

/// on
extension DHUIntlNumExtensions on num {
  /// Returns a localized string based on the plural category of this number.
  ///
  /// This uses the `Intl.plural` function to determine the appropriate
  /// plural form for the current locale and number.
  ///
  /// Arguments:
  ///   - `other`: The string to return for plural forms other than zero, one, two, few, or many.
  ///   - `zero`, `one`, `two`, `few`, `many`: Strings for specific plural forms (optional).
  ///   - `desc`, `examples`, `locale`, `name`, `args`, `meaning`, `skip`:
  ///     Optional parameters for fine-tuning the pluralization logic
  ///     (see `Intl.plural` documentation).
  String pluralize({
    required String other,
    String? zero,
    String? one,
    String? two,
    String? few,
    String? many,
    String? desc,
    Map<String, Object>? examples,
    String? locale,
    int? precision,
    String? name,
    List<Object>? args,
    String? meaning,
    bool? skip,
  }) => Intl.plural(
    this,
    other: other,
    zero: zero,
    one: one,
    two: two,
    few: few,
    many: many,
    desc: desc,
    examples: examples,
    locale: locale,
    precision: precision,
    name: name,
    args: args,
    meaning: meaning,
    skip: skip,
  );

  /// Determines the plural category of this number based on the current locale.
  ///
  /// This uses the `Intl.pluralLogic` function to categorize the number into
  /// one of the following: 'zero', 'one', 'two', 'few', 'many', or 'other'.
  ///
  /// Arguments:
  ///   - `other`: A default value to return if none of the specific plural forms match.
  ///   - `zero`, `one`, `two`, `few`, `many`: Values to return for specific plural forms (optional).
  ///   - `locale`, `precision`, `meaning`:
  ///     Optional parameters to customize the pluralization rules
  ///     (see `Intl.pluralLogic` documentation).
  ///   - `useExplicitNumberCases`:  If `true`, number cases (e.g., "1") are passed to `Intl.pluralLogic`.
  ///     If `false`, only the number's value is passed.
  T getPluralCategory<T>({
    required T other,
    T? zero,
    T? one,
    T? two,
    T? few,
    T? many,
    String? locale,
    int? precision,
    String? meaning,
    bool useExplicitNumberCases = true,
  }) => Intl.pluralLogic(
    this,
    zero: zero,
    one: one,
    two: two,
    few: few,
    many: many,
    other: other,
    locale: locale,
    precision: precision,
    meaning: meaning,
    useExplicitNumberCases: useExplicitNumberCases,
  );
}

/// DHUIntlNumExtensions
extension DHUIntlExtensions on String {
  /// Sets this string as the default locale for subsequent `Intl` operations.
  ///
  /// This overrides the locale used for new `Intl` instances where the
  /// locale isn't explicitly specified.
  ///
  /// Note: Using `Intl.withLocale` is often preferable for setting locales
  /// temporarily within specific blocks of code.
  void setAsDefaultLocale() => Intl.defaultLocale = this;

  /// Sets this string as the system locale, typically obtained from
  /// browser settings or the operating system.
  ///
  /// This should generally be called after importing `intl_browser.dart` or
  /// `intl_standalone.dart` and using `findSystemLocale()` to determine the
  /// actual system locale value.
  void setAsSystemLocale() => Intl.systemLocale = this;

  /// Translates this string using `Intl.message`, returning the localized version.
  ///
  /// Arguments:
  ///   - `desc`: A description of the message for translators (optional).
  ///   - `examples`: Examples of how the message is used (optional).
  ///   - `locale`: The specific locale to use for translation (optional).
  ///   - `name`: A name for the message (optional).
  ///   - `args`: Arguments to substitute into the message (optional).
  ///   - `meaning`: An additional meaning for disambiguation (optional).
  ///   - `skip`: If `true`, the message is not extracted for translation (optional).
  String translate({
    String? desc = '',
    Map<String, Object>? examples,
    String? locale,
    String? name,
    List<Object>? args,
    String? meaning,
    bool? skip,
  }) => Intl.message(
    this,
    desc: desc,
    examples: examples,
    locale: locale,
    name: name,
    args: args,
    meaning: meaning,
    skip: skip,
  );

  /// Selects a localized string based on the gender associated with this string,
  /// using `Intl.gender`.
  ///
  /// Arguments:
  ///   - `other`: The string to return for genders other than "female" or "male".
  ///   - `female`, `male`: Strings for specific genders (optional).
  ///   - `desc`, `examples`, `locale`, `name`, `args`, `meaning`, `skip`:
  ///     Optional parameters for customizing the gender-based selection
  ///     (see `Intl.gender` documentation).
  String genderSelect({
    required String other,
    String? female,
    String? male,
    String? desc,
    Map<String, Object>? examples,
    String? locale,
    String? name,
    List<Object>? args,
    String? meaning,
    bool? skip,
  }) => Intl.gender(
    this,
    female: female,
    male: male,
    other: other,
    desc: desc,
    examples: examples,
    locale: locale,
    name: name,
    args: args,
    meaning: meaning,
    skip: skip,
  );

  /// Determines the gender category of this string (e.g., 'female', 'male', or 'other')
  /// based on the current locale, using `Intl.genderLogic`.
  ///
  /// Arguments:
  ///   - `other`: A default value to return if none of the specific gender values match.
  ///   - `female`, `male`: Values to return for specific genders (optional).
  ///   - `locale`: The specific locale to use for gender determination (optional).
  T getGenderCategory<T>({
    required T other,
    T? female,
    T? male,
    String? locale,
  }) => Intl.genderLogic(
    this,
    female: female,
    male: male,
    other: other,
    locale: locale,
  );
}
