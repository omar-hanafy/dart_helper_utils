# dart_helper_utils API quick reference (v6.x)

Exact member names by domain, verified against the 6.x source. Getters are
marked (g); everything else is a method. Extensions on nullable receivers are
marked `T?`.

## Exports

```dart
export 'package:collection/collection.dart';          // wholesale
export 'package:convert_object/convert_object.dart';  // wholesale
export 'package:stringo/stringo.dart';                // wholesale (since 6.1.0)
// intl is SHOW-filtered to exactly:
//   Bidi, BidiFormatter, DateFormat, Intl, NumberFormat
```

Since 6.1.0 the string TEXT TRANSFORMATIONS below (casing, slugify, truncate,
mask, whitespace, blank/character checks) physically live in `stringo` and are
re-exported. Domain validators (`isValidEmail`, `isUuid`, `isValidIp4`, ...),
MIME checks, and `parseDuration` stayed in DHU. Either way one DHU import
reaches all of them.

Extension type names for the moved members changed in 6.1.0:
`DHUCaseConversionExtensions` -> `StringCaseExtensions`,
`DHUNullSafeCaseConversionExtensions` -> `NullableStringCaseExtensions`, and
the moved half of `DHUStringExtensions` / `DHUNullSafeStringExtensions` ->
`StringTransformExtensions` / `NullableStringTransformExtensions` /
`StringChecksExtensions`. This only matters for code that names an extension
explicitly (`show ...`, or `Ext('x').member`).

## Strings - general (`String` / `String?`)

- Cleanup: `nullIfEmpty`(g), `nullIfBlank`(g), `removeEmptyLines`(g),
  `toOneLine`(g), `removeWhiteSpaces`(g), `clean`(g),
  `normalizeWhitespace()`, `words`(g), `lines`(g).
- Encoding: `base64Encode()`, `base64Decode({bool? allowMalformed})`.
- `slugify({String separator = '-'})` - ASCII only, drops non-ASCII letters,
  throws `ArgumentError` on empty separator.
- `parseDuration()` - clock `HH:mm:ss`/`mm:ss` (minutes/seconds < 60) or
  tokens `2d 3h 4m 5s` (units d/h/m/s, case-insensitive, leading `-`
  negates); anything else throws `FormatException`. Any `:` in the string
  selects the clock parser.
- On `String?`: `isEmptyOrNull`(g)/`isBlank`(g), `isNotEmptyOrNull`(g),
  `toCharArray()`, `insert(index, str)`, `isPalindrome`(g),
  `isAlphanumeric`(g), `hasSpecialChars`(g), `startsWithNumber`(g),
  `containsDigits`(g), `isValidUsername`(g), `isValidCurrency`(g),
  `isValidPhoneNumber`(g), `isValidEmail`(g), `isValidIp4`(g),
  `isValidUrl`(g), `isNumeric`(g) (ASCII digits only), `isAlphabet`(g),
  `hasCapitalLetter`(g), `isBool`(g),
  `hasMatch(pattern, {multiLine, caseSensitive, unicode, dotAll})`,
  `equalsIgnoreCase(other)`, `removeSurrounding(delimiter)`,
  `replaceAfter`/`replaceBefore`, `orEmpty`(g), `ifEmpty(action)`,
  `lastIndex`(g), `limitFromEnd(n)`/`limitFromStart(n)`,
  `truncate(int length, {String suffix = '...'})`,
  `wrapString({wordCount, wrapEach, delimiter})`.
- `isUuid`(g), `maskEmail`(g),
  `mask({visibleStart = 0, visibleEnd = 0, char = '*'})`.

## Casing (`String`, ALL getters except noted)

`toWords`, `toPascalCase`, `toTitleCase`, `toCamelCase`, `toSnakeCase`,
`toKebabCase`, `toScreamingSnakeCase`, `toScreamingKebabCase`,
`toPascalSnakeCase`, `toPascalKebabCase`, `toTrainCase` (same output as
`toPascalKebabCase`), `toCamelSnakeCase`, `toCamelKebabCase`, `toDotCase`,
`toFlatCase`, `toScreamingCase`, `capitalizeFirstLetter`,
`lowercaseFirstLetter`, `capitalizeFirstLowerRest`, `toTitle` (keeps
`-`/`_` delimiters, unlike `toTitleCase`). On `String?`:
`tryToLowerCase()`, `tryToUpperCase()`.

`toTitleCase` ALWAYS capitalizes the first word, then lowercases ~70 exception
words (a, the, of, ...) that appear later in the title. The exception set is
public as `titleCaseExceptions`. `toTitle` applies `toTitleCase` per segment
while preserving `-`/`_` delimiters.

Changed in 6.1.0: a leading stop word used to stay lowercase, so
`'the lord of the rings'.toTitleCase` returned `'the Lord of the Rings'`; it
now returns `'The Lord of the Rings'`.

