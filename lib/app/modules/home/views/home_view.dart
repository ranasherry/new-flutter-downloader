import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:path_provider/path_provider.dart';
import 'package:video_downloader/app/modules/home/controllers/tabs_controller.dart';
import 'package:video_downloader/app/modules/home/views/myWebView.dart';
import 'package:video_downloader/app/routes/app_pages.dart';
import 'package:video_downloader/app/utils/CM.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';
import 'package:video_downloader/app/utils/size_config.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../provider/admob_ads_provider.dart';
import '../../../utils/app_strings.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  TabsController _tabsController = Get.find();

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
    // initBanner();
    // initNative();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // backgroundColor: Color(0xFF1E1E1E),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // physics: NeverScrollableScrollPhysics(),
        child: Container(
            height: SizeConfig.screenHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Obx(() => isBannerLoaded.value &&
                //         AdMobAdsProvider.instance.isAdEnable.value
                //     ? Container(
                //         height: AdSize.banner.height.toDouble(),
                //         child: AdWidget(ad: myBanner))
                //     : Container()),
                // verticalSpace(SizeConfig.blockSizeVertical),

                Obx(() => controller.isBrowsing.value
                    ? Container()
                    : _textInput(controller.searchTextCTL, "Past your URL here",
                        TextInputType.text, false)),

                verticalSpace(SizeConfig.blockSizeVertical * 2),
                Obx(() => controller.isBrowsing.value
                    ? Expanded(
                        child: Container(
                            height: 100,
                            width: SizeConfig.screenWidth,
                            color: Colors.red,
                            child: MyWebView()),
                      )
                    : Container(
                        // color: Colors.red,
                        child: _tabsController.tabIndex.value == 5
                            ? Container()
                            : _appCatalog(),
                      )),
                // verticalSpace(SizeConfig.blockSizeVertical),
                // AdMobAdsProvider.instance.isAdEnable.value
                //     ? Center(
                //         child: Container(
                //             margin: EdgeInsets.symmetric(
                //                 horizontal: SizeConfig.blockSizeHorizontal * 5),
                //             child: NativeAdMethed(nativeAd, nativeAdIsLoaded)),
                //       )
                //     : Container()

                // controller.isBrowsing.value ? Container() : _nativeAd()
              ],
            )),
      ),
      floatingActionButton: Obx(() => controller.isBrowsing.value
          ? FloatingActionButton(
              backgroundColor: controller.videos.length > 0
                  ? Colors.green[400]
                  : Colors.grey,
              onPressed: () {
                // print("")
                if (controller.videos.length > 0) {
                  _showDownloadDialogue();
                }
              },
              child: Icon(
                Icons.download,
                color: Colors.white,
              ),
            )
          : Container()),
    );
  }

  void _showDownloadDialogue() async {
    // controller.watchUrl.value = "";

    Get.bottomSheet(Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 5,
          vertical: SizeConfig.blockSizeVertical * 2),
      // height: SizeConfig.blockSizeVertical * 25,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        children: [
          Container(
            // height: SizeConfig.blockSizeVertical * 0.5,
            width: SizeConfig.blockSizeHorizontal * 5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Download Options",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.close))
            ],
          ),
          verticalSpace(SizeConfig.blockSizeVertical * 2),
          Obx(() => Expanded(
                child: ListView.builder(
                    // shrinkWrap: true,
                    itemCount: controller.videos.length,
                    itemBuilder: (BuildContext, index) {
                      return _downloadFileItem(index);
                    }),
              ))
        ],
      ),
    ));
  }

  Container _downloadFileItem(int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 3,
          vertical: SizeConfig.blockSizeVertical * 1.5),
      margin: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all()),
      child: Row(
        children: [
          // Container(
          //   padding: EdgeInsets.all(5),
          //   decoration: BoxDecoration(color: Colors.green),
          //   child: Text("SD", style: TextStyle(color: Colors.white),),
          // ),
          horizontalSpace(SizeConfig.blockSizeHorizontal * 2),
          Container(
            width: SizeConfig.blockSizeHorizontal * 15,
            height: SizeConfig.blockSizeVertical * 5,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FutureBuilder(
                    future: _getImage(controller.videos[index].link),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Image.file(
                            File(snapshot.data.toString()),
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Center(
                            child: Image.asset(
                              AppImages.thumbnail_demo,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      } else {
                        return Center(
                          child: Image.asset(
                            AppImages.thumbnail_demo,
                            fit: BoxFit.fitHeight,
                          ),
                        );
                      }
                    })),
          ),
          horizontalSpace(SizeConfig.blockSizeHorizontal * 3),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.videos[index].name),
              FutureBuilder(
                  future: controller.getSize(controller.videos[index].link),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return Text("${snapshot.data.toString()} MB");

                        // Image.file(
                        //   File(snapshot.data.toString()),
                        //   fit: BoxFit.cover,
                        // );
                      } else {
                        return Text("Calculating Size...");
                      }
                    } else {
                      return Text("Calculating Size...");
                    }
                  }),

              // Text("${controller.videos[index].size.toStringAsFixed(3)} MB")
            ],
          ),
          Spacer(),
          InkWell(
              onTap: () {
                // controller.download(urls);
                controller.download(index);

                Get.back();
                // controller.appLovin_CTL.showInterAd();
              },
              child: Icon(Icons.download)),
        ],
      ),
    );
  }

  Padding _appCatalog() {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 5),
      child: GridView(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: SizeConfig.blockSizeHorizontal * 3,
            mainAxisSpacing: SizeConfig.blockSizeVertical * 1,
            childAspectRatio: 2 / 2),
        children: [
          _selectApp("Facebook", AppImages.fb_ic, 0, 0xFF3b5998),
          // _selectApp("Vimeo", AppImages.vimo_ic, 1, 0xFF19B1E3),
          // _selectApp("DailyMotion", AppImages.dailymotion_ic, 2, 0xFF000000),
          _selectApp("Likee", AppImages.likee_ic, 1, 0xFF000000),
          _selectApp("Instagram", AppImages.instagram_ic, 2, 0xFFE90214),
          // _selectApp("Twitter", AppImages.twitter_ic, 5),
          _selectApp("Tiktok", AppImages.tiktok_ic, 3, 0xFF000000),
          _selectApp("Pinterest", AppImages.pinterest, 4, 0xFF000000),
          _selectApp("Twitter", AppImages.twitter_ic, 5, 0xFF000000),
          _selectApp("Vimeo", AppImages.vimo_ic, 6, 0xFF000000),
          _selectApp("FB Watch", AppImages.fb_watch, 7, 0xFF000000),
          // _selectApp("Snack Video", AppImages.snack_ic, 8, 0xFF000000),
          // _selectApp("ShareChat", AppImages.sharechat_ic, 9, 0xFF000000),
          // _selectApp("Chingari", AppImages.chingari_ic, 10, 0xFF000000),

          // _selectApp("WhatsApp", AppImages.whatsapp_ic, 7, 0xFF1BBE42),
        ],
      ),
    );
  }

  Widget _selectApp(String name, String img, int index, int color) {
    return InkWell(
      onTap: () {
        AdMobAdsProvider.instance.showInterstitialAd();
        if (index == 0) {
          controller.searchTextCTL.text = "www.facebook.com";
          controller.isBrowsing.value = true;
          return;
        } else if (index == 2) {
          controller.searchTextCTL.text = 'www.instagram.com';
          controller.isBrowsing.value = true;
        } else {
          controller.searchTextCTL.text = "";
          Get.toNamed(Routes.SocialIconsView, arguments: index);
          controller.selectedIndex.value = index;
        }

        //  else {
        //   if (index == 0) {
        //     if (link.contains("facebook") || ("fb")) {
        //       controller.callFacebookApi(link);
        //     }
        //     // // // // //
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text = "https://facebook.com/";
        //   } else if (index == 1) {
        //     // // // // //
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text = "https://vimeo.com";
        //   } else if (index == 2) {
        //     // // // // //
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text = "https://dailymotion.com";
        //     // ComFunction.showInfoDialog(
        //     //     title: "Coming Soon!", msg: "DailyMotion is Coming Soon");
        //   } else if (index == 3) {
        //     // // // // //
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text =
        //     //     "https://likee.video/@barbie401/video";
        //     // ComFunction.showInfoDialog(
        //     //     title: "Coming Soon!", msg: "Likee is Coming Soon");

        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text = "https://sck.io/p/VYCtBuhv";
        //   } else if (index == 4) {
        //     // // // // //
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text = "https://www.instagram.com";
        //   } else if (index == 5) {
        //     // // // // //
        //     // ComFunction.showInfoDialog(
        //     //     title: "Coming Soon!", msg: "Twitter is Coming Soon");

        //     // controller.isBrowsing.value = true;

        //     // controller.searchTextCTL.text = "https://mobile.twitter.com";
        //   } else if (index == 6) {
        //     // // // // //
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text =
        //     //     "https://www.tiktok.com/trending?lang=en";
        //   } else if (index == 7) {
        //     // // // // //
        //     // _tabsController.tabIndex.value = 4;
        //     // Get.toNamed(Routes.WHATSAPP_FEATURES);
        //   } else if (index == 8) {
        //     // // // // //
        //     // Get.toNamed(Routes.WHATSAPP_FEATURES);
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text = "https://sck.io/p/VYCtBuhv";
        //   } else if (index == 9) {
        //     // // // // //
        //     // Get.toNamed(Routes.WHATSAPP_FEATURES);
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text = "sharechat.com";
        //   } else if (index == 10) {
        //     // // // // //
        //     // Get.toNamed(Routes.WHATSAPP_FEATURES);
        //     // controller.isBrowsing.value = true;
        //     // controller.searchTextCTL.text = "https://chingari.io/post/latest";
        //   }
        // } // controller.appLovin_CTL.showInterAd();
      },
      child: Column(
        // crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            img,
            width: SizeConfig.blockSizeHorizontal * 25,
            height: SizeConfig.blockSizeHorizontal * 14,
          ),
          verticalSpace(SizeConfig.blockSizeHorizontal * 1),
          FittedBox(
            child: Text(
              "$name",
              style: TextStyle(
                fontSize: SizeConfig.blockSizeHorizontal * 3,
              ),
            ),
          ),
        ],
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
                    cursorColor: Colors.black,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
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

                              if (link.contains("youtube") ||
                                  link.contains("google") ||
                                  link.contains("googlevideo") ||
                                  link.contains("youtu.be") ||
                                  link.contains("ytimg")) {
                                ComFunction.showInfoDialog(
                                  title: "Invalid URL",
                                  msg: "Please enter a valid URL",
                                );
                              } else {
                                if (link.contains("tiktok")) {
                                  controller.callTiktokApi(link);
                                } else {
                                  if (link.contains("facebook") ||
                                      link.contains("fb")) {
                                    controller.searchTextCTL.text = link;
                                    controller.isBrowsing.value = true;
                                    // controller.callFacebookApi(link);
                                  } else {
                                    if (link.contains("instagram")) {
                                      controller.searchTextCTL.text = link;
                                      controller.isBrowsing.value = true;
                                      // controller.callInstagramApi(link);
                                    } else {
                                      if (link.contains("pin")) {
                                        // controller.callPinterestApi(link);
                                        controller.searchTextCTL.text = link;
                                        controller.isBrowsing.value = true;
                                      } else {
                                        if (link.contains("l.likee")) {
                                          // controller.searchTextCTL.text = link;
                                          // controller.isBrowsing.value = true;
                                          controller.callLikeeApi(link);
                                        } else {
                                          if (link.contains("x.com")) {
                                            controller.callTwitterApi(link);
                                          } else {
                                            if (link.contains("vimeo.com")) {
                                              controller.callVimeoApi(link);
                                            }
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                              // controller.searchTextCTL.clear();
                            },
                            child: Container(
                              height: SizeConfig.blockSizeVertical * 5,
                              width: SizeConfig.blockSizeHorizontal * 40,
                              decoration: BoxDecoration(
                                  color: Colors.green,
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

    // Card(
    //   elevation: 5,
    //   shape:
    //       RoundedRectangleBorder(side: BorderSide(color: AppColors.navColors)),
    //   margin:
    //       EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 3),
    //   child: Container(
    //     // margin: EdgeInsets.symmetric(
    //     //     horizontal: SizeConfig.blockSizeHorizontal * 3),
    //     // height: SizeConfig.blockSizeVertical * 4,
    //     // width: SizeConfig.blockSizeHorizontal * 30,
    //     padding: EdgeInsets.symmetric(
    //         horizontal: SizeConfig.blockSizeHorizontal * 2),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(5),
    //       color: Colors.grey.shade300,
    //       boxShadow: [
    //         BoxShadow(
    //           color: Colors.grey.withOpacity(0.5), // Shadow color
    //           spreadRadius: 1, // How far the shadow spreads
    //           blurRadius: 2, // The blur radius for the shadow
    //           offset: Offset(0, 3), // Offset of the shadow (x, y)
    //         ),
    //       ],
    //     ),
    //     child: Row(
    //       children: [
    //         // Image.asset(
    //         //   AppImages.dailymotion_ic,
    //         //   height: SizeConfig.blockSizeVertical * 3,
    //         // ),
    //         horizontalSpace(SizeConfig.blockSizeHorizontal * 3),
    //         Expanded(
    //           child: TextFormField(
    //             controller: ctl,
    //             obscureText: isPassword,
    //             keyboardType: inputType,
    //             cursorColor: Colors.black,
    //             textAlign: TextAlign.left,
    //             style: TextStyle(
    //                 color: Colors.black,
    //                 fontSize: SizeConfig.blockSizeHorizontal * 3.5),
    //             decoration: InputDecoration(
    //               border: InputBorder.none,
    //               focusedBorder: InputBorder.none,
    //               enabledBorder: InputBorder.none,

    //               // contentPadding: EdgeInsets.all(9),
    //               //hintStyle: TextStyle(color: Colors.blue),

    //               errorBorder: InputBorder.none,
    //               disabledBorder: InputBorder.none,
    //               hintText: hint,
    //             ),
    //           ),
    //         ),
    //         controller.isBrowsing.value
    //             ? InkWell(
    //                 onTap: () {
    //                   controller.searchTextCTL.text = "";
    //                   controller.isBrowsing.value = false;
    //                   controller.videos.clear();
    //                 },
    //                 child: Icon(Icons.close))
    //             : InkWell(
    //                 onTap: () {
    //                   String link = controller.searchTextCTL.text;

    //                   if (link.contains("youtube") ||
    //                       link.contains("google") ||
    //                       link.contains("googlevideo") ||
    //                       link.contains("youtu.be") ||
    //                       link.contains("ytimg")) {
    //                     ComFunction.showInfoDialog(
    //                         title: "Invalid URL",
    //                         msg: "Please enter a valid URL");
    //                   } else {
    //                     if (link.contains("tiktok")) {
    //                       controller.callTiktokApi(link);
    //                     } else {
    //                       if (link.contains("facebook") ||
    //                           link.contains("fb")) {
    //                         controller.callFacebookApi(link);
    //                       } else {
    //                         if (link.contains("instagram")) {
    //                           controller.callInstagramApi(link);
    //                         } else {
    //                           if (link.contains("pin")) {
    //                             controller.callPinterestApi(link);
    //                           } else {
    //                             if (link.contains("l.likee")) {
    //                               controller.callLikeeApi(link);
    //                             }
    //                           }
    //                         }
    //                       }
    //                     }
    //                     // controller.isBrowsing.value = true;
    //                   }
    //                 },
    //                 child: Icon(Icons.arrow_forward_ios)),
    //       ],
    //     ),
    //   ),
    // );
  }

  _getImage(videoPathUrl) async {
    await Future.delayed(Duration(milliseconds: 500));
    String? thumb = await VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,

      imageFormat: ImageFormat.JPEG,
      maxHeight:
          64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );
    print("thumbnail: $thumb");
    return thumb;
  }
}
