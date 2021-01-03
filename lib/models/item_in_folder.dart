import 'package:migrator/models/item_with_id.dart';
import 'package:xml/xml.dart';

import 'item_with_id.dart';

abstract class ItemInFolder extends ItemWithId {
  ItemInFolder(XmlElement element) : super(element);

  String get folderId;
}
