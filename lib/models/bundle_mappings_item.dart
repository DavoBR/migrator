import 'package:xml/xml.dart';

import 'item.dart';
import 'item_mapping.dart';

class BundleMappingsItem extends Item {
  BundleMappingsItem(XmlElement element) : super(element);

  bool get isTest {
    final flag = element
        .getElement('l7:Link')
        ?.getAttribute('uri')
        ?.contains('test=true');

    if (flag == null) {
      throw Exception(
        'XML no es valido, no se puede validar el resultado de la migración',
      );
    }

    return flag;
  }

  List<ItemMapping> get mappings {
    return element
            .getElement('l7:Resource')
            ?.getElement('l7:Mappings')
            ?.findElements('l7:Mapping')
            .map((e) => ItemMapping(e))
            .toList() ??
        [];
  }
}
