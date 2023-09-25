import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get/get.dart';
import 'package:video_downloader/app/provider/admob_ads_provider.dart';
import 'package:video_downloader/app/utils/app_strings.dart';

class TabsController extends GetxController {
  //TODO: Implement HomeController

  var tabIndex = 0.obs;
//  AppLovin_CTL appLovin_CTL=Get.find();
  // GoogleAdsCTL googleAdsCTL = Get.find();

  final remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void onInit() async {
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(minutes: 5),
    ));

    await remoteConfig.setDefaults(const {
      "isAdEnable": false,
      "native_ad": "",
      "banner_ad": "",
      "inter_ad": "",
      "appopen_ad": "",
      "app_id": ""
    });

    remoteConfig.onConfigUpdated.listen((event) async {
      await remoteConfig.activate();

      // Use the new config values here.
    });

    await remoteConfig.fetchAndActivate().then((value) {
      bool isAdEnable = remoteConfig.getBool("isAdEnable");
      AdMobAdsProvider.instance.isAdEnable.value = isAdEnable;

      AppStrings.ADMOB_APP_OPEN = remoteConfig.getString("appopen_ad");
      AppStrings.ADMOB_NATIVE = remoteConfig.getString("native_ad");
      AppStrings.ADMOB_INTERSTITIAL = remoteConfig.getString("inter_ad");
      AppStrings.ADMOB_BANNER = remoteConfig.getString("banner_ad");

      if (isAdEnable) {
        AdMobAdsProvider.instance.initialize();
      }

      print("Remote Ads: ${AppStrings.ADMOB_APP_OPEN}");
    });
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
}
