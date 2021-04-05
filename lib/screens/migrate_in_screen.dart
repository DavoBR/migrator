import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:collection/collection.dart';

import 'package:migrator/common/common.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/stores/stores.dart';

class MigrateInScreen extends StatefulWidget {
  @override
  _MigrateInScreenState createState() => _MigrateInScreenState();
}

class _MigrateInScreenState extends State<MigrateInScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((_) => _migrateIn(true));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store<MigrateStore>();
    return WillPopScope(
      onWillPop: () async {
        store.clearMigrateIn();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: const Text('Despliegue de objetos (Migrate In)'),
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
              onPressed: () => showHighlight(
                context,
                title: Text('Bundle - MigrateIn'),
                language: 'xml',
                code: store.buildMigrateInBundle(),
              ),
            ),
          ],
        ),
        body: MigrateScreenBody(
          statusBar: _buildStatusBar(),
          cwpSuffixIconBuilder: _buildCWPSuffixIcon,
          headersHook: (labels) => labels.add('Resultado'),
          rowsHook: (cells, item) => cells.add(
            item != null ? _buildMappingResultCell(item) : Text('---'),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final store = context.store<MigrateStore>();
    return StatusBar(
      child: Observer(builder: (_) {
        if (store.tested) {
          return store.deployResultFuture.when(
            pending: () => Indicator(
              Text('Migración en progreso...'),
              color: Colors.green,
              size: 16.0,
            ),
            fulfilled: (result) => Indicator(
              Text(result != null ? 'Migración completada' : 'Espere...'),
              color: Colors.green,
              size: 16.0,
              icon: result != null ? Icons.check : null,
            ),
            rejected: (error) => Indicator(
              Text('Error en la migración (hacer click para ver error)'),
              color: Colors.red,
              size: 16.0,
              icon: Icons.error,
            ).gestures(
              onTap: () => alert(
                context,
                title: Text('Error durante la migración'),
                content: Text(error.toString()),
              ),
            ),
          );
        }

        return store.testResultFuture.when(
          pending: () => Indicator(
            Text('Prueba en progreso...'),
            color: Colors.green,
            size: 16.0,
          ),
          fulfilled: (result) => Indicator(
            Text(result != null
                ? 'Prueba completada, proceder con el despliegue'
                : 'Espere...'),
            color: Colors.green,
            size: 16.0,
            icon: result != null ? Icons.check : null,
          ),
          rejected: (error) => Indicator(
            Text('Error en la prueba (hacer click para ver error)'),
            color: Colors.red,
            size: 16.0,
            icon: Icons.error,
          ).gestures(
            onTap: () => alert(
              context,
              title: Text('Error de la prueba'),
              content: Text(error.toString()),
            ),
          ),
        );
      }),
    );
  }

  void _migrateIn(bool test) async {
    final store = context.store<MigrateStore>();
    String? versionComment;

    if (!test) {
      final confirmed = await confirm(
        context,
        title: Text('Confirmar despliegue'),
        content: Text('Ambiente: ${store.targetConnection}'),
      );

      if (!confirmed) return;

      versionComment = await prompt(
        context,
        title: Text('Comentario de la versión'),
      );

      if (versionComment == null || versionComment.isEmpty) {
        return;
      }
    } else {
      versionComment = '';
    }

    store.migrateIn(test, versionComment);
  }

  Widget _buildCWPSuffixIcon(
    ClusterPropertyItem cwp,
    String value,
    bool isOverflow,
  ) {
    if (!isOverflow) {
      return SizedBox();
    }

    return IconButton(
      icon: const Icon(Icons.loupe),
      iconSize: 14.0,
      color: Colors.green,
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () async {
        await alert(
          context,
          title: Text(cwp.name),
          content: Text(value),
        );
      },
    );
  }

  Widget _buildMappingResultCell(ItemWithId item) {
    final store = context.store<MigrateStore>();
    final migrateInResult = store.deployResult ?? store.testResult;
    final mapping = migrateInResult?.mappings
        .firstWhereOrNull((mapping) => mapping.srcId == item.id);

    String? errorMessage;
    String status = 'No Result';
    IconData? iconData;
    Color? iconColor;

    if (mapping != null) {
      if (mapping.rawActionTaken.isNotEmpty) {
        status = mapping.rawActionTaken;

        if (store.warningActions.contains(mapping.actionTaken)) {
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
    }

    return Row(
      children: [
        Icon(iconData, color: iconColor, size: 16.0),
        const SizedBox(width: 5.0),
        Text(status),
      ],
    ).gestures(onTap: () {
      if (errorMessage != null) {
        alert(
          context,
          title: Text(
            '[${item.rawType}] ${item.name}: ${mapping?.rawErrorType}',
          ),
          content: Text(errorMessage),
        );
      }
    });
  }
}
