import 'package:xml/xml.dart';

import 'item_with_id.dart';

class ClusterPropertyItem extends ItemWithId {
  ClusterPropertyItem(XmlElement element) : super(element);

  XmlElement? get _cpElement =>
      element.getElement('l7:Resource')?.getElement('l7:ClusterProperty');

  String get value => _cpElement?.getElement('l7:Value')?.text ?? '';
}
