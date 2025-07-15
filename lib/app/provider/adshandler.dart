import 'package:video_downloader/app/provider/admob_ads_provider.dart';

class AdsHandler {
  static int addcount = 0;
  getAd() {
    addcount++;
    if (addcount >= 3) {
      AdMobAdsProvider.instance.showInterstitialAd();
      addcount = 0;
    }
  }
}
