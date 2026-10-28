import 'package:dart_helper_utils/dart_helper_utils.dart';

bool nullable(String? text) => text.isEmptyOrNull;

bool nonNull(String text) => text.isNotEmptyOrNull;

bool onExpression(String text) => text.trim().isEmptyOrNull;

bool explicitOverride(String? text) =>
    StringChecksExtensions(text).isNotEmptyOrNull;

// Controls: collections keep their own isEmptyOrNull and isNotEmptyOrNull.
bool list(List<int>? values) => values.isEmptyOrNull;

bool map(Map<String, int>? values) => values.isNotEmptyOrNull;
