import 'package:get/get.dart';
import 'package:migrator/models/git_release_model.dart';
import 'package:migrator/utils/constants.dart';

class GitHubProvider extends GetConnect {
  Future<GitReleaseModel> getLatestRelease() async {
    final res = await get(REPOSITORY_URL);

    if (res.hasError) {
      return Future.error(res.statusText ??
          'Ha ocurrido un error descargando información del la ultima versión');
    }

    return GitReleaseModel.fromMap(res.body!);
  }
}
