import 'package:get/get.dart';
import 'package:collection/collection.dart';

import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/services/services.dart';
import 'package:migrator/utils/utils.dart';

class ItemsSelectionController extends GetxController {
  final _restman = Get.put(RestmanService());
  final _connectionCtrl = Get.find<ConnectionsSelectionController>();

  final itemsStatus = RxStatus.empty().obs;
  final items = <ItemInFolder>[].obs;
  final selectedIds = <String>[].obs;
  final fetchtingItems = Map<String, RxStatus>().obs;
  final rootFolderId = ''.obs;

  Iterable<ItemInFolder> get selectedItems =>
      items.where((item) => selectedIds.contains(item.id));

  @override
  void onInit() {
    fetchRootItems();
    super.onInit();
  }

  @override
  void onClose() {
    itemsStatus.value = RxStatus.empty();
    items.clear();
    selectedIds.clear();
  }

  Future<void> fetchRootItems() async {
    try {
      itemsStatus.value = RxStatus.loading();
      log('Fetching root folder');

      final folders = await _restman.fetchItems<FolderItem>(
        _connectionCtrl.source.value,
        parentFolderId: '',
      );

      items.addAll(folders);

      rootFolderId.value = folders.first.id;

      await fetchItems(rootFolderId.value);

      itemsStatus.value = RxStatus.success();
    } catch (error, st) {
      logError(
        error,
        message: 'Error descargando carpeta raiz',
        stackTrace: st,
      );
      itemsStatus.value = RxStatus.error(error.toString());
    }
  }

  Future<void> fetchItems(String folderId) async {
    try {
      fetchtingItems[folderId] = RxStatus.loading();

      log('Fetching folder items: $folderId');
      final futures = [
        _restman.fetchItems<FolderItem>(
          _connectionCtrl.source.value,
          parentFolderId: folderId,
        ),
        _restman.fetchItems<ServiceItem>(
          _connectionCtrl.source.value,
          parentFolderId: folderId,
        ),
        _restman.fetchItems<PolicyItem>(
          _connectionCtrl.source.value,
          parentFolderId: folderId,
        ),
      ];
      final folderItems = await Future.wait(futures);

      await Future.delayed(Duration(seconds: 1));

      items.removeWhere((item) => item.folderId == folderId);

      for (var chunk in folderItems) {
        items.addAll(chunk.sortedBy((item) => item.name));
      }

      fetchtingItems[folderId] = RxStatus.success();
    } catch (error, st) {
      logError(
        error,
        stackTrace: st,
        message: 'Error descargando carpeta: $folderId',
      );
      fetchtingItems[folderId] = RxStatus.error(error.toString());
    }
  }

  void select(String id) {
    selectedIds.addIf(!selectedIds.contains(id), id);
  }

  void unselect(String id) {
    if (!selectedIds.contains(id)) return;

    selectedIds.remove(id);
  }

  void reset() {
    items.clear();
    selectedIds.clear();
  }
}
