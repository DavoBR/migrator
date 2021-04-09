import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';

class NodeIcon extends HookWidget {
  final ItemInFolder _item;

  NodeIcon(this._item);

  @override
  Widget build(BuildContext context) {
    Color? color;
    IconData icon;
    double size = 18.0;

    final isLoading = useProvider(folderIsLoadingFamily(_item.id)).state;

    switch (_item.type) {
      case ItemType.folder:
        if (isLoading) {
          return SizedBox(
            width: 18.0,
            height: 18.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
            ),
          );
        }

        icon = Icons.folder;
        color = Colors.green;
        break;
      case ItemType.service:
        final service = _item as ServiceItem;
        icon = Icons.insert_drive_file;
        color = service.isEnabled ? Colors.blue : Colors.red;
        break;
      case ItemType.policy:
        final policy = _item as PolicyItem;
        icon = Icons.insert_drive_file_outlined;
        switch (policy.policyType) {
          case PolicyType.internal:
            color = Colors.orange;
            break;
          case PolicyType.serviceOperation:
            color = Colors.deepOrange;
            break;
          default:
            color = Colors.lightBlue;
        }
        break;
      default:
        icon = Icons.check_box_outline_blank;
    }

    return Icon(
      icon,
      color: color,
      size: size,
    );
  }
}
