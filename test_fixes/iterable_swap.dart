import 'package:dart_helper_utils/dart_helper_utils.dart';

List<int> onSet(Set<int> values) => values.swap(0, 1);

List<int> onIterable(Iterable<int> values) => values.map((v) => v).swap(0, 1);

List<int> explicitCall(Iterable<int> values) =>
    DHUCollectionsExtensions(values).swap(0, 1);

// Control: on a List, `swap` is package:collection's in-place swap.
void onList(List<int> values) => values.swap(0, 1);
