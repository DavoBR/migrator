import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:migrator/utils/utils.dart';

import 'select_connections_screen.dart';

class CheckVersionScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: FutureBuilder<String?>(
            future: http('GET', REPOSITORY_URL).then((res) async {
              final result = await res.transform(utf8.decoder).join();

              if (res.statusCode != 200)
                throw Exception('[GIT][STATUS: ${res.statusCode}]: $result');

              return result;
            }),
            builder: (_, snapshot) {
              return snapshot.when(
                  waiting: () => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Verificando versión...'),
                          SizedBox(height: 20.0),
                          LinearProgressIndicator(),
                        ],
                      ),
                  data: (json) {
                    if (json == null) return _next(context);

                    dynamic release;

                    try {
                      release = jsonDecode(json.toString());
                    } catch (error) {
                      print(error);
                      return _next(context);
                    }

                    final tagName = release['tag_name'];
                    final name = release['name'];
                    final htmlUrl = release['html_url'].toString();
                    final body = release['body'];

                    if (tagName == APP_VERSION) return _next(context);

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Nueva versión disponible'),
                        SizedBox(height: 20.0),
                        Text(name),
                        SizedBox(height: 10.0),
                        Text(body),
                        SizedBox(height: 10.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                              ),
                              onPressed: () async {
                                if (await canLaunch(htmlUrl)) {
                                  launch(htmlUrl);
                                } else {
                                  alert(
                                    context,
                                    title: Text(
                                        'No se pudo abrir la pagina de descargar'),
                                    content: Column(
                                      children: [
                                        Text(
                                            'Usar el siguiente enlace en su navegador para descargar la nueva versión'),
                                        SizedBox(height: 10.0),
                                        Text(htmlUrl),
                                      ],
                                    ),
                                  );
                                }
                              },
                              child: Text('Click para descargar'),
                            ),
                            SizedBox(width: 10.0),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Theme.of(context).primaryColor,
                              ),
                              onPressed: () => _next(context),
                              child: Text('Continuar con esta versión'),
                            ),
                          ],
                        )
                      ],
                    );
                  },
                  error: (error) => _next(context, error: error));
            },
          ),
        ),
      ),
    );
  }

  Widget _next(BuildContext context, {dynamic? error}) {
    if (error != null) print(error);

    Future.microtask(() => navigate(
          context,
          (_) => SelectConnectionsScreen(),
          replace: true,
        ));

    return SizedBox.shrink();
  }
}
