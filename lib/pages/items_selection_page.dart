import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/controllers/controllers.dart';

import 'migrate_out_page.dart';

class ItemsSelectionPage extends StatelessWidget {
  final _ctrl = Get.put(ItemsSelectionController());
  final _connectionCtrl = Get.put(ConnectionsSelectionController());
  final _treeCtrl = TreeController(allNodesExpanded: false);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _ctrl.reset();
        _connectionCtrl.reset();
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
    return AppBar(
      title: const Text('Selecionar objetos'),
      actions: [
        ActionButton(
          icon: Icons.download_outlined,
          label: 'Descargar (Migrate Out)',
          onPressed: () => Get.to(() => MigrateOutPage()),
        )
      ],
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        SelectedConnectionsBar(),
        Expanded(
          child: Obx(
            () => _ctrl.itemsStatus.value.when(
              success: () => SplitView(
                viewMode: SplitViewMode.Vertical,
                initialWeight: 0.6,
                gripColor: Get.theme.primaryColor,
                gripSize: 3.0,
                view1: _buildTreeView().padding(all: 8.0),
                view2: _buildSelectedsPanel().padding(all: 8.0),
              ),
              loading: () => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Descargando carpeta raiz...'),
                  SizedBox(height: 20.0),
                  LinearProgressIndicator(),
                ],
              ).padding(horizontal: 50.0).center(),
              error: (error) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error descargando la carpeta raiz'),
                  SizedBox(height: 20.0),
                  Text(error ?? '...'),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Get.theme.primaryColor,
                    ),
                    onPressed: () => _ctrl.fetchRootItems(),
                    child: Text('Reintentar'),
                  ),
                ],
              ).padding(horizontal: 50.0).center(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTreeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Obx(
        () => TreeView(
          treeController: _treeCtrl,
          indent: 15.0,
          nodes: _buildTreeChildren(_ctrl.rootFolderId.value),
        ),
      ),
    );
  }

  List<TreeNode> _buildTreeChildren(String folderId) {
    final items = _ctrl.items.where((item) => item.folderId == folderId);

    if (items.isEmpty) return [];

    return items.map((item) => _buildTreeNode(item)).toList();
  }

  String _buildTooltipText(Item item) {
    if (item is ServiceItem) {
      return '${item.name} [${item.urlPattern}]';
    }

    return item.name;
  }

  TreeNode _buildTreeNode(ItemInFolder item) {
    final key = Key(item.id);

    return TreeNode(
      key: key,
      content: GestureDetector(
        child: Tooltip(
          message: _buildTooltipText(item),
          child: _buildNodeContent(item),
        ),
        onDoubleTap: () async {
          if (item is FolderItem) {
            _treeCtrl.expandNode(key);
            _ctrl.fetchItems(item.id);
          } else {
            _ctrl.select(item.id);
          }
        },
      ),
      children: item is FolderItem ? _buildTreeChildren(item.id) : [],
    );
  }

  Widget _buildNodeContent(ItemInFolder item) {
    String text = item.name;
    TextStyle? textStyle;

    if (item is ServiceItem) {
      text += ' [${item.urlPattern}]';

      if (!item.isEnabled) {
        textStyle = TextStyle(
          decoration: TextDecoration.lineThrough,
          decorationStyle: TextDecorationStyle.solid,
          decorationColor: Colors.red,
        );
      }
    }

    final content = Row(children: [
      Obx(() => NodeIcon(item, _ctrl.fetchtingItems[item.id])),
      SizedBox(width: 5.0),
      Text(text, style: textStyle),
    ]);

    return Draggable(
      data: item,
      feedback: Material(
        child: content,
        type: MaterialType.transparency,
      ),
      child: content,
    );
  }

  Widget _buildSelectedsPanel() {
    return DragTarget<ItemInFolder>(
      onWillAccept: (item) => item is ServiceItem || item is PolicyItem,
      onAccept: (item) => _ctrl.select(item.id),
      builder: (context, accepteds, rejecteds) {
        return Obx(
          () => Case(
            children: [
              When(
                _ctrl.selectedIds.isEmpty,
                (_) => const Text(
                  'Arrastra aquí o haz doble click en los servicios o politicas a desplegar y luego hacer click en Descargar (Migrate out) para continuar.',
                ).center(),
              ),
              Otherwise(
                (_) => SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: _buildTable(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTable(BuildContext context) {
    return Obx(
      () => Table(
        columnWidths: {
          0: FixedColumnWidth(50.0),
          1: FlexColumnWidth(),
          2: FixedColumnWidth(100.0),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          _buildTableHeader(),
          ..._ctrl.selectedItems.map((item) => _buildTableRow(context, item)),
        ],
      ),
    ).alignment(Alignment.topRight);
  }

  Widget _buildHeaderText(String text) {
    return Text(text).fontWeight(FontWeight.bold);
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        SizedBox.shrink(),
        _buildHeaderText('Nombre'),
        _buildHeaderText('Tipo'),
      ],
    );
  }

  TableRow _buildTableRow(BuildContext context, ItemInFolder item) {
    var name = item.name;

    if (item is ServiceItem) {
      name += ' [${item.urlPattern}]';
    }

    return TableRow(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          iconSize: 16.0,
          onPressed: () => _ctrl.unselect(item.id),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name),
            Text('ID: ${item.id}')
                .italic()
                .textColor(Colors.grey)
                .fontSize(10.0),
          ],
        ),
        Text(item.rawType),
      ],
    );
  }
}
