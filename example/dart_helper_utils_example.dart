// ignore_for_file: omit_local_variable_types, unused_local_variable

import 'package:dart_helper_utils/dart_helper_utils.dart';

void main() async {
// DATETIME:
  final now = DateTime.now();
  final DateTime tomorrow = now.addDays(1); // Adds 1 day to current date.
  final DateTime afterOneHour = now.addHours(1); // Adds 1 hour to current date.
  final String fullMonthName = now.month.toFullMonthName; // e.g March
  final String fullSmallName = now.month.toSmallMonthName; // e.g Mar
  final bool isToday = now.isToday; // true

// DURATION:
  const duration = Duration(seconds: 1, milliseconds: 30);
  // Adds the Duration to the current DateTime and returns a DateTime in the future.
  final DateTime futureDate = duration.fromNow;
  // Subtracts the Duration from the current DateTime and returns a DateTime in the past
  final DateTime pastDate = duration.ago;
  await duration.delay<void>(); // run async delay

// NUMBERS:
  const int number = 100;
  final String greeks = number.asGreeks; // 10k
  final Duration seconds = number.asSeconds; //  Duration(seconds: 100)
  final int numberOfDigits = number.numberOfDigits; // 3
  final int doubled = number.doubled; // 200

// TEXT:
  const text = 'hello there!';
  // wrap string at the specified index
  final String wrappedString = text.wrapString(2);
  final String capitalized = text.capitalizeFirstLetter; // 'Hello there!'
  final String pascalCase = text.toPascalCase; // 'HelloThere!'.
  final String camelCase = text.toCamelCase; // 'helloThere!'.
  final String titleCase = text.toTitleCase; // 'Hello There!'.
  final bool isAlphanumeric = text.isAlphanumeric; // false
  // tryToInt, tryToDateTime are also available
  final double? tryToDouble = text.tryToDouble;
  // limit the string from the start. limitFromEnd also available
  final String? limitFromStart = text.limitFromStart(3);
  // check if the string is a valid username. 'isValidPhoneNumber', isValidEmail, isValidHTML, and more are also available
  final bool isValidUsername = text.isValidUsername;
}
