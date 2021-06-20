import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:get/get.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';

class ConnectionsEditPage extends StatelessWidget {
  final _ctrl = Get.put(ConnectionsEditController());
  final _formKey = GlobalKey<FormBuilderState>();

  Connection get _connection {
    final fields = _formKey.currentState!.fields;
    return Connection(
      id: _ctrl.selected.value.id,
      name: fields['name']!.value,
      host: fields['host']!.value,
      username: fields['username']!.value,
      password: fields['password']!.value,
      certificate: fields['certificate']!.value,
    );
  }

  set _connection(Connection value) {
    final formState = _formKey.currentState;

    if (formState == null) return;

    formState.reset();

    if (!value.isEmpty) {
      final fields = formState.fields;

      fields['name']!.didChange(value.name);
      fields['host']!.didChange(value.host);
      fields['username']!.didChange(value.username);
      fields['password']!.didChange(value.password);
      fields['certificate']!.didChange(value.certificate);
    }
  }

  ConnectionsEditPage() {
    ever(_ctrl.selected, (Connection value) => _connection = value);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _ctrl.select(Connection.empty());
        Get.find<ConnectionsSelectionController>().reset();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  void _delete(Connection connection) {
    if (_ctrl.selected.value.id == connection.id) {
      _formKey.currentState!.reset();
    }
    _ctrl.delete(connection);
  }

  void _save() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    _ctrl.save(_connection);
  }

  void _test() async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    _ctrl.test(_connection);
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text('Conexiones'),
      actions: [
        ActionButton(
          icon: CupertinoIcons.plus,
          label: 'Nuevo',
          onPressed: () => _ctrl.select(Connection.empty()),
        ),
        ActionButton(
          icon: Icons.save,
          label: 'Guardar',
          onPressed: () => _save(),
        ),
        ActionButton(
          icon: CupertinoIcons.lab_flask,
          label: 'Probar',
          onPressed: () => _test(),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            color: Colors.white,
            child: Obx(() => _buildList(_ctrl.connections)),
          ),
        ),
        VerticalDivider(),
        Expanded(
          child: Container(
            color: Colors.white,
            child: Column(
              children: [_buildForm(), _buildTestIndicator()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestIndicator() {
    const iconSize = 100.0;
    return Padding(
      padding: const EdgeInsets.all(100.0),
      child: Obx(
        () => _ctrl.testing.value.when(
          waiting: () => SizedBox(
            width: iconSize,
            height: iconSize,
            child: const CircularProgressIndicator(
              strokeWidth: 10.0,
            ),
          ),
          data: (result) => (result ?? false)
              ? const Icon(
                  Icons.check,
                  color: Colors.green,
                  size: iconSize,
                )
              : SizedBox.shrink(),
          error: (error, st) => Column(
            children: [
              const Icon(
                Icons.error,
                color: Colors.red,
                size: iconSize,
              ),
              Text(error.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildList(List<Connection> connections) {
    if (connections.length == 0)
      return Text('No hay conexiones configuradas').center();

    return ListView.separated(
      itemCount: connections.length,
      shrinkWrap: true,
      separatorBuilder: (context, itemCount) => Divider(
        color: Theme.of(context).primaryColor,
      ),
      itemBuilder: (context, index) => _buildTile(
        context,
        connections[index],
      ),
    );
  }

  Widget _buildTile(BuildContext context, Connection connection) {
    return Obx(
      () => ListTile(
        selected: _ctrl.selected.value.id == connection.id,
        leading: Icon(Icons.public).padding(right: 12.0).border(right: 1.0),
        title: Text(connection.toString()),
        trailing: Wrap(
          spacing: 8,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              iconSize: 16.0,
              tooltip: 'Editar',
              onPressed: () => _ctrl.select(connection),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              iconSize: 16.0,
              tooltip: 'Eliminar',
              onPressed: () => _delete(connection),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return FormBuilder(
      key: _formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: "name",
            decoration: InputDecoration(
              labelText: "Nombre",
              prefixIcon: Icon(Icons.text_fields),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.max(Get.context!, 20),
              FormBuilderValidators.required(Get.context!),
            ]),
          ),
          FormBuilderTextField(
            name: "host",
            decoration: InputDecoration(
              labelText: "Gateway Host",
              prefixIcon: Icon(Icons.public),
            ),
            validator: FormBuilderValidators.compose(
                [FormBuilderValidators.required(Get.context!)]),
          ),
          FormBuilderTextField(
            name: 'username',
            decoration: InputDecoration(
              labelText: 'Usuario',
              prefixIcon: Icon(Icons.person),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.max(Get.context!, 20),
            ]),
          ),
          FormBuilderTextField(
            name: 'password',
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: Icon(Icons.lock),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.max(Get.context!, 100),
            ]),
          ),
          FormBuilderFileField(
            name: 'certificate',
            decoration: InputDecoration(
              labelText: 'Certificado',
              prefixIcon: Icon(Icons.vpn_key),
            ),
            filter: {
              'PKCS #12  (*.p12;*.pfx)': '*.p12;*.pfx',
              'All Files': '*.*'
            },
            defaultExtension: 'p12',
            dialogTitle: 'Selecionar certificado asignado al usuario',
            textBuilder: (file) {
              return Text(file != null ? 'Cambiar certificado' : '');
            },
            onChanged: (file) async {
              await prompt<String>(
                title: 'Escribe la contraseña del certificado',
                obscureText: true,
                onConfirm: (password) {
                  _formKey.currentState!.fields['username']!.didChange('');
                  _formKey.currentState!.fields['password']!
                      .didChange(password);
                },
                onCancel: () {
                  _formKey.currentState!.fields['certificate']!.didChange(null);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