## MIME checks (`String?`, filename/extension based, all getters)

- Base: `mimeType({List<int>? headerBytes})`.
- Video: `isVideo`, `isMP4`, `isMOV`, `isAVI`, `isWMV`, `isMKV`, `isWebM`,
  `isFLV`.
- Image: `isImage`, `isPNG`, `isJPEG`/`isJPG`, `isSVG`, `isGIF`, `isWebP`,
  `isBMP`, `isTIFF`/`isTIF`, `isHEIC`, `isHEIF`, `isIcon`, `isICO`, `isICNS`.
- Documents: `isPDF`, `isDOCX`, `isDOC` (alias of `isDOCX`), `isExcel`,
  `isXLSX`, `isXLS`, `isPowerPoint`, `isPPTX`, `isPPT`, `isTXT`,
  `isMarkdown`, `isRTF`.
- Audio: `isAudio`, `isMP3`, `isWAV`, `isAAC`, `isFLAC`, `isOGG`, `isAIFF`.
- Archive: `isArchive`, `isZIP`, `isRAR`, `is7Z`, `isTAR`, `isGZIP`/`isGZ`,
  `isDeb`, `isISO`.
- Code: `isHTML`, `isCSS`, `isJSON`, `isXML`, `isJavaScript`, `isTypeScript`,
  `isPython`, `isJAVA`, `isPHP`, `isCSharp`, `isCpp`, `isC`, `isGo`,
  `isRuby`, `isSwift`, `isKotlin`.
- Fonts: `isFont`, `isTTF`, `isOTF`, `isWOFF`, `isWOFF2`, `isEOT`.
  Contacts: `isContact`.

## Maps

- `Map<K, V>`: `swapKeysWithValues()`, `setIfMissing(key, value)` (checks
  key PRESENCE, keeps existing null values), `keysWhere(condition)`,
  `mapValues<V2>(transform)`, `filter((k, v) => bool)`.
- `Map<K, V>?`: `isPrimitive()`, `isEmptyOrNull`(g), `isNotEmptyOrNull`(g).
- String-keyed `Map<K extends String, V>`:
  - `flatMap({delimiter = '.', excludeArrays = false})` - flattens nested
    maps AND lists (indices become path segments); circular-ref safe.
  - `unflatten({delimiter = '.', parseIndices = true})` - inverse.
  - `deepMerge(Map<String, Object?> other)` - recursive, other wins,
    returns a new map.
  - `getPath(path, {delimiter = '.', parseIndices = true})` - supports
    `items[0].id`; null on miss.
  - `setPath(path, value, {delimiter = '.', parseIndices = true})` - creates
    intermediate maps/lists, pads lists with nulls, returns bool success.
- Typed getters (`getInt`, `tryGetString`, `getList<T>`, ...) come from
  convert_object; `tryGetRaw(key, alternativeKeys: [...])` returns the first
  NON-null raw value.

## Iterables

- `Iterable<E>`: `chunks(size)`, `windowed(size, {step = 1,
  partials = false})`, `partition(pred)` -> `(List<E>, List<E>)` record,
  `pairwise()` -> `List<(E, E)>`, `intersperse(element)`,
  `associate<K2, V>(keySelector, [valueSelector])`,
  `distinctBy<R>(keySelector, {equals, hashCode, isValidKey})` (equals and
  hashCode go together), `subtract(other)`, `find(predicate)`,
  `takeOnly(n)`, `drop(n)`, `firstHalf()`, `secondHalf()`, `halfLength`(g),
  `swap(i, j)`, `getRandom([seed])` (throws on empty), `containsAll(other)`,
  `filter`/`filterNot` (skip nulls), `orEmpty()`,
  `concatWithSingleList`/`concatWithMultipleList` (return the non-empty side
  when one side is empty), `toListConverted<R>()`/`toSetConverted<R>()`,
  `mapConcurrent<R>(action, {parallelism = 1})` (async; COMPLETION order).
- `Iterable<E>?`: `of(index)` (bounds-safe), `isEmptyOrNull`(g),
  `firstOrDefault(default)`/`lastOrDefault(default)`, `tryGetRandom([seed])`,
  `isEqual(other)` (deep), `totalBy(selector)`.
- `List<E>?`: `tryRemoveAt(i)`, `indexOfOrNull(e)`,
  `indexWhereOrNull(test, [start])`, `tryRemoveWhere(predicate)`.
- SDK/`collection` provides `firstOrNull`, `firstWhereOrNull`, `groupBy`,
  `mapIndexed`, `sorted`, ... via the re-export; DHU does not duplicate them.

## Numbers

