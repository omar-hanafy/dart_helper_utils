[![dart_helper_utils logo](https://raw.githubusercontent.com/omar-hanafy/dart_helper_utils/fb2b340acff23ad89b09319dac691d98f1ecca90/logo.svg)](https://pub.dev/packages/dart_helper_utils)

[![pub package](https://img.shields.io/pub/v/dart_helper_utils)](https://pub.dev/packages/dart_helper_utils)

The `dart_helper_utils` package provides a collection of Dart utilities, tools for converting dynamic objects to various types, and extending core Dart classes with an extension.

**Note:** This package is tailored for Dart projects. For Flutter projects, use [`flutter_helper_utils`](https://pub.dev/packages/flutter_helper_utils), which includes all `dart_helper_utils` features plus additional utilities and extension for Flutter, such as `Widget`, `Color`, and `BuildContext` extension.

# Featured

## Pagination

Three powerful pagination implementations for different use cases:

```dart
// Synchronous pagination for in-memory lists
final paginator = Paginator(
  items: myItems,
  pageSize: 10,
);

// Asynchronous pagination with automatic retries and caching
final asyncPaginator = AsyncPaginator<User>(
  fetchPage: (pageNumber, pageSize) => api.fetchUsers(pageNumber, pageSize),
  pageSize: 20,
);

// Infinite scrolling with cursor-based pagination
final infinitePaginator = InfinitePaginator.cursorBased(
  fetchItems: (pageSize, cursor) => api.fetchItems(pageSize, cursor),
  getNextCursor: (items) => PaginationCursor(items.last.id),
);

// Add analytics tracking to any paginator
paginator with PaginationAnalytics<Item>
```

Key Features:
- Built-in caching and error handling
- Customizable retry logic
- Race condition prevention for async operations
- Support for both page-based and cursor-based pagination
- Analytics tracking for page loads, errors, and cache performance
- Transformations (map, filter) with automatic cache management

## DoublyLinkedList
A powerful implementation of doubly linked list that offers:

```dart
final myList = DoublyLinkedList<int>([1,2,3,4]);

// Basic Operations
myList.append(5);
myList.prepend(0);
myList.insert(1, 15);

// Node Operations
for (final node in myList.nodes) {
  print('Value: ${node.data}, Previous: ${node.prev?.data}, Next: ${node.next?.data}');
}

// Factory Constructors
final filledList = DoublyLinkedList.filled(3, 0);  // [0, 0, 0]
final generatedList = DoublyLinkedList.generate(3, (i) => i * 2);  // [0, 2, 4]
```

## Converting Objects
Type-safe conversion utilities with enhanced error handling and format support:

```dart
// Simple conversions with global methods.
int number = toInt('123');  // 123
double price = toDouble('19.99');  // 19.99
bool isActive = toBool('true');  // true

// U can use the ConvertObject class to avoid ambiguty
// for example the toMap works here well but sometimes u might have already method named toMap.
final map = toMap<String, dynamic>(data);
// to resolve this use the static method instead
final map = ConvertObject.toMap<String, dynamic>(data);

// Complex conversions with format support
DateTime date = toDateTime('2024-01-13', format: 'yyyy-MM-dd');
num amount = toNum('1,234.56', format: '#,##0.00');

// Collection conversions with type safety
List<int> numbers = toList<int>('[1, 2, 3]');  // Accepts JSON strings
Map<String, dynamic> data = toMap('{"name": "John", "age": 30}');

// Safe extraction from collections
final map = {'user': {'age': '25'}};
int age = map.getInt('user', innerKey: 'age');  // 25

final list = ['John', '25', true];
String name = list.getString(0);  // "John"

// conversion on any object
final id = '123';
final idNumber = id.convertToInt();
```

## TimeUtils
Comprehensive time measurement and execution control utilities:

```dart
// Measure execution time
final duration = await TimeUtils.executionDuration(() async {
  await someAsyncTask();
});

// Run with timeout
try {
  final result = await TimeUtils.runWithTimeout(
    task: () => longRunningTask(),
    timeout: Duration(seconds: 5),
  );
} catch (e) {
  print('Task timed out');
}

// Periodic execution
final subscription = TimeUtils.runPeriodically(
  interval: Duration(minutes: 1),
  task: () => checkForUpdates(),
);
```

# Extensions

## Date Extensions

The Date Extensions provide comprehensive functionality for DateTime manipulation and formatting:

### Parsing
```dart
// Convert timestamp to DateTime
final date = 1643673600000.timestampToDate;

// Convert string to DateTime with various formats
final date = "2024-01-13".tryToDateTime();
final date = "13/01/2024".toDateTime(format: "dd/MM/yyyy");
```

### Formatting
```dart
DateTime now = DateTime.now();

// Convert to local time
final localTime = now.local;

// Convert to UTC ISO format
final utcIso = now.toUtcIso;

// Custom format
final formatted = now.format("dd-MM-yyyy");
```

### Comparison
```dart
final date = DateTime.now();

// Relative time checks
print(date.isTomorrow);
print(date.isToday);
print(date.isYesterday);
print(date.isInFuture);
print(date.isInPast);

// Component level comparison
final otherDate = DateTime(2024, 1, 1);
print(date.isAtSameYearAs(otherDate));
print(date.isAtSameMonthAs(otherDate));
print(date.isAtSameDayAs(otherDate));
```

### Duration Calculation
```dart
final date = DateTime.now().add(Duration(days: 5));

// Get passed or remaining duration
final passed = date.passedDuration;
final remaining = date.remainingDuration;

// Get passed or remaining days
final passedDays = date.passedDays;
final remainingDays = date.remainingDays;
```

### Manipulation
```dart
final date = DateTime.now();

// Get start points
final startOfDay = date.startOfDay;
final startOfMonth = date.startOfMonth;
final startOfYear = date.startOfYear;

// Navigation
final nextDay = date.nextDay;
final previousWeek = date.previousWeek;
final lastDayOfMonth = date.lastDayOfMonth;
```

## Intl Extensions

### DateFormat

#### String Extensions
```dart
// Create DateFormat from pattern
final formatter = "yyyy-MM-dd".dateFormat();

// Parse string to DateTime with auto format detection
final date = "2024-01-13".tryToDateAutoFormat();

// Parse with specific format
final date = "13/01/2024".toDateFormatted("dd/MM/yyyy");

// Parse with locale
final date = "13 janvier 2024".toDateFormatted("dd MMMM yyyy", locale: "fr");
```

#### DateTime Extensions
```dart
final date = DateTime.now();

// Basic formatting
print(date.yMMMMdFormat); // "January 13, 2024"
print(date.formatAsd); // "01/13/2024"

// Weekday formatting
print(date.formatAsEEEE); // "Saturday"
print(date.formatAsEEEEE); // "S"

// Month formatting
print(date.formatAsLLL); // "Jan"
print(date.formatAsLLLL); // "January"

// With locale
print(date.formatAsLLLL(locale: 'fr')); // "janvier"
```

### NumberFormat

#### String Extensions
```dart
// Parse string to number with formatting
final num = "1,234.56".toNumFormatted("#,##0.00");
final int = "1,234".toIntFormatted("#,##0");
final double = "1,234.56".toDoubleFormatted("#,##0.00");
```

#### Number Extensions
```dart
final number = 1234567.89;

// Currency formatting
print(number.formatAsCurrency(symbol: "$")); // "$1,234,567.89"
print(number.formatAsSimpleCurrency(name: "USD")); // "USD 1,234,567.89"

// Compact formatting
print(number.formatAsCompact()); // "1.2M"
print(number.formatAsCompactLong()); // "1.2 million"

// Percentage and decimal
print(number.formatAsPercentage()); // "123,456,789%"
print(number.formatAsDecimal(decimalDigits: 2)); // "1,234,567.89"
```

### Bidi Support

Comprehensive support for bidirectional text handling:

```dart
final text = "Hello عالم";

// Direction detection
print(text.startsWithLtr()); // true
print(text.endsWithRtl()); // true
print(text.hasAnyRtl()); // true

// Enforcing direction
print(text.enforceLtr()); // Forces LTR direction
print(text.enforceRtl()); // Forces RTL direction

// Wrapping with direction markers
print(text.wrapWithSpan()); // Wraps with span and direction
print(text.wrapWithUnicode()); // Wraps with unicode markers
```

Each Bidi method provides optional parameters for HTML handling and direction estimation, making it perfect for multilingual applications.

## String Extension

String extensions provide powerful text manipulation and validation capabilities:

### Case Conversion
```dart
final text = "helloWorld_example-TEXT";

print(text.toPascalCase());     // "HelloWorldExampleText"
print(text.toCamelCase());      // "helloWorldExampleText"
print(text.toSnakeCase());      // "hello_world_example_text"
print(text.toKebabCase());      // "hello-world-example-text"
print(text.toScreamingCase());  // "HELLOWORLDEXAMPLETEXT"
print(text.toTitleCase());      // "Hello World Example Text"

// Smart capitalization
print("helloWORLD".capitalizeFirstLetter());     // "HelloWORLD"
print("helloWORLD".capitalizeFirstLowerRest());  // "Helloworld"
```

### Text Manipulation
```dart
// Clean and format
print("multi\nline text".toOneLine());          // "multi line text"
print("  hello  world  ".removeWhiteSpaces());  // "helloworld"
print("long text".wrapString(5));               // "long\ntext"

// String operations
print("Hello World".replaceAfter("o", "!")));   // "Hello!"
print("Hello World".removeSurrounding("H", "d")); // "ello Worl"
```

### Validation
```dart
// Common validations
print("test@email.com".isValidEmail);        // true
print("192.168.1.1".isValidIp4);            // true
print("https://dart.dev".isValidUrl);        // true
print("Hello123".isAlphanumeric);           // true
print("12345".isNumeric);                   // true
print("level".isPalindrome);                // false

// Type checking
print("true".isBool);                       // true
print("123".containsDigits);                // true
print("Test123!".hasSpecialChars);          // true
```

### Utility Functions
```dart
// Safe operations
final nullableText = null;
print(nullableText.orEmpty);                // ""
print("".ifEmpty(() => "default"));         // "default"

// JSON handling
print('{"key": "value"}'.decode());         // Map<String, dynamic>
print('{"key": "value"}'.tryDecode());      // Returns null if invalid JSON
```

## Collection Extensions

### Iterable Extension

General purpose extensions for all collection types:

```dart
final numbers = [1, 2, 3, 4, 5, null, 6];

// Safe operations
print(numbers.isEmptyOrNull);                // false
print(numbers.firstOrNull);                  // 1
print(numbers.lastOrDefault(0));             // 6
print(numbers.tryGetRandom());               // Random element or null

// Type-safe conversions
print(numbers.getInt(1));                    // 2
print(numbers.tryGetDouble(5));              // null

// Collection operations
print(numbers.filter((e) => e.isOdd));       // [1, 3, 5]
print(numbers.whereIndexed((i, e) => i < 3)); // [1, 2, 3]

// Aggregation
print(numbers.total);                        // Sum of all numbers
final products = [Product(price: 10), Product(price: 20)];
print(products.totalBy((p) => p.price));     // 30

// Grouping and distinct
final grouped = numbers.groupBy((e) => e.isEven);
final unique = ["a", "a", "b"].distinctBy((e) => e.toLowerCase());
```

### List Extension

Specialized operations for Lists:

```dart
final list = [1, 2, 3, 4, 5];

// Safe operations
list.tryRemoveAt(1);                     // Safely removes element at index
print(list.indexOfOrNull(3));            // Returns index or null if not found

// List manipulation
print(list.halfLength);                  // 2
print(list.takeOnly(3));                 // [1, 2, 3]
print(list.firstHalf);                   // [1, 2]
print(list.secondHalf);                  // [3, 4, 5]

// Element operations
final swapped = list.swap(0, 1);         // [2, 1, 3, 4, 5]
print(list.getRandom());                 // Random element
```

### Set Extension

Extensions specific to Sets:

```dart
final set = <int>{1, 2, 3};

// Safe operations
set.addIfNotNull(4);                    // Adds only if not null
print(set.isEmptyOrNull);               // false

// Set operations
final other = <int>{3, 4, 5};
print(set.intersect(other));            // {3}

// Conversions
final mutableSet = set.toMutableSet();  // Creates mutable copy
```

### Map Extension

Powerful extensions for working with Maps:

```dart
final map = {'name': 'John', 'age': '25', 'scores': ['90', '85', '95']};

// Type-safe extraction
print(map.getString('name'));           // "John"
print(map.getInt('age'));              // 25
print(map.getList<String>('scores'));   // ["90", "85", "95"]

// Safe operations
map.setIfMissing('email', 'john@example.com');  // Only if key doesn't exist

// Map manipulation
final filtered = map.filter((k, v) => k != 'age');
final flattened = map.flatMap();        // Flattens nested maps

// Collection views
print(map.keysList);                    // List of keys
print(map.valuesSet);                   // Set of values

// JSON operations
print(map.encodedJsonString);           // Safe JSON encoding
```

Each extension method is designed to be null-safe and provides convenient ways to handle common operations while maintaining clean, readable code.

## Number Extensions

Extensions for both `num`, `int`, and `double` types:

### Common Operations (num)
```dart
final number = 123.456;

// HTTP Status Checks
print(200.isSuccessHttpResCode);      // true
print(404.isNotFoundError);           // true
print(429.isRateLimitError);          // true

// Number Properties
print(number.isPositive);             // true
print(number.numberOfDigits);         // 3
print(number.removeTrailingZero);     // "123.456"

// Formatting
print(number.asGreeks);               // "123.46"
print(1500000.asGreeks);             // "1.5M"

// Calculations
print(number.tenth);                  // 12.3456
print(number.half);                   // 61.728
print(100.getRandom);                 // Random number between 0-100
```

### Integer Specific (int)
```dart
final number = 100;

// Range Operations
print(number.inRangeOf(0, 200));      // 100
print(number.absolute);               // 100
print(number.squared);                // 10000

// Time Delays
await 5.secDelay;                     // Delays 5 seconds
await 2.minDelay;                     // Delays 2 minutes
await 1.hoursDelay;                   // Delays 1 hour

// Duration Conversions
print(5.asSeconds);                   // Duration(seconds: 5)
print(2.asMinutes);                   // Duration(minutes: 2)
print(1.asDays);                      // Duration(days: 1)
```

### Double Specific (double)
```dart
final number = 123.456;

// Formatting
print(number.inRangeOf(0, 200));      // 123.456
print(number.roundToTenth);           // 120.0

// Math Operations
print(number.doubled);                // 246.912
print(number.squared);                // 15241.383936
```

## Duration Extension

Powerful extensions for working with durations:

```dart
final duration = Duration(hours: 2, minutes: 30);

// Future Time Operations
await duration.delayed(() => print('Delayed!'));  // Executes after duration
print(duration.fromNow);                          // DateTime 2.5 hours from now
print(duration.ago);                              // DateTime 2.5 hours ago

// Chaining
final newDuration = Duration(minutes: 30)
    .fromNow
    .add(Duration(hours: 1));                     // 1.5 hours from now
```

## Uri Extension

Extensions for URI handling and validation:

```dart
// String to URI conversion
final uriString = "https://pub.dev";
print(uriString.isValidUri);                // true
final uri = uriString.toUri;                // Uri object

// URI Properties
print(uri.isHttp);                          // false
print(uri.isHttps);                         // true
print(uri.host);                            // "pub.dev"
print(uri.path);                            // "/"

// Validation
print("not-a-url".isValidUri);              // false
```

## Bool Extension

Useful extensions for boolean values:

```dart
bool value = true;

// Toggle Operations
print(value.toggled);                       // false

// Nullable Boolean Handling
bool? nullableBool;
print(nullableBool.val);                    // false
print(nullableBool.isTrue);                 // false
print(nullableBool.isFalse);               // false

// Binary Conversion
print(true.binary);                         // 1
print(false.binary);                        // 0
```

## Object Extension

General purpose extensions for all objects:

```dart
dynamic object = {"name": "John", "age": 30};

// Type Conversions
print(object.toInt());                      // null (not convertible)
print(object.toString1());                  // "{name: John, age: 30}"
print(object.tryToMap<String, dynamic>());  // {"name": "John", "age": 30}

// Null Checking
print(object.isNull);                       // false
print(object.isNotNull);                    // true

// JSON Operations
print(object.encode());                     // '{"name":"John","age":30}'

// Boolean Conversion
print(object.asBool);                      // true (non-null)
print(null.asBool);                        // false
```

Each extension is designed to provide convenient, null-safe operations while maintaining clean, readable code. The extensions are particularly useful for data manipulation, time calculations, and type conversions in Dart applications.

# HTTP Utilities

## Status Codes

The package provides comprehensive HTTP status code handling with user-friendly and developer-oriented messages:

```dart
// Status Code Checks
print(200.isOkCode);              // true
print(201.isCreatedCode);         // true
print(401.isAuthenticationError); // true
print(404.isNotFoundError);       // true
print(429.isRateLimitError);      // true
print(503.isRetryableError);      // true

// Retry Handling
final retryDelay = 429.statusCodeRetryDelay; // Returns suggested retry duration
```

## Status Messages

Access both user-friendly and technical status messages:

```dart
// User-Friendly Messages
print(404.toHttpStatusUserMessage);
// "The requested resource could not be found. Please check the URL and try again."

// Developer Messages
print(404.toHttpStatusDevMessage);
// "Resource not found. Verify the path and parameters. Check if resource exists and access permissions."

// Complete Status Messages Map
final userMessages = httpStatusUserMessage;
final devMessages = httpStatusDevMessage;
```

# Constants

## Time Constants

Predefined duration constants for common time intervals:

```dart
// Basic Time Units
print(oneSecond);       // Duration(seconds: 1)
print(oneMinute);       // Duration(minutes: 1)
print(oneHour);         // Duration(hours: 1)
print(oneDay);          // Duration(days: 1)

// Milliseconds Constants
print(millisecondsPerSecond);  // 1000
print(millisecondsPerMinute);  // 60000
print(millisecondsPerHour);    // 3600000
print(millisecondsPerDay);     // 86400000

// Usage Example
final delay = oneMinute * 5;   // 5 minutes duration
```

## Number Formats

Constants for number formatting and conversion:

```dart
// Greek Number Suffixes for large numbers
print(greekNumberSuffixes);
// {
//   'K': 1000,
//   'M': 1000000,
//   'B': 1000000000,
//   'T': 1000000000000,
// }

// Roman Numerals
print(romanNumerals);
// {
//   1: 'I',
//   5: 'V',
//   10: 'X',
//   50: 'L',
//   100: 'C',
//   500: 'D',
//   1000: 'M',
// }

// Calendar Constants
print(smallWeekdays);
// {1: 'Mon', 2: 'Tue', ...}

print(fullWeekdays);
// {1: 'Monday', 2: 'Tuesday', ...}

print(smallMonthsNames);
// {1: 'Jan', 2: 'Feb', ...}

print(fullMonthsNames);
// {1: 'January', 2: 'February', ...}
```

## Regular Expressions

Pre-defined RegExp patterns for common validation scenarios:

```dart
// Validation Patterns
print(RegExp(alphanumericPattern).hasMatch('Test123'));     // true
print(RegExp(specialCharsPattern).hasMatch('Test@123'));    // true
print(RegExp(usernamePattern).hasMatch('user_123'));        // true
print(RegExp(currencyPattern).hasMatch('$123.45'));         // true
print(RegExp(phoneNumberPattern).hasMatch('+1234567890'));  // true
print(RegExp(emailPattern).hasMatch('test@example.com'));   // true
print(RegExp(ip4Pattern).hasMatch('192.168.1.1'));         // true
print(RegExp(ip6Pattern).hasMatch('2001:0db8:85a3:0000:0000:8a2e:0370:7334')); // true
print(RegExp(urlPattern).hasMatch('https://dart.dev'));     // true
print(RegExp(numericPattern).hasMatch('12345'));           // true
print(RegExp(alphabetPattern).hasMatch('abcDEF'));         // true

// Usage Example with String Extension
print('test@example.com'.isValidEmail);    // true
print('192.168.1.1'.isValidIp4);          // true
print('https://dart.dev'.isValidUrl);      // true
```

These utilities and constants provide a robust foundation for handling HTTP responses, formatting numbers, validating input, and working with common time-based operations in your Dart applications.

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