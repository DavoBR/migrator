import 'package:xml/xml.dart';

import 'item.dart';
import 'item_factory.dart';
import 'item_with_id.dart';
import 'item_mapping.dart';

class BundleItem extends Item {
  BundleItem(XmlElement element) : super(element);

  XmlElement? get _bundle =>
      element.getElement('l7:Resource')?.getElement('l7:Bundle');

  List<ItemWithId> get items {
    return _bundle
            ?.getElement('l7:References')
            ?.findElements('l7:Item')
            .map((e) => ItemFactory.fromElement<ItemWithId>(e))
            .toList() ??
        [];
  }

  List<ItemMapping> get mappings =>
      _bundle
          ?.getElement('l7:Mappings')
          ?.findElements('l7:Mapping')
          .map((e) => ItemMapping(e))
          .where((x) => x.srcId.isNotEmpty)
          .toList() ??
      [];

  factory BundleItem.empty() {
    return BundleItem(Item.empty().element);
  }
}
