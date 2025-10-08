import 'package:convert_object/convert_object.dart';
import 'package:convert_object/src/utils/bools.dart';
import 'package:convert_object/src/utils/numbers.dart';

void main() {
  // Basic conversions
  basicConversions();

  // Collection conversions
  collectionConversions();

  // Safe conversions
  safeConversions();

  // Advanced conversions
  advancedConversions();

  // Custom converters
  customConverters();
}

void basicConversions() {
  print('=== Basic Conversions ===');

  // String conversions
  final text1 = 123.convert.toText(); // '123'
  final text2 = true.convert.toText(); // 'true'
  print('123 to text: $text1');
  print('true to text: $text2');

  // Number conversions
  final int1 = '456'.convert.toInt(); // 456
  final double1 = '3.14'.convert.toDouble(); // 3.14
  final num1 = '789'.convert.toNum(); // 789
  print('\'456\' to int: $int1');
  print('\'3.14\' to double: $double1');
  print('\'789\' to num: $num1');

  // Bool conversions
  final bool1 = 'true'.convert.toBool(); // true
  final bool2 = 1.convert.toBool(); // true
  final bool3 = 0.convert.toBool(); // false
  print('\'true\' to bool: $bool1');
  print('1 to bool: $bool2');
  print('0 to bool: $bool3');

  // DateTime conversions
  final date1 = '2024-01-15'.convert.toDateTime();
  final date2 = 1705276800000.convert.toDateTime(); // From milliseconds
  print('\'2024-01-15\' to DateTime: $date1');
  print('Milliseconds to DateTime: $date2');

  // Uri conversions
  final uri1 = 'https://example.com'.convert.toUri();
  final uri2 = '+1234567890'.convert.toUri(); // Phone number
  print('URL to Uri: $uri1');
  print('Phone to Uri: $uri2');

  print('');
}

void collectionConversions() {
  print('=== Collection Conversions ===');

  // Map conversions
  final map = {
    'name': 'John Doe',
    'age': '30',
    'active': 'true',
    'scores': [85, 90, 88],
    'address': {'city': 'New York', 'zip': '10001'}
  };

  final name = map.getString('name'); // 'John Doe'
  final age = map.getInt('age'); // 30
  final active = map.getBool('active'); // true
  final scores = map.getList<int>('scores'); // [85, 90, 88]
  final city =
      map.getMap<String, dynamic>('address').getString('city'); // 'New York'

  print('Name: $name');
  print('Age: $age');
  print('Active: $active');
  print('Scores: $scores');
  print('City: $city');

  // List conversions
  final list = ['1', '2', '3', '4', '5'];
  final firstAsInt = list.getInt(0); // 1
  final secondAsDouble = list.getDouble(1); // 2.0
  final allAsInt = list.convertAll<int>(); // [1, 2, 3, 4, 5]

  print('First as int: $firstAsInt');
  print('Second as double: $secondAsDouble');
  print('All as int: $allAsInt');

  // Set conversions
  final set = {'1', '2', '3'};
  final intSet = set.convertTo<int>(); // {1, 2, 3}
  print('String set to int set: $intSet');

  print('');
}

void safeConversions() {
  print('=== Safe Conversions ===');

  // OrNull variants
  const String? nullableValue = null;
  final safeInt = const Converter(nullableValue).tryToInt(); // null
  final safeText = const Converter(nullableValue).tryToText(); // null
  print('null to int (safe): $safeInt');
  print('null to text (safe): $safeText');

  // Or variants with defaults
  final withDefault1 = 'invalid'.convert.toIntOr(42); // 42
  final withDefault2 = const Converter(null).toTextOr('default'); // 'default'
  print('\'invalid\' to int with default 42: $withDefault1');
  print('null to text with default: $withDefault2');

  // Using alternative keys in maps
  final data = {'username': 'john_doe'};
  final userId = data.tryGetString(
    'user_id',
    alternativeKeys: ['userId', 'username'],
  ); // 'john_doe'
  print('Get with alternative keys: $userId');

  // Quick conversions with extensions
  final quickInt = '123'.tryToInt(); // 123
  final quickBool = 'yes'.asBool; // true
  print('Quick int conversion: $quickInt');
  print('Quick bool conversion: $quickBool');

  print('');
}

void advancedConversions() {
  print('=== Advanced Conversions ===');

  // Nested extraction
  final nested = {
    'response': {
      'data': {
        'users': [
          {'id': '1', 'name': 'Alice'},
          {'id': '2', 'name': 'Bob'},
        ]
      }
    }
  };

  final users = nested.convert
      .fromMap('response')
      .fromMap('data')
      .toMap<String, dynamic>()
      .getList<Map<String, dynamic>>('users');

  print('Extracted users: $users');

  // JSON string conversion
  const jsonString = '{"value": 42, "items": ["a", "b", "c"]}';
  final decoded = jsonString.convert.decoded.toMap<String, dynamic>();
  final value = decoded.getInt('value'); // 42
  final items = decoded.getList<String>('items'); // ['a', 'b', 'c']

  print('JSON value: $value');
  print('JSON items: $items');

  // Let extensions for null-safe operations
  const nullableString = 'hello' as String?;
  final uppercase = nullableString.let((s) => s.toUpperCase()); // 'HELLO'
  const String? nullString = null;
  final defaulted =
      nullString.letOr((s) => s, defaultValue: 'default'); // 'default'

  print('Let transformation: $uppercase');
  print('Let with default: $defaulted');

  print('');
}

// Define enum and class outside function
enum Status { active, inactive, pending }

class User {
  User(this.name, this.age);

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      map.getString('name'),
      map.getInt('age'),
    );
  }

  final String name;
  final int age;

  @override
  String toString() => 'User(name: $name, age: $age)';
}

void customConverters() {
  print('=== Custom Converters ===');

  // Custom converter for enum
  Status statusConverter(Object? value) {
    final str = value.toString().toLowerCase();
    return Status.values.firstWhere(
      (e) => e.name == str,
      orElse: () => Status.pending,
    );
  }

  final status = 'active'
      .convert
      .withConverter(statusConverter)
      .to<Status>(); // Status.active

  print('String to enum: $status');

  // Custom converter for domain object
  final userMap = {'name': 'John', 'age': '25'};
  // Note: parseAs expects the value at key to be a map, so let's use the map directly
  final userDirect = User.fromMap(userMap);

  print('Map to User: $userDirect');

  print('');
}
