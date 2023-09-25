import 'package:get/get.dart';
import 'package:video_downloader/app/modules/home/controllers/home_controller.dart';

class SocialIconsViewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    //   Get.lazyPut<GoogleAdsCTL>(
    //   () => GoogleAdsCTL(),
    // );
    // // Get.put(AppLovin_CTL());
  }
}
