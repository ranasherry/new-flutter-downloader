import 'package:get/get.dart';
import 'package:video_downloader/app/modules/home/controllers/google_ad_ctl.dart';

class TabsController extends GetxController {
  //TODO: Implement HomeController

  var tabIndex = 0.obs;
//  AppLovin_CTL appLovin_CTL=Get.find();
  GoogleAdsCTL googleAdsCTL = Get.find();
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
