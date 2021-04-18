import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:xml/xml.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';
import 'package:migrator/services/services.dart';

class MigrateInController
    extends StateNotifier<AsyncValue<BundleMappingsItem>> {
  Reader _read;

  RestmanService get _restman => _read(restmanServiceProvider);

  Connection get _connection {
    final connection = _read(targetConnectionProvider).state;

    if (connection == null) {
      final error = Exception('No se ha selecionado una conexión destino');
      state = AsyncValue.error(error);
      throw error;
    }

    return connection;
  }

  MigrateInController(this._read) : super(AsyncValue.loading());

  Future<void> migrateIn(bool test, String versionComment) async {
    state = AsyncValue.loading();

    final keyPassPhrase = _read(migratePassPhraseProvider).state;
    final bundleXml = await buildBundleXml();
    final resultTypeCtrl = _read(migrateResultTypeProvider);

    resultTypeCtrl.state = MigrateResultType.none;

    final result = await _restman.migrateIn(
      _connection,
      bundleXml,
      test: test,
      versionComment: versionComment,
      keyPassPhrase: keyPassPhrase,
    );

    resultTypeCtrl.state =
        test ? MigrateResultType.test : MigrateResultType.live;

    state = AsyncValue.data(result);
  }

  Future<String> buildBundleXml() async {
    final bundle = _read(migrateOutProvider.state).data?.value;

    if (bundle == null) throw Exception("migrateOut bundle is null");

    final bundleElement = bundle.element
        .getElement('l7:Resource')
        ?.getElement('l7:Bundle')
        ?.copy();

    if (bundleElement == null) throw Exception("migrateOut bundle invalid XML");

    bundleElement.setAttribute(
      'xmlns:l7',
      bundle.element.getAttribute('xmlns:l7'),
    );

    // configurar mappings
    await _configureMappings(bundleElement);

    // actualizar los valores de los cwp mopdificados
    _configureClusterPropValues(bundleElement);

    return bundleElement.toXmlString();
  }

  Future<void> _configureMappings(XmlElement bundleElement) async {
    final mappingElements = bundleElement.findAllElements('l7:Mapping');

    for (var mappingElement in mappingElements) {
      if (mappingElement.getAttribute('srcId') == null) continue;

      _setMappingAction(mappingElement);
      _setMappingProps(mappingElement);

      await _addNewFolders(mappingElement, bundleElement);
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
        print('CWP Id element no found in the bundle: $name');
        continue;
      }

      final valueElement = cwpElement
          .getElement('l7:Resource')
          ?.getElement('l7:ClusterProperty')
          ?.getElement('l7:Value');

      if (valueElement == null) {
        print('CWP Value element no found in the bundle: $name');
        continue;
      }

      final userValue = _read(cwpValueFamily(id)).state;

      if (userValue != null && userValue != valueElement.text) {
        valueElement.innerText = userValue;
      }
    }
  }

  Future _addNewFolders(
    XmlElement mappingElement,
    XmlElement bundleElement,
  ) async {
    final srcId = mappingElement.getAttribute('srcId')!;
    final type = mappingElement.getAttribute('type')!;
    final action = mappingElement.getAttribute('action')!;
    final referencesElement = bundleElement.getElement('l7:References');

    if (referencesElement == null)
      throw Exception('Bundle no have References tag');

    // agregar las definiciones de los folders marcados como new
    if (type == 'FOLDER' && action.startsWith('New')) {
      //buscar definicion en la lista de folders descargados
      final folder = await _read(
        migrateOutItemFamily(Tuple2(srcId, ItemType.folder)).future,
      );

      if (folder == null)
        throw Exception('Folder with id $srcId not found in origin');

      //agregar definicion al bundle
      referencesElement.children.add(folder.element.copy());
    }
  }

  void _setMappingProps(XmlElement mappingElement) {
    final srcId = mappingElement.getAttribute('srcId')!;
    final props = _read(mappingPropsFamily(srcId)).state;

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
    final mappingAction = _read(mappingActionFamily(srcId))
        .state
        .toString()
        .split('.')[1]
        .toPascalCase();

    if (mappingAction != defaultAction) {
      mappingElement.setAttribute('action', mappingAction);
    }
  }
}
