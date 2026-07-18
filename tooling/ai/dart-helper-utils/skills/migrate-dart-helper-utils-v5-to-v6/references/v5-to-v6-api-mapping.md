# dart_helper_utils v5 to v6 API mapping

Verified against the repository's migration_guides.md and the 6.x source.

## Conversion facade (moved to convert_object, re-exported by DHU 6)

| v5 | v6 |
|---|---|
| `ConvertObject.toInt(...)` | `Convert.toInt(...)` (same mapKey/listIndex args) |
| `ConvertObject.toString1(v)` | `Convert.string(v)` |
| `ConvertObject.tryToX(...)` | `Convert.tryToX(...)` |
| `ConvertObject.toEnum` / `tryToEnum` | `Convert.toEnum` / `tryToEnum` (`parser:` required) |

## Top-level conversion functions (bare names gained a prefix)

| v5 | v6 |
|---|---|
| `toString1(v)` / `tryToString(v)` | `convertToString(v)` / `tryConvertToString(v)` |
| `toNum(v)` / `tryToNum(v)` | `convertToNum(v)` / `tryConvertToNum(v)` |
| `toInt(v)` / `tryToInt(v)` | `convertToInt(v)` / `tryConvertToInt(v)` |
| `toDouble(v)` / `tryToDouble(v)` | `convertToDouble(v)` / `tryConvertToDouble(v)` |
| `toBigInt(v)` / `tryToBigInt(v)` | `convertToBigInt(v)` / `tryConvertToBigInt(v)` |
| `toBool(v)` / `tryToBool(v)` | `convertToBool(v)` / `tryConvertToBool(v)` |
| `toDateTime(v)` / `tryToDateTime(v)` | `convertToDateTime(v)` / `tryConvertToDateTime(v)` |
| `toUri(v)` / `tryToUri(v)` | `convertToUri(v)` / `tryConvertToUri(v)` |
| `toMap<K,V>(v)` / `tryToMap<K,V>(v)` | `convertToMap<K,V>(v)` / `tryConvertToMap<K,V>(v)` |
| `toSet<T>(v)` / `tryToSet<T>(v)` | `convertToSet<T>(v)` / `tryConvertToSet<T>(v)` |
| `toList<T>(v)` / `tryToList<T>(v)` | `convertToList<T>(v)` / `tryConvertToList<T>(v)` |
| `toType<T>(v)` / `tryToType<T>(v)` | `convertToType<T>(v)` / `tryConvertToType<T>(v)` |

## Exceptions

| v5 | v6 |
|---|---|
| `ParsingException` | `ConversionException` |
| `e.parsingInfo` | `e.context` (plus `e.fullReport()` for the verbose dump) |

## Map / Iterable

| v5 | v6 |
|---|---|
| `map.getString('k', altKeys: [...])` | `map.getString('k', alternativeKeys: [...])` (every typed getter) |
| `map.firstValueForKeys('k', altKeys: a)` | `map.tryGetRaw('k', alternativeKeys: a)` (first NON-null wins) |
| `iterable.firstElementForIndices(...)` | `tryGetX(i, alternativeIndices: [...])` typed getters |
| `map.flatJson(...)` | `map.flatMap(...)` |
| `map.makeEncodable` / `encodableCopy` | `map.toJsonSafe()` / `map.toJsonMap()` |
| `map.safelyEncodedJson` / `encodedJsonString` | `map.toJsonString(indent: '  ')` / `map.encodeWithIndent` |
| `list.convertTo<T>()` | `convertToList<T>(list)` (`Set.convertTo` unchanged) |
| `iter.firstOrNull`, `lastOrNull`, `firstWhereOrNull`, `whereNotNull`, `mapIndexed`, `forEachIndexed`, `whereIndexed`, `groupBy` | same names from re-exported `package:collection` (no code change with a single DHU import) |
| `iter.sortedDescending()` | `iter.sorted((a, b) => b.compareTo(a))` |
| `iter.count(pred)` | `iter.where(pred).length` |
| `map.isEqual(other)` | `const MapEquality().equals(map, other)` (deep: `DeepCollectionEquality`) |
| `list.tryRemoveWhere(index)` | `list.tryRemoveWhere((e) => ...)` (now a predicate that removes) |

## DateTime / numbers / strings

| v5 | v6 |
|---|---|
| `date.httpFormat` | `date.httpDateFormat` |
| `values.percentile(0.5)` | `values.percentile(50)` (0-100 range) |
| `2.secDelay` / `2.delay()` | `2.secondsDelay()` (methods; v4-era change) |
| `5.minDelay` | `5.minutesDelay()` |
| `obj.isInt` / `obj.isDouble` / `obj.isNum` | `tryConvertToInt(obj) != null` etc. |
| `obj.isNull` / `obj.isNotNull` | `obj == null` / `obj != null` |
| `DHUBoolNullablelEx` (typo name) | `DHUBoolNullableEx` |
| Roman numeral helpers | moved to convert_object (`42.toRomanNumeral()`, `'XLII'.asRomanNumeralToInt`) |
| String to num/DateTime parsing helpers | convert_object (`convertToNum`, `Convert.toDateTime`) |

## TimeUtils

| v5 | v6 |
|---|---|
| `TimeUtils.throttle(duration: d, function: f)` | `TimeUtils.throttle(f, d, {leading = true, trailing = false, onError})` -> `ThrottledCallback` (call/cancel/dispose) |
| (no debounce helper) | `TimeUtils.debounce(f, d, {maxWait, immediate, debugLabel})` -> `DebouncedCallback` |
| `runWithTimeout` cancels hard | soft `TimeoutException`; task keeps running, late errors swallowed |

## Removed entirely (replacement decisions)

| Removed in v6 | Replacement |
|---|---|
| `Paginator`, `AsyncPaginator`, `InfinitePaginator`, `PaginationConfig`, `PaginationAnalytics` | pagination packages (e.g. infinite_scroll_pagination) or custom code |
| `DoublyLinkedList`, `toDoublyLinkedList` | `doubly_linked_list` package |
| `StringSimilarity`, `SimilarityAlgorithm`, `String.similarityTo`, `String.compareWith`, `StringSimilarityConfig` | `string_search_algorithms` package (`levenshteinDistance` is now `levenshtein`) |
| `DHUCountry`, `DHUTimezone`, `CountrySearchService`, `getRawCountriesData`, `getTimezonesRawData`, `getTimezonesList` | dedicated data package or API |
| `DatesHelper` static class | `DateTime` extensions (`date.isSameDayAs(other)`, ...) |

## Kept with surprising semantics

- `Iterable.intersect` still MERGES (union) - historical behavior preserved
  deliberately; do not "fix" call sites.
- `isNumeric`/`isAlphabet` are ASCII-only and trim whitespace; `isBool` is
  case-insensitive and trims.
