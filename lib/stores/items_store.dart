import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:migrator/common/common.dart';
import 'package:migrator/services/restman_service.dart';
import 'package:migrator/models/models.dart';

import 'selected_connections_store.dart';

part 'items_store.g.dart';

class ItemsStore = _ItemsStoreBase with _$ItemsStore;

abstract class _ItemsStoreBase with Store {
  _ItemsStoreBase(this._contextStore);

  final _restman = GetIt.I<RestmanService>();
  final SelectedConnectionsStore _contextStore;

  @observable
  ObservableList<String> selectedIds = ObservableList<String>();

  @observable
  ObservableList<ItemInFolder> items = ObservableList<ItemInFolder>();

  @computed
  List<ItemInFolder> get selectedItems =>
      items.where((i) => selectedIds.contains(i.id)).toList();

  @observable
  ObservableMap<String, bool> folderLoadState = ObservableMap<String, bool>();

  @computed
  Connection get connection => _contextStore.sourceConnection;

  @action
  Future<List<ItemInFolder>> loadItems(String folderId) async {
    folderLoadState[folderId] = true;

    final foldersFuture = _restman.fetchItems(connection, ItemType.folder,
        parentFolderId: folderId);
    final servicesFuture = _restman.fetchItems(
        this.connection, ItemType.service,
        parentFolderId: folderId);
    final policiesFuture = _restman.fetchItems(connection, ItemType.policy,
        parentFolderId: folderId);

    try {
      final chunks = await Future.wait([
        foldersFuture.then((folders) => folders.sortBy((i) => i.name)),
        servicesFuture.then((services) => services.sortBy((i) => i.name)),
        policiesFuture.then((items) => items.cast<PolicyItem>()).then(
              (policies) => policies
                  .distinct((p) => p.rawPolicyType)
                  .expand((type) => policies
                      .cast<PolicyItem>()
                      .where((p) => p.rawPolicyType == type))
                  .toList(),
            ),
      ]);

      final items = chunks.expand((items) => items).map((_item) {
        final item = _item as ItemInFolder;
        this.items.removeWhere((currItem) => currItem.id == item.id);
        this.items.add(item);
        return item;
      }).toList();

      return items;
    } finally {
      folderLoadState[folderId] = false;
    }
  }

  @action
  void clear() {
    this.items.clear();
    this.selectedIds.clear();
    this.folderLoadState.clear();
  }

  @action
  void select(ItemInFolder item) {
    if (!selectedIds.contains(item.id)) {
      selectedIds.add(item.id);
    }
  }

  @action
  void deselect(ItemInFolder item) {
    selectedIds.remove(item.id);
  }
}
