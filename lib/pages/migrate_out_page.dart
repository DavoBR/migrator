import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/controllers/controllers.dart';

import 'migrate_in_page.dart';

class MigrateOutPage extends StatelessWidget {
  final _ctrl = Get.put(MigrateOutController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Descarga - Migrate Out'),
      actions: [
        ActionButton(
          icon: CupertinoIcons.lab_flask,
          label: 'Probar Despliegue',
          onPressed: () => Get.to(() => MigrateInPage()),
        ),
        ActionButton(
          icon: Icons.code,
          label: 'Bundle',
          onPressed: () {
            showHighlight(
              title: Text('Bundle - MigrateOut'),
              language: 'xml',
              code: _ctrl.bundle.value.element.toXmlString(pretty: true),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        SelectedConnectionsBar(),
        Expanded(
          child: Obx(
            () => _ctrl.migrateOutStatus.value.when(
              success: () => MigrateScreenBody(
                mappingActionEditable: true,
                cwpEditable: true,
              ),
              loading: () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Descargando los objetos seleccionados y sus dependencias...',
                  ),
                  SizedBox(height: 20.0),
                  LinearProgressIndicator(),
                ],
              ).padding(horizontal: 50.0).center(),
              error: (error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error en la descarga de objetos'),
                  SizedBox(height: 20.0),
                  Text(error ?? '...'),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Get.theme.primaryColor,
                    ),
                    onPressed: () => _ctrl.migrateOut(),
                    child: Text('Reintentar'),
                  ),
                ],
              ).padding(horizontal: 50.0).center(),
            ),
          ),
        ),
      ],
    );
  }
}
