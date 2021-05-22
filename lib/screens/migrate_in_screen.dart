import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';

class MigrateInScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    useEffect(() {
      Future.microtask(() => _migrateIn(context, true));
    }, []);
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    final context = useContext();
    return AppBar(
      title: const Text('Despliegue - Migrate In'),
      actions: [
        ActionButton(
          icon: CupertinoIcons.lab_flask,
          label: 'Probar',
          onPressed: () => _migrateIn(context, true),
        ),
        SizedBox(width: 10.0),
        ActionButton(
          icon: CupertinoIcons.rocket,
          label: 'Desplegar',
          onPressed: () => _migrateIn(context, false),
        ),
        SizedBox(width: 10.0),
        ActionButton(
          icon: Icons.code,
          label: 'Bundle',
          onPressed: () async => showHighlight(
            context,
            title: Text('Bundle - MigrateIn'),
            language: 'xml',
            code: await context.read(migrateInProvider).buildBundleXml(),
          ),
        ),
        SizedBox(width: 10.0),
      ],
    );
  }

  Widget _buildBody() {
    final context = useContext();
    final migrateResultState = useProvider(migrateInProvider.state);
    final isTestMigration = useProvider(isTestMigrationProvider).state;

    return Column(
      children: [
        SelectedConnectionsBar(),
        Expanded(
          child: migrateResultState.when(
            data: (result) => MigrateScreenBody(
              headersHook: (labels) => labels.add(
                result.isTest ? 'Resultado Prueba' : 'Resultado',
              ),
              rowsHook: (cells, item) => cells.add(MappingResultCell(item)),
            ),
            loading: () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isTestMigration
                      ? 'Prueba de migración de objetos en curso...'
                      : 'Migración de objetos en curso...',
                ),
                SizedBox(height: 20.0),
                LinearProgressIndicator(),
              ],
            ).padding(horizontal: 50.0).center(),
            error: (error, st) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isTestMigration
                      ? 'Error en la migración de prueba'
                      : 'Error en la migración',
                ),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                  ),
                  onPressed: () => _migrateIn(context, isTestMigration),
                  child: Text('Reintentar'),
                ),
                SizedBox(height: 20.0),
                Text(error.toString()),
                SizedBox(height: 5.0),
                Text(st.toString()),
              ],
            ).padding(horizontal: 50.0).center(),
          ),
        ),
      ],
    );
  }

  void _migrateIn(BuildContext context, bool test) async {
    String versionComment = '';

    final targetConnection = context.read(targetConnectionProvider).state;
    final migrateInResult = context.read(migrateInProvider.state).data?.value;

    if (!test) {
      // se debe ejecutar un test antes de desplegar al ambiente
      if (migrateInResult == null || !migrateInResult.isTest) {
        alert(
          context,
          title: Text('Volver hacer la prueba'),
          content: Text(
            'Antes de desplegar volver hacer la prueba y verificar los resultados.',
          ),
        );
        return;
      }

      final confirmed = await confirm(
        context,
        title: Text('Confirmar despliegue'),
        content: Text('Ambiente: $targetConnection'),
      );

      if (!confirmed) return;

      versionComment = await prompt(
        context,
        title: Text('Comentario de la versión'),
      );

      if (versionComment.isEmpty) return;
    }

    await context.read(migrateInProvider).migrateIn(test, versionComment);

    if (!test) {
      alert(
        context,
        title: Text('Migración completada al ambiente $targetConnection'),
      );
    }
  }
}

final warningActions = [
  MappingActionTaken.deleted,
  MappingActionTaken.updatedExisting,
];

class MappingResultCell extends HookWidget {
  final ItemWithId? item;

  MappingResultCell(this.item);

  @override
  Widget build(BuildContext context) {
    if (item == null) return Text('item null');

    final mapping = useProvider(mappingResultFamily(item!.id));

    String? errorMessage;
    String status = 'No Result';
    IconData? iconData;
    Color? iconColor;

    if (mapping != null) {
      if (mapping.rawActionTaken.isNotEmpty) {
        status = mapping.rawActionTaken;

        if (warningActions.contains(mapping.actionTaken)) {
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
            '[${mapping!.rawType}] ${(item?.name ?? mapping.srcId)}: ${mapping.rawErrorType}',
          ),
          content: Text(errorMessage),
        );
      }
    });
  }
}
