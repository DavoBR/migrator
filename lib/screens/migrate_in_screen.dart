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
    Future.microtask(() => _migrateIn(context, true));
    return WillPopScope(
      onWillPop: () async {
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
              onPressed: () => _migrateIn(context, true),
            ),
            SizedBox(width: 5.0),
            ActionButton(
              icon: CupertinoIcons.rocket,
              label: 'Desplegar',
              onPressed: () => _migrateIn(context, false),
            ),
            SizedBox(width: 5.0),
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
          ],
        ),
        body: MigrateScreenBody(
          headersHook: (labels) => labels.add('Resultado'),
          rowsHook: (cells, item) => cells.add(MappingResultCell(item)),
        ),
      ),
    );
  }

  void _migrateIn(BuildContext context, bool test) async {
    String versionComment = '';

    if (!test) {
      final targetConnection = context.read(targetConnectionProvider).state;
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

    context.read(migrateInProvider).migrateIn(true, versionComment);
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