- HTTP status on `num?` (all getters): `isSuccessCode` (200-299),
  `isOkCode`, `isCreatedCode`, `isNoContentCode`, `isClientErrorCode`,
  `isServerErrorCode`, `isRedirectionCode`, `isAuthenticationError`
  (401/403), `isValidationError` (422), `isRateLimitError` (429),
  `isTimeoutError` (408/504), `isConflictError` (409), `isNotFoundError`,
  `isRetryableError` (408/429/503/504), `statusCodeRetryDelay` (408 5s,
  429 1m, 503 5m, 504 10s, else zero unless retryable),
  `toHttpStatusMessage`, `toHttpStatusUserMessage`, `toHttpStatusDevMessage`.
- `num?`: `tryToInt()`, `tryToDouble()`,
  `percentage(total, {allowDecimals = true})`, `isZeroOrNull`(g),
  `asBool`(g) (> 0), `toDecimalString(places, {keepTrailingZeros})`.
- `num`: `numberOfDigits`(g), `removeTrailingZero`(g), `half`(g)/`third`(g)/
  `fourth`(g)/`tenth`(g), `getRandom`(g), `random([seed])`,
  `asGreeks([zerosFractionDigits, fractionDigits])`,
  `toFileSize({decimals = 2})`, `secondsDelay([callback])` (+ days/hours/
  minutes/milliseconds variants), `asSeconds`(g) (+ asMilliseconds/
  asMinutes/asHours/asDays -> Duration), `sqrt()`, `until(end, {step = 1})`,
  `safeDivide(divisor, {...})`, `roundToNearestMultiple(m)`/
  `roundUpToMultiple(m)`/`roundDownToMultiple(m)`,
  `isBetween(min, max, {inclusive = true})`,
  `toPercent({fractionDigits = 2})`,
  `isApproximatelyEqual(other, {tolerance = 0.01})`,
  `scaleBetween(min, max)`, `toFractionString()`, `isInteger`(g),
  `toOrdinal({asWord = false, includeAnd = false})` (21st / twenty-first;
  negatives throw).
- `int`: `inRangeOf(min, max)`, `factorial()`, `gcd(other)`, `lcm(other)`,
  `isPrime()`, `primeFactors()`, `isPerfectSquare()`, `isPerfectCube()`,
  `isFibonacci()`, `isPowerOf(base)`, `toBinaryString()`, `toHexString()`,
  `bitCount()`, `isDivisibleBy(d)`, `squared`(g)/`doubled`(g)/`tripled`(g).
- Stats on `Iterable<num>` (and int/double variants): `mean`(g),
  `median`(g), `mode`(g), `variance`(g), `standardDeviation`(g),
  `percentile(double p)` with p in 0-100. `Iterable<num?>?.total`(g) treats
  null as 0. Static twins on `NumbersHelper` (`safeDivide`, `mean`,
  `median`, `percentile(values, p)`, `gcd`, `isPerfectSquare`).
- Top-level: `randomInRange(min, max, [seed])` (inclusive; throws when
  min > max).

## Dates (`DateTime` / `DateTime?`)

- Formatting: `httpDateFormat`(g) (RFC-1123), `toUtcIso`(g), `toIso`(g),
  `format(pattern, [locale])`, `dateFormatUtc(pattern, [locale])`, ~30
  `formatAsX([locale])` shortcuts (`formatAsyMMMMd`, `formatAsEEEE`,
  `formatAsMMMEd`, `formatAsHms`, ...; note the odd casings `formatASyQQQ`
  and `formatAsyQQQQ`). On `DateTime?`: `tryFormat(format)`.
- Navigation: `startOfDay`(g)/`startOfMonth`(g)/`startOfYear`(g),
  `tomorrow`(g)/`yesterday`(g)/`dateOnly`(g), `previousDay`(g)/`nextDay`(g),
  `previousWeek`(g)/`nextWeek`(g), `firstDayOfMonth`(g)/`lastDayOfMonth`(g),
  `previousMonth`(g)/`nextMonth`(g),
  `firstDayOfWeek({startOfWeek = DateTime.monday})`,
  `lastDayOfWeek({startOfWeek = DateTime.monday})`,
  `daysInMonth`(g) - CALENDAR GRID padded to whole Mon-Sun weeks.
- Arithmetic: `+`/`-` with Duration, `addDays(n)`...`addMicroseconds(n)`,
  `subtractDays(n)`..., `addOrSubtractYears(n)`...,
  `addBusinessDays(n)` (skips weekends, negatives ok), `min(other)`/
  `max(other)`, `roundTo(Duration)`/`floorTo`/`ceilTo`, `clampBetween(a, b)`.
