import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:styled_widget/styled_widget.dart';

import 'package:migrator/common/common.dart';
import 'package:migrator/widgets/widgets.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/stores/stores.dart';

class ConnectionsScreen extends StatefulWidget {
  @override
  _ConnectionsScreenState createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text('Conexiones'),
        actions: [
          ActionButton(
            icon: CupertinoIcons.plus,
            label: 'Nuevo',
            onPressed: () => _select(null),
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
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildBodyContent(),
        _buildStatusBar(),
      ],
    );
  }

  Widget _buildBodyContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildList().expanded(),
        _buildForm().expanded(),
      ],
    ).flexible(fit: FlexFit.tight);
  }

  Widget _buildStatusBar() {
    final store = context.store<ConnectionsStore>();
    return StatusBar(
      child: Observer(
        builder: (_) {
          return store.testFuture.when(
            pending: () => Indicator(
              Text('Probando conexión...'),
              color: Colors.green,
              size: 16.0,
            ),
            fulfilled: (ok) => ok
                ? Indicator(
                    Text('Conexión exitosa'),
                    icon: Icons.check,
                    color: Colors.green,
                    size: 16.0,
                  )
                : SizedBox(),
            rejected: (error) => Indicator(
              Text('Error de conexión (click para ve detalle'),
              icon: Icons.error,
              color: Colors.red,
              size: 16.0,
            ).gestures(
              onTap: () => alert(
                context,
                title: Text('Error de conexión'),
                content: Text(error.toString()),
              ),
            ),
          );
        },
      ),
    );
  }

  Connection get _connection {
    final fields = _formKey.currentState!.fields;
    return Connection(
      name: fields['name']!.value,
      host: fields['host']!.value,
      username: fields['username']!.value,
      password: fields['password']!.value,
      certificate: fields['certificate']!.value,
    );
  }

  void _select(Connection? connection) {
    context.store<ConnectionsStore>().select(connection);

    final formState = _formKey.currentState!;

    formState.reset();

    if (connection != null) {
      formState.fields['name']!.didChange(connection.name);
      formState.fields['host']!.didChange(connection.host);
      formState.fields['username']!.didChange(connection.username);
      formState.fields['password']!.didChange(connection.password);
      formState.fields['certificate']!.didChange(connection.certificate);
    }
  }

  void _save() {
    if (!_formKey.currentState!.saveAndValidate()) return;

    context.store<ConnectionsStore>().save(_connection);
  }

  void _test() {
    if (!_formKey.currentState!.saveAndValidate()) return;

    final store = context.store<ConnectionsStore>();

    store.test(_connection);
  }

  Widget _buildList() {
    final store = context.store<ConnectionsStore>();
    return Observer(
      builder: (context) {
        if (store.connections.length == 0) {
          return Text('No hay conexiones configuradas').center();
        }

        return ListView.separated(
          itemCount: store.connections.length,
          shrinkWrap: true,
          separatorBuilder: (_, __) => Divider(
            color: Theme.of(context).primaryColor,
          ),
          itemBuilder: (context, index) => _buildTile(store.connections[index]),
        );
      },
    ).card(elevation: 8);
  }

  Widget _buildTile(Connection connection) {
    final store = context.store<ConnectionsStore>();
    return Observer(
      builder: (_) {
        final selected = store.selected == connection;
        return ListTile(
          selected: selected,
          leading: Icon(Icons.public).padding(right: 12.0).border(right: 1.0),
          title: Text(connection.toString()),
          trailing: Wrap(
            spacing: 8,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                iconSize: 16.0,
                tooltip: 'Editar',
                onPressed: () => _select(connection),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                iconSize: 16.0,
                tooltip: 'Eliminar',
                onPressed: () => store.remove(connection),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildForm() {
    return Card(
      elevation: 8.0,
      child: FormBuilder(
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
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(context),
              ]),
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
                  _formKey.currentState!.fields['password']!
                      .didChange(password);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
