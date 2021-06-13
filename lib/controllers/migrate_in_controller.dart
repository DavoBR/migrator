import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:xml/xml.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/services/services.dart';

import 'controllers.dart';

class MigrateInController extends GetxController {
  final _restman = Get.put(RestmanService());
  final _connCtrl = Get.find<ConnectionsSelectionController>();
  final _migrateOutCtrl = Get.find<MigrateOutController>();
  final _itemsCtrl = Get.find<ItemsSelectionController>();
  final migrateInStatus = RxStatus.empty().obs;
  final mappingResult = BundleMappingsItem.empty().obs;
  final isTesting = false.obs;

  @override
  void onInit() {
    migrateIn(true, '');
    super.onInit();
  }

  Future<void> migrateIn(bool test, String versionComment) async {
    try {
      migrateInStatus.value = RxStatus.loading();
      final bundleXml = await _buildBundleXml();

      isTesting.value = test;

      mappingResult.value = await _restman.migrateIn(
        _connCtrl.target.value,
        bundleXml,
        test: test,
        versionComment: versionComment,
        keyPassPhrase: _migrateOutCtrl.keyPassPhrase,
      );

      migrateInStatus.value = RxStatus.success();
    } catch (error, st) {
      logError(error, stackTrace: st, message: 'MigrateIn [test: $test]');
      migrateInStatus.value = RxStatus.error(error.toString());
    }
  }

  Future<String> _buildBundleXml({bool pretty: false}) async {
    final bundle = _migrateOutCtrl.bundle.value;

    final bundleElement = bundle.element
        .getElement('l7:Resource')
        ?.getElement('l7:Bundle')
        ?.copy();

    if (bundleElement == null) throw Exception("migrateOut bundle invalid XML");

    // copiar namespace
    bundleElement.setAttribute(
      'xmlns:l7',
      bundle.element.getAttribute('xmlns:l7'),
    );

    // configurar mappings
    await _configureMappings(bundleElement);

    // actualizar los valores de los cwp mopdificados
    _configureClusterPropValues(bundleElement);

    return bundleElement.toXmlString(pretty: pretty);
  }

  Future<void> _configureMappings(XmlElement bundleElement) async {
    final mappingElements = bundleElement.findAllElements('l7:Mapping');

    for (var mappingElement in mappingElements) {
      if (mappingElement.getAttribute('srcId') == null) continue;

      _setMappingAction(mappingElement);
      _setMappingProps(mappingElement);
      _addReference(mappingElement, bundleElement);
    }
  }

  void _configureClusterPropValues(XmlElement bundleElement) {
    final cwpElements = bundleElement
        .findAllElements('l7:Item')
        .where((e) => e.getElement('l7:Type')?.text == 'CLUSTER_PROPERTY');

    for (var cwpElement in cwpElements) {
      final name = cwpElement.getElement('l7:Name')?.text;
      final id = cwpElement.getElement('l7:Id')?.text;

      if (id == null) {
        log('CWP Id element no found in the bundle: $name');
        continue;
      }

      final valueElement = cwpElement
          .getElement('l7:Resource')
          ?.getElement('l7:ClusterProperty')
          ?.getElement('l7:Value');

      if (valueElement == null) {
        log('CWP Value element no found in the bundle: $name');
        continue;
      }

      valueElement.innerText = _migrateOutCtrl.cwpValues[id]!.value;
    }
  }

  _addReference(XmlElement mappingElement, XmlElement bundleElement) {
    final srcId = mappingElement.getAttribute('srcId')!;
    final type = mappingElement.getAttribute('type')!;
    final action = mappingElement.getAttribute('action')!;
    final referencesElement = bundleElement.getElement('l7:References');

    if (referencesElement == null)
      throw Exception('Bundle no have References tag');

    // agregar referencia de los folder marcados como new
    if (type == 'FOLDER' && action.startsWith('New')) {
      //buscar definicion en la lista de folders descargados
      final folder = _itemsCtrl.items.firstWhereOrNull(
        (item) => item.id == srcId && item.type == ItemType.folder,
      );

      if (folder == null)
        throw Exception('Folder with id $srcId not found in origin');

      //agregar definicion al bundle
      referencesElement.children.add(folder.element.copy());
    }
  }

  void _setMappingProps(XmlElement mappingElement) {
    final srcId = mappingElement.getAttribute('srcId')!;
    final props = _migrateOutCtrl.mappingProps[srcId]!;

    if (props.isEmpty) return;

    final List<XmlElement> propElements = [];

    for (var entry in props.entries) {
      String elementName;
      switch (entry.value) {
        case bool:
          elementName = 'BooleanValue';
          break;
        case DateTime:
          elementName = 'DateValue';
          break;
        default:
          elementName = 'StringValue';
      }

      propElements.add(XmlElement(
        XmlName('Property', 'l7'),
        [XmlAttribute(XmlName('key'), entry.key)],
        [
          XmlElement(
            XmlName(elementName, 'l7'),
            [],
            [XmlText(entry.value.toString())],
          )
        ],
      ));
    }

    mappingElement.children.clear();
    mappingElement.children.add(
      XmlElement(
        XmlName('Properties', 'l7'),
        [],
        propElements,
      ),
    );
  }

  void _setMappingAction(XmlElement mappingElement) {
    final srcId = mappingElement.getAttribute('srcId')!;
    final defaultAction = mappingElement.getAttribute('action');
    final mappingAction = _migrateOutCtrl.mappingActions[srcId]!
        .toString()
        .split('.')[1]
        .toPascalCase();

    if (mappingAction != defaultAction) {
      mappingElement.setAttribute('action', mappingAction);
    }
  }

  Future<void> copyBundleToClipboard() async {
    Clipboard.setData(
      ClipboardData(text: await _buildBundleXml(pretty: true)),
    );

    Get.snackbar(
      'Bundle copiado',
      'Se ha copiado el bundle de la migración al portapapeles',
    );
  }
}
