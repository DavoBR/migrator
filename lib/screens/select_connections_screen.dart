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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    final context = useContext();
    final sourceConnectionState = useProvider(sourceConnectionProvider).state;
    final targetConnectionState = useProvider(targetConnectionProvider).state;

    return AppBar(
      title: const Text('Selecionar Conexiones'),
      actions: [
        ActionButton(
          icon: Icons.arrow_forward_outlined,
          label: 'Continuar',
          onPressed: () {
            if (sourceConnectionState == null ||
                targetConnectionState == null) {
              alert(
                context,
                title: Text('Falto algo...'),
                content: Text(
                  'Debes selecionar una conexión origen y otra destino para continuar',
                ),
              );
              return;
            }
            push(context, (_) => SelectItemsScreen());
          },
        ),
        const SizedBox(width: 5.0),
        ActionButton(
          icon: Icons.public_outlined,
          label: 'Conexiones',
          onPressed: () => push(context, (_) => ConnectionsScreen()),
        ),
        const SizedBox(width: 5.0),
      ],
    );
  }

  Widget _buildBody() {
    final connectionListState = useProvider(connectionListProvider.state);
    final connectionListCtrl = useProvider(connectionListProvider);

    useEffect(() {
      Future.microtask(() => connectionListCtrl.fetch());
    }, []);

    return connectionListState.when(
      data: (connections) {
        if (connections.length == 0) {
          return Text('No hay conexiones configuradas')
              .textColor(Colors.white)
              .center();
        }

        if (connections.length == 1) {
          return Text('Solo hay una conexión, registrar otra')
              .textColor(Colors.white)
              .center();
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPanel(true),
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

  Widget _buildPanel(bool isSource) {
    return Column(
      children: [
        Text(isSource ? 'Origen' : 'Destino')
            .fontWeight(FontWeight.bold)
            .padding(top: 20.0),
        _buildList(isSource),
      ],
    ).card(elevation: 8).expanded();
  }

  Widget _buildList(bool isSource) {
    final sourceConnection = useProvider(sourceConnectionProvider).state;
    final connectionListState = useProvider(connectionListProvider.state);

    return connectionListState.maybeWhen(
      data: (_connections) {
        final connections = _connections
            .where((connection) =>
                isSource ? true : (connection.id != sourceConnection?.id))
            .toList();

        if (!isSource && sourceConnection == null) {
          return Text('Selecionar la conexión origen').center().expanded();
        }

        return ListView.separated(
          itemCount: connections.length,
          shrinkWrap: true,
          separatorBuilder: (context, __) => Divider(
            color: Theme.of(context).primaryColor,
          ),
          itemBuilder: (context, index) =>
              _buildTile(context, isSource, connections[index]),
        );
      },
      orElse: () => Text('Invalid state'),
    );
  }

  Widget _buildTile(
    BuildContext context,
    bool isSource,
    Connection connection,
  ) {
    final sourceConnection = context.read(sourceConnectionProvider);
    final targetConnection = context.read(targetConnectionProvider);
    final status = context.read(statusProvider);
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
          status.setStatus('Seleciona la conexión destino');
        } else {
          targetConnection.state = connection;
          status.setStatus('Conexiones selecionadas, puedes continuar');
        }
      },
    );
  }
}
