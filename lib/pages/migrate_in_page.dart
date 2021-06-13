import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/controllers/controllers.dart';

class MigrateInPage extends StatelessWidget {
  final _ctrl = Get.put(MigrateInController());
  final _connCtrl = Get.find<ConnectionsSelectionController>();

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
      title: const Text('Despliegue - Migrate In'),
      actions: [
        ActionButton(
          icon: CupertinoIcons.lab_flask,
          label: 'Probar',
          onPressed: () => _migrateIn(true),
        ),
        ActionButton(
          icon: CupertinoIcons.rocket,
          label: 'Desplegar',
          onPressed: () => _migrateIn(false),
        ),
        ActionButton(
          icon: Icons.code,
          label: 'Bundle',
          onPressed: () async => showHighlight(
            title: Text('Bundle - MigrateIn'),
            language: 'xml',
            code: await _ctrl.buildBundleXml(),
          ),
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
            () => _ctrl.migrateInStatus.value.when(
              success: () => MigrateScreenBody(
                headersHook: (labels) => labels.add(
                  _ctrl.mappingResult.value.isTest
                      ? 'Resultado Prueba'
                      : 'Resultado',
                ),
                rowsHook: (cells, item) => cells.add(MappingResultCell(item)),
              ),
              loading: () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Obx(
                    () => Text(
                      _ctrl.isTesting.value
                          ? 'Prueba de migración de objetos en curso...'
                          : 'Migración de objetos en curso...',
                    ),
                  ),
                  SizedBox(height: 20.0),
                  LinearProgressIndicator(),
                ],
              ).padding(horizontal: 50.0).center(),
              error: (error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _ctrl.isTesting.value
                        ? 'Error en la migración de prueba'
                        : 'Error en la migración',
                  ),
                  SizedBox(height: 20.0),
                  Text(error ?? ''),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Get.theme.primaryColor,
                    ),
                    onPressed: () => _migrateIn(_ctrl.isTesting.value),
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

  void _migrateIn(bool test) async {
    String? versionComment = '';

    final targetConnection = _connCtrl.target.value;
    final migrateInResult = _ctrl.mappingResult.value;

    if (!test) {
      // se debe ejecutar un test antes de desplegar al ambiente
      if (migrateInResult.isEmpty || !migrateInResult.isTest) {
        alert(
          title: 'Volver hacer la prueba',
          content: Text(
            'Antes de desplegar volver hacer la prueba y verificar los resultados.',
          ),
        );
        return;
      }

      final confirmed = await confirm(
        title: 'Confirmar despliegue',
        content: Text('Ambiente: $targetConnection'),
      );

      if (!confirmed) return;

      versionComment = await prompt(title: 'Comentario de la versión');

      if (versionComment == null || versionComment.isEmpty) return;
    }

    await _ctrl.migrateIn(test, versionComment);

    if (!test) {
      alert(title: 'Migración completada al ambiente $targetConnection');
    }
  }
}
