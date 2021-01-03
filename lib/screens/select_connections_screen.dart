import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/common/common.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/stores/stores.dart';

import 'connections_screen.dart';
import 'select_items_screen.dart';

class SelectConnectionsScreen extends StatefulWidget {
  @override
  _SelectConnectionsScreenState createState() =>
      _SelectConnectionsScreenState();
}

class _SelectConnectionsScreenState extends State<SelectConnectionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: const Text('Selecionar Conexiones'),
        actions: [
          ActionButton(
            icon: Icons.arrow_forward_outlined,
            label: 'Continuar',
            onPressed: () {
              final store = context.store<SelectedConnectionsStore>();
              if (store.sourceConnection == null ||
                  store.targetConnection == null) {
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
          ActionButton(
            icon: Icons.public_outlined,
            label: 'Conexiones',
            onPressed: () => push(context, (_) => ConnectionsScreen()),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final store = context.store<ConnectionsStore>();

    if (store.connections.length == 0) {
      return Text('No hay conexiones configuradas')
          .textColor(Colors.white)
          .center();
    }

    if (store.connections.length == 1) {
      return Text('Solo hay una conexión, registrar otra')
          .textColor(Colors.white)
          .center();
    }

    return Column(
      children: [
        _buildBodyContent(),
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildBodyContent() {
    return Row(
      children: [
        _buildPanel(true),
        _buildPanel(false),
      ],
    ).flexible(fit: FlexFit.tight);
  }

  Widget _buildStatusBar() {
    final store = context.store<SelectedConnectionsStore>();
    return StatusBar(
      child: Observer(builder: (_) {
        var message;

        if (store.targetConnection != null) {
          message = 'Conexiones selecionadas, puedes continuar';
        } else if (store.sourceConnection != null) {
          message = 'Seleciona la conexión destino';
        }

        if (message == null) {
          return SizedBox();
        }

        return Indicator(
          Text(message),
          icon: Icons.info_rounded,
          color: Colors.blue,
          size: 16.0,
        );
      }),
    );
  }

  Widget _buildPanel(bool isSource) {
    final title = isSource ? 'Origen' : 'Destino';
    return Column(
      children: [
        Text(title).fontWeight(FontWeight.bold).padding(top: 20.0),
        _buildList(isSource),
      ],
    ).card(elevation: 8).expanded();
  }

  Widget _buildList(bool isSource) {
    final selectedConnectionsStore = context.store<SelectedConnectionsStore>();
    final connectionsStore = context.store<ConnectionsStore>();
    return Observer(
      builder: (context) {
        final connections = connectionsStore.connections.where((conn) {
          return isSource
              ? true
              : (conn != selectedConnectionsStore.sourceConnection);
        }).toList();

        if (!isSource && selectedConnectionsStore.sourceConnection == null) {
          return Text('Selecionar la conexión origen').center().expanded();
        }

        return ListView.separated(
          itemCount: connections.length,
          shrinkWrap: true,
          separatorBuilder: (_, __) => Divider(
            color: Theme.of(context).primaryColor,
          ),
          itemBuilder: (_, index) => _buildTile(isSource, connections[index]),
        );
      },
    );
  }

  Widget _buildTile(bool isSource, Connection connection) {
    final store = context.store<SelectedConnectionsStore>();
    return Observer(builder: (_) {
      final current =
          isSource ? store.sourceConnection : store.targetConnection;
      final selected = current == connection;
      return ListTile(
        leading: Icon(Icons.public).padding(right: 12.0).border(right: 1.0),
        title: Text(connection.toString()),
        trailing: selected ? Icon(Icons.check_box) : null,
        selected: selected,
        onTap: () {
          if (isSource) {
            store.sourceConnection = connection;
            store.targetConnection = null;
          } else {
            store.targetConnection = connection;
          }
        },
      );
    });
  }
}
