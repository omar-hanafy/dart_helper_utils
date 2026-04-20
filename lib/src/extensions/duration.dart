import 'dart:async';

import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:meta/meta.dart';

/// Extensions for Duration formatting and scheduling helpers.
extension DHUDurationExt on Duration {
  /// Adds the Duration to the current DateTime and returns a DateTime in the future
  DateTime get fromNow => DateTime.now() + this;

  /// Subtracts the Duration from the current DateTime and returns a DateTime in the past
  DateTime get ago => DateTime.now() - this;

  /// Formats the duration as HH:mm:ss.
  String toClockString() {
    final isNegative = this.isNegative;
    final duration = abs();
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    final value =
        '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return isNegative ? '-$value' : value;
  }

  /// Formats the duration as a short human-readable string (e.g., "1h 3m 4s").
  String toHumanShort() {
    final isNegative = this.isNegative;
    final duration = abs();
    final parts = <String>[];

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) parts.add('${days}d');
    if (hours > 0) parts.add('${hours}h');
    if (minutes > 0) parts.add('${minutes}m');
    if (seconds > 0 || parts.isEmpty) parts.add('${seconds}s');

    final value = parts.join(' ');
    return isNegative ? '-$value' : value;
  }

  /// Utility to delay some callback (or code execution).
  ///
  /// Sample:
  /// ```dart
  ///   await 3.seconds.delay(() {
  ///           ....
  ///   }
  ///```
  @optionalTypeArgs
  Future<T> delayed<T extends Object?>([
    FutureOr<T> Function()? computation,
  ]) async => Future<T>.delayed(this, computation);
}
