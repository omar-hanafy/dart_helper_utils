import 'package:dart_helper_utils/dart_helper_utils.dart';

int? onList(List<int> values) => values.find((value) => value.isEven);

String? onSet(Set<String> values) => values.find((value) => value.isEmpty);

int? onIterable(Iterable<int> values) =>
    values.where((value) => value > 0).find((value) => value > 1);

int? Function(bool Function(int)) tearOff(List<int> values) => values.find;

// Control: a type with its own `find` keeps it.
class Finder {
  int? find(bool Function(int) test) => null;
}

int? control(Finder finder) => finder.find((value) => true);
