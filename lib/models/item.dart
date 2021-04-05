import 'package:xml/xml.dart';
import 'package:migrator/common/common.dart';

enum ItemType {
  unknown,
  folder,
  service,
  policy,
  bundle,
  bundleMappings,
  clusterProperty,
  invalidArgument,
  jdbcConnection,
  ssgActiveConnector
}

class Item {
  Item(this.element);

  final XmlElement element;

  String get name => element.getElement('l7:Name')?.text ?? '';

  String get rawType => element.getElement('l7:Type')?.text ?? '';

  ItemType get type => parseEnum(
        ItemType.values,
        rawType.toCamelCase(),
        orElse: () => ItemType.unknown,
      );
}
