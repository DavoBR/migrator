import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:get/get.dart';

import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/utils/constants.dart';
import 'package:migrator/utils/utils.dart';

class MappingResultCell extends GetWidget {
  final _migrateInCtrl = Get.find<MigrateInController>();
  final ItemWithId item;

  MappingResultCell(this.item);

  @override
  Widget build(BuildContext context) {
    final mapping = _migrateInCtrl.mappingResult.value.mappings
        .firstWhereOrNull((m) => m.type == item.type && m.srcId == item.id);

    String? errorMessage;
    String status = 'No Result';
    IconData? iconData;
    Color? iconColor;

    if (mapping != null) {
      if (mapping.rawActionTaken.isNotEmpty) {
        status = mapping.rawActionTaken;

        if (WARNING_ACTIONS.contains(mapping.actionTaken)) {
          iconData = Icons.warning_rounded;
          iconColor = Colors.amber;
        } else {
          iconData = Icons.check_circle;
          iconColor = Colors.green;
        }
      }

      if (mapping.rawErrorType.isNotEmpty) {
        iconData = Icons.error_rounded;
        status = mapping.rawErrorType;
        iconColor = Colors.red;
      }

      errorMessage = mapping.properties['ErrorMessage'];
    } else {
      iconData = Icons.warning_rounded;
      iconColor = Colors.amber;

      errorMessage =
          'Mapping result not found for item: ${item.name}[id:${item.id}]';
    }

    return GestureDetector(
      child: Row(
        children: [
          Icon(iconData, color: iconColor, size: 16.0),
          const SizedBox(width: 5.0),
          Text(status),
        ],
      ),
      onTap: () {
        if (errorMessage != null) {
          alert(
            title:
                '[${mapping!.rawType}] ${item.name}: ${mapping.rawErrorType}',
            content: Text(errorMessage),
          );
        }
      },
    );
  }
}
