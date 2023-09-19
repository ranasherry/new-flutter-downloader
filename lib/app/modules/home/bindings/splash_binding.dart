import 'package:get/get.dart';

import 'package:video_downloader/app/modules/home/controllers/splash_ctl.dart';

import '../controllers/home_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(),
    );
    //   Get.lazyPut<GoogleAdsCTL>(
    //   () => GoogleAdsCTL(),
    // );
    // // Get.put(AppLovin_CTL());
  }
}
