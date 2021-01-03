import 'package:xml/xml.dart';

import 'item_in_folder.dart';

class FolderItem extends ItemInFolder {
  FolderItem(XmlElement element) : super(element);

  @override
  String get folderId => element
      .getElement('l7:Resource')
      .getElement('l7:Folder')
      .getAttribute('folderId');
}
