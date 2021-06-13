import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';

const int _MAX_LENGTH = 45;

class ClusterPropertyCell extends StatelessWidget {
  final _migrateOutCtrl = Get.find<MigrateOutController>();

  final ClusterPropertyItem cwp;
  final bool editable;

  ClusterPropertyCell(this.cwp, this.editable);

  @override
  Widget build(BuildContext context) {
    if (cwp.isEmpty) return SizedBox();

    final value = _migrateOutCtrl.cwpValues[cwp.id]!;

    return Obx(
      () => Row(
        children: [
          Text(value.value.length > _MAX_LENGTH
              ? value.substring(0, _MAX_LENGTH) + '...'
              : value.toString()),
          SizedBox(width: 5.0),
          IconButton(
            icon: Icon(editable ? Icons.edit : Icons.loupe),
            iconSize: 14.0,
            color: Colors.green,
            tooltip: editable ? 'Editar valor antes de desplegar' : '',
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            onPressed: () async {
              if (editable) {
                await prompt<String>(
                  title: cwp.name,
                  initialValue: value.value,
                  maxLines: 6,
                  onConfirm: (newValue) {
                    if (newValue != null) {
                      value.value = newValue;
                    }
                  },
                );
              } else {
                await alert(title: cwp.name, content: Text(value.toString()));
              }
            },
          ),
        ],
      ),
    );
  }
}
