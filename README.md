dart_helper_utils
Dart utilities and extensions with type-safe conversions via convert_object.

Repository: https://github.com/omar-hanafy/dart_helper_utils
Package: https://pub.dev/packages/dart_helper_utils

Install
dependencies:
  dart_helper_utils: ^6.0.0

Import
import 'package:dart_helper_utils/dart_helper_utils.dart';

API overview
Conversions (re-exported from convert_object)
convertToInt(value: Object?, {defaultValue: int}) -> int | throws ConversionException
tryConvertToInt(value: Object?) -> int?
convertToDateTime(value: Object?, {format: String?, locale: String?}) -> DateTime | throws ConversionException
Convert.toInt(value: Object?, {defaultValue: int}) -> int | throws ConversionException
Convert.configure(config: ConvertConfig) -> void

Strings
String.toCamelCase -> String
String.slugify(separator: String>0) -> String | throws ArgumentError
String.parseDuration() -> Duration | throws FormatException
String.maskEmail -> String

Collections
Iterable<E>.chunks(size: int>0) -> List<List<E>> | throws ArgumentError
Iterable<E>.windowed(size: int>0, step: int>0, partials: bool) -> List<List<E>> | throws ArgumentError
Iterable<E>.mapConcurrent(action: Future<R> Function(E), parallelism: int>0) -> Future<List<R>> (completion order)
Map<String, Object?>.getPath(path: String, delimiter: String) -> Object?
Map<String, Object?>.setPath(path: String, value: Object?, delimiter: String, parseIndices: bool) -> bool
Map<String, Object?>.deepMerge(other: Map<String, Object?>) -> Map<String, Object?>

Date and time
DateTime.httpDateFormat -> String
DateTime.isBetween(start: DateTime, end: DateTime, inclusiveStart: bool, inclusiveEnd: bool, ignoreTime: bool, normalize: bool) -> bool | throws ArgumentError
DateTime.roundTo(duration: Duration) -> DateTime
Duration.toClockString() -> String
Duration.toHumanShort() -> String

Async helpers
Future<T>.minWait(duration: Duration) -> Future<T>
Future<T>.timeoutOrNull(timeout: Duration) -> Future<T?>
Future<T> Function().retry(retries: int>=0, delay: Duration>0, retryIf: bool Function(Object)?) -> Future<T>
Iterable<Future<T> Function()>.waitConcurrency(concurrency: int>0) -> Future<List<T>> (completion order)

Streams
StreamController<T>.safeAdd(event: T) -> bool
Stream<T>.retry(retryCount: int>=0, delayFactor: Duration>0, shouldRetry: bool Function(Object)?) -> Stream<T>

HTTP helpers
num.isSuccessCode -> bool
num.statusCodeRetryDelay -> Duration
num.toHttpStatusUserMessage -> String

Raw data
greekNumberSuffixes -> List<String>
httpStatusMessages -> Map<int, String>
cssColorNamesToArgb -> Map<String, int>

Examples
Example 1 conversions
import 'package:dart_helper_utils/dart_helper_utils.dart';
void main() {
  print(convertToInt('42')); /* -> 42 */
  print(tryConvertToInt('x')); /* -> null */
  convertToInt('x'); /* throws ConversionException */
}

Example 2 DateTime.isBetween
import 'package:dart_helper_utils/dart_helper_utils.dart';
void main() {
  final start = DateTime(2024, 1, 1);
  final end = DateTime(2024, 1, 2);
  print(DateTime(2024, 1, 1).isBetween(start, end)); /* -> true */
  print(DateTime(2024, 1, 2).isBetween(start, end)); /* -> false */
}

Example 3 String.parseDuration
import 'package:dart_helper_utils/dart_helper_utils.dart';
void main() {
  print('1h 30m'.parseDuration()); /* -> 1:30:00.000000 */
  '1h 30'.parseDuration(); /* throws FormatException */
}
