import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_downloader/app/modules/home/controllers/home_controller.dart';
import 'package:video_downloader/app/provider/admob_ads_provider.dart';

import '../../../utils/CM.dart';
import '../../../utils/app_strings.dart';
import '../../../utils/colors.dart';
import '../../../utils/size_config.dart';

class SocialIconsView extends GetView<HomeController> {
  // const SocialIconsView({super.key});
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

  // // // Native Ad Implementation start // // //
  NativeAd? nativeAd;
  RxBool nativeAdIsLoaded = false.obs;

  initNative() {
    nativeAd = NativeAd(
      adUnitId: AppStrings.ADMOB_NATIVE,
      request: AdRequest(),
      // factoryId: ,
      nativeTemplateStyle:
          NativeTemplateStyle(templateType: TemplateType.medium),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          print('$NativeAd loaded.');

          nativeAdIsLoaded.value = true;
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$NativeAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$NativeAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$NativeAd onAdClosed.'),
      ),
    )..load();
  }

  /// Native Ad Implemntation End ///

  @override
  Widget build(BuildContext context) {
    initBanner();
    initNative();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
            color: AppColors.Text_color,
            // color: Colors.white,
            fontSize: SizeConfig.blockSizeHorizontal * 6),
        title: Text(
          "All Video Downloader",
          // style: GoogleFonts.pacifico(),
        ),
        leading: GestureDetector(
            onTap: () {
              AdMobAdsProvider.instance.showInterstitialAd();
              controller.searchTextCTL.clear();
              Get.back();
            },
            child: Icon(Icons.arrow_back_ios)),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Obx(() => isBannerLoaded.value &&
                    AdMobAdsProvider.instance.isAdEnable.value
                ? Container(
                    height: AdSize.banner.height.toDouble(),
                    child: AdWidget(ad: myBanner))
                : Container()),
            // verticalSpace(SizeConfig.blockSizeVertical),
            verticalSpace(SizeConfig.blockSizeVertical * 5),
            _textInput(controller.searchTextCTL, "Paste your URL here",
                TextInputType.text, false),
            verticalSpace(SizeConfig.blockSizeVertical * 10),
            AdMobAdsProvider.instance.isAdEnable.value
                ? Center(
                    child: Container(
                        margin: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockSizeHorizontal * 5),
                        child: NativeAdMethed(nativeAd, nativeAdIsLoaded)),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Future<void> getClipboardData() async {
    try {
      var clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      String copiedLink = clipboardData?.text ??
          ''; // Provide a default value if clipboardData is null
      controller.searchTextCTL.text = copiedLink;
      print('Copied Link: $copiedLink');
    } on PlatformException catch (e) {
      print('Error getting clipboard data: $e');
    }
  }

  Widget _textInput(TextEditingController ctl, String hint,
      TextInputType inputType, isPassword) {
    return Center(
      child: Container(
        height: SizeConfig.blockSizeVertical * 14,
        width: SizeConfig.blockSizeHorizontal * 90,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius:
              BorderRadius.circular(SizeConfig.blockSizeHorizontal * 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 1, // How far the shadow spreads
              blurRadius: 2, // The blur radius for the shadow
              offset: Offset(0, 3), // Offset of the shadow (x, y)
            ),
          ],
        ),
        // elevation: 5,
        // shape:
        // RoundedRectangleBorder(side: BorderSide(color: AppColors.navColors)),
        margin: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 3),
        child: Stack(
          children: [
            Column(
              children: [
                verticalSpace(SizeConfig.blockSizeVertical * 1),
                Container(
                  margin: EdgeInsets.only(
                      left: SizeConfig.blockSizeHorizontal * 2,
                      right: SizeConfig.blockSizeHorizontal * 2),
                  // padding: EdgeInsets.symmetric(
                  //     horizontal: SizeConfig.blockSizeHorizontal * 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5), // Shadow color
                        spreadRadius: 1, // How far the shadow spreads
                        blurRadius: 2, // The blur radius for the shadow
                        offset: Offset(0, 3), // Offset of the shadow (x, y)
                      ),
                    ],
                  ),
                  child:
                      // horizontalSpace(SizeConfig.blockSizeHorizontal * 3),
                      TextFormField(
                    controller: ctl,
                    obscureText: isPassword,
                    keyboardType: inputType,
                    cursorColor: AppColors.Text_color,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.Text_color,
                      fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                    ),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.only(
                          left: SizeConfig.blockSizeHorizontal * 2),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      hintText: hint,
                    ),
                  ),
                ),
                verticalSpace(SizeConfig.blockSizeVertical * 1),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        getClipboardData();
                      },
                      child: Container(
                        height: SizeConfig.blockSizeVertical * 5,
                        width: SizeConfig.blockSizeHorizontal * 40,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockSizeHorizontal * 2)),
                        child: Center(child: Text("Paste Link")),
                      ),
                    ),
                    controller.isBrowsing.value
                        ? InkWell(
                            onTap: () {
                              controller.searchTextCTL.text = "";
                              controller.isBrowsing.value = false;
                              controller.videos.clear();
                            },
                            child: Icon(Icons.close),
                          )
                        : InkWell(
                            onTap: () {
                              String link = controller.searchTextCTL.text;

                              if (controller.selectedIndex.value == 0) {
                                print(
                                    "selectedIndex ${controller.selectedIndex.value}");
                                if (link.contains("facebook") ||
                                    link.contains("fb")) {
                                  controller.callFacebookApi(link);
                                  print("facebookApi");
                                } else {
                                  ComFunction.showInfoDialog(
                                    title: "Invalid URL",
                                    msg: "Please enter Facebook URL",
                                  );
                                }
                              } else if (controller.selectedIndex.value == 1) {
                                if (link.contains("l.likee")) {
                                  controller.callLikeeApi(link);
                                } else {
                                  ComFunction.showInfoDialog(
                                    title: "Invalid URL",
                                    msg: "Please enter Likee URL",
                                  );
                                }
                              } else if (controller.selectedIndex.value == 2) {
                                if (link.contains("instagram")) {
                                  controller.callInstagramApi(link);
                                } else {
                                  ComFunction.showInfoDialog(
                                    title: "Invalid URL",
                                    msg: "Please enter Instagram URL",
                                  );
                                }
                              } else if (controller.selectedIndex.value == 3) {
                                if (link.contains("tiktok")) {
                                  controller.callTiktokApi(link);
                                } else {
                                  ComFunction.showInfoDialog(
                                    title: "Invalid URL",
                                    msg: "Please enter TikTok URL",
                                  );
                                }
                              } else if (controller.selectedIndex.value == 4) {
                                if (link.contains("pin")) {
                                  controller.callPinterestApi(link);
                                } else {
                                  ComFunction.showInfoDialog(
                                    title: "Invalid URL",
                                    msg: "Please enter Pinterest URL",
                                  );
                                }
                              } else if (controller.selectedIndex.value == 5) {
                                if (link.contains("twitter")) {
                                  controller.callTwitterApi(link);
                                } else {
                                  ComFunction.showInfoDialog(
                                    title: "Invalid URL",
                                    msg: "Please enter Twitter URL",
                                  );
                                }
                              } else if (controller.selectedIndex.value == 6) {
                                if (link.contains("vimeo.com")) {
                                  controller.callVimeoApi(link);
                                } else {
                                  ComFunction.showInfoDialog(
                                      title: "Invalid URL",
                                      msg: "Please Enter Vimeo URL");
                                }
                              } else if (controller.selectedIndex.value == 7) {
                                if (link.contains("facebook") ||
                                    link.contains("fb")) {
                                  controller.callFacebookApi(link);
                                } else {
                                  ComFunction.showInfoDialog(
                                    title: "Invalid URL",
                                    msg: "Please enter FB Watch URL",
                                  );
                                }
                              }

                              // if (link.contains("youtube") ||
                              //     link.contains("google") ||
                              //     link.contains("googlevideo") ||
                              //     link.contains("youtu.be") ||
                              //     link.contains("ytimg")) {
                              //   ComFunction.showInfoDialog(
                              //     title: "Invalid URL",
                              //     msg: "Please enter a valid URL",
                              //   );
                              // } else {
                              //   if (link.contains("tiktok")) {
                              //     controller.callTiktokApi(link);
                              //   } else {
                              //     if (link.contains("facebook") ||
                              //         link.contains("fb")) {
                              //       controller.callFacebookApi(link);
                              //     } else {
                              //       if (link.contains("instagram")) {
                              //         controller.callInstagramApi(link);
                              //       } else {
                              //         if (link.contains("pin")) {
                              //           controller.callPinterestApi(link);
                              //         } else {
                              //           if (link.contains("l.likee")) {
                              //             controller.callLikeeApi(link);
                              //           }
                              //         }
                              //       }
                              //     }
                              //   }
                              // }
                              controller.searchTextCTL.clear();
                            },
                            child: Container(
                              height: SizeConfig.blockSizeVertical * 5,
                              width: SizeConfig.blockSizeHorizontal * 40,
                              decoration: BoxDecoration(
                                  color: AppColors.donwload_button_color,
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockSizeHorizontal * 2)),
                              child: Center(
                                  child: Text(
                                "Download",
                                style: TextStyle(color: Colors.white),
                              )),
                            )),
                  ],
                ),
                // SizedBox(
                //     height:
                //         16), // Add some space between the TextFormField and the button
              ],
            ),
          ],
        ),
      ),
    );
  }
}
