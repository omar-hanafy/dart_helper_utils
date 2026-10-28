import 'package:dart_helper_utils/dart_helper_utils.dart';

String implicitCall(String text) => text.enforceRtlIn();

String onExpression(String text) => text.trim().enforceRtlIn();

String explicitCall(String text) =>
    DHUBidiStringExtensions(text).enforceRtlIn();
