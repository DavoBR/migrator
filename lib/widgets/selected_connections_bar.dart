import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:migrator/controllers/controllers.dart';

class SelectedConnectionsBar extends GetWidget<ConnectionsSelectionController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => Text(controller.source.value.toString())),
          const SizedBox(width: 5.0),
          const Icon(Icons.arrow_forward, color: Colors.green),
          const SizedBox(width: 5.0),
          Obx(() => Text(controller.target.value.toString())),
        ],
      ),
    );
  }
}
