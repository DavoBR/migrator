import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:migrator/providers/providers.dart';
import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';

import 'migrate_in_screen.dart';

class MigrateOutScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final context = useContext();
    Future.microtask(() => context.read(migrateOutProvider).migrateOut());

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    final context = useContext();

    return AppBar(
      title: const Text('Descarga de objetos (Migrate Out)'),
      actions: [
        ActionButton(
          icon: CupertinoIcons.lab_flask,
          label: 'Probar Despliegue',
          onPressed: () => push(context, (_) => MigrateInScreen()),
        ),
        SizedBox(width: 5.0),
        ActionButton(
          icon: Icons.code,
          label: 'Bundle',
          onPressed: () {
            final bundleState = context.read(migrateOutProvider.state);
            showHighlight(
              context,
              title: Text('Bundle - MigrateOut'),
              language: 'xml',
              code: bundleState.maybeWhen(
                data: (bundle) => bundle.element.toXmlString(pretty: true),
                orElse: () => 'Cargando...',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    return MigrateScreenBody(mappingActionEditable: true, cwpEditable: true);
  }
}
