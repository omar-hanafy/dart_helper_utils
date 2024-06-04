![](https://raw.githubusercontent.com/omar-hanafy/dart_helper_utils/fb2b340acff23ad89b09319dac691d98f1ecca90/logo.svg)

The `dart_helper_utils` package provides a collection of Dart utilities, tools for converting dynamic objects to various types, and extending core Dart classes with extensions.

**Note:** This package is tailored for Dart projects. For Flutter projects, use [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils), which includes all `dart_helper_utils` features plus additional utilities and extensions for Flutter, such as `Widget`, `Color`, and `BuildContext` extensions.

## Table of Contents
- [Featured](#featured)
    - [Converting Objects](#converting-objects)
        - [Sample Usage](#sample-usage)
        - [Available Conversions](#available-conversions)
        - [Optional Parameters](#optional-parameters)
    - [TimeUtils](#timeutils)
    
- [Extensions](#extensions)
    - [Date Extensions](#date-extensions)
        - [Month and Day Name Conversion](#month-and-day-name-conversion)
        - [Date and Time Parsing](#date-and-time-parsing)
        - [Date and Time Formatting](#date-and-time-formatting)
        - [Date and Time Comparison](#date-and-time-comparison)
        - [Duration Calculations](#duration-calculations)
        - [Basic DateTime Operations](#basic-datetime-operations)
        - [DateTime Comparison](#datetime-comparison)
        - [DateTime Manipulation](#datetime-manipulation)
    - [String Extensions](#string-extensions)
        - [Case Conversion](#case-conversion)
        - [Text Formatting](#text-formatting)
        - [String Replacement](#string-replacement)
        - [String Comparison](#string-comparison)
        - [String Limiting](#string-limiting)
        - [Character Checks](#character-checks)
        - [Validation](#validation)
        - [Utility](#utility)
        - [Parsing](#parsing)
    - [Extensions For Intl](#extensions-for-intl)
        - [General](#general)
        - [DateFormats](#dateformats)
        - [Bidi Extensions](#bidi-extensions)
        - [Number Format Extensions](#number-format-extensions)
    - [List and Iterable Extensions](#list-and-iterable-extensions)
        - [List Extensions](#list-extensions)
        - [Iterable Extensions](#iterable-extensions)
    - [Duration Extensions](#duration-extensions)
    - [Map Extensions](#map-extensions)
    - [Number Extensions](#number-extensions)
    - [Objects Extensions](#objects-extensions)
    - [Set Extensions](#set-extensions)
    - [Uri Extensions](#uri-extensions)
    - [Bool Extensions](#bool-extensions)
    
    

# Featured

## Converting Objects

Convert objects to various types, such as `int`, `double`, `bool`, `String`, `List`, `Set`, and `Map`. These methods are
useful when dealing with dynamic data from APIs, offering simple and flexible type conversions.

### Sample Usage:

Given an API response:

```dart

Map<String, dynamic> apiResponse = {'score': '12.4'};

// Using parse
int score = double.parse(apiResponse['score']).toInt();

// Using the package:
int score = toInt(apiResponse['score']);
```

### Available Conversions:

#### Methods:

- `toNum()` / `tryToNum()`
- `toInt()` / `tryToInt()`
- `toDouble()` / `tryToDouble()`
- `toBool()` / `tryToBool()`
- `toString1()` / `tryToString1()`
- `toList<T>()` / `tryToList<T>()`
- `toSet<T>()` / `tryToSet<T>()`
- `toMap<K, V>()` / `tryToMap<K, V>()`

### Static Methods:

The methods above call the original static methods from the `ConvertObject` class. For instance:

```dart
int score = toInt(map['key']); // global method
// same as
int score = ConvertObject.toInt(map['key']); // static method
```

**Note:** To avoid conflicts with method names (e.g., `toList`), use the static method directly:

```dart
List myList = ConvertObject.toList(dynamicObject);
```

### Optional Parameters:
Each method accepts two optional parameters: `listIndex` and `mapKey`. These parameters allow specific value extraction and conversion within a `List` or `Map`.

#### Example with `listIndex`:
```dart
dynamic dynamicList = ['10', '20', '30'];
final int number = toInt(dynamicList, listIndex: 1); // 20
```

#### Example with `mapKey`:
```dart
dynamic dynamicMap = {
  'name': 'John',
  'age': '30',
  'bools': {
    'isHuman': 'yes',
  }
};
final bool isHuman = toBool(dynamicMap['bools'], mapKey: 'isHuman'); // true
```

Absolutely! Here's the enhanced documentation for the `ConvertObject` class update:

#### Auto Decoding of JSON Strings for Collections

The `ConvertObject` class now simplifies working with JSON data by automatically decoding raw JSON strings when converting to `List`, `Set`, or `Map` types. This eliminates the need for manual parsing before conversion.

**Example Usage:**

```dart
final myList = tryToList<int>("[1, 2, 3]"); // List<int>
final mySet = tryToSet<String>('["hello", "world"]'); // Set<String>
final myMap = tryToMap<String, dynamic>('{"name": "Alice", "age": 30}'); // Map<String, dynamic>
```

## TimeUtils:

The TimeUtils class provides utilities for measuring and comparing execution times, creating throttled functions, running tasks periodically, and handling tasks with timeouts. Here is a sample with the **executionDuration** method:

```dart
final excutionTime = await TimeUtils.executionDuration(() {
  for (var i = 0; i < 1000000; i++) {}
});
print('Synchronous task took $syncDuration');
// NOTE: works also with asynchronous task
```

Another example with **runWithTimeout**:

```dart
try {
  final result = await TimeUtils.runWithTimeout(
    task: () async {
      await 5.secDelay;
      return 'Completed';
    },
    timeout: const Duration(seconds: 3),
  );
  print('Result: $result');
} catch (e) {
  print('Error: $e');
}
```

# Extensions
## Date Extensions
### Month and Day Name Conversion
- `toFullMonthName`: Numeric month (1-12) to full name (e.g., 1 to "January").
- `toSmallMonthName`: Numeric month (1-12) to abbreviated name (e.g., 1 to "Jan").
- `toFullDayName`: Numeric day (1-7) to full name (e.g., 1 to "Monday").
- `toSmallDayName`: Numeric day (1-7) to abbreviated name (e.g., 1 to "Mon").

### Date and Time Parsing
- `timestampToDate`: Timestamp (milliseconds since epoch) to `DateTime`.
- `tryToDateTime`: Safely parses a nullable string to a nullable `DateTime`.
- `toDateTime`: String to `DateTime`.

### Date and Time Formatting
- `local`: Converts a nullable `DateTime` to local time.
- `toUtcIso`: Converts a nullable `DateTime` to ISO 8601 format in UTC.

### Date and Time Comparison
- `isTomorrow`: Checks if the nullable `DateTime` is tomorrow.
- `isToday`: Checks if the nullable `DateTime` is today.
- `isYesterday`: Checks if the nullable `DateTime` is yesterday.
- `isPresent`: Checks if the nullable `DateTime` is in the future.
- `isPast`: Checks if the nullable `DateTime` is in the past.
- `isInPastWeek`: Checks if the nullable `DateTime` is within the past week.
- `isInThisYear`: Checks if the nullable `DateTime` is in the current year.
- `isFirstDayOfMonth`: Checks if the nullable `DateTime` is the first day of the month.
- `isLastDayOfMonth`: Checks if the nullable `DateTime` is the last day of the month.
- `isLeapYear`: Checks if the nullable `DateTime` is in a leap year.

### Duration Calculations
- `passedDuration`: Gets the duration since the nullable `DateTime`.
- `remainingDuration`: Gets the duration until the nullable `DateTime`.
- `remainingDays`: Gets the remaining days until the nullable `DateTime`.
- `passedDays`: Gets the passed days since the nullable `DateTime`.

### Basic DateTime Operations
- `local`: Converts a `DateTime` to local time.
- `format`: Formats a `DateTime` to a string with the specified format.
- `toUtcIso`: Converts a `DateTime` to ISO 8601 format in UTC.
- `passedDuration`: Gets the duration since the `DateTime`.
- `passedDays`: Gets the passed days since the `DateTime`.
- `remainingDuration`: Gets the duration until the `DateTime`.
- `remainingDays`: Gets the remaining days until the `DateTime`.

### DateTime Comparison
- `isAtSameYearAs`, `isAtSameMonthAs`, `isAtSameDayAs`, `isAtSameHourAs`, `isAtSameMinuteAs`, `isAtSameSecondAs`, `isAtSameMillisecondAs`, `isAtSameMicrosecondAs`: Checks if another `DateTime` matches the same component.

### DateTime Manipulation
- `startOfDay`, `startOfMonth`, `startOfYear`: Gets the start of the day, month, year.
- `tomorrow`, `yesterday`, `today`: Gets the date of tomorrow, yesterday, today.
- `dateOnly`: Gets the date only (midnight time).
- `daysInMonth`: Gets the list of days in the month.
- `previousDay`, `nextDay`: Gets the previous/next day.
- `previousWeek`, `nextWeek`: Gets the date of the previous/next week.
- `firstDayOfWeek`, `lastDayOfWeek`: Gets the first/last day of the week.
- `previousMonth`, `nextMonth`: Gets the date of the previous/next month.
- `firstDayOfMonth`, `lastDayOfMonth`: Gets the first/last day of the month.
- `addOrRemoveYears`, `addOrRemoveMonth`, `addOrRemoveDay`, `addOrRemoveMinutes`, `addOrRemoveSeconds`: Adds or removes years, months, days, minutes, seconds from a `DateTime`.
- `min`, `max`: Returns the smaller/larger of two `DateTime` objects.
- `addDays`, `addHours`: Adds days/hours to a `DateTime`.

## Duration Extensions
- `delayed(FutureOr<T> Function()? computation)`: Delays execution by the duration.
- `fromNow`: Adds the Duration to the current DateTime and gives a future time.
- `ago`: Subtracts the Duration from the current DateTime and gives a pastime.

## List and Iterable Extensions
### List Extensions
- `of`: Retrieves the element at the specified index in a null-safe manner.
- `tryRemoveAt`: Removes the element at the specified index in a null-safe manner.
- `indexOfOrNull`: Retrieves the index of the specified element in a null-safe manner.
- `indexWhereOrNull`: Retrieves the index of the first element that matches the specified predicate in a null-safe manner.
- `tryRemoveWhere`: Removes elements that match the specified condition in a null-safe manner.
- `halfLength`: Returns half the size of the list.
- `takeOnly`: Returns a list containing the first `n` elements.
- `drop`: Returns a list containing all elements except the first `n` elements.
- `firstHalf`: Returns the first half of the list.
- `secondHalf`: Returns the second half of the list.
- `swap`: Returns a list with two items swapped.
- `getRandom`: Retrieves a random element from the list.

### Iterable Extensions
- `isEmptyOrNull`: Returns true if the iterable is either null or empty.
- `isNotEmptyOrNull`: Returns false if the iterable is either null or empty.
- `elementAtOrNull`: Retrieves the element at the specified index or returns null.
- `elementOrNull`: Retrieves the element at the specified index or returns a default value.
- `firstOrNull`: Retrieves the first element or returns null.
- `lastOrNull`: Retrieves the last element or returns null.
- `firstWhereOrNull`: Retrieves the first element that matches the specified predicate or returns null.
- `lastOrDefault`: Retrieves the last element or returns a default value.
- `firstOrDefault`: Retrieves the first element or returns a default value.
- `tryGetRandom`: Retrieves a random element from the iterable or returns null.
- `orEmpty`: Returns the iterable if it's not null and the empty list otherwise.
- `any`: Returns true if at least one element matches the given predicate.
- `concatWithSingleList`: Concatenates the current iterable with another iterable.
- `concatWithMultipleList`: Concatenates the current iterable with multiple iterables.
- `toMutableSet`: Converts the iterable to a set.
- `intersect`: Returns a set containing all elements that are contained by both this set and the specified collection.
- `groupBy`: Groups the elements by the value returned by the specified key function.
- `filter`: Returns a list containing only elements matching the given predicate.
- `filterNot`: Returns a list containing all elements not matching the given predicate.
- `mapList`: Returns the result of applying a function to each element in the iterable as a list.
- `whereIndexed`: Returns an iterable with all elements that satisfy the predicate.
- `forEachIndexed`: Performs the given action on each element in the iterable, providing the sequential index with the element.
- `sortedDescending`: Returns a new list with all elements sorted in descending order.
- `containsAll`: Returns true if all elements in the specified collection are contained in this collection.
- `count`: Returns the number of elements that match the given predicate.
- `all`: Returns true if all elements match the given predicate.
- `distinctBy`: Returns a list containing only elements that have distinct keys, determined by the predicate.
- `subtract`: Returns a set containing all elements that are contained by this collection and not contained by the specified collection.
- `find`: Returns the first element matching the given predicate, or null if not found.
- `encodedJson`: Encodes the iterable as a JSON string.

## Map Extensions
- `makeEncodable`: Converts a map to an encodable format.
- `safelyEncodedJson`: Returns a safely encoded JSON string.
- `isEmptyOrNull`: Checks if the map is empty or null.
- `isNotEmptyOrNull`: Checks if the map is not empty or null.
- `flatJson({String delimiter = '.', bool safe = false, int? maxDepth})`: Flattens a JSON structure.

## Number Extensions
### For `num`
- `isSuccessHttpResCode`: Checks if the HTTP response code is 200 or 201.
- `isValidPhoneNumber`: Checks if the number is a valid phone number.
- `toHttpResStatus`: Converts the number to an `HttpResStatus` enum.
- `tryToInt`: Parses the number as an integer or returns null if it is not a number.
- `tryToDouble`: Parses the number as a double or returns null if it is not a number.
- `percentage`: Calculates the percentage of the number with respect to a total value, with an option to allow decimals.
- `asBool`: Returns true if the number is greater than zero.
- `isPositive`: Returns true if the number is positive.
- `isNegative`: Returns true if the number is negative.
- `isZeroOrNull`: Returns true if the number is zero or null.
- `isZero`: Returns true if the number is zero.
- `isValidPhoneNumber`: Checks if the number is a valid phone number.
- `numberOfDigits`: Returns the number of digits in the number.
- `removeTrailingZero`: Removes trailing zeros from the number's string representation.
- `roundToFiftyOrHundred`: Rounds the number to the nearest fifty or hundred.
- `roundToTenth`: Rounds the number to the nearest tenth.
- `tenth`: Returns a tenth of the number.
- `fourth`: Returns a fourth of the number.
- `third`: Returns a third of the number.
- `half`: Returns half of the number.
- `getRandom`: Returns a random integer between 0 and the number.
- `asGreeks`: Converts the number to a format that includes Greek symbols for thousands, millions, and beyond.
- `delay`: Delays code execution by the number of seconds.
- `daysDelay`: Delays code execution by the number of days.
- `hoursDelay`: Delays code execution by the number of hours.
- `minDelay`: Delays code execution by the number of minutes.
- `secDelay`: Delays code execution by the number of seconds.
- `millisecondsDelay`: Delays code execution by the number of milliseconds.
- `asMilliseconds`: Converts the number to a `Duration` in milliseconds.
- `asSeconds`: Converts the number to a `Duration` in seconds.
- `asMinutes`: Converts the number to a `Duration` in minutes.
- `asHours`: Converts the number to a `Duration` in hours.
- `asDays`: Converts the number to a `Duration` in days.
- `until`: Generates a sequence of numbers starting from the current number up to the specified end value, with the specified step size.

### For `int`
- `inRangeOf`: Returns the number if it is within the specified range, otherwise returns the min or max value.
- `absolute`: Returns the absolute value of the number.
- `doubled`: Returns the number multiplied by two.
- `tripled`: Returns the number multiplied by three.
- `quadrupled`: Returns the number multiplied by four.
- `squared`: Returns the square of the number.

### For `double`
- `inRangeOf`: Returns the number if it is within the specified range, otherwise returns the min or max value.
- `absolute`: Returns the absolute value of the number.
- `doubled`: Returns the number multiplied by two.
- `tripled`: Returns the number multiplied by three.
- `quadrupled`: Returns the number multiplied by four.
- `squared`: Returns the square of the number.

## Objects Extensions
- `encode({Object? Function(dynamic object)? toEncodable})`: Encodes an object to JSON.
- `isNull`: Checks if the object is null.
- `isNotNull`: Checks if the object is not null.
- `asBool`: Converts an object to a boolean value.

## Set Extensions
- `isEmptyOrNull`: Checks if the set is empty or null.
- `isNotEmptyOrNull`: Checks if the set is not empty or null.
- `addIfNotNull(T? value)`: Adds a value to the set if it's not null.
- `toMutableSet()`: Converts the set to a mutable set.
- `intersect(Iterable<T> other)`: Returns the intersection of two sets.

## String Extensions

### Case Conversion
- `toPascalCase`: PascalCase aka (UpperCamelCase).
- `toTitleCase`: Title Case
- `toCamelCase`: camelCase aka (dromedaryCase)
- `toSnakeCase`: snake_case aka (snail_case, pothole_case).
- `toKebabCase`: kebab-case aka (dash-case, lisp-case, spinal-case).
- `toScreamingSnakeCase`: SCREAMING_SNAKE_CASE aka (MACRO_CASE, CONSTANT_CASE, ALL_CAPS).
- `toScreamingKebabCase`: SCREAMING-KEBAB-CASE aka (COBOL-CASE).
- `toPascalSnakeCase`: Pascal_Snake_Case.
- `toPascalKebabCase`: Pascal-Kebab-Case.
- `toTrainCase`: Train-Case aka (HTTP-Header-Case).
- `toCamelSnakeCase`: camel_Snake_Case.
- `toCamelKebabCase`: camel-Kebab-Case.
- `toDotCase`: dot.case.
- `toFlatCase`: flatcase.
- `toScreamingCase`: SCREAMINGCASE.

- `toTitle`: Capitalizes the first letter of each word in the string while retaining `-`, `_`, and space characters.
- `toWords`: Converts any `String` to a `List<String>`, handling complex cases more effectively than the native `split()` method.

### Text Formatting
- `lowercaseFirstLetter`: Lowercases only the first letter of the string, preserving the rest of the case.
- `capitalizeFirstLetter`: Converts the first letter to uppercase and preserves the rest of the case.
- `capitalizeFirstLowerRest`: Converts the first letter to uppercase and the rest to lowercase.
- `tryToLowerCase`: Converts the string to lowercase if it's not null.
- `tryToUpperCase`: Converts the string to uppercase if it's not null.
- `removeEmptyLines`: Removes consecutive empty lines, replacing them with single newlines.
- `toOneLine`: Converts to a single line by replacing all newline characters with spaces.
- `removeWhiteSpaces`: Removes all whitespace characters.
- `clean`: Combines `removeWhiteSpaces` and `toOneLine` to collapse into a single line.
- `wrapString`: Wraps text based on the specified word count, wrapping behavior, and custom delimiter.

### String Replacement
- `replaceAfter`: Replaces part of the string after the first occurrence of the given delimiter with a specified string.
- `replaceBefore`: Replaces part of the string before the first occurrence of the given delimiter with a specified string.
- `removeSurrounding`: Removes the surrounding delimiter if it exists at both ends.

### String Comparison
- `equalsIgnoreCase`: Compares with another string for equality, ignoring case differences.

### String Limiting
- `limitFromEnd`: Shrinks the string to no more than a specified length, starting from the end.
- `limitFromStart`: Shrinks the string to no more than a specified length, starting from the start.

### Character Checks
- `isAlphanumeric`: Checks if the string contains only letters and numbers.
- `hasSpecialChars`: Checks if the string contains any characters that are not letters, numbers, or spaces.
- `hasNoSpecialChars`: Checks if the string does not contain any special characters.
- `startsWithNumber`: Checks if the string starts with a number.
- `containsDigits`: Checks if the string contains any digits.
- `hasCapitalLetter`: Checks if the string contains at least one capital letter.
- `isNumeric`: Checks if the string consists only of numbers.
- `isAlphabet`: Checks if the string consists only of alphabetic characters.
- `isBool`: Checks if the string is a boolean value (true or false).

### Validation
- `isValidUsername`: Checks if the string is a valid username.
- `isValidCurrency`: Checks if the string is a valid currency format.
- `isValidPhoneNumber`: Checks if the string is a valid phone number.
- `isValidEmail`: Checks if the string is a valid email address.
- `isValidHTML`: Checks if the string is a valid HTML file or URL.
- `isValidIp4`: Checks if the string is a valid IPv4 address.
- `isValidIp6`: Checks if the string is a valid IPv6 address.
- `isValidUrl`: Checks if the string is a valid URL.
- `isEmptyOrNull` || `isBlank`: Checks if the string is null or empty.
- `isNotEmptyOrNull` || `isNotBlank`: Checks if the string is not null and not empty.
- `isPalindrome`: Checks if the string is a palindrome.

### Utility
- `orEmpty`: Returns the string if it is not null, or an empty string otherwise.
- `ifEmpty`: Performs an action if the string is empty.
- `lastIndex`: Gets the last character of the string.
- `isNotBlank`: Returns true if the string is neither null, empty, nor solely made of whitespace characters.
- `toCharArray`: Returns a list of characters.
- `insert`: Inserts a specified string at a specified index position.
- `isNullOrWhiteSpace`: Indicates whether the string is null, empty, or consists only of white-space characters.
- `asBool`: Converts the string to a boolean.
- `decode`: Decodes the JSON string into a dynamic data structure.

### Parsing
- `tryToNum`: Parses the string as a number or returns null if it is not a number.
- `tryToDouble`: Parses the string as a double or returns null if it is not a number.
- `tryToInt`: Parses the string as an integer or returns null if it is not a number.
- `toNum`: Parses the string as a number.
- `toDouble`: Parses the string as a double.
- `toInt`: Parses the string as an integer.

## Uri Extensions
- `isValidUri`: Checks if the string is a valid URI.
- `toUri`: Converts the string to a URI object.
- `isHttp`: Checks if the URI uses the HTTP scheme.
- `isHttps`: Checks if the URI uses the HTTPS scheme.
- `host`: Returns the host part of the URI.
- `path`: Returns the path part of the URI.

## Bool Extensions
- `toggled`: returns a new bool which is toggled from the current one.
- `val` & `isTrue`: (nullable boolean): Returns `true` if the value is not null and true
- `isFalse`: (nullable boolean): Returns `true` if the value is not null and false
- `binary`: Returns `1` if the value is non-null and true, otherwise returns `0`.

## Extensions For Intl
### General
#### on Map
- `intlSelectLogic`: Selects a value from the map based on a choice.
- `intlSelect`: Formats a message based on the choice and returns the formatted message.

#### on Num
- `pluralize`: Returns a localized string based on the plural category of the number.
- `getPluralCategory`: Determines the plural category of the number based on the current locale.

#### on String
- `setAsDefaultLocale`: Sets the string as the default locale for subsequent `Intl` operations.
- `setAsSystemLocale`: Sets the string as the system locale.
- `translate`: Translates the string using `Intl.message`.
- `genderSelect`: Selects a localized string based on the gender associated with the string.
- `getGenderCategory`: Determines the gender category of the string based on the current locale.

### DateFormats
#### on String
- `dateFormat`: Returns a `DateFormat` object based on the string pattern.
- `toDateFormatted`: Parses the string to `DateTime` with the provided format, locale, and UTC option.
- `toDateFormattedLoose`: Parses the string to `DateTime` using loose parsing.
- `toDateFormattedStrict`: Parses the string to `DateTime` using strict parsing.
- `toDateFormattedUtc`: Parses the string to `DateTime` in UTC using the provided format and locale.
- `tryToDateFormatted`: Attempts to parse the nullable string to `DateTime` with the provided format, locale, and UTC option.
- `tryToDateFormattedLoose`: Attempts to parse the nullable string to `DateTime` using loose parsing.
- `tryToDateFormattedStrict`: Attempts to parse the nullable string to `DateTime` using strict parsing.
- `tryToDateFormattedUtc`: Attempts to parse the nullable string to `DateTime` in UTC using the provided format and locale.
- `localeExists`: Checks if the locale exists in `DateFormat`.
#### on DateTime
- `tryFormat` and `format`: Formats the DateTime object using the provided pattern and optional locale.
- A variety of methods to format `DateTime` objects in different styles:
    - **Basic:** `yMMMMdFormat`, `d_Format`
    - **Weekday:** `E_Format`, `EEEE_Format`, `EEEEE_Format`
    - **Month:** `LLL_Format`, `LLLL_Format`, `MMMMEEEEd_Format`, etc.
    - **Quarter:** `QQQ_Format`, `QQQQ_Format`
    - **Year:** `y_Format`, `yMMM_Format`, `yQQQQ_Format`, etc.
    - **Time:** `H_Format`, `Hm_Format`, `jms_Format`
      All methods support an optional `locale` parameter.

### Bidi Extensions
#### on TextDirection
- `toBidiFormatter`: Creates a BidiFormatter object based on the directionality.

#### on String
- `stripHtmlIfNeeded`: Strips HTML tags from the string if needed, preserving bidirectional text direction.
- `startsWithLtr`: Checks if the string starts with left-to-right (LTR) text, optionally considering HTML markup.
- `startsWithRtl`: Checks if the string starts with right-to-left (RTL) text, optionally considering HTML markup.
- `endsWithLtr`: Checks if the string ends with left-to-right (LTR) text, optionally considering HTML markup.
- `endsWithRtl`: Checks if the string ends with right-to-left (RTL) text, optionally considering HTML markup.
- `hasAnyLtr`: Checks if the string contains any left-to-right (LTR) characters, optionally considering HTML markup.
- `hasAnyRtl`: Checks if the string contains any right-to-left (RTL) characters, optionally considering HTML markup.
- `isRtlLanguage`: Checks if the string represents a right-to-left (RTL) language text.
- `enforceRtlInHtml`: Enforces right-to-left (RTL) directionality in HTML markup.
- `enforceRtlIn`: Enforces right-to-left (RTL) directionality in plain text.
- `enforceLtrInHtml`: Enforces left-to-right (LTR) directionality in HTML markup.
- `enforceLtr`: Enforces left-to-right (LTR) directionality in plain text.
- `guardBracketInHtml`: Guards brackets in HTML markup to maintain bidirectional text support.
- `guardBracket`: Guards brackets in plain text to maintain bidirectional text support.
- `guessDirection`: Guesses the text directionality based on its content, optionally considering HTML markup.
- `detectRtlDirectionality`: Detects the predominant text directionality in the string, optionally considering HTML markup.
- `wrapWithSpan`: Wraps the text with a `span` tag and sets the direction attribute (dir) based on the provided or estimated direction.
- `wrapWithUnicode`: Wraps the text with unicode BiDi formatting characters based on the provided or estimated direction.

## Number Format Extensions
#### on String
- `tryToNumFormatted`: Tries to parse the string to a number with the given pattern and locale.
- `tryToIntFormatted`: Tries to parse the string to an integer with the given pattern and locale.
- `tryToDoubleFormatted`: Tries to parse the string to a double with the given pattern and locale.
- `toNumFormatted`: Parses the string to a number with the given pattern and locale.
- `toIntFormatted`: Parses the string to an integer with the given pattern and locale.
- `toDoubleFormatted`: Parses the string to a double with the given pattern and locale.

#### on Num
- `formatAsCurrency`: Formats the number as currency with the given locale, symbol, and decimal digits.
- `formatAsSimpleCurrency`: Formats the number as simple currency with the given locale and name.
- `formatAsCompact`: Formats the number in a compact form with the given locale.
- `formatAsCompactLong`: Formats the number in a long compact form with the given locale.
- `formatAsCompactCurrency`: Formats the number as compact simple currency with the given locale and name.
- `formatAsDecimal`: Formats the number as a decimal with the given locale and decimal digits.
- `formatAsPercentage`: Formats the number as a percentage with the given locale.
- `formatAsDecimalPercent`: Formats the number as a decimal percentage with the given locale and decimal digits.
- `formatAsScientific`: Formats the number as a scientific value with the given locale.
- `formatWithCustomPattern`: Formats the number using a custom pattern with the given locale.

## Exceptions
The `ConvertObject` class throws a `ParsingException` if there is an error while converting an object. This exception
provides information about the type of the object and the method used for conversion.

## Contributions
Contributions to this package are welcome. If you have any suggestions, issues, or feature requests, please create a
pull request in the [repository](https://github.com/omar-hanafy/dart_helper_utils).

## License
`dart_helper_utils` is available under the [BSD 3-Clause License.](https://opensource.org/license/bsd-3-clause/)

<a href="https://www.buymeacoffee.com/omar.hanafy" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

**KEYWORDS:**
extension pack, helpers, utilities, string manipulation, conversions, time utils, date extensions, datetime helper,
iterable, map, number, object, set, URI, and boolean extensions, JSON encoding/decoding.