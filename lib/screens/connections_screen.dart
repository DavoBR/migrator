import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/models/models.dart';
import 'package:migrator/providers/providers.dart';
import 'package:migrator/utils/utils.dart';
import 'package:migrator/widgets/widgets.dart';

class ConnectionsScreen extends HookWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  Connection _getConnectionFromForm() {
    final fields = _formKey.currentState!.fields;
    return Connection(
      id: '',
      name: fields['name']!.value,
      host: fields['host']!.value,
      username: fields['username']!.value,
      password: fields['password']!.value,
      certificate: fields['certificate']!.value,
    );
  }

  void _select(BuildContext context, Connection? connection) {
    context.read(selectedConnectionProvider).state = connection;
  }

  void _save(BuildContext context) async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final listCtrl = context.read(connectionListProvider);
    final selected = context.read(selectedConnectionProvider).state;
    final connection = _getConnectionFromForm();

    if (selected == null) {
      await listCtrl.add(_getConnectionFromForm());
    } else {
      connection.id = selected.id;
      await listCtrl.update(_getConnectionFromForm());
    }
  }

  void _test(BuildContext context) async {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final testCtrl = context.read(connectionTestProvider);
    final connection = _getConnectionFromForm();

    await testCtrl.test(connection);
  }

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

    return AppBar(
      title: Text('Conexiones'),
      actions: [
        ActionButton(
          icon: CupertinoIcons.plus,
          label: 'Nuevo',
          onPressed: () => _select(context, null),
        ),
        const SizedBox(width: 5.0),
        ActionButton(
          icon: Icons.save,
          label: 'Guardar',
          onPressed: () => _save(context),
        ),
        const SizedBox(width: 5.0),
        ActionButton(
          icon: CupertinoIcons.lab_flask,
          label: 'Probar',
          onPressed: () => _test(context),
        ),
        const SizedBox(width: 5.0),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: Container(color: Colors.white, child: _buildList())),
        VerticalDivider(),
        Expanded(child: Container(color: Colors.white, child: _buildForm())),
      ],
    );
  }

  Widget _buildList() {
    final connectionListState = useProvider(connectionListProvider.state);
    final connectionListCtrl = useProvider(connectionListProvider);

    useEffect(() {
      Future.microtask(() => connectionListCtrl.fetch());
    }, []);

    return connectionListState.when(
      data: (connections) {
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
      },
      loading: () => Text('Cargando...').center(),
      error: (e, st) =>
          Text('Ha ocurrido un error cargando las conexiones').center(),
    );
  }

  Widget _buildTile(BuildContext context, Connection connection) {
    final connectionList = context.read(connectionListProvider);
    final selected = context.read(selectedConnectionProvider).state;

    return ListTile(
      selected: selected?.id == connection.id,
      leading: Icon(Icons.public).padding(right: 12.0).border(right: 1.0),
      title: Text(connection.toString()),
      trailing: Wrap(
        spacing: 8,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            iconSize: 16.0,
            tooltip: 'Editar',
            onPressed: () => _select(context, connection),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            iconSize: 16.0,
            tooltip: 'Eliminar',
            onPressed: () => connectionList.delete(connection),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    final context = useContext();
    final selected = useProvider(selectedConnectionProvider).state;

    useEffect(() {
      if (_formKey.currentState != null) {
        if (selected != null) {
          final fields = _formKey.currentState!.fields;

          fields['name']!.didChange(selected.name);
          fields['host']!.didChange(selected.host);
          fields['username']!.didChange(selected.username);
          fields['password']!.didChange(selected.password);
          fields['certificate']!.didChange(selected.certificate);
        } else {
          _formKey.currentState!.reset();
        }
      }
    }, [selected]);

    return FormBuilder(
      key: _formKey,
      initialValue: {
        'name': selected?.name,
        'host': selected?.host,
        'username': selected?.username,
        'password': selected?.password,
        'certificate': selected?.certificate,
      },
      child: Column(
        children: [
          FormBuilderTextField(
            name: "name",
            decoration: InputDecoration(
              labelText: "Nombre",
              prefixIcon: Icon(Icons.text_fields),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.max(context, 20),
              FormBuilderValidators.required(context),
            ]),
          ),
          FormBuilderTextField(
            name: "host",
            decoration: InputDecoration(
              labelText: "Gateway Host",
              prefixIcon: Icon(Icons.public),
            ),
            validator: FormBuilderValidators.compose(
                [FormBuilderValidators.required(context)]),
          ),
          FormBuilderTextField(
            name: 'username',
            decoration: InputDecoration(
              labelText: 'Usuario',
              prefixIcon: Icon(Icons.person),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.max(context, 20),
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
              FormBuilderValidators.max(context, 100),
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
              final password = await prompt<String>(
                context,
                title: Text('Escribe la contraseña del certificado'),
                obscureText: true,
                textOK: Text('Aceptar'),
                textCancel: Text('Cancelar'),
              );

              if (password == null) {
                _formKey.currentState!.fields['certificate']!.didChange(null);
              } else {
                _formKey.currentState!.fields['username']!.didChange('');
                _formKey.currentState!.fields['password']!.didChange(password);
              }
            },
          ),
        ],
      ),
    );
  }
}
