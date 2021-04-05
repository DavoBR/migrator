import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/common/common.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/stores/stores.dart';

import 'migrate_in_screen.dart';

class MigrateOutScreen extends StatefulWidget {
  @override
  _MigrateOutScreenState createState() => _MigrateOutScreenState();
}

class _MigrateOutScreenState extends State<MigrateOutScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((_) => _migrateOut());
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store<MigrateStore>();
    return WillPopScope(
      onWillPop: () async {
        store.clearMigrateOut();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: const Text('Descarga de objetos (Migrate Out)'),
          actions: [
            ActionButton(
              icon: CupertinoIcons.lab_flask,
              label: 'Probar Despliegue',
              onPressed: () => push(context, (_) => MigrateInScreen()),
            ),
            ActionButton(
              icon: Icons.code,
              label: 'Bundle',
              onPressed: () => showHighlight(
                context,
                title: Text('Bundle - MigrateOut'),
                language: 'xml',
                code: store.bundle?.element.toXmlString(pretty: true) ?? '',
              ),
            ),
          ],
        ),
        body: MigrateScreenBody(
          statusBar: _buildStatusBar(),
          mappingActionEditable: true,
          cwpSuffixIconBuilder: _buildCWPSuffixIcon,
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    final store = context.store<MigrateStore>();
    return StatusBar(
      child: Observer(builder: (_) {
        return store.bundleFuture.when(
          pending: () => Indicator(
            Text('Descargando bundle de los objetos selecionados...'),
            color: Colors.green,
            size: 16.0,
          ),
          fulfilled: (bundle) => bundle != null
              ? Indicator(
                  Text(
                    'Descarga del bundle completada, proceder con la prueba del despliegue',
                  ),
                  color: Colors.green,
                  size: 16.0,
                  icon: Icons.check,
                )
              : SizedBox(),
          rejected: (error) => Indicator(
            Text('Error descargando el bundle (click para ver detalle)'),
            color: Colors.red,
            size: 16.0,
            icon: Icons.error,
          ).gestures(
            onTap: () => alert(
              context,
              title: Text('Error de despliegue'),
              content: Text(error.toString()),
            ),
          ),
        );
      }),
    );
  }

  void _migrateOut() {
    final store = context.store<MigrateStore>();
    store.migrateOut();
  }

  Widget _buildCWPSuffixIcon(
    ClusterPropertyItem cwp,
    String value,
    bool isOverflow,
  ) {
    final store = context.store<MigrateStore>();
    return IconButton(
      icon: const Icon(Icons.edit),
      iconSize: 14.0,
      color: Colors.green,
      tooltip: 'Editar valor antes de desplegar',
      padding: EdgeInsets.zero,
      constraints: BoxConstraints(),
      onPressed: () async {
        final newValue = await prompt(
          context,
          title: Text(cwp.name),
          initialValue: value,
          maxLines: 6,
        );

        if (newValue != null) {
          store.setClusterProperty(cwp, newValue);
        }
      },
    );
  }
}
