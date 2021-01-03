import 'package:xml/xml.dart';

import 'item.dart';

class ItemWithId extends Item {
  ItemWithId(XmlElement element) : super(element);

  String get id => element.getElement('l7:Id')?.text;
}
