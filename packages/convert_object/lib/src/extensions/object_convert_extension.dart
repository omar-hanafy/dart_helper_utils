import '../core/converter.dart';

extension ConvertObjectExtension on Object? {
  Converter get convert => Converter(this);
}
