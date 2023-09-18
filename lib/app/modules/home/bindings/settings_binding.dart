import 'package:get/get.dart';
import 'package:video_downloader/app/modules/home/controllers/settings_controller.dart';



class SettingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(),
    );
  }
}
