import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_downloader/app/modules/home/controllers/home_controller.dart';
import 'package:video_downloader/app/modules/home/controllers/tabs_controller.dart';
import 'package:video_downloader/app/modules/home/views/download_progress_screen.dart';
import 'package:video_downloader/app/modules/home/views/downloaded_screen.dart';
import 'package:video_downloader/app/modules/home/views/home_view.dart';
import 'package:video_downloader/app/modules/whatsapp_features/views/whatsapp_features_view.dart';
import 'package:video_downloader/app/routes/app_pages.dart';
import 'package:video_downloader/app/utils/CM.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';
import 'package:video_downloader/app/utils/size_config.dart';

import '../../../utils/app_strings.dart';
import 'browse_view.dart';

class TabsScreenView extends GetView<TabsController> {
  HomeController homeController = Get.find();
  @override
  Widget build(BuildContext context) {
    print("build function called");

    return WillPopScope(
      child: Scaffold(
        // resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          titleTextStyle: TextStyle(
              color: AppColors.black,
              // color: Colors.white,
              fontSize: SizeConfig.blockSizeHorizontal * 6),
          title: Text(
            "All Video Downloader",
            // style: GoogleFonts.pacifico(),
          ),
          actions: [
            Padding(
                padding:
                    EdgeInsets.only(right: SizeConfig.blockSizeHorizontal * 2),
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.SettingsScreen);
                  },
                  child: Icon(
                    Icons.settings_outlined,
                    size: 26.0,
                    color: AppColors.black,
                  ),
                )),
          ],
          elevation: 0.0,
        ),
        body: Obx(() => IndexedStack(
              index: controller.tabIndex.value,
              children: [
                HomeView(),
                DownloadProgressScreen(),
                DownloadedScreen(),
                // HomeView(),
                // DownloadProgressScreen(),
                // DownloadedScreen(),
                // WhatsappFeaturesView(),
                // BrowseView(),
              ],
            )),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Obx(() => controller.tabIndex.value != 0
            //     ? Container(
            //         margin: EdgeInsets.only(
            //             bottom: SizeConfig.blockSizeVertical * 2),
            //         child: BannerMaxView(
            //           (AppLovinAdListener? event) =>
            //               print("Banner Add Event: $event"),
            //           BannerAdSize.banner,
            //           AppStrings.MAX_BANNER_ID,
            //         )

            //         // ),
            //         )
            //     : Container()),
            Obx(() => Card(
                  color: Colors.white,
                  shadowColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 10,
                  margin: EdgeInsets.all(0.0),
                  child: Container(
                    // decoration: BoxDecoration(),
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockSizeHorizontal * 3,
                        vertical: SizeConfig.blockSizeVertical * 1.2),
                    width: SizeConfig.blockSizeHorizontal * 100,
                    height: SizeConfig.blockSizeVertical * 7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            // radius: 5,
                            onTap: () {
                              controller.tabIndex.value = 0;
                              homeController.searchTextCTL.text = "";
                              homeController.isBrowsing.value = false;
                              homeController.videos.clear();
                              // controller.appLovin_CTL.showInterAd();
                            },
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.home_rounded,
                                    color: controller.tabIndex.value == 0
                                        ? AppColors.background
                                        : AppColors.grey,
                                  ),
                                  verticalSpace(
                                      SizeConfig.blockSizeVertical * 1),
                                  Text(
                                    "Home",
                                    style: TextStyle(
                                        color: controller.tabIndex.value == 0
                                            ? AppColors.background
                                            : AppColors.grey,
                                        fontSize: controller.tabIndex.value == 0
                                            ? 15
                                            : 13),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              controller.tabIndex.value = 1;
                              // controller.appLovin_CTL.showInterAd();
                            },
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.downloading,
                                    color: controller.tabIndex.value == 1
                                        ? AppColors.background
                                        : AppColors.grey,
                                  ),
                                  verticalSpace(
                                      SizeConfig.blockSizeVertical * 1),
                                  Text(
                                    "Progress",
                                    style: TextStyle(
                                        color: controller.tabIndex.value == 1
                                            ? AppColors.background
                                            : AppColors.grey,
                                        fontSize: controller.tabIndex.value == 1
                                            ? 15
                                            : 13),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(50),
                            onTap: () {
                              controller.tabIndex.value = 2;
                              // controller.appLovin_CTL.showInterAd();
                              // controller.googleAdsCTL.showInterstitialAd();
                            },
                            child: FittedBox(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.home_repair_service,
                                    color: controller.tabIndex.value == 2
                                        ? AppColors.background
                                        : AppColors.grey,
                                  ),
                                  verticalSpace(
                                      SizeConfig.blockSizeVertical * 1),
                                  Text(
                                    "Downloads",
                                    style: TextStyle(
                                        color: controller.tabIndex.value == 2
                                            ? AppColors.background
                                            : AppColors.grey,
                                        fontSize: controller.tabIndex.value == 2
                                            ? 15
                                            : 13),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        //! Browser
                        // Expanded(
                        //   child: InkWell(
                        //     borderRadius: BorderRadius.circular(50),
                        //     onTap: () {
                        //       controller.tabIndex.value = 5;
                        //       // controller.appLovin_CTL.showInterAd();
                        //       // controller.googleAdsCTL.showInterstitialAd();
                        //     },
                        //     child: FittedBox(
                        //       child: Column(
                        //         children: [
                        //           Icon(
                        //             Icons.travel_explore,
                        //             color: controller.tabIndex.value == 5
                        //                 ? AppColors.navColors
                        //                 : AppColors.white,
                        //           ),
                        //           verticalSpace(
                        //               SizeConfig.blockSizeVertical * 1),
                        //           Text(
                        //             "Browse",
                        //             style: TextStyle(
                        //                 color: controller.tabIndex.value == 5
                        //                     ? AppColors.navColors
                        //                     : AppColors.white,
                        //                 fontSize: controller.tabIndex.value == 5
                        //                     ? 15
                        //                     : 13),
                        //           )
                        //         ],
                        //       ),
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() async {
    if (controller.tabIndex.value != 0) {
      controller.tabIndex.value = 0;
      return false;
    } else {
      if (homeController.searchTextCTL.text.isNotEmpty) {
        homeController.searchTextCTL.text = "";
        homeController.isBrowsing.value = false;

        return false;
      } else {
        ComFunction.showExitDialog(title: "Exit", msg: "Do You want to exit?");
      }
    }
    return false;
  }
}
