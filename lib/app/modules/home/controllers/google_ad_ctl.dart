import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:video_downloader/app/utils/app_strings.dart';

class GoogleAdsCTL extends GetxController {
  GoogleAdsCTL() {
    isNativeLoaded.value = false;
  }

  //TODO: Implement HomeControlle

  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int maxFailedLoadAttempts = 3;

  BannerAd? myBanner;
  BannerAd? myBannerNoDownloadinProgress;
  BannerAd? myBannerDownloadinProgress;
  BannerAd? myBannerNoDownloaded;
  BannerAd? myBannerDownloaded;
  BannerAd? myBannersplashScreen;
  BannerAd? myBannerBrowseScreen;
  NativeAd? myNative;
  NativeAd? myNativeBrowseScreen;
  NativeAd? myNativeSplashScreen;
  AdWidget? nativeAdWidget;
  Rx<bool> isNativeLoaded = false.obs;
  Rx<bool> isNativeOnBrowseLoaded = false.obs;
  Rx<bool> isNativeOnSplashLoaded = false.obs;

  //  NativeAdListener nativeListener = NativeAdListener(
  //   // Called when an ad is successfully received.
  //   onAdLoaded: (Ad ad) {
  //     print('Native Ad loaded.');
  //     isNativeLoaded.value = true;
  //   },
  //   // Called when an ad request failed.
  //   onAdFailedToLoad: (Ad ad, LoadAdError error) {
  //     // Dispose the ad here to free resources.
  //     ad.dispose();
  //     print('Native Ad failed to load: $error');
  //   },
  //   // Called when an ad opens an overlay that covers the screen.
  //   onAdOpened: (Ad ad) => print('Ad opened.'),
  //   // Called when an ad removes an overlay that covers the screen.
  //   onAdClosed: (Ad ad) => print('Ad closed.'),
  //   // Called when an impression occurs on the ad.
  //   onAdImpression: (Ad ad) => print('Ad impression.'),
  //   // Called when a click is recorded for a NativeAd.
  //   onNativeAdClicked: (NativeAd ad) => print('Ad clicked.'),
  // );

  @override
  void onInit() async {
    super.onInit();
    myBanner = BannerAd(
      adUnitId: AppStrings.BANNER_UNITID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBannerNoDownloadinProgress = BannerAd(
      adUnitId: AppStrings.BANNER_UNITID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBannerDownloadinProgress = BannerAd(
      adUnitId: AppStrings.BANNER_UNITID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBannerNoDownloaded = BannerAd(
      adUnitId: AppStrings.BANNER_UNITID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBannerDownloaded = BannerAd(
      adUnitId: AppStrings.BANNER_UNITID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBannersplashScreen = BannerAd(
      adUnitId: AppStrings.BANNER_UNITID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBannerBrowseScreen = BannerAd(
      adUnitId: AppStrings.BANNER_UNITID,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
 
    myNative = NativeAd(
      adUnitId: AppStrings.NATIVE_UNITID,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          isNativeLoaded.value = true;
          print('Native Ad loaded. $isNativeLoaded');
        },

        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          print('Native Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
        // Called when a click is recorded for a NativeAd.
        onNativeAdClicked: (NativeAd ad) => print('Ad clicked.'),
      ),
    );
    myNativeSplashScreen = NativeAd(
      adUnitId: AppStrings.NATIVE_UNITID,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          isNativeOnSplashLoaded.value = true;
          print('Native Ad loaded. $isNativeOnSplashLoaded');
        },

        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          print('Native Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
        // Called when a click is recorded for a NativeAd.
        onNativeAdClicked: (NativeAd ad) => print('Ad clicked.'),
      ),
    );
 
    myNativeBrowseScreen = NativeAd(
      adUnitId: AppStrings.NATIVE_UNITID,
      factoryId: 'listTile',
      request: AdRequest(),
      listener: NativeAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (Ad ad) {
          isNativeOnBrowseLoaded.value = true;
          print('Native Ad loaded. $isNativeLoaded');
        },

        // Called when an ad request failed.
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          // Dispose the ad here to free resources.
          ad.dispose();
          print('Native Ad failed to load: $error');
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) => print('Ad opened.'),
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) => print('Ad closed.'),
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) => print('Ad impression.'),
        // Called when a click is recorded for a NativeAd.
        onNativeAdClicked: (NativeAd ad) => print('Ad clicked.'),
      ),
    );

    myBanner!.load();
    myBannerNoDownloadinProgress!.load();
    myBannerDownloadinProgress!.load();
    myBannerNoDownloaded!.load();
    myBannerDownloaded!.load();
    myBannersplashScreen!.load();
    myBannerBrowseScreen!.load();
    myNative!.load();
    myNativeBrowseScreen!.load();
    myNativeSplashScreen!.load();
    nativeAdWidget = AdWidget(ad: myNative!);

    _createInterstitialAd();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  final BannerAdListener listener = BannerAdListener(
    // Called when an ad is successfully received.
    onAdLoaded: (Ad ad) => print('Ad loaded.'),
    // Called when an ad request failed.
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      // Dispose the ad here to free resources.
      ad.dispose();
      print('Ad failed to load: $error');
    },
    // Called when an ad opens an overlay that covers the screen.
    onAdOpened: (Ad ad) => print('Ad opened.'),
    // Called when an ad removes an overlay that covers the screen.
    onAdClosed: (Ad ad) => print('Ad closed.'),
    // Called when an impression occurs on the ad.
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );

  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: AppStrings.INTER_UNITID,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
