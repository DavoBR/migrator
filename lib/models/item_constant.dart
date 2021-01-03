import 'item.dart';

class ItemConstant {
  const ItemConstant({this.title, this.resource});

  final String title;
  final String resource;

  static const Map<ItemType, ItemConstant> _constants = {
    ItemType.folder: const ItemConstant(title: 'Carpetas', resource: 'folders'),
    ItemType.service:
        const ItemConstant(title: 'Servicios', resource: 'services'),
    ItemType.policy:
        const ItemConstant(title: 'Politicas', resource: 'policies'),
  };

  static ItemConstant of(ItemType type) => _constants.containsKey(type)
      ? _constants[type]
      : ItemConstant(title: "", resource: "");
}
