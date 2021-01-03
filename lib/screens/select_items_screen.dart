import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:split_view/split_view.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:mobx/mobx.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:migrator/common/common.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/stores/stores.dart';

import 'migrate_out_screen.dart';

class SelectItemsScreen extends StatefulWidget {
  SelectItemsScreen();

  @override
  _SelectItemsScreenState createState() => _SelectItemsScreenState();
}

class _SelectItemsScreenState extends State<SelectItemsScreen> {
  final _treeCtrl = TreeController(allNodesExpanded: false);

  ObservableFuture<List<Item>> itemsFuture;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 1)).then((_) => _loadInitialItems());
  }

  void _loadInitialItems() {
    final store = context.store<ItemsStore>();

    store.items.clear();
    store.selectedIds.clear();

    // descargar la primera carpeta
    var future = store.loadItems('');

    future = future.then((items) async {
      // descargar contenido de la primera carpeta
      final items2 = await store.loadItems(items.first.id);
      _treeCtrl.expandAll();
      return [...items, ...items2];
    });

    setState(() {
      itemsFuture = ObservableFuture(future);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.store<ItemsStore>();
    return WillPopScope(
      onWillPop: () async {
        store.clear();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: const Text('Selecionar objectos'),
          actions: [
            ActionButton(
              icon: Icons.download_outlined,
              label: 'Descargar (Migrate Out)',
              onPressed: () => push(context, (_) => MigrateOutScreen()),
            )
          ],
        ),
        body: Column(
          children: [
            _buildBodyContent(),
            _buildStatusBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    return SplitView(
      viewMode: SplitViewMode.Horizontal,
      initialWeight: 0.3,
      gripColor: Theme.of(context).backgroundColor,
      gripSize: 8.0,
      view1: _buildTreeView().padding(all: 8.0),
      view2: _buildRightPanel().padding(all: 8.0),
    ).card(elevation: 8.0).flexible(fit: FlexFit.tight);
  }

  Widget _buildStatusBar() {
    return StatusBar(
      child: FutureBuilder(
        future: itemsFuture,
        builder: (context, snaphost) {
          return snaphost.when(
            none: () => Indicator(
              Text('Espere...'),
              color: Colors.green,
              size: 16.0,
            ),
            waiting: () => Indicator(
              Text('Descargando objetos...'),
              color: Colors.green,
              size: 16.0,
            ),
            data: (_) => Observer(builder: (_) {
              final store = context.store<ItemsStore>();
              if (store.selectedIds.isEmpty) {
                return Indicator(
                  Text(
                    'Selecionar objetos a migrar',
                  ),
                  color: Colors.blue,
                  size: 16.0,
                  icon: Icons.info,
                );
              } else {
                return Indicator(
                  Text(
                    'Proceder con la descarga del bundle',
                  ),
                  color: Colors.blue,
                  size: 16.0,
                  icon: Icons.info,
                );
              }
            }),
            error: (error) => Indicator(
              Text('Error descargando el bundle'),
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
        },
      ),
    );
  }

  Widget _buildTreeView() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Observer(builder: (_) {
          return TreeView(
            treeController: _treeCtrl,
            indent: 15.0,
            nodes: _buildTreeChildren(null),
          );
        }),
      ),
    );
  }

  List<TreeNode> _buildTreeChildren(String folderId) {
    final store = context.store<ItemsStore>();
    final items = store.items
        .where((item) => item.folderId == folderId)
        .map((item) => _buildTreeNode(item))
        .toList();

    return items;
  }

  String _buildTooltipText(Item item) {
    if (item is ServiceItem) {
      return '${item.name} [${item.urlPattern}]';
    }

    return item.name;
  }

  TreeNode _buildTreeNode(ItemInFolder item) {
    final store = context.store<ItemsStore>();
    final key = Key(item.id);
    return TreeNode(
      key: key,
      content: GestureDetector(
        child: Tooltip(
          message: _buildTooltipText(item),
          child: _buildNodeContent(item),
        ),
        onDoubleTap: () {
          if (item is FolderItem) {
            if (store.folderLoadState.get(item.id, orElse: () => false)) {
              return;
            }

            final future = store.loadItems(item.id);
            _treeCtrl.expandNode(key);

            setState(() {
              itemsFuture = ObservableFuture(future);
            });
          } else {
            store.select(item);
          }
        },
      ),
      children: item is FolderItem ? _buildTreeChildren(item.id) : [],
    );
  }

  Widget _buildNodeIcon(ItemInFolder item) {
    Color color;
    IconData icon;
    double size = 18.0;

    switch (item.type) {
      case ItemType.folder:
        icon = Icons.folder;
        color = Colors.green;

        final store = context.store<ItemsStore>();
        if (store.folderLoadState.get(item.id, orElse: () => false)) {
          return SpinKitCircle(color: color, size: size).sizedBox(height: size);
        }
        break;
      case ItemType.service:
        final service = item as ServiceItem;
        icon = Icons.insert_drive_file;
        color = service.isEnabled ? Colors.blue : Colors.red;
        break;
      case ItemType.policy:
        final policy = item as PolicyItem;
        icon = Icons.insert_drive_file_outlined;
        switch (policy.policyType) {
          case PolicyType.internal:
            color = Colors.orange;
            break;
          case PolicyType.serviceOperation:
            color = Colors.deepOrange;
            break;
          default:
            color = Colors.lightBlue;
        }
        break;
      default:
        icon = Icons.check_box_outline_blank;
    }

    return Icon(
      icon,
      color: color,
      size: size,
    );
  }

  Widget _buildNodeContent(ItemInFolder item) {
    String text = item.name;
    TextStyle textStyle;

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
      _buildNodeIcon(item),
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

  Widget _buildRightPanel() {
    final store = context.store<ItemsStore>();
    return Observer(builder: (_) {
      if (store.items.isEmpty) {
        if (store.folderLoadState.isEmpty) {
          return Indicator(
            Text('Esperar...'),
            alignment: MainAxisAlignment.center,
          );
        }

        if (store.folderLoadState.containsValue(true)) {
          return Indicator(
            Text(
              'Descargando carpetas, servicios y politicas...',
            ),
            alignment: MainAxisAlignment.center,
          );
        }
      }

      return _buildDropZone();
    });
  }

  Widget _buildDropZone() {
    final store = context.store<ItemsStore>();

    return DragTarget<ItemInFolder>(
      onWillAccept: (item) => item is ServiceItem || item is PolicyItem,
      onAccept: (item) => store.select(item),
      builder: (context, accepteds, rejecteds) {
        if (store.selectedIds.isEmpty) {
          return const Text(
            'Arrastra aquí los servicios o politicas a desplegar',
          ).center();
        }

        return _buildTable();
      },
    );
  }

  Widget _buildTable() {
    final store = context.store<ItemsStore>();

    return Observer(builder: (_) {
      return Align(
        alignment: Alignment.topRight,
        child: Table(
          columnWidths: {
            0: FixedColumnWidth(50.0),
            1: FlexColumnWidth(),
            2: FixedColumnWidth(100.0),
            3: FixedColumnWidth(250.0),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            _buildTableHeader(),
            ...store.selectedItems.map(_buildTableRow),
          ],
        ),
      );
    });
  }

  Widget _buildHeaderText(String text) {
    return Text(text).fontWeight(FontWeight.bold);
  }

  TableRow _buildTableHeader() {
    return TableRow(
      children: [
        Container(),
        _buildHeaderText('Nombre'),
        _buildHeaderText('Tipo'),
        _buildHeaderText('Id'),
      ],
    );
  }

  TableRow _buildTableRow(ItemInFolder item) {
    final store = context.store<ItemsStore>();

    var name = item.name;

    if (item is ServiceItem) {
      name += ' [${item.urlPattern}]';
    }

    return TableRow(
      children: [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.red),
          iconSize: 16.0,
          onPressed: () => store.deselect(item),
        ),
        Text(name),
        Text(item.rawType),
        Text(item.id),
      ],
    );
  }
}
