# Migration Guide: dart_helper_utils → convert_object

This guide maps the most common APIs from the old `dart_helper_utils` conversion helpers to the new `convert_object` package.

## Imports

```diff
- import 'package:dart_helper_utils/src/other_utils/convert_types.dart';
+ import 'package:convert_object/convert_object.dart';
```

## Exceptions

```diff
- on ParsingException catch (e) {
+ on ConversionException catch (e) {
    print(e);
  }
```

## Static / top-level API (mostly drop-in)

- toString1 / tryToString
- toNum / tryToNum
- toInt / tryToInt
- toDouble / tryToDouble
- toBool / tryToBool
- toBigInt / tryToBigInt
- toDateTime / tryToDateTime
- toUri / tryToUri
- toMap / tryToMap
- toSet / tryToSet
- toList / tryToList
- toType<T> / tryToType<T>

All accept `mapKey` and `listIndex` like before.

## Fluent API (new, optional)

```dart
final value = someDynamic.convert
    .fromMap('data')
    .fromList(0)
    .toInt();

final safe = someDynamic.convert.toIntOrNull();
```

## Map & Iterable extensions

Old → New mapping (representative sample):

```diff
- list.getString(0)
+ list.getString(0)

- list.getNum(1)
+ list.getNum(1)

- map.getInt('age')
+ map.getInt('age')

- map.tryGetString('name')
+ map.getStringOrNull('name')
```

The new helpers add inner selectors and defaults:

```dart
map.getInt('user', innerKey: 'age', alternativeKeys: ['u', 'user']);
list.getInt(0, innerMapKey: 'value', innerIndex: 2, defaultValue: 0);
```

## Enum parsing

```dart
final s = map.getString('status');
final status = ConvertObject.toEnum<Status>(
  s,
  parser: EnumParsers.byNameCaseInsensitive(Status.values),
);
```

Or directly from the map using `getEnum` / `getEnumOrNull`.

## Behavior differences (intentional improvements)

- `toDateTime` accepts numeric epoch (seconds or milliseconds).
- `toUri` detects phone numbers (`tel:`) and email addresses (`mailto:`).
- `toType<Uri>()` is supported.

These are generally helpful and should not break most code; document if you rely on strict parsing.

## Null-aware let helpers

```dart
final upper = nullableString.let((s) => s.toUpperCase());
final withDefault = nullableString.letOr((s) => s, defaultValue: 'fallback');
// If your block expects T?, use:
final r = nullableString.letNullable((s) => s?.toUpperCase());
```

## Troubleshooting

- If you previously used `tryToType<T>` and expected it to never throw, use a `try { ... } catch` or a `toTypeOrNull<T>()` helper.
- Use `ConversionException.fullReport()` for a JSON dump of the context when debugging.

Happy converting!

