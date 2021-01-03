import 'package:xml/xml.dart';

import 'item.dart';
import 'item_mapping.dart';

class BundleMappingsItem extends Item {
  BundleMappingsItem(XmlElement element) : super(element);

  List<ItemMapping> get mappings {
    return element
        .getElement('l7:Resource')
        .getElement('l7:Mappings')
        .findElements('l7:Mapping')
        .map((e) => ItemMapping(e))
        .where((x) => x != null)
        .toList();
  }
}
