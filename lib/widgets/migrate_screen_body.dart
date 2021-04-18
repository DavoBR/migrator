import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:tuple/tuple.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';

import 'action_mapping_cell.dart';
import 'cluster_property_cell.dart';

class MigrateScreenBody extends HookWidget {
  MigrateScreenBody({
    this.mappingActionEditable = false,
    this.cwpEditable = false,
    this.headersHook,
    this.rowsHook,
  });

  final Function(List<String> labels)? headersHook;
  final Function(List<Widget> cells, ItemWithId? item)? rowsHook;
  final bool mappingActionEditable;
  final bool cwpEditable;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _buildTabBar(),
          _buildTabsPanel(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final context = useContext();
    return TabBar(
      labelPadding: const EdgeInsets.all(10.0),
      labelColor: Theme.of(context).primaryColor,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      tabs: [
        Text('Servicios y Politicas'),
        Text('Propiedades'),
        Text('Dependencias'),
      ],
    );
  }

  Widget _buildTabsPanel() {
    final selectedItemsMappings = useProvider(itemMappingsFamily(true));
    final dependenciesMappings = useProvider(itemMappingsFamily(false));
    return TabBarView(
      children: [
        _buildTable(selectedItemsMappings),
        _buildTable(
          dependenciesMappings,
          only: ItemType.clusterProperty,
        ),
        _buildTable(
          dependenciesMappings,
          ignore: ItemType.clusterProperty,
        ),
      ],
    ).padding(horizontal: 10.0, vertical: 5.0).expanded();
  }

  Widget _buildTable(
    List<ItemMapping> mappings, {
    ItemType? only,
    ItemType? ignore,
  }) {
    final isForCwp = only == ItemType.clusterProperty;
    final header = _buildTableHeader(isForCwp);

    var mappings2 = mappings.where((m) => m.srcId.isNotEmpty);

    if (only != null) {
      mappings2 = mappings2.where((m) => m.type == only);
    } else if (ignore != null) {
      mappings2 = mappings2.where((m) => m.type != ignore);
    }

    final mappings3 = mappings2.toList();
    mappings3.sort((a, b) => a.rawType.compareTo(b.rawType));
    final rows = mappings3.map(_buildTableRow).toList();

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
    if (headersHook != null) headersHook!(labels);
    final headers = labels
        .map((text) => Text(text).fontSize(16.0).fontWeight(FontWeight.bold));

    return TableRow(children: [...headers]);
  }

  TableRow _buildTableRow(ItemMapping mapping) {
    final asyncItem =
        useProvider(migrateOutItemFamily(Tuple2(mapping.srcId, mapping.type)));

    final cells = asyncItem.when(
      data: (item) => [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildItemNameText(item), _buildItemIdText(item)],
        ),
        mapping.type == ItemType.clusterProperty
            ? ClusterPropertyCell(item as ClusterPropertyItem, cwpEditable)
            : Text(mapping.rawType),
        ActionMappingCell(item, this.mappingActionEditable)
      ],
      loading: () => [
        Text('...'),
        Text('...'),
        Text('...'),
      ],
      error: (error, st) {
        print(error);
        return [
          Text('<Error>'),
          Text('<Error>'),
          Text('<Error>'),
        ];
      },
    );

    if (rowsHook != null) rowsHook!(cells, asyncItem.data?.value);

    return TableRow(children: [...cells]);
  }

  Widget _buildItemNameText(Item? item) {
    var name = item?.name ?? 'Unknown';

    if (item is ServiceItem) {
      name += ' [${item.urlPattern}]';
    }

    return Text(name);
  }

  Widget _buildItemIdText(ItemWithId? item) {
    return Text('ID: ${item?.id ?? ''}')
        .italic()
        .textColor(Colors.grey)
        .fontSize(10.0);
  }
}
