import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:meta/meta.dart';

///
extension DHUDurationExt on Duration {
  /// Adds the Duration to the current DateTime and returns a DateTime in the future
  DateTime get fromNow => DateTime.now() + this;

  /// Subtracts the Duration from the current DateTime and returns a DateTime in the past
  DateTime get ago => DateTime.now() - this;

  /// Utility to delay some callback (or code execution).
  ///
  /// Sample:
  /// ```dart
  ///   await 3.seconds.delay(() {
  ///           ....
  ///   }
  ///```
  @optionalTypeArgs
  Future<T> delayed<T extends Object?>(
          [FutureOr<T> Function()? computation]) async =>
      Future<T>.delayed(this, computation);
}
