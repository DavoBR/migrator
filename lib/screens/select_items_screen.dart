import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:migrator/providers/item_providers.dart';
import 'package:migrator/utils/utils.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';

import 'migrate_out_screen.dart';

class SelectItemsScreen extends HookWidget {
  final _treeCtrl = TreeController(allNodesExpanded: false);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      Future.microtask(
          () async => await context.read(itemListProvider).fetchRootItems());
    }, []);

    return WillPopScope(
      onWillPop: () async {
        context.read(itemListProvider).clear();
        context.read(selectedItemIdsProvider).clear();
        context.read(sourceConnectionProvider).state = null;
        context.read(targetConnectionProvider).state = null;
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
      title: const Text('Selecionar objetos'),
      actions: [
        ActionButton(
          icon: Icons.download_outlined,
          label: 'Descargar (Migrate Out)',
          onPressed: () => push(context, (_) => MigrateOutScreen()),
        )
      ],
    );
  }

  Widget _buildBody() {
    final context = useContext();
    final itemList = useProvider(itemListProvider.state);

    return Column(
      children: [
        SelectedConnectionsBar(),
        Expanded(
          child: itemList.when(
            data: (_) => SplitView(
              viewMode: SplitViewMode.Vertical,
              initialWeight: 0.6,
              gripColor: Theme.of(context).primaryColor,
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
            error: (error, st) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error descargando la carpeta raiz'),
                SizedBox(height: 20.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Theme.of(context).primaryColor,
                  ),
                  onPressed: () =>
                      context.read(itemListProvider).fetchRootItems(),
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

  Widget _buildTreeView() {
    final rootFolderId = useProvider(rootFolderIdProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: TreeView(
        treeController: _treeCtrl,
        indent: 15.0,
        nodes: _buildTreeChildren(rootFolderId),
      ),
    );
  }

  List<TreeNode> _buildTreeChildren(String? folderId) {
    final items = useProvider(folderItemsFamily(folderId));

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
    final context = useContext();

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
            context.read(itemListProvider).fetchItems(item.id);
          } else {
            context.read(selectedItemIdsProvider).select(item.id);
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
      NodeIcon(item),
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
    final context = useContext();
    final selectedItems = useProvider(selectedItemsProvider);

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DragTarget<ItemInFolder>(
        onWillAccept: (item) => item is ServiceItem || item is PolicyItem,
        onAccept: (item) =>
            context.read(selectedItemIdsProvider).select(item.id),
        builder: (context, accepteds, rejecteds) {
          if (selectedItems.isEmpty)
            return const Text(
              'Arrastra aquí los servicios o politicas a desplegar y luego hacer click en Descargar (Migrate out) para continuar',
            ).center();

          return _buildTable(context);
        },
      ),
    );
  }

  Widget _buildTable(BuildContext context) {
    final selectedItems = context.read(selectedItemsProvider);

    return Table(
      columnWidths: {
        0: FixedColumnWidth(50.0),
        1: FlexColumnWidth(),
        2: FixedColumnWidth(100.0),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        _buildTableHeader(),
        ...selectedItems.map((item) => _buildTableRow(context, item)),
      ],
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
    final selectedItemIdsCtrl = context.read(selectedItemIdsProvider);

    var name = item.name;

    if (item is ServiceItem) {
      name += ' [${item.urlPattern}]';
    }

    return TableRow(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          iconSize: 16.0,
          onPressed: () => selectedItemIdsCtrl.unselect(item.id),
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
