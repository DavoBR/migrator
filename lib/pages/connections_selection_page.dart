import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:migrator/utils/utils.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/controllers/controllers.dart';

import 'connections_edit_page.dart';
import 'items_selection_page.dart';

enum PanelSide { left, right }

class ConnectionsSelectionPage extends StatelessWidget {
  final _ctrl = Get.put(ConnectionsSelectionController());

  ConnectionsSelectionPage() {
    everAll([_ctrl.source, _ctrl.target], (_) => _nextPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Get.theme.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Selecionar Conexiones'),
      automaticallyImplyLeading: false,
      actions: [
        ActionButton(
          icon: Icons.public_outlined,
          label: 'Conexiones',
          onPressed: () => Get.to(() => ConnectionsEditPage()),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Obx(
      () => Case(
        children: [
          When(
            _ctrl.connectionsCount == 0,
            (_) => _buildNeedConnection('No hay conexiones configuradas'),
          ),
          When(
            _ctrl.connectionsCount == 1,
            (_) => _buildNeedConnection(
              'Solo hay una conexión, debes registrar otra',
            ),
          ),
          Otherwise(
            (_) => Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Obx(
                  () => _buildPanel(
                    title: 'Selecionar conexión origen',
                    items: _ctrl.sourceConnectionList,
                    selected: _ctrl.source.value,
                    onSelect: _ctrl.selectSource,
                  ),
                ),
                VerticalDivider(),
                Obx(
                  () => _buildPanel(
                    title: 'Selecionar conexión destino',
                    items: _ctrl.targetConnectionList,
                    selected: _ctrl.target.value,
                    onSelect: _ctrl.selectTarget,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedConnection(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message).fontSize(22.0),
          SizedBox(height: 10.0),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: Get.theme.primaryColor,
              textStyle: TextStyle(fontSize: 18.0),
            ),
            child: Text('Configurar conexión'),
            onPressed: () => Get.to(() => ConnectionsEditPage()),
          )
        ],
      ),
    );
  }

  Widget _buildPanel({
    required String title,
    required List<Connection> items,
    required Connection selected,
    required void Function(Connection conn) onSelect,
  }) {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            Text(title)
                .fontSize(18.0)
                .textColor(Get.theme.primaryColor)
                .fontWeight(FontWeight.w500)
                .padding(vertical: 10.0),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                shrinkWrap: true,
                separatorBuilder: (context, __) => Divider(
                  color: Theme.of(context).primaryColor,
                ),
                itemBuilder: (context, index) {
                  final connection = items[index];
                  final isSelected = connection.id == selected.id;
                  return ListTile(
                    leading: Icon(Icons.public)
                        .padding(right: 12.0)
                        .border(right: 1.0),
                    title: Text(connection.toString()),
                    trailing: isSelected ? Icon(Icons.check_box) : null,
                    selected: isSelected,
                    onTap: () => onSelect(connection),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextPage() {
    if (_ctrl.source.value.isEmpty ||
        _ctrl.target.value.isEmpty ||
        Get.isDialogOpen!) {
      return;
    }

    confirm(
      title: '¿Continuar con esta selección?',
      content: Wrap(
        direction: Axis.vertical,
        spacing: 10.0,
        children: [
          Text('Origen: ${_ctrl.source}'),
          Text('Destino: ${_ctrl.target}'),
        ],
      ),
      onConfirm: () => Get.to(() => ItemsSelectionPage()),
      onCancel: () => _ctrl.reset(),
    );
  }
}
