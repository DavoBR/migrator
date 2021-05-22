import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';

import 'connections_screen.dart';
import 'select_items_screen.dart';

class SelectConnectionsScreen extends HookWidget {
  Future<void> _continue(BuildContext context) async {
    final source = context.read(sourceConnectionProvider);
    final target = context.read(targetConnectionProvider);

    final ok = await confirm(
      context,
      title: Text('¿Continuar con esta selección?'),
      content: Wrap(
        direction: Axis.vertical,
        spacing: 10.0,
        children: [
          Text('Origen: ${source.state}'),
          Text('Destino: ${target.state}'),
        ],
      ),
    );

    if (!ok) {
      source.state = null;
      return;
    }

    push(context, (_) => SelectItemsScreen());
  }

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      Future.microtask(() {
        context.read(sourceConnectionProvider).state = null;
        context.read(targetConnectionProvider).state = null;
      });
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
      title: const Text('Selecionar Conexiones'),
      actions: [
        ActionButton(
          icon: Icons.public_outlined,
          label: 'Conexiones',
          onPressed: () => push(context, (_) => ConnectionsScreen()),
        ),
        const SizedBox(width: 10.0),
      ],
    );
  }

  Widget _buildBody() {
    final context = useContext();
    final asyncList = useProvider(connectionListProvider.state);

    useEffect(() {
      Future.microtask(() => context.read(connectionListProvider).fetch());
    }, []);

    return asyncList.when(
      data: (connections) {
        if (connections.length == 0) {
          return _buildNeedConnectionFeedback('No hay conexiones configuradas');
        }

        if (connections.length == 1) {
          return _buildNeedConnectionFeedback(
            'Solo hay una conexión, debes registrar otra',
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPanel(true),
            VerticalDivider(),
            _buildPanel(false),
          ],
        );
      },
      loading: () =>
          Text('Cargando las conexiones...').textColor(Colors.white).center(),
      error: (e, st) => Text('Error cargando las conexiones: ${e.toString()}')
          .textColor(Colors.white)
          .center(),
    );
  }

  Widget _buildNeedConnectionFeedback(String message) {
    final context = useContext();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message).fontSize(22.0).textColor(Colors.white),
          SizedBox(height: 8.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Theme.of(context).primaryColor,
              textStyle: TextStyle(fontSize: 18.0),
            ),
            child: Text('Crear conexión'),
            onPressed: () => push(context, (_) => ConnectionsScreen()),
          )
        ],
      ),
    );
  }

  Widget _buildPanel(bool isSource) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            _buildPanelTop(isSource),
            _buildPanelList(isSource).expanded(),
          ],
        ),
      ),
    );
  }

  Widget _buildPanelTop(bool isSource) {
    final context = useContext();
    final sourceConnection = useProvider(sourceConnectionProvider).state;
    final targetConnection = useProvider(targetConnectionProvider).state;

    String message = '';

    if (isSource && sourceConnection == null) {
      message = 'Selecionar ambiente origen';
    }

    if (!isSource && sourceConnection != null && targetConnection == null) {
      message = 'Selecionar ambiente destino';
    }

    return Text(message)
        .fontSize(18.0)
        .textColor(Theme.of(context).primaryColor)
        .fontWeight(FontWeight.w500)
        .padding(vertical: 10.0);
  }

  Widget _buildPanelList(bool isSource) {
    final asyncList = useProvider(connectionListFamily(isSource));

    return asyncList.maybeWhen(
      data: (connections) => ListView.separated(
        itemCount: connections.length,
        shrinkWrap: true,
        separatorBuilder: (context, __) => Divider(
          color: Theme.of(context).primaryColor,
        ),
        itemBuilder: (context, index) => _buildTile(
          context,
          isSource,
          connections[index],
        ),
      ),
      orElse: () => Text('!!Upps this should not happen.'),
    );
  }

  Widget _buildTile(
    BuildContext context,
    bool isSource,
    Connection connection,
  ) {
    final sourceConnection = context.read(sourceConnectionProvider);
    final targetConnection = context.read(targetConnectionProvider);
    final current = isSource ? sourceConnection.state : targetConnection.state;
    final isSelected = current?.id == connection.id;

    return ListTile(
      leading: Icon(Icons.public).padding(right: 12.0).border(right: 1.0),
      title: Text(connection.toString()),
      trailing: isSelected ? Icon(Icons.check_box) : null,
      selected: isSelected,
      onTap: () {
        if (isSource) {
          sourceConnection.state = connection;
          targetConnection.state = null;
        } else {
          targetConnection.state = connection;
          _continue(context);
        }
      },
    );
  }
}
