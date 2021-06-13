import 'package:migrator/models/models.dart';

import 'item.dart';

class ItemConstant {
  const ItemConstant(this.title, this.resource);

  final String title;
  final String resource;

  static const Map<ItemType, ItemConstant> _constants = {
    ItemType.folder: const ItemConstant('Carpetas', 'folders'),
    ItemType.service: const ItemConstant('Servicios', 'services'),
    ItemType.policy: const ItemConstant('Politicas', 'policies'),
  };

  factory ItemConstant.of(ItemType itemType) {
    if (!_constants.containsKey(itemType)) {
      throw 'The item type $itemType is not defined in ItemConstant';
    }

    return _constants[itemType]!;
  }

  static ItemConstant ofType<T>() {
    final type = T.toString();
    switch (type) {
      case 'FolderItem':
        return ItemConstant.of(ItemType.folder);
      case 'ServiceItem':
        return ItemConstant.of(ItemType.service);
      case 'PolicyItem':
        return ItemConstant.of(ItemType.policy);
      default:
        throw 'The type $type is not defined in ItemConstant';
    }
  }
}
