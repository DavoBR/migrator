import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';

class ActionMappingCell extends StatelessWidget {
  final _migrateOutCtrl = Get.find<MigrateOutController>();

  final ItemWithId item;
  final bool editable;

  get _mappingAction => _migrateOutCtrl.mappingActions[item.id]!;

  ActionMappingCell(this.item, this.editable);

  @override
  Widget build(BuildContext context) {
    if (item.isEmpty) return Text('Unknown');

    return editable ? _buildEditable() : _buildNoEditable();
  }

  Widget _buildNoEditable() {
    return Obx(
      () => Text(
        _mappingAction.toString().split('.')[1].toPascalCase(),
      ),
    );
  }

  Widget _buildEditable() {
    return SizedBox(
      height: 30.0,
      child: Obx(
        () => DropdownButton<MappingAction>(
          value: _mappingAction.value,
          underline: SizedBox(),
          onChanged: (action) {
            if (action != null) {
              _mappingAction.value = action;
            }
          },
          items: MappingAction.values
              .where((value) => value != MappingAction.unknown)
              .map(
                (value) => DropdownMenuItem(
                  value: value,
                  child: Text(value.toString().split('.')[1].toPascalCase()),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
