import 'package:migrator/common/common.dart';
import 'package:xml/xml.dart';

import 'item_in_folder.dart';

enum PolicyType {
  internal,
  include,
  serviceOperation,
}

class PolicyItem extends ItemInFolder {
  PolicyItem(XmlElement element) : super(element);

  @override
  String get folderId => _policyDetail.getAttribute('folderId');

  String get rawPolicyType => _policyDetail.getElement('l7:PolicyType')?.text;

  PolicyType get policyType =>
      parseEnum(PolicyType.values, rawPolicyType?.toCamelCase());

  XmlElement get _policyDetail => element
      .getElement('l7:Resource')
      .getElement('l7:Policy')
      .getElement('l7:PolicyDetail');
}
