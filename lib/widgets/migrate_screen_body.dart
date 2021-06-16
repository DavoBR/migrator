import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:collection/collection.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/controllers/controllers.dart';

import 'action_mapping_cell.dart';
import 'cluster_property_cell.dart';

class MigrateScreenBody extends StatelessWidget {
  final _itemsCtrl = Get.find<ItemsSelectionController>();
  final _migrateOutCtrl = Get.find<MigrateOutController>();

  final void Function(List<Widget> cells)? headersHook;
  final void Function(List<Widget> cells, ItemWithId item)? rowsHook;
  final bool mappingActionEditable;
  final bool cwpEditable;
  final Rx<BundleMappingsItem>? mappingResult;

  MigrateScreenBody({
    this.mappingActionEditable = false,
    this.cwpEditable = false,
    this.headersHook,
    this.rowsHook,
    this.mappingResult,
  });

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

  Widget _buildConflictsCount(bool Function(ItemMapping) test) {
    if (mappingResult == null) return SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Obx(
        () {
          final conflictsCount = mappingResult!.value.mappings
              .where((m) => m.rawErrorType.isNotEmpty && test(m))
              .length;

          if (conflictsCount == 0) return SizedBox.shrink();

          return Text(
            '$conflictsCount conflicto${conflictsCount > 1 ? 's' : ''}',
            style: TextStyle(
              color: conflictsCount == 0 ? Colors.green : Colors.red,
              fontStyle: FontStyle.italic,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabBar() {
    return TabBar(
      labelPadding: const EdgeInsets.all(10.0),
      labelColor: Get.theme.primaryColor,
      labelStyle: TextStyle(fontWeight: FontWeight.bold),
      tabs: [
        Row(children: [
          Text('Servicios y Politicas'),
          _buildConflictsCount(
            (m) => m.type == ItemType.service || m.type == ItemType.policy,
          )
        ]),
        Row(children: [
          Text('Propiedades'),
          _buildConflictsCount((m) => (m.type == ItemType.clusterProperty))
        ]),
        Row(children: [
          Text('Dependencias'),
          _buildConflictsCount(
            (m) =>
                m.type != ItemType.service &&
                m.type != ItemType.policy &&
                m.type != ItemType.clusterProperty &&
                m.rawErrorType.isNotEmpty,
          ),
        ]),
      ],
    );
  }

  Widget _buildTabsPanel() {
    return TabBarView(
      children: [
        Obx(() => _buildTable(_migrateOutCtrl.selectedItemsMapping)),
        Obx(
          () => _buildTable(
            _migrateOutCtrl.dependenciesMapping
                .where((m) => m.type == ItemType.clusterProperty),
          ),
        ),
        Obx(
          () => _buildTable(
            _migrateOutCtrl.dependenciesMapping
                .where((m) => m.type != ItemType.clusterProperty),
          ),
        ),
      ],
    ).padding(horizontal: 10.0, vertical: 5.0).expanded();
  }

  Widget _buildTable(Iterable<ItemMapping> mappings) {
    final mappingsList =
        mappings.where((m) => m.srcId.isNotEmpty).sortedBy((m) => m.rawType);
    final onlyCwp =
        !mappingsList.any((m) => m.type != ItemType.clusterProperty);
    final header = _buildTableHeader(onlyCwp);

    return SingleChildScrollView(
      child: Table(
        columnWidths: {
          0: FlexColumnWidth(),
          1: FixedColumnWidth(onlyCwp ? 500.0 : 250.0),
          2: FixedColumnWidth(200.0),
          3: FixedColumnWidth(200.0),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [header, ...mappingsList.map(_buildTableRow)],
      ),
    );
  }

  TableRow _buildTableHeader(bool isForCwp) {
    final style = TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold);
    final List<Widget> cells = [
      Text('Nombre', style: style),
      Text(isForCwp ? 'Valor' : 'Tipo', style: style),
      Text('Acción', style: style),
    ];

    if (headersHook != null) headersHook!(cells);

    return TableRow(children: cells);
  }

  TableRow _buildTableRow(ItemMapping mapping) {
    final where = (ItemWithId item) =>
        item.type == mapping.type && item.id == mapping.srcId;
    final item = _migrateOutCtrl.bundle.value.items.firstWhere(
      where,
      orElse: () => _itemsCtrl.items.firstWhere(where),
    );

    final cells = [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildItemNameText(item), _buildItemIdText(item)],
      ),
      mapping.type == ItemType.clusterProperty
          ? ClusterPropertyCell(item as ClusterPropertyItem, cwpEditable)
          : Text(mapping.rawType),
      ActionMappingCell(item, this.mappingActionEditable)
    ];

    if (rowsHook != null) rowsHook!(cells, item);

    return TableRow(children: [...cells]);
  }

  Widget _buildItemNameText(Item item) {
    var name = item.name;

    if (item is ServiceItem) {
      name += ' [${item.urlPattern}]';
    }

    return Text(name);
  }

  Widget _buildItemIdText(ItemWithId item) {
    return Text('ID: ${item.id}')
        .italic()
        .textColor(Colors.grey)
        .fontSize(10.0);
  }
}
