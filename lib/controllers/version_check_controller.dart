import 'package:get/get.dart';
import 'package:migrator/models/models.dart';
import 'package:migrator/pages/pages.dart';
import 'package:migrator/providers/providers.dart';
import 'package:migrator/utils/utils.dart';

class VersionCheckController extends GetxController {
  final _github = Get.put(GitHubProvider());

  final release = GitReleaseModel.empty().obs;

  @override
  void onInit() {
    _fetchLastReleaseInfo();
    super.onInit();
  }

  void _fetchLastReleaseInfo() async {
    try {
      final release = await _github.getLatestRelease();
      if (release.tagName != APP_VERSION) {
        this.release.value = release;
      } else {
        nextPage();
      }
    } catch (error, st) {
      logError(error, message: 'Error verificando versión', stackTrace: st);
      nextPage();
    }
  }

  void nextPage() {
    Get.off(() => ConnectionsSelectionPage());
  }
}
