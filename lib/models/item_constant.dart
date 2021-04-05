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

  static ItemConstant of(ItemType type) =>
      _constants[type] ?? ItemConstant("", "");
}
