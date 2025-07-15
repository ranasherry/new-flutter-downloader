import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
// import 'package:ripple_animation/ripple_animation.dart';

import 'package:share_plus/share_plus.dart';
import 'package:video_downloader/app/modules/home/controllers/settings_controller.dart';
import 'package:video_downloader/app/routes/app_pages.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';
import 'package:video_downloader/app/utils/size_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_downloader/app/utils/style.dart';

import '../../../provider/admob_ads_provider.dart';
import '../../../utils/app_strings.dart';

class SettingsScreen extends GetView<SettingsController> {
  SettingsScreen({Key? key}) : super(key: key);
  // // // Banner Ad Implementation start // // //

  late BannerAd myBanner;
  RxBool isBannerLoaded = false.obs;

  initBanner() {
    BannerAdListener listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) {
        print('Ad loaded.');
        isBannerLoaded.value = true;
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) {
        print('Ad opened.');
      },
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) {
        print('Ad closed.');
      },
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) {
        print('Ad impression.');
      },
    );

    myBanner = BannerAd(
      adUnitId: AppStrings.ADMOB_BANNER,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBanner.load();
  }

  /// Banner Ad Implementation End ///

  @override
  Widget build(BuildContext context) {
    initBanner();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
            color: AppColors.Text_color,
            fontSize: SizeConfig.blockSizeHorizontal * 6),
        title: Text(
          "Settings",
          // style: GoogleFonts.pacifico()
        ),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios,
            // color: AppColors.black,
            color: AppColors.Text_color,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 5,
            vertical: SizeConfig.blockSizeVertical * 1),
        child: ListView(
          children: [
            Column(
              children: [
                Obx(() => isBannerLoaded.value &&
                        AdMobAdsProvider.instance.isAdEnable.value
                    ? Container(
                        height: AdSize.banner.height.toDouble(),
                        child: AdWidget(ad: myBanner))
                    : Container()),
                CircleAvatar(
                  // backgroundColor: Colors.white,
                  radius: 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(AppImages.splash_icon),
                  ),
                ),
// Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.04),child: Text('Profile',style: GoogleFonts.pacifico()))
              ],
            ),
            _myHeadings("General"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.help_outline,
                color: AppColors.background,
              ),
              title: Text(
                "How to Download",
                style: StyleSheet.Setting_Sub_heading,
                // style: GoogleFonts.pacifico(color: AppColors.black1)
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.background,
              ),
              onTap: () {
                Get.toNamed(Routes.HOW_TO_SCREEN);
              },
            ),
            // Divider(),
            // _myHeadings("Download"),
            // GestureDetector(
            //   onTap: () {
            //     // controller.openDownloadDirectory(context);
            //   },
            //   child: ListTile(
            //     contentPadding: EdgeInsets.zero,
            //     leading: Icon(
            //       Icons.sd_storage,
            //       color: AppColors.background,
            //     ),
            //     title: Text(
            //       "Storage Location",
            //       style: StyleSheet.Setting_Sub_heading,
            //       // style: GoogleFonts.pacifico(color: AppColors.black1)
            //     ),
            //     subtitle: Padding(
            //       padding:
            //           EdgeInsets.only(top: SizeConfig.blockSizeVertical * 0.5),
            //       child: Text("Downloads/video Downloader videos/",
            //           style: TextStyle(color: Colors.grey.shade600)
            //           // GoogleFonts.pacifico(color: Colors.grey.shade600)
            //           ),
            //     ),
            //   ),
            // ),
            Divider(),
            _myHeadings("Help"),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   leading: Icon(
            //     Icons.privacy_tip_outlined,
            //     color: AppColors.black1,
            //   ),
            //   title: Text("Privacy Policy",
            //       style: GoogleFonts.pacifico(color: AppColors.black1)),
            //   onTap: () {},
            // ),
            // ListTile(
            //   contentPadding: EdgeInsets.zero,
            //   leading: Icon(
            //     Icons.thumb_up_outlined,
            //     color: AppColors.black1,
            //   ),
            //   title: Text("Feedback",
            //       style: GoogleFonts.pacifico(color: AppColors.black1)),
            //   onTap: () {
            //     LaunchReview.launch(
            //       androidAppId:
            //           "videodownloader.newdownloader.fast.video.download.promate",
            //     );
            //   },
            // ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.star_border_outlined,
                color: AppColors.background,
              ),
              title: Text(
                "Rate us",
                style: StyleSheet.Setting_Sub_heading,
                // style: GoogleFonts.pacifico(color: AppColors.black1)
              ),
               onTap: () async {
                final InAppReview inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                  inAppReview.openStoreListing(
                    appStoreId: 'com.brokmeds.videodownloader.allvideodownloder.hdvideo',
                  );
                }
              },
              // onTap: () {
              //   LaunchReview.launch(
              //     androidAppId:
              //         "com.brokmeds.videodownloader.allvideodownloder.hdvideo",
              //   );
              // },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.share_outlined, color: AppColors.background),
              title: Text(
                "Share",
                style: StyleSheet.Setting_Sub_heading,
                // style: GoogleFonts.pacifico(color: AppColors.black1)
              ),
              onTap: () {
                Share.share(
                    'Download Your Favourite Videos from this Application https://play.google.com/store/apps/details?id=com.brokmeds.videodownloader.allvideodownloder.hdvideo');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.exit_to_app_rounded, color: AppColors.background),
              title: Text(
                "Exit",
                style: StyleSheet.Setting_Sub_heading,
                // style: GoogleFonts.pacifico(color: AppColors.black1)
              ),
              onTap: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Text _myHeadings(String heading) {
    return Text(
      heading,
      //  style: GoogleFonts.pacifico(color: AppColors.black1)
      style: StyleSheet.Setting_text,
      // TextStyle(
      //     color: AppColors.black, fontSize: 18, fontWeight: FontWeight.bold, ),
    );
  }
}
