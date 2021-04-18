import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/providers/providers.dart';
import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';

import 'migrate_in_screen.dart';

class MigrateOutScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final context = useContext();
    useEffect(() {
      Future.microtask(() => context.read(migrateOutProvider).migrateOut());
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
      title: const Text('Descarga - Migrate Out'),
      actions: [
        ActionButton(
          icon: CupertinoIcons.lab_flask,
          label: 'Probar Despliegue',
          onPressed: () {
            context.read(migrateOutProvider.state).whenData((value) {
              push(context, (_) => MigrateInScreen());
            });
          },
        ),
        SizedBox(width: 5.0),
        ActionButton(
          icon: Icons.code,
          label: 'Bundle',
          onPressed: () {
            context.read(migrateOutProvider.state).whenData((bundle) {
              showHighlight(
                context,
                title: Text('Bundle - MigrateOut'),
                language: 'xml',
                code: bundle.element.toXmlString(pretty: true),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildBody() {
    final context = useContext();
    final migrateOutBundle = useProvider(migrateOutProvider.state);

    return Column(
      children: [
        SelectedConnectionsBar(),
        Expanded(
          child: migrateOutBundle.when(
            data: (_) => MigrateScreenBody(
              mappingActionEditable: true,
              cwpEditable: true,
            ),
            loading: () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Descargando bundle de los objetos seleccionados...'),
                SizedBox(height: 20.0),
                LinearProgressIndicator(),
              ],
            ).padding(horizontal: 50.0).center(),
            error: (error, st) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error descargando el bundle'),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                  ),
                  onPressed: () =>
                      context.read(migrateOutProvider).migrateOut(),
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
}
