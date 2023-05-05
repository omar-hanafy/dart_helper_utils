![](./logo.svg)

The [dart_helper_utils](https://pub.dev/packages/dart_helper_utils) is a valuable tool for developers who want to speed up their development process. It offers various [extensions](https://dart.dev/language/extension-methods) and helper methods that can make development more efficient.

## **Why I Created This Package**

Hey there! As developers, we all know that writing repeated or boilerplate code can really slow down the development process. That's why I wanted to share all the helper methods and [extensions](https://dart.dev/language/extension-methods) I've created in my previous projects within this package.

For instance, if you want to safeley cast dynamic list to list of strings you can use `ConvertObject.tryToList<String>(dynamicList);`

If you want to learn more about extensions, click [here](https://dart.dev/language/extension-methods).

## Installation

To use this package, add `dart_helper_utils` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  dart_helper_utils: ^1.0.0
```

Then, run `dart pub get` in your terminal.

## Usage

After installation, import the package in your dart file:

```dart
import 'package:dart_helper_utils/dart_helper_utils.dart';
```

You can now use any of the helper methods or extensions provided by the package. Some examples include:

### `Duration` extension

```dart
const duration = Duration(hours: 1, minutes: 30);

// Adds the Duration to the current DateTime and returns a DateTime in the future.
DateTime futureDate = duration.fromNow;

// Subtracts the Duration from the current DateTime and returns a DateTime in the past
DateTime pastDate = duration.ago;

// run async delay
await duration.delay<void>(); 

```

### `int, double, and num` extension

```dart
final int number = 100;

// convert numbers to greeks.
  // e.g 1000 => 1k
  //     20000 => 20k
  //     1000000 => 1M
String greeks = number.asGreeks; // 10k

// Easy way to make Durations from numbers.
Duration seconds = number.asSeconds; //  Duration(seconds: 100)
  
int numberOfDigits = number.numberOfDigits; // 3

// Return this number time two (tripled, quadrupled, and squared are also available).
int doubled = number.doubled; // 200
```

### `String` extension:

```dart
String text = 'hello there!';

// wrap string at the specified index
String wrappedString = text.wrapString(2);

// capitalize the first letter of the string
String capitalized = text.capitalizeFirstLetter; // 'Hello there!'

// convert the string to PascalCase ('camelCase' and 'Title Case' also available)
String pascalCase = text.toPascalCase; // 'HelloThere'.

// check if the string is alphanumeric
bool isAlphanumeric = text.isAlphanumeric; // false

// convert to one line string
String twoLineString = 'ab'
  										 'cd';
String oneLine = text.toOneLine; // abcd

// check if the string is null or empty
bool isEmptyOrNull = text.isEmptyOrNull;

// check if the string is a valid username 
bool isValidUsername = text.isValidUsername; // 'isValidPhoneNumber', isValidEmail, isValidHTML, and more are also available

// convert string to double or return null
double? tryToDouble = text.tryToDouble; // tryToInt also available

// limit the string from the start
String? limitFromStart = text.limitFromStart(3); // limitFromEnd also available

```

## Contributions

Contributions to this package are welcome. If you have any suggestions, issues, or feature requests, please create a pull request on the [repository](https://github.com/omar-hanafy/dart_helper_utils).

## License

`dart_helper_utils` is available under the [BSD 3-Clause License.](https://opensource.org/license/bsd-3-clause/)

<a href="https://www.buymeacoffee.com/omar.hanafy" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>
