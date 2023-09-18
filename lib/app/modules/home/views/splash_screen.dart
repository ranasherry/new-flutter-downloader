import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:video_downloader/app/modules/home/controllers/splash_ctl.dart';
import 'package:video_downloader/app/routes/app_pages.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';
import 'package:video_downloader/app/utils/size_config.dart';

class SplashScreen extends GetView<SplashController> {
  SplashScreen({Key? key}) : super(key: key);
  // Obtain shared preferences.
  bool? b;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    b = controller.isFirstTime;
    return Scaffold(
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
        color: Colors.black,
        child: Stack(
          children: [
            Align(
                alignment: Alignment.center,
                child: Image.asset(
                  AppImages.splash_ic,
                  width: SizeConfig.screenWidth,
                  height: SizeConfig.screenHeight,
                  fit: BoxFit.cover,
                )),
            Opacity(
              opacity: 0.7,
              child: Container(
                width: SizeConfig.screenWidth,
                height: SizeConfig.screenHeight,
                color: Colors.black,
              ),
            ),

            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  verticalSpace(SizeConfig.blockSizeVertical * 5),
                  Text("All Video Downloader",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.blockSizeHorizontal * 6,
                          fontWeight: FontWeight.bold)),
                  verticalSpace(SizeConfig.blockSizeVertical * 1),
                  Text("Download all videos in one click",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.blockSizeHorizontal * 3,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 5),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(() => controller.isLoaded.value
                        ? GestureDetector(
                            onTap: () {
                              if (controller.isFirstTime!) {
                                controller.setFirstTime(false);
                                Get.offAndToNamed(Routes.HOW_TO_SCREEN);
                              } else {
                                Get.offAndToNamed(Routes.TabsScreenView);
                              }
                            },
                            child: Container(
                              height: SizeConfig.blockSizeVertical * 5.5,
                              width: SizeConfig.blockSizeHorizontal * 70,
                              decoration: BoxDecoration(
                                  color: Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockSizeHorizontal * 3)),
                              child: Center(
                                child: Text(
                                  "GET STARTED",
                                  style: TextStyle(
                                      fontSize:
                                          SizeConfig.blockSizeHorizontal * 6,
                                      color: AppColors.navColors),
                                ),
                              ),
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(
                                top: SizeConfig.blockSizeVertical * 15,
                                right: SizeConfig.blockSizeHorizontal * 15,
                                left: SizeConfig.blockSizeHorizontal * 15),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    8.0), // Adjust the radius as per your requirement
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(
                                    10), // Same radius as the container
                                child: LinearProgressIndicator(
                                    minHeight: 6,
                                    backgroundColor: Colors.white,
                                    color: AppColors.navColors),
                              ),
                            )))
                    // Container(
                    //   padding: EdgeInsets.symmetric(
                    //       horizontal: SizeConfig.blockSizeHorizontal * 15),
                    //   width: SizeConfig.screenWidth,
                    //   child: Center(
                    //     child: Obx(() => LinearPercentIndicator(
                    //           width: SizeConfig.screenWidth * .65,
                    //           lineHeight: SizeConfig.blockSizeVertical,
                    //           percent: controller.percent.value / 100,

                    //           // center: new Text("${controller.percent.value} %"),
                    //           backgroundColor: Colors.white,
                    //           progressColor: Colors.red,
                    //         )),
                    //   ),
                    // ),

                    // verticalSpace(SizeConfig.blockSizeVertical * 5),
                    // Text("All Video Downloader",
                    //     style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: 16,
                    //         fontWeight: FontWeight.bold)),
                    // Text("(Download Your favorite videos)",
                    //     style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: 12,
                    //         fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            _nativeAd(),
            // Align(
            //     alignment: Alignment.topCenter,
            //     child: Container(
            //       margin:
            //           EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
            //       child: Container(
            //           width: SizeConfig.screenWidth,
            //           height: controller
            //               .googleAdsCT.myBannersplashScreen!.size.height
            //               .toDouble(),
            //           child: Center(
            //             child: AdWidget(
            //               ad: controller.googleAdsCT.myBannersplashScreen!,
            //             ),
            //           )),

            //       // ),
            //     )),
          ],
        ),
      ),
      // floatingActionButton: Obx(() => controller.isLoaded.value
      //     ? FloatingActionButton(
      //         backgroundColor: Color(0xFFF12073),
      //         onPressed: () {
      //           print("Is First Time: ${controller.isFirstTime}");
      //           // controller.appLovin_CTL.showInterAd();

      //           if (controller.isFirstTime!) {
      //             controller.setFirstTime(false);
      //             Get.offAndToNamed(Routes.HOW_TO_SCREEN);
      //           } else {
      //             Get.offAndToNamed(Routes.TabsScreenView);
      //           }
      //         },
      //         child: Icon(
      //           Icons.arrow_forward,
      //           color: Colors.white,
      //         ),
      //       )
      //     : Container()),
    );
  }

  Widget _nativeAd() {
    return Obx(() => controller.googleAdsCT.isNativeOnBrowseLoaded.value
        ? Align(
            alignment: Alignment.topCenter,
            child: Container(
                color: Colors.grey[400],
                alignment: Alignment.center,
                width: 320,
                // height: 120,
                height: 220,
                //                 width: 500,
                // height: 500,
                // color: Colors.red,
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
                child:
                    AdWidget(ad: controller.googleAdsCT.myNativeBrowseScreen!)),
          )
        : Container());
  }
}
