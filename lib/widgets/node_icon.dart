import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';

class NodeIcon extends StatelessWidget {
  final ItemInFolder _item;
  final RxStatus? _status;

  NodeIcon(this._item, this._status);

  @override
  Widget build(BuildContext context) {
    return Case(
      children: [
        When(_status == null, (_) => _buildIcon()),
        Otherwise(
          (_) => _status!.when(
            success: () => _buildIcon(),
            // TODO mostrar icono de error y un dialog al hacer click
            error: (error) => _buildIcon(),
            loading: () => SizedBox(
              width: 18.0,
              height: 18.0,
              child: CircularProgressIndicator(strokeWidth: 2.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIcon() {
    Color? color;
    IconData icon;
    double size = 18.0;

    switch (_item.type) {
      case ItemType.folder:
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
