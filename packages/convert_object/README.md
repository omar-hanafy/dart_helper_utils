# convert_object

A comprehensive type conversion library for Dart that provides a fluent, type-safe API for converting between different types with extensive support for collections, custom converters, and robust error handling.

## Features

- 🎯 **Type-safe conversions** with compile-time type checking
- 🔗 **Fluent API** for chaining conversion operations
- 🛡️ **Null-safe** with `OrNull` and `Or` variants
- 📦 **Collection support** for List, Set, and Map conversions
- 🔧 **Custom converters** for domain-specific conversions
- ⚡ **Error handling** with `ConversionResult` for functional error handling
- 🎨 **Minimal extensions** to avoid cluttering IDE suggestions
- 🔍 **Smart extraction** from nested data structures

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  convert_object: ^1.0.0
```

Then run:

```bash
dart pub get
```

## Quick Start

```dart
import 'package:convert_object/convert_object.dart';

void main() {
  // Simple conversions
  final text = 123.convert.toText(); // '123'
  final number = '456'.convert.toInt(); // 456
  final safe = data.convert.toIntOrNull(); // null if fails
  
  // With defaults
  final value = data.convert.toIntOr(0); // 0 if conversion fails
  
  // From collections
  final map = {'age': '25', 'name': 'John'};
  final age = map.getInt('age'); // 25
  
  // Nested access
  final nested = {'user': {'age': '30'}};
  final userAge = nested.convert
      .fromMap('user')
      .toMap<String, dynamic>()
      .getInt('age'); // 30
}
```

## Migration From dart_helper_utils

If you previously used the conversion helpers from `dart_helper_utils`, this package offers a compatible surface with clearer names and additional features. Key mappings:

- `getString/getNum/getInt/...` → `getString/getNum/getInt/...`
- `tryGetString/tryGetNum/...` → `getStringOrNull/getNumOrNull/...`
- `ParsingException` → `ConversionException`

Behavior improvements to be aware of:

- `toDateTime` accepts numeric epoch (seconds or milliseconds) besides strings
- `toUri` detects phone numbers (`tel:`) and emails (`mailto:`)
- `toType<Uri>()` is supported

See MIGRATION_GUIDE.md for a compact mapping and notes.

## Core Concepts

### The Converter Class

The `Converter` class is the heart of the library, providing a fluent API for all conversions:

```dart
// Access via extension
final converter = myObject.convert;

// Or create directly
final converter = Converter(myObject);

// Chain operations
final result = myObject.convert
    .fromMap('data')
    .withDefault(0)
    .toInt();
```

### Conversion Methods

Each type has three variants:

1. **`toType()`** - Converts or throws `ConversionException`
2. **`toTypeOrNull()`** - Converts or returns `null`
3. **`toTypeOr(defaultValue)`** - Converts or returns default value

```dart
// Throws if conversion fails
final strict = '123'.convert.toInt(); // 123

// Returns null if conversion fails
final safe = 'abc'.convert.toIntOrNull(); // null

// Returns default if conversion fails
final withDefault = 'abc'.convert.toIntOr(0); // 0
```

## Supported Types

### Primitive Types

```dart
// String conversions (using toText to avoid toString conflict)
final text = 123.convert.toText(); // '123'

// Number conversions
final integer = '456'.convert.toInt(); // 456
final double = '3.14'.convert.toDouble(); // 3.14
final number = '789'.convert.toNum(); // 789

// Boolean conversions
final bool1 = 'true'.convert.toBool(); // true
final bool2 = 1.convert.toBool(); // true
final bool3 = 0.convert.toBool(); // false
```

### BigInt Support

```dart
// Handle large numbers
final bigNumber = '123456789012345678901234567890'.convert.toBigInt();
final fromNum = 42.convert.toBigInt(); // BigInt.from(42)
```

### DateTime Conversions

```dart
// ISO 8601 strings
final date1 = '2024-01-15T10:30:00Z'.convert.toDateTime();

// From milliseconds since epoch
final date2 = 1705316400000.convert.toDateTime();

// UTC conversions
final utcDate = '2024-01-15'.convert.toDateTimeUtc();
```

### Uri Conversions

```dart
// URLs
final uri1 = 'https://example.com'.convert.toUri();

// Phone numbers (auto-detected)
final uri2 = '+1234567890'.convert.toUri(); // tel:+1234567890

// Email addresses (auto-detected)
final uri3 = 'user@example.com'.convert.toUri(); // mailto:user@example.com
```

### Collections

```dart
// List conversions
final list1 = [1, 2, 3].convert.toList<int>(); // [1, 2, 3]
final list2 = 'single'.convert.toList<String>(); // ['single']
final list3 = {'a': 1, 'b': 2}.convert.toList<int>(); // [1, 2]

// Set conversions
final set = [1, 2, 2, 3].convert.toSet<int>(); // {1, 2, 3}

// Map conversions
final map = {'a': '1', 'b': '2'}.convert.toMap<String, int>(
  valueConverter: (v) => int.parse(v.toString())
); // {'a': 1, 'b': 2}
```

## Collection Extensions

### Map Extensions

```dart
final map = {
  'name': 'John',
  'age': '30',
  'scores': [85, 90, 88],
  'address': {
    'city': 'New York',
    'zip': '10001'
  }
};

// Direct conversions
final name = map.getString('name'); // 'John'
final age = map.getInt('age'); // 30

