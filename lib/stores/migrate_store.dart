import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'package:collection/collection.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/stores/items_store.dart';
import 'package:migrator/common/common.dart';
import 'package:migrator/services/restman_service.dart';

import 'selected_connections_store.dart';

part 'migrate_store.g.dart';

class MigrateStore = _MigrateStoreBase with _$MigrateStore;

abstract class _MigrateStoreBase with Store {
  _MigrateStoreBase(this._selectedConnectionsStore, this._itemsStore);

  final _restman = GetIt.I<RestmanService>();
  final SelectedConnectionsStore _selectedConnectionsStore;
  final ItemsStore _itemsStore;

  final warningActions = [
    MappingActionTaken.deleted,
    MappingActionTaken.updatedExisting
  ];

  @computed
  Connection get sourceConnection =>
      _selectedConnectionsStore.sourceConnection!;

  @computed
  Connection get targetConnection =>
      _selectedConnectionsStore.targetConnection!;

  @observable
  ObservableFuture<BundleItem?> bundleFuture = ObservableFuture.value(null);

  @observable
  ObservableFuture<BundleMappingsItem?> testResultFuture =
      ObservableFuture.value(null);

  @observable
  ObservableFuture<BundleMappingsItem?> deployResultFuture =
      ObservableFuture.value(null);

  @computed
  bool get tested =>
      testResultFuture.isFulfilled() && testResultFuture.value != null;

  @computed
  BundleItem? get bundle => bundleFuture.value;

  @computed
  BundleMappingsItem? get testResult => testResultFuture.value;

  @computed
  BundleMappingsItem? get deployResult => deployResultFuture.value;

  @computed
  bool get hasMigrateModification {
    final mappingResult = testResult ?? deployResult;

    if (mappingResult == null) return false;
    return mappingResult.mappings
        .any((m) => warningActions.contains(m.actionTaken));
  }

  @computed
  bool get hasMigrateError {
    final mappingResult = testResult ?? deployResult;

    if (mappingResult == null) return false;

    return mappingResult.mappings.any((m) => m.rawErrorType.isNotEmpty);
  }

  @observable
  ObservableMap<String, MappingConfig> mappings = ObservableMap.of({});

  @observable
  ObservableMap<String, String> clusterProperties = ObservableMap.of({});

  @computed
  List<ItemMapping> get mappingOfSelectedItems => (bundle?.mappings ?? [])
      .where((e) => _itemsStore.selectedIds.contains(e.srcId))
      .toList();

  @computed
  List<ItemMapping> get mappingOfDependencyItems => (bundle?.mappings ?? [])
      .where((e) => !_itemsStore.selectedIds.contains(e.srcId))
      .toList();

  String? _keyPassPhrase;
  List<FolderItem> folders = [];

  @action
  void migrateOut() {
    if (bundleFuture.isPending()) return;

    mappings = ObservableMap<String, MappingConfig>();
    clusterProperties = ObservableMap<String, String>();

    _keyPassPhrase = base64.encode(utf8.encode(Uuid().v4()));

    final services = _itemsStore.selectedItems.whereType<ServiceItem>();
    final policies = _itemsStore.selectedItems.whereType<PolicyItem>();

    // descargar el bundle
    bundleFuture = ObservableFuture(_restman.migrateOut(
      sourceConnection,
      services: services.map((e) => e.id).toList(),
      policies: policies.map((e) => e.id).toList(),
      keyPassPhrase: _keyPassPhrase,
    ));

    when((_) => bundleFuture.isFulfilled(), () => _postMigrateOut());
  }

  @action
  Future<void> migrateIn(bool test, String versionComment) async {
    if (test) {
      testResultFuture = ObservableFuture.value(null);
    }

    deployResultFuture = ObservableFuture.value(null);

    final bundleXml = buildMigrateInBundle();

    final future = ObservableFuture(_restman.migrateIn(
      targetConnection,
      bundleXml,
      test: test,
      versionComment: versionComment,
      keyPassPhrase: _keyPassPhrase,
    ));

    if (test) {
      testResultFuture = future;
    } else {
      deployResultFuture = future;
    }
  }

  @action
  void clearMigrateOut() {
    bundleFuture = ObservableFuture.value(null);
    mappings = ObservableMap.of({});
    clusterProperties = ObservableMap.of({});
  }

  @action
  void clearMigrateIn() {
    testResultFuture = ObservableFuture.value(null);
    deployResultFuture = ObservableFuture.value(null);
  }

  @action
  void setMappingAction(ItemWithId item, MappingAction action) {
    final mapping = MappingConfig(
      action: action,
      properties: mappings[item.id]?.properties ?? {},
    );
    mappings.addAll({item.id: mapping});
  }

  @action
  void setClusterProperty(ClusterPropertyItem cwp, String value) {
    clusterProperties.addAll({cwp.id: value});

    final action = cwp.value != value
        ? MappingAction.newOrUpdate
        : MappingAction.newOrExisting;

    setMappingAction(cwp, action);
  }

