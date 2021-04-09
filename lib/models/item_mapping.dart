import 'package:xml/xml.dart';

import 'package:migrator/utils/utils.dart';

import 'item.dart';

enum MappingAction {
  unknown,
  newOrExisting,
  newOrUpdate,
  alwaysCreateNew,
  delete,
  ignore,
}

enum MappingActionTaken {
  unknown,
  usedExisting,
  updatedExisting,
  createdNew,
  deleted,
  ignored,
}

class ItemMapping {
  ItemMapping(this.element);

  final XmlElement element;

  XmlElement? get _propsElement => element.getElement('l7:Properties');

  String get srcId => element.getAttribute('srcId') ?? '';

  String get rawType => element.getAttribute('type') ?? '';

  String get rawAction => element.getAttribute('action') ?? '';

  String get rawActionTaken => element.getAttribute('actionTaken') ?? '';

  String get rawErrorType => element.getAttribute('errorType') ?? '';

  MappingAction get action {
    return parseEnum(
      MappingAction.values,
      rawAction.toCamelCase(),
      orElse: () => MappingAction.unknown,
    );
  }

  MappingActionTaken get actionTaken {
    return parseEnum(
      MappingActionTaken.values,
      rawActionTaken.toCamelCase(),
      orElse: () => MappingActionTaken.unknown,
    );
  }

  ItemType get type => parseEnum(
        ItemType.values,
        rawType.toCamelCase(),
        orElse: () => ItemType.unknown,
      );

  Map<String, dynamic> get properties {
    final props = _propsElement?.findElements('l7:Property');

    if (props == null) return {};

    final entries = props.map(
      (e) => MapEntry(
        e.getAttribute('key'),
        _getPropValue(e),
      ),
    );

    return Map.unmodifiable(Map.fromEntries(entries));
  }

  dynamic _getPropValue(XmlElement e) {
    final child = e.firstElementChild;

    switch (child?.name.toString()) {
      case 'l7:BooleanValue':
        return child?.innerText == 'true';
      default:
        return child?.innerText;
    }
  }
}