// Nested access
final city = map.getMap<String, dynamic>('address')
    .getString('city'); // 'New York'

// Alternative keys
final id = map.getStringOrNull(
  'user_id',
  alternativeKeys: ['userId', 'id', 'username'],
); // Tries each key in order

// Parse custom objects
class User {
  final String name;
  final int age;
  
  User.fromJson(Map<String, dynamic> json)
    : name = json.getString('name'),
      age = json.getInt('age');
}

final user = map.parseAs('userData', User.fromJson);
```

### Iterable Extensions

```dart
final list = ['123', '456', 'true', '3.14'];

// Get by index with conversion
final first = list.getInt(0); // 123
final second = list.getDouble(1); // 456.0
final third = list.getBool(2); // true

// Convert all elements
final numbers = ['1', '2', '3'].convertAll<int>(); // [1, 2, 3]

// With alternative indices
final value = list.getIntOrNull(
  10, // primary index
  alternativeIndices: [0, 1], // fallback indices
); // Returns 123 (from index 0)
```

## Advanced Features

### Nested Data Extraction

```dart
final complexData = {
  'response': {
    'data': {
      'users': [
        {'id': 1, 'name': 'Alice'},
        {'id': 2, 'name': 'Bob'},
      ]
    },
    'meta': {
      'total': '2',
      'page': '1'
    }
  }
};

// Extract nested values
final users = complexData.convert
    .fromMap('response')
    .fromMap('data')
    .toMap<String, dynamic>()
    .getList<Map<String, dynamic>>('users');

// Get specific user
final firstUserName = users.first.getString('name'); // 'Alice'
```

### Custom Converters

```dart
// Enum converter
enum Status { active, inactive, pending }

final statusConverter = (Object? value) {
  final str = value.toString().toLowerCase();
  return Status.values.firstWhere(
    (e) => e.name == str,
    orElse: () => Status.pending,
  );
};

final status = 'active'.convert
    .withConverter(statusConverter)
    .to<Status>(); // Status.active

// Complex object converter
class Product {
  final String name;
  final double price;
  
  Product({required this.name, required this.price});
  
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      name: map.getString('name'),
      price: map.getDouble('price'),
    );
  }
}

final productMap = {'name': 'Widget', 'price': '19.99'};
final product = Product.fromMap(productMap);
```

### Error Handling with ConversionResult

```dart
// Try conversion with result
final result = 'abc'.convert.tryToInt();

// Check success
if (result.isSuccess) {
  print('Value: ${result.value}');
} else {
  print('Error: ${result.error}');
}

// Functional approach
final message = result.fold(
  onSuccess: (value) => 'Parsed: $value',
  onFailure: (error) => 'Failed: $error',
);

// Chain operations
final processed = '42'.convert
    .tryToInt()
    .map((value) => value * 2)
    .flatMap((value) => value.convert.tryToText())
    .valueOr('failed'); // '84'
```

### JSON Support

```dart
// Decode JSON strings automatically
final jsonString = '{"name": "John", "age": 30}';
final data = jsonString.convert.decoded.toMap<String, dynamic>();
final name = data.getString('name'); // 'John'

// Work with JSON arrays
final jsonArray = '[1, 2, 3, 4, 5]';
final numbers = jsonArray.convert.decoded.toList<int>(); // [1, 2, 3, 4, 5]
```

### Let Extensions (Null-Safe Operations)

```dart
// Transform non-null values
final result = nullableString?.let((s) => s.toUpperCase());

// With default value
final processed = nullableValue?.letOr(
  (v) => v * 2,
  defaultValue: 0,
);
```

## Best Practices

### 1. Choose the Right Method

```dart
// When you need the value or want to handle errors
try {
  final value = data.convert.toInt();
  // use value
} catch (e) {
  // handle error
}

// When null is acceptable
final value = data.convert.toIntOrNull();
if (value != null) {
  // use value
}

// When you have a sensible default
final value = data.convert.toIntOr(0);
```

### 2. Use Type Checking

```dart
// Check before conversion
if (data.canConvertTo<int>()) {
  final value = data.convert.toInt();
}

// Or use ConversionResult
final result = data.convert.tryToInt();
if (result.isSuccess) {
  // use result.value
}
```

### 3. Leverage Fluent API

```dart
// Chain operations for complex extractions
final value = response.convert
    .fromMap('data')
    .fromMap('attributes')
    .fromList(0)
    .toIntOr(0);
```

### 4. Custom Converters for Domain Objects

```dart
// Define converters close to your domain models
class User {
  static User fromDynamic(Object? obj) {
    final map = obj.convert.toMap<String, dynamic>();
    return User(
      id: map.getInt('id'),
      name: map.getString('name'),
      email: map.getString('email'),
    );
  }
}

// Use with the converter
final user = data.convert
    .withConverter(User.fromDynamic)
    .to<User>();
```

## API Reference

### Core Classes

- `Converter` - Main conversion class with fluent API
- `ConversionResult<T>` - Result wrapper for safe error handling
- `ConversionOptions` - Configuration for conversions
- `ConversionException` - Exception thrown on conversion failures

### Extension Methods

- `ConvertObjectExtension` - Minimal extensions on `Object?`
- `ConvertIterableExtension` - Rich conversion methods for iterables
- `ConvertMapExtension` - Rich conversion methods for maps
- `PrimitiveConverters` - Extensions for primitive type conversions
- `CollectionConverters` - Extensions for collection conversions

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
