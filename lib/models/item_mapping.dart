import 'package:xml/xml.dart';

import 'package:migrator/common/common.dart';

import 'item.dart';

enum MappingAction {
  newOrExisting,
  newOrUpdate,
  alwaysCreateNew,
  delete,
  ignore,
}

enum MappingActionTaken {
  usedExisting,
  updatedExisting,
  createdNew,
  deleted,
  ignored,
}

class ItemMapping {
  ItemMapping(this.element);

  final XmlElement element;

  XmlElement get _propsElement => element.getElement('l7:Properties');

  String get srcId => element.getAttribute('srcId');

  String get rawType => element.getAttribute('type');

  String get rawAction => element.getAttribute('action');

  String get rawActionTaken => element.getAttribute('actionTaken');

  String get rawErrorType => element.getAttribute('errorType');

  MappingAction get action {
    return parseEnum(MappingAction.values, rawAction.toCamelCase());
  }

  MappingActionTaken get actionTaken {
    return parseEnum(MappingActionTaken.values, rawActionTaken.toCamelCase());
  }

  ItemType get type {
    return parseEnum(ItemType.values, rawType.toCamelCase());
  }

  Map<String, dynamic> get properties {
    final props = _propsElement?.findElements('l7:Property');

    if (props == null) return {};

    final entries =
        props.map((e) => MapEntry(e.getAttribute('key'), _getPropValue(e)));

    return Map.unmodifiable(Map.fromEntries(entries));
  }

  dynamic _getPropValue(XmlElement e) {
    if (e == null) return null;

    switch (e.firstElementChild.name.toString()) {
      case 'l7:BooleanValue':
        return e.firstElementChild.innerText == 'true';
      default:
        return e.firstElementChild.innerText;
    }
  }
}