- Queries: `isToday`(g), `isTomorrow`(g), `isYesterday`(g), `isPast`(g),
  `isPresent`(g), `isInPastWeek`(g), `isInThisMonth`(g), `isLeapYear`(g),
  `isWeekend`(g)/`isWeekday`(g), `isSameDayAs(other)`/`isSameWeekAs`/
  `isSameHourAs`, `isAtSameYearAs(other)`...`isAtSameMicrosecondAs`,
  `isBetween(start, end, {inclusiveStart = true, inclusiveEnd = false,
  ignoreTime = false, normalize = false})`, `passedDuration`(g)/
  `remainingDuration`(g), `passedDays`(g)/`remainingDays`(g),
  `daysDifferenceTo([other])`, `daysUpTo(end)` (DST-aware iterable),
  `calculateAge()` -> `({int years, int months, int days})` record.
- On `num`: `toFullMonthName`(g), `toSmallMonthName`(g),
  `toFullDayName`(g)/`toSmallDayName`(g) (ISO 1 = Monday),
  `isCurrentYear`(g)/`isCurrentMonth`(g)/`isCurrentDay`(g),
  `isBetweenMonths(start, end)`.

## Durations

`fromNow`(g), `ago`(g), `toClockString()` (`HH:mm:ss`), `toHumanShort()`
(`1h 3m 4s`), `delayed<T>([computation])`.

## Uri

`domainName`(g), `rebuild({schemeBuilder, hostBuilder, portBuilder,
pathBuilder, pathSegmentsBuilder, queryBuilder, queryParametersBuilder,
fragmentBuilder, userInfoBuilder})` (segment builders beat string builders),
`withQueryParameters(map)` (replaces), `mergeQueryParameters(map)`
(incoming wins), `removeQueryParameters(keys)`, `appendPathSegment(s)`,
`appendPathSegments(list)`, `normalizeTrailingSlash({trailingSlash = true})`.
Iterable query values expand to repeated keys (`?ids=1&ids=2`).

## Bool / Object / globals

- `bool`: `toggled`(g). `bool?`: `isTrue`(g), `isFalse`(g) (non-null false
  only), `val`(g) (null -> false), `binary`(g) (1/0), `binaryText`(g).
- `Object?`: `isPrimitive()`.
- Top-level: `isEqual(a, b)` (deep collection equality), `now`(g),
  `currentMillisecondsSinceEpoch`(g), `randomBool([seed])`,
  `randomInt(max, [seed])`, `randomDouble([seed])`,
  `isValuePrimitive(v)`, `isTypePrimitive<T>()`.

## Intl wrappers

- num: `formatAsCurrency({locale, symbol = r'$', decimalDigits = 2,
  customPattern})`, `formatAsSimpleCurrency`, `formatAsCompact`,
  `formatAsCompactLong({explicitSign = false})`, `formatAsCompactCurrency`,
  `formatAsDecimal`, `formatAsPercentage`, `formatAsDecimalPercent`,
  `formatAsScientific`, `formatWithCustomPattern(pattern, {locale})`,
  `formatAsReadableNumber({locale, decimalDigits = 2, groupingSeparator,
  decimalSeparator, trimTrailingZeros = false})`.
- String: `symbolCurrencyFormat`(g), `simpleCurrencyFormat`(g),
  `compactCurrencyFormat`(g), `numberFormat({locale})` on `String?`,
  `dateFormat([locale])` on `String?` -> `DateFormat`.
- Plural/gender: `count.pluralize({required other, zero, one, two, few,
  many, locale, ...})`, `count.getPluralCategory(...)`,
  `'f'.genderSelect({required other, female, male, ...})`,
  `'locale'.setAsDefaultLocale()`, `translate({...})`.
- Bidi on String: `stripHtmlIfNeeded()`, `startsWithLtr`/`startsWithRtl`,
  `hasAnyLtr`/`hasAnyRtl`, `isRtlLanguage([lang])`, `enforceRtlInHtml()`,
  `enforceRtlIn()`, `enforceLtrInHtml()`, `enforceLtr()`,
  `guessDirection({isHtml = false})`, `wrapWithSpan({...})`,
  `wrapWithUnicode({...})`; constants `textDirectionLTR`,
  `textDirectionRTL`, `textDirectionUNKNOWN`.

## Constants (raw_data)

`fullWeekdays`/`smallWeekdays`, `fullMonthsNames`/`smallMonthsNames`
(1-indexed maps), `cssColorNamesToArgb`, `greekNumberSuffixes`,
`oneSecond`/`oneMinute`/`oneHour`/`oneDay`, `httpStatusMessages`/
`httpStatusUserMessage`/`httpStatusDevMessage`, regex constants
(`regexValidEmail`, `regexValidIp4`, `regexValidHexColor`, ...).

## Exceptions

`RException` (`message`; `RException.steps()` thrown by `num.until` on a
zero step). Conversion failures throw convert_object's
`ConversionException` (read `e.fullReport()`).
