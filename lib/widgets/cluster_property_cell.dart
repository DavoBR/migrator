import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/providers/providers.dart';
import 'package:migrator/utils/utils.dart';
import 'package:migrator/models/models.dart';

class ClusterPropertyCell extends HookWidget {
  final ClusterPropertyItem? cwp;
  final bool editable;

  ClusterPropertyCell(this.cwp, this.editable);

  @override
  Widget build(BuildContext context) {
    if (cwp == null) return SizedBox();

    final cwpValueCtrl = useProvider(cwpValueFamily(cwp!.id));
    final value = cwpValueCtrl.state ?? cwp!.value;
    final maxLength = 45;
    final isOverflow = value.length > maxLength;

    return Row(
      children: [
        Text(isOverflow ? value.substring(0, maxLength) + '...' : value),
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
              final newValue = await prompt(
                context,
                title: Text(cwp!.name),
                initialValue: value,
                maxLines: 6,
              );

              if (newValue != null) {
                cwpValueCtrl.state = newValue;
              }
            } else {
              await alert(
                context,
                title: Text(cwp!.name),
                content: Text(value),
              );
            }
          },
        ),
      ],
    );
  }
}
