import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';

class ActionMappingCell extends HookWidget {
  final ItemWithId? item;
  final bool editable;

  ActionMappingCell(this.item, this.editable);

  @override
  Widget build(BuildContext context) {
    if (item == null) return Text('Unknown');

    final mappingActionCtrl = useProvider(mappingActionFamily(item!.id));

    if (!editable) {
      return Text(
        mappingActionCtrl.state.toString().split('.')[1].toPascalCase(),
      );
    }

    return SizedBox(
      height: 30.0,
      child: DropdownButton<MappingAction>(
        value: mappingActionCtrl.state,
        underline: SizedBox(),
        onChanged: (action) {
          if (action != null) {
            mappingActionCtrl.state = action;
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
    );
  }
}
