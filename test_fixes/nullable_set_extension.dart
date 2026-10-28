import 'package:dart_helper_utils/dart_helper_utils.dart';

bool explicitSet(Set<int>? values) =>
    DHUNullableSetExtensions(values).isEmptyOrNull;

// Control: implicit calls already resolve to the Iterable extension.
bool implicitSet(Set<int>? values) => values.isNotEmptyOrNull;
