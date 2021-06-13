import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:migrator/models/git_release_model.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:migrator/utils/utils.dart';
import 'package:migrator/controllers/controllers.dart';
import 'package:migrator/utils/constants.dart';

class VersionCheckPage extends StatelessWidget {
  final _ctrl = Get.put(VersionCheckController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: _ctrl.release.stream.when(
            data: (release) => _buildSuccess(release!),
            waiting: () => _buildLoading(),
            error: (error, st) => _buildLoading(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Verificando versión...'),
        SizedBox(height: 20.0),
        LinearProgressIndicator(),
      ],
    );
  }

  Widget _buildSuccess(GitReleaseModel release) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Nueva versión disponible'),
        SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(APP_VERSION),
            const SizedBox(width: 5.0),
            const Icon(
              Icons.arrow_forward,
              color: Colors.green,
            ),
            const SizedBox(width: 5.0),
            Text(release.name)
          ],
        ),
        SizedBox(height: 10.0),
        Text(release.body),
        SizedBox(height: 10.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Get.theme.primaryColor,
              ),
              onPressed: () async {
                if (await canLaunch(release.htmlUrl)) {
                  launch(release.htmlUrl);
                } else {
                  alert(
                    title: 'No se pudo abrir la pagina de descargar',
                    content: Column(
                      children: [
                        Text(
                          'Usar el siguiente enlace en su navegador para descargar la nueva versión',
                        ),
                        SizedBox(height: 10.0),
                        Text(release.htmlUrl),
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
                primary: Get.theme.primaryColor,
              ),
              onPressed: () => _ctrl.nextPage(),
              child: Text('Continuar con esta versión'),
            ),
          ],
        )
      ],
    );
  }
}
