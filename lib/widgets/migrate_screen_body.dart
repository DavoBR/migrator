import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:collection/collection.dart';

import 'package:migrator/common/common.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/stores/stores.dart';

class MigrateScreenBody extends StatefulWidget {
  MigrateScreenBody({
    required this.statusBar,
    this.mappingActionEditable = false,
    this.headersHook,
    this.rowsHook,
    this.cwpSuffixIconBuilder,
  });

  final Widget statusBar;
  final Function(List<String> labels)? headersHook;
  final Function(List<Widget> cells, ItemWithId? item)? rowsHook;
  final bool mappingActionEditable;
  final Widget Function(
    ClusterPropertyItem cwp,
    String value,
    bool isOverflow,
  )? cwpSuffixIconBuilder;

  @override
  _MigrateScreenBodyState createState() => _MigrateScreenBodyState();
}

class _MigrateScreenBodyState extends State<MigrateScreenBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBodyContent(),
        widget.statusBar,
      ],
    );
  }

  Widget _buildBodyContent() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildTabBar(),
          _buildInfoBar(),
          _buildTabsPanel(),
        ],
      ),
    ).card(elevation: 8.0).flexible(fit: FlexFit.tight);
  }

  Widget _buildTabBar() {
    return TabBar(
      labelPadding: const EdgeInsets.all(10.0),
      labelColor: Theme.of(context).backgroundColor,
      tabs: [
        Text('Servicios y Politicas'),
        Text('Propiedades'),
        Text('Dependencias'),
      ],
    );
  }

  Widget _buildInfoBar() {
    final store = context.store<MigrateStore>();
    return Container(
      padding: EdgeInsets.all(10.0),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Observer(builder: (_) => Text(store.sourceConnection.toString())),
          const SizedBox(width: 5.0),
          const Icon(Icons.arrow_forward, color: Colors.green),
          const SizedBox(width: 5.0),
          Observer(builder: (_) => Text(store.targetConnection.toString())),
        ],
      ),
    );
  }

  Widget _buildTabsPanel() {
    final store = context.store<MigrateStore>();
    return TabBarView(
      children: [
        Observer(
          builder: (_) => _buildTable(
            context,
            mappings: store.mappingOfSelectedItems,
          ),
        ),
        Observer(
          builder: (_) => _buildTable(
            context,
            mappings: store.mappingOfDependencyItems,
            only: ItemType.clusterProperty,
          ),
        ),
        Observer(
          builder: (_) => _buildTable(
            context,
            mappings: store.mappingOfDependencyItems,
            ignore: ItemType.clusterProperty,
          ),
        ),
      ],
    ).padding(horizontal: 10.0, vertical: 5.0).expanded();
  }

  Widget _buildTable(
    BuildContext context, {
    required List<ItemMapping> mappings,
    ItemType? only,
    ItemType? ignore,
  }) {
    final isForCwp = only == ItemType.clusterProperty;
    final header = _buildTableHeader(isForCwp);

    var mappings2 = mappings.where((m) => m.srcId != null);

    if (only != null) {
      mappings2 = mappings2.where((m) => m.type == only);
    } else if (ignore != null) {
      mappings2 = mappings2.where((m) => m.type != ignore);
    }

    final mappings3 = mappings2.toList();
    mappings3.sort((a, b) => a.rawType.compareTo(b.rawType));
    final rows = mappings3.map((m) => _buildTableRow(context, m)).toList();

    return SingleChildScrollView(
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(),
          1: FixedColumnWidth(isForCwp ? 500.0 : 250.0),
          2: FixedColumnWidth(200.0),
          3: FixedColumnWidth(200.0),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [header, ...rows],
      ),
    );
  }

  TableRow _buildTableHeader(bool isForCwp) {
    final labels = ['Nombre', (isForCwp ? 'Valor' : 'Tipo'), 'Acción'];
    if (widget.headersHook != null) {
      widget.headersHook!(labels);
    }
    final headers = labels
        .map((text) => Text(text).fontSize(16.0).fontWeight(FontWeight.bold));

    return TableRow(children: [...headers]);
  }

  TableRow _buildTableRow(BuildContext context, ItemMapping mapping) {
    final store = context.store<MigrateStore>();
    var item = store.bundle?.items
        .firstWhereOrNull((item) => item.id == mapping.srcId);

    if (item == null && mapping.type == ItemType.folder) {
      item = store.folders
          .firstWhereOrNull((folder) => folder.id == mapping.srcId);
    }

    List<Widget> cells;

    if (item == null) {
      print(
        'Item is not present in the bundle [id: ${mapping.srcId} type: ${mapping.rawType}]',
      );

      cells = [Text('---'), Text('---'), Text('---')];
    } else {
      cells = [
        _buildItemNameCell(item),
        item is ClusterPropertyItem
            ? _buildClusterPropertyCell(item)
            : _buildItemTypeCell(mapping),
        _buildActionMappingCell(item)
      ];
    }

    if (widget.rowsHook != null) {
      widget.rowsHook!(cells, item);
    }

    return TableRow(children: [...cells]);
  }

  Widget _buildItemNameCell(ItemWithId item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildItemNameText(item), _buildItemIdText(item)],
    );
  }

  Widget _buildItemTypeCell(ItemMapping mapping) {
    return Text(mapping.rawType);
  }

  Widget _buildItemNameText(Item item) {
    var name = item.name;

    if (item is ServiceItem) name += ' [${item.urlPattern}]';

    return Text(name);
  }

  Widget _buildItemIdText(ItemWithId item) {
    return Text(
      'ID: ${item.id}',
      style: TextStyle(
        fontSize: 10.0,
        fontStyle: FontStyle.italic,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildClusterPropertyCell(ClusterPropertyItem cwp) {
    final store = context.store<MigrateStore>();
    return Observer(builder: (_) {
      final value = store.clusterProperties.get(
        cwp.id,
        orElse: () => cwp.value,
      )!;
      final maxLength = 45;
      final isOverflow = value.length > maxLength;
      return Row(
        children: [
          Text(isOverflow ? value.substring(0, maxLength) + '...' : value),
          SizedBox(width: 5.0),
          widget.cwpSuffixIconBuilder != null
              ? widget.cwpSuffixIconBuilder!(cwp, value, isOverflow)
              : SizedBox()
        ],
      );
    });
  }

  Widget _buildActionMappingCell(ItemWithId? item) {
    if (item == null) return Text('Unknown');

    final store = context.store<MigrateStore>();
    final customMapping = store.mappings.get(
      item.id,
      orElse: () => MappingConfig(action: MappingAction.unknown),
    )!;
    final mappingAction = customMapping.action;
    if (widget.mappingActionEditable) {
      return DropdownButton<MappingAction>(
        value: mappingAction,
        underline: SizedBox(),
        onChanged: (action) {
          if (action != null) store.setMappingAction(item, action);
        },
        items: MappingAction.values
            .map(
              (value) => DropdownMenuItem(
                value: value,
                child: Text(value.toString().split('.')[1].toPascalCase()),
              ),
            )
            .toList(),
      ).sizedBox(height: 30.0);
    } else {
      return Text(mappingAction.toString().split('.')[1].toPascalCase());
    }
  }
}
