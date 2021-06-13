import 'dart:convert';

import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:collection/collection.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/services/services.dart';
import 'package:migrator/controllers/controllers.dart';

class MigrateOutController extends GetxController {
  final _restman = Get.put(RestmanService());
  final _connCtrl = Get.find<ConnectionsSelectionController>();
  final _itemsCtrl = Get.find<ItemsSelectionController>();

  final migrateOutStatus = RxStatus.empty().obs;
  final bundle = BundleItem.empty().obs;
  final mappingActions = Map<String, Rx<MappingAction>>();
  final mappingProps = Map<String, RxMap<String, Object>>();
  final cwpValues = Map<String, RxString>();

  Iterable<ItemMapping> get selectedItemsMapping => bundle.value.mappings
      .where((mapping) => _itemsCtrl.selectedIds.contains(mapping.srcId));

  Iterable<ItemMapping> get dependenciesMapping => bundle.value.mappings
      .where((mapping) => !_itemsCtrl.selectedIds.contains(mapping.srcId));

  String keyPassPhrase = "";

  @override
  void onInit() {
    if (bundle.value.isEmpty) {
      migrateOut();
    }
    super.onInit();
  }

  @override
  void onClose() {
    migrateOutStatus.value = RxStatus.empty();
    bundle.value = BundleItem.empty();
    mappingActions.clear();
    mappingProps.clear();
    cwpValues.clear();
    keyPassPhrase = "";
  }

  Future<void> migrateOut() async {
    try {
      migrateOutStatus.value = RxStatus.loading();
      this.bundle.value = BundleItem.empty();

      final serviceItemIds = _itemsCtrl.selectedItems
          .where((i) => i.type == ItemType.service)
          .map((e) => e.id)
          .toList();
      final policyItemIds = _itemsCtrl.selectedItems
          .where((i) => i.type == ItemType.policy)
          .map((e) => e.id)
          .toList();

      keyPassPhrase = base64.encode(utf8.encode(Uuid().v4()));

      final bundle = await _restman.migrateOut(
        _connCtrl.source.value,
        services: serviceItemIds,
        policies: policyItemIds,
        keyPassPhrase: keyPassPhrase,
      );

      if (bundle.isEmpty) throw Exception('bundle is empty');

      await _setCustomMappings(bundle);

      for (var cwp in bundle.items.whereType<ClusterPropertyItem>()) {
        cwpValues[cwp.id] = cwp.value.obs;
      }

      this.bundle.value = bundle;
      migrateOutStatus.value = RxStatus.success();
    } catch (error, st) {
      logError(error, stackTrace: st, message: 'MigrateOut');
      migrateOutStatus.value = RxStatus.error(error.toString());
    }
  }

  Future<void> _setCustomMappings(BundleItem bundle) async {
    for (var mapping in bundle.mappings) {
      var action = mapping.action;
      final props = Map<String, Object>();

      if (_itemsCtrl.selectedIds.contains(mapping.srcId)) {
        // marcar los objetos selecionados para crear o actualizar
        action = MappingAction.newOrUpdate;
      } else {
        switch (mapping.type) {
          case ItemType.folder:
          case ItemType.clusterProperty:
          case ItemType.jdbcConnection:
          case ItemType.ssgActiveConnector:
            // marcar para crear o usar existente si es un FOLDER, CWP o CONEXION (BD, MQ, ACTIVE DIRECTORY)
            action = MappingAction.newOrExisting;
            break;
          default:
            action = MappingAction.ignore;
        }
      }

      //print('srcId: ${mapping.srcId}: ${mapping.action} => $action');

      switch (mapping.type) {
        case ItemType.service:
          // mapear servicios por url y no por id, para evitar duplicación
          props['MapBy'] = 'routingUri';
          break;
        case ItemType.policy:
          // mapear politicas por gui y no por id, para evitar duplicación
          props['MapBy'] = 'gui';
          break;
        case ItemType.folder:
          // mapear las carpetas por ruta para mantener homologación entre ambientes
          props['MapBy'] = 'path';
          props['MapTo'] = await _buildFolderPath(mapping.srcId);
          break;
        default:
          // cual otra cosa mapear por el nombre (CWP, CONEXIONES MQ, BD, ACTIVE DIRECTORY, etc..)
          props['MapBy'] = 'name';
          break;
      }

      mappingActions[mapping.srcId] = action.obs;
      mappingProps[mapping.srcId] = props.obs;
    }
  }

  Future<String> _buildFolderPath(String itemId) async {
    log('Building path for folder: $itemId');
    final pathParts = [];
    var item = await _fetchFolder(itemId);

    while (!item.isEmpty && item.folderId.isNotEmpty) {
      pathParts.add(item.name);
      item = await _fetchFolder(item.folderId);
    }

    final path = '/${pathParts.reversed.join('/')}';

    log('Folder path for $itemId: $path');

    return path;
  }

  Future<FolderItem> _fetchFolder(String id) async {
    log('Find folder $id in local list');
    var folder = _itemsCtrl.items
        .whereType<FolderItem>()
        .firstWhereOrNull((item) => item.id == id);

    if (folder == null) {
      log('Fetching folder $id from restman');
      folder = await _restman.fetchItemById<FolderItem>(
        _connCtrl.source.value,
        id,
      );

      _itemsCtrl.items.add(folder);
    }

    return folder;
  }
}
