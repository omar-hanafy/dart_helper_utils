[![dart_helper_utils logo](https://raw.githubusercontent.com/omar-hanafy/dart_helper_utils/fb2b340acff23ad89b09319dac691d98f1ecca90/logo.svg)](https://pub.dev/packages/dart_helper_utils)

[![pub package](https://img.shields.io/pub/v/dart_helper_utils)](https://pub.dev/packages/dart_helper_utils)

The `dart_helper_utils` package provides a collection of Dart utilities, tools for converting dynamic objects to various types, and extending core Dart classes with extension.

**Note:** This package is tailored for Dart projects. For Flutter projects, use [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils), which includes all `dart_helper_utils` features plus additional utilities and extension for Flutter, such as `Widget`, `Color`, and `BuildContext` extension.

## Table of Contents
- [Featured](#featured)
  - [Converting Objects](#converting-objects)
    - [Sample Usage](#sample-usage)
    - [Available Conversions](#available-conversions)
    - [Optional Parameters](#optional-parameters)
    - [Extract and Convert](#extract-and-convert)
  - [TimeUtils](#timeutils)
- [Extensions](#extensions)
  - [Date Extensions](#date-extensions)
    - [Parsing](#parsing)
    - [Formatting](#formatting)
    - [Comparison](#comparison)
    - [Duration Calculation](#duration-calculation)
    - [Manipulation](#manipulation)
  - [Extensions For Intl](#extensions-for-intl)
    - [DateFormat](#dateformat)
    - [NumberFormat](#numberformat)
    - [General](#general)
    - [TextDirection](#textdirection)
    - [Bidi](#bidi)
  - [String Extension](#string-extension)
    - [Case Conversion](#case-conversion)
    - [Text Formatting](#text-formatting)
    - [String Replacement](#string-replacement)
    - [String Comparison](#string-comparison)
    - [String Limiting](#string-limiting)
    - [Character Checks](#character-checks)
    - [Validation](#validation)
    - [Utility](#utility)
    - [Parsing](#parsing)
  - [Collection Extension](#collection-extension)
    - [Iterable Extension](#iterable-extension)
    - [List Extension](#list-extension)
    - [Set Extension](#set-extension)
    - [Map Extension](#map-extension)
  - [Number Extension](#number-extension)
      - [For All](#for-all-num)
      - [For Int](#for-int)
      - [For Double](#for-double)
  - [Duration Extension](#duration-extension)
  - [Uri Extension](#uri-extension)
  - [Bool Extension](#bool-extension)
  - [Objects Extension](#objects-extension)
    
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
- `toString1()` / `tryToString()`
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
- Each method accepts two optional parameters: `listIndex` and `mapKey`. These parameters allow specific value extraction and conversion within a `List` or `Map`.
- All dates and number conversion methods accepts extra format, and local for better localization and formatting.


#### Example with `listIndex`:
```dart
dynamic dynamicList = ['10', '20', '30'];
final int number = toInt(dynamicList, listIndex: 1); // 20
```

#### Example with `mapKey`:
```dart
final dynamicMap = <dynamic, dynamic>{
  'name': 'John',
  'age': '30',
  'bools': {
    'isHuman': 'yes',
  }
};
final bool isHuman = toBool(dynamicMap['bools'], mapKey: 'isHuman'); // true
```

#### Auto Decoding of JSON Strings for Collections

The `ConvertObject` class now simplifies working with JSON data by automatically decoding raw JSON strings when converting to `List`, `Set`, or `Map` types. This eliminates the need for manual parsing before conversion.

**Example Usage:**

```dart
final myList = tryToList<int>("[1, 2, 3]"); // List<int>
final mySet = tryToSet<String>('["hello", "world"]'); // Set<String>
final myMap = tryToMap<String, dynamic>('{"name": "Alice", "age": 30}'); // Map<String, dynamic>
```

### Extract And Convert

Starting from version 2.0.0 and above, we added a new methods to easily extract values from `Map<K, V>` and `List<E>`, and, safely convert it to a specific type!
- `getString`, `getNum`, `getInt`, `getBigInt`, `getDouble`, `getBool`, `getDateTime`, `getUri`, `getMap`, `getSet`, and `getList`.
- For Map, it requires the key e.g. `map.getNum('key')` 
- For List, it requires the index e.g. `list.getNum(1)`
- They also supports nullable converters such as  `tryGetString`, `tryGetNum`, `tryGetInt`, etc.
- all supported types and optionals in the `ConvertObject` class are also included.

Sample:

```dart
final map = <dynamic, dynamic>{
  'name': 'John',
  'age': '30',
  'bools': {
    'isHuman': 'yes',
  }
};

final age = map.getInt('age'); // 30
final score = map.tryGetInt('score'); // null
final isHuman = map.getBool('bools', innerKey: 'isHuman'); // true
```

or with List:

```dart
final dynamicList = <dynamic>['John', 30, true];
final age = dynamicList.getInt(1); // 30
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
### Parsing
- `timestampToDate`: Converts a timestamp (milliseconds since epoch) to a `DateTime` object.
- `try/toDateTime`: Converts a string to a `DateTime` object.

### Formatting
- `local`: Converts a potentially null `DateTime` to local time.
- `toUtcIso`: Converts a potentially null `DateTime` to ISO 8601 format in UTC.
- `format`: Formats a `DateTime` object into a string according to the given format.

### Comparison
- Relative to Current Time:
  - `isTomorrow`
  - `isToday`
  - `isYesterday`
  - `isInFuture`
  - `isInPast`
  - `isInPastWeek`
  - `isInThisYear`
- Within the Month/Year:
  - `isFirstDayOfMonth`
  - `isLastDayOfMonth`
  - `isLeapYear`
- Component-Level: (Compare two `DateTime` objects)
  - `isAtSameYearAs(other: DateTime)`
  - `isAtSameMonthAs(other: DateTime)`
  - `isAtSameDayAs(other: DateTime)`
  - ... (and so on for hour, minute, etc.)

### Duration Calculation
- `passedDuration`: Gets the duration that has passed since the given (potentially null) `DateTime`.
- `remainingDuration`: Gets the duration remaining until the given (potentially null) `DateTime`.
- `passedDays`: Gets the number of days that have passed since the given (potentially null) `DateTime`.
- `remainingDays`: Gets the number of days remaining until the given (potentially null) `DateTime`.

### Manipulation
- Start Points:
  - `startOfDay`: Gets the start of the day (midnight) for the given `DateTime`.
  - `startOfMonth`: Gets the start of the month for the given `DateTime`.
  - `startOfYear`: Gets the start of the year for the given `DateTime`.
- Extraction:
  - `dateOnly`: Extracts only the date portion (midnight time) from the `DateTime`.
- Lists:
  - `daysInMonth`: Gets a list of all the `DateTime` objects representing the days in the month of the given `DateTime`.
- Navigation:
  - `previousDay`, `nextDay`: Gets the `DateTime` for the previous/next day.
  - `previousWeek`, `nextWeek`: Gets the `DateTime` for the previous/next week.
  - `firstDayOfWeek`, `lastDayOfWeek`: Gets the `DateTime` for the first/last day of the week.
  - `previousMonth`, `nextMonth`: Gets the `DateTime` for the previous/next month.
  - `firstDayOfMonth`, `lastDayOfMonth`: Gets the `DateTime` for the first/last day of the month.

## Extensions For Intl
### DateFormat
#### on String
- `dateFormat`: Returns a `DateFormat` object based on the string pattern.
- `try/toDateAutoFormat`: Parses the string to `DateTime` and autodetect the format, with the provided locale, useCurrentLocale, and UTC option.
- `try/toDateFormatted`: Parses the string to `DateTime` with the provided format, locale, and UTC option.
- `try/toDateFormattedLoose`: Parses the string to `DateTime` using loose parsing.
- `try/toDateFormattedStrict`: Parses the string to `DateTime` using strict parsing.
- `try/toDateFormattedUtc`: Parses the string to `DateTime` in UTC using the provided format and locale.
- `localeExists`: Checks if the locale exists in `DateFormat`.

#### on DateTime
- `tryFormat` and `format`: Formats the DateTime object using the provided pattern and optional locale.
- A variety of methods to format `DateTime` objects in different styles:
  - **Basic:** `yMMMMdFormat`, `formatAsd`
  - **Weekday:** `formatAsEEEE`, `formatAsEEEEE`
  - **Month:** `formatAsLLL`, `formatAsLLLL`, `formatAsMMMMEEEEd`, etc.
  - **Quarter:** `formatAsQQQ`, `formatAsQQQQ`
  - **Year:** `formatAsyMMM`, `formatAsyQQQQ`, etc.
  - **Time:** `formatAsH`, `formatAsHm`, etc.
    All methods support an optional `locale` parameter.

## NumberFormat
#### on String
- `numberFormat`: Returns a `NumberFormat` object based on the string pattern.
- `try/toNumFormatted`: Parses the string to a number with the given pattern and locale.
- `try/toIntFormatted`: Parses the string to an integer with the given pattern and locale.
- `try/toDoubleFormatted`: Parses the string to a double with the given pattern and locale.
- `numberFormat`: Creates a `NumberFormat` object using the string as the pattern, along with the given locale.
- `symbolCurrencyFormat`: Creates a `NumberFormat` object as currency using the string as the currency symbol, along with the given locale and optional decimal digits.
- `simpleCurrencyFormat`: Creates a `NumberFormat` object as simple currency using the string as the currency name, along with the given locale.
- `compactCurrencyFormat`: Creates a `NumberFormat` object as compact simple currency using the string as the currency name, along with the given locale.

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

### TextDirection
These constants eliminate the need to import and use the `TextDirection` class from the `intl` package, which could be confused with Flutter's `TextDirection` enum.
- `textDirectionLTR`: Represents left-to-right text direction (e.g., English, French).
- `textDirectionRTL`: Represents right-to-left text direction (e.g., Arabic, Hebrew).
- `textDirectionUNKNOWN`: Represents unknown or neutral text direction.

### Bidi
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

## String Extension
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
- `decode/tryDecode`: Decodes the JSON string into a dynamic data structure (`tryDecode` returns null upon failure).

### Parsing
- `try/toNum`: Parses the string as a number.
- `try/toDouble`: Parses the string as a double.
- `try/toInt`: Parses the string as an integer.

## Collection Extension
### Iterable Extension
-  Type-safe extract and convert methods like `getInt(index)`, `getDateTime(index)`, `getMap(index)` etc.
- `isEmptyOrNull`: Returns true if the iterable is either null or empty.
- `isNotEmptyOrNull`: Returns false if the iterable is either null or empty.
- `of`: Retrieves the element at the specified index in a null-safe manner.
- `firstOrNull`: Retrieves the first element or returns null.
- `lastOrNull`: Retrieves the last element or returns null.
- `firstWhereOrNull`: Retrieves the first element that matches the specified predicate or returns null.
- `firstOrDefault`: Retrieves the first element or returns a default value.
- `lastOrDefault`: Retrieves the last element or returns a default value.
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
- `distinctBy`: Returns a new list containing the first occurrence of each element with a unique key, as determined by the provided key selector function.
- `subtract`: Returns a set containing all elements that are contained by this collection and not contained by the specified collection.
- `find`: Returns the first element matching the given predicate, or null if not found.
- `encodedJson`: Encodes the iterable as a JSON string.

### List Extension
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

### Set Extension
- `isEmptyOrNull`: Checks if the set is empty or null.
- `isNotEmptyOrNull`: Checks if the set is not empty or null.
- `addIfNotNull(T? value)`: Adds a value to the set if it's not null.
- `toMutableSet()`: Converts the set to a mutable set.
- `intersect(Iterable<T> other)`: Returns the intersection of two sets.

### Map Extension
-  Type-safe extract and convert methods like `getInt(key)`, `getDateTime(key)`, `getMap(key)` etc.
- `makeEncodable`: Converts a map to an encodable format.
- `safelyEncodedJson`: Returns a safely encoded JSON string.
- `flatMap` Flatten nested maps into single-level structures.
- `isEmptyOrNull`: Checks if the map is empty or null.
- `isNotEmptyOrNull`: Checks if the map is not empty or null.
- `setIfMissing` Add entries conditionally.
- `update` Update values based on a condition.
- `filter` Filter entries using predicates.
- `keysList`, `valuesList`, `keysSet`, `valuesSet` Get lists or sets of keys and values.

## Number Extension
### For all `num`
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

## Duration Extension
- `delayed(FutureOr<T> Function()? computation)`: Delays execution by the duration.
- `fromNow`: Adds the Duration to the current DateTime and gives a future time.
- `ago`: Subtracts the Duration from the current DateTime and gives a pastime.

## Uri Extension
- `isValidUri`: Checks if the string is a valid URI.
- `toUri`: Converts the string to a URI object.
- `isHttp`: Checks if the URI uses the HTTP scheme.
- `isHttps`: Checks if the URI uses the HTTPS scheme.
- `host`: Returns the host part of the URI.
- `path`: Returns the path part of the URI.

## Bool Extension
- `toggled`: returns a new bool which is toggled from the current one.
- `val` & `isTrue`: (nullable boolean): Returns `true` if the value is not null and true
- `isFalse`: (nullable boolean): Returns `true` if the value is not null and false
- `binary`: Returns `1` if the value is non-null and true, otherwise returns `0`.

## Objects Extension
- `encode({Object? Function(dynamic object)? toEncodable})`: Encodes an object to JSON.
- `isNull`: Checks if the object is null.
- `isNotNull`: Checks if the object is not null.
- `asBool`: Converts an object to a boolean value.

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
extension pack, helpers, utilities, string manipulation, conversions, time utils, date extension, datetime helper,
DateFormat, intl, extensions, iterable, map, number, object, set, URI, and boolean extension, JSON encoding/decoding,
parsing, safe parsing, object conversion, cast, list casting.