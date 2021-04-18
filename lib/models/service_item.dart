import 'package:xml/xml.dart';

import 'item_in_folder.dart';

class ServiceItem extends ItemInFolder {
  ServiceItem(XmlElement element) : super(element);

  XmlElement? get _serviceDetail => element
      .getElement('l7:Resource')
      ?.getElement('l7:Service')
      ?.getElement('l7:ServiceDetail');

  XmlElement? get _serviceMappings =>
      _serviceDetail?.getElement('l7:ServiceMappings');

  XmlElement? get _httpMapping =>
      _serviceMappings?.getElement('l7:HttpMapping');

  String get folderId => _serviceDetail?.getAttribute('folderId') ?? '';

  bool get isEnabled =>
      _serviceDetail?.getElement('l7:Enabled')?.text == 'true';

  String get urlPattern =>
      _httpMapping?.getElement('l7:UrlPattern')?.text ?? '';

  List<String> get verbs =>
      _httpMapping
          ?.getElement('l7:Verbs')
          ?.children
          .map((node) => node.innerText)
          .toList() ??
      [];
}
