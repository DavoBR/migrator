import 'package:migrator/models/cluster_property_item.dart';
import 'package:xml/xml.dart';
import 'package:migrator/common/common.dart';

import 'item.dart';
import 'folder_item.dart';
import 'service_item.dart';
import 'policy_item.dart';
import 'bundle_item.dart';
import 'bundle_mappings_item.dart';
import 'item_with_id.dart';

class ItemFactory {
  const ItemFactory._();

  static List<T> listFromXml<T extends Item>(String xml) {
    final doc = XmlDocument.parse(xml);
    final items = doc.firstElementChild
        ?.findElements('l7:Item')
        .map((e) => fromElement<T>(e))
        .toList();

    return items ?? [];
  }

  static T fromXml<T extends Item>(String xml) {
    final doc = XmlDocument.parse(xml);
    final element = doc.firstElementChild;

    if (element == null)
      throw Exception('Unexpected xml in ItemFactory.fromXml');

    return fromElement<T>(element);
  }

  static T fromElement<T extends Item>(XmlElement element) {
    if (element.name.toString() == 'l7:Error') {
      final errorType = element.getElement('l7:Type')?.text;
      final errorDetail = element.getElement('l7:Detail')?.text;

      throw '$errorType: $errorDetail';
    }

    final type = parseEnum(
      ItemType.values,
      (element.getElement('l7:Type')?.text ?? '').toCamelCase(),
      orElse: () => ItemType.unknown,
    );

    Item item;

    switch (type) {
      case ItemType.folder:
        item = FolderItem(element);
        break;
      case ItemType.service:
        item = ServiceItem(element);
        break;
      case ItemType.policy:
        item = PolicyItem(element);
        break;
      case ItemType.bundle:
        item = BundleItem(element);
        break;
      case ItemType.bundleMappings:
        item = BundleMappingsItem(element);
        break;
      case ItemType.clusterProperty:
        item = ClusterPropertyItem(element);
        break;
      default:
        item = ItemWithId(element);
        break;
    }

    return item as T;
  }
}
