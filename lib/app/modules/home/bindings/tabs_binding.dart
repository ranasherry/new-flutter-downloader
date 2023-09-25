import 'package:get/get.dart';
import 'package:video_downloader/app/modules/home/controllers/download_progress_ctl.dart';
import 'package:video_downloader/app/modules/home/controllers/downloaded_controller.dart';
import 'package:video_downloader/app/modules/home/controllers/home_controller.dart';
import 'package:video_downloader/app/modules/home/controllers/tabs_controller.dart';
import 'package:video_downloader/app/modules/whatsapp_features/controllers/whatsapp_features_controller.dart';

class TabsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TabsController>(
      () => TabsController(),
    );
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.lazyPut<DownloadProgressCTL>(
      () => DownloadProgressCTL(),
    );
    Get.lazyPut<DownloadedCTL>(
      () => DownloadedCTL(),
    );
    // Get.lazyPut<WhatsappFeaturesController>(
    //   () => WhatsappFeaturesController(),
    // );
  }
}