  String buildMigrateInBundle() {
    if (bundle == null)
      throw Exception('bundle is null in buildMigrateInBundle');

    final bundleElement = bundle!.element
        .getElement('l7:Resource')
        ?.getElement('l7:Bundle')
        ?.copy();

    if (bundleElement == null)
      throw Exception('bundleElement is null in buildMigrateInBundle');

    bundleElement.setAttribute(
      'xmlns:l7',
      bundle!.element.getAttribute('xmlns:l7'),
    );

    // actualizar los valores de los mappings
    final mappingElements = bundleElement.findAllElements('l7:Mapping');

    for (var mappingElement in mappingElements) {
      final srcId = mappingElement.getAttribute('srcId');
      final type = mappingElement.getAttribute('type');

      if (!mappings.containsKey(srcId)) continue;

      final mappingConfig = mappings[srcId];
      final customAction =
          mappingConfig!.action.toString().split('.')[1].toPascalCase();
      final defaultAction = mappingElement.getAttribute('action');

      if (customAction != defaultAction) {
        mappingElement.setAttribute('action', customAction);
      }

      if (mappingConfig.properties.isNotEmpty) {
        mappingElement.children.clear();
        mappingElement.children.add(
          XmlElement(
            XmlName('Properties', 'l7'),
            [],
            mappingConfig.properties.entries.map(
              (entry) => XmlElement(
                XmlName('Property', 'l7'),
                [XmlAttribute(XmlName('key'), entry.key)],
                [
                  XmlElement(
                    XmlName(_getPropValueElementName(entry.value), 'l7'),
                    [],
                    [XmlText(entry.value.toString())],
                  )
                ],
              ),
            ),
          ),
        );
      }

      final referencesElement = bundleElement.getElement('l7:References');

      // agregar las definiciones de los folders marcados como new
      if (referencesElement != null &&
          type == 'FOLDER' &&
          customAction.startsWith('New')) {
        //buscar definicion en la lista de folders descargados
        final folder = folders.firstWhere((f) => f.id == srcId);

        //agregar definicion al bundle
        referencesElement.children.add(folder.element.copy());
      }
    }

    // actualizar los valores de los cwp mopdificados
    final cwpElements = bundleElement
        .findAllElements('l7:Item')
        .where((e) => e.getElement('l7:Type')?.text == 'CLUSTER_PROPERTY');

    for (var cwpElement in cwpElements) {
      final name = cwpElement.getElement('l7:Name')?.text;
      final id = cwpElement.getElement('l7:Id')?.text;

      if (!clusterProperties.containsKey(id)) continue;

      final valueElement = cwpElement
          .getElement('l7:Resource')
          ?.getElement('l7:ClusterProperty')
          ?.getElement('l7:Value');

      if (valueElement == null) {
        print('CWP Value element no found in the bundle: $name');
        continue;
      }

      final value = clusterProperties[id];

      if (value != null && value != valueElement.text) {
        valueElement.innerText = value;
      }
    }

    return bundleElement.toXmlString();
  }

  Future<void> _postMigrateOut() async {
    try {
      await _loadSourceFolders();
      await _setCustomMappings();
    } catch (error) {
      // TODO guardar error en un observable para mostrar alert en la vista

      print('_postMigrateOut: $error');
    }
  }

  Future<void> _loadSourceFolders() async {
    folders = await _restman
        .fetchItems(this.sourceConnection, ItemType.folder)
        .then((items) => items.cast<FolderItem>());
  }

  Future<void> _setCustomMappings() async {
    for (var mapping in bundle!.mappings) {
      var action = mapping.action;
      final props = Map<String, Object>();

      if (_itemsStore.selectedIds.contains(mapping.srcId)) {
        // marcar para crear o actualizar si es uno de los objetos selecionados de lo contrario ignorar
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
          props['MapTo'] = _buildFolderPath(mapping.srcId);
          break;
        default:
          // cual otra cosa mapear por el nombre (CWP, CONEXIONES MQ, BD, ACTIVE DIRECTORY, etc..)
          props['MapBy'] = 'name';
          break;
      }

      mappings[mapping.srcId] = MappingConfig(
        action: action,
        properties: props,
      );
    }
  }

  String _buildFolderPath(String itemId) {
    final pathParts = [];
    var item = folders.firstWhereOrNull((e) => e.id == itemId);

    while (item != null && item.folderId.isNotEmpty) {
      pathParts.add(item.name);
      item = folders.firstWhereOrNull((e) => e.id == item!.folderId);
    }

    final path = '/${pathParts.reversed.join('/')}';

    return path;
  }

  String _getPropValueElementName(Object value) {
    switch (value) {
      case bool:
        return 'BooleanValue';
      case DateTime:
        return 'DateValue';
      default:
        return 'StringValue';
    }
  }
}
