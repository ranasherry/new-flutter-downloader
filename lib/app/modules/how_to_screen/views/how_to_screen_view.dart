import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';

import 'package:video_downloader/app/routes/app_pages.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';
import 'package:video_downloader/app/utils/size_config.dart';
import 'package:video_downloader/app/utils/style.dart';

import '../controllers/how_to_screen_controller.dart';

class HowToScreenView extends GetView<HowToScreenController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Colors.grey.shade800,
        // backgroundColor: Color(0xFF1E1E1E),
        backgroundColor: AppColors.background_color,
        body: Container(
          margin: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 5),
          child: Column(
            children: [
              verticalSpace(SizeConfig.blockSizeVertical * 6),
              Container(
                child: Row(
                  children: [
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.offAllNamed(Routes.TabsScreenView);
                        // Get.put(AppLovin_CTL());
                      },
                      child: Row(
                        children: [
                          Text("Skip",style: StyleSheet.home_text,),
                          Icon(
                            Icons.navigate_next_rounded,
                            color: AppColors.Text_color,
                            size: SizeConfig.screenHeight * 0.05,
                          ),
                        ],
                      )
                      // Text(
                      //   "Skip",
                      //   style: TextStyle(
                      //       color: Colors.white,
                      //       fontSize: SizeConfig.blockSizeVertical * 3),
                      // )
                      ,
                    )
                  ],
                ),
              ),
              verticalSpace(SizeConfig.blockSizeVertical * 2),
              Container(
                height: SizeConfig.blockSizeVertical * 70,
                child: PageView(
                  controller: controller.pageController,
                  children: [
                    _screens_view("Find Your Video",
                        "Search for video URL from the search bar provided or paste the URL to to start downloading"),
                    _screens_view("Play Your Video",
                        "Tap on the play button and wait for download button to activate"),
                    _screens_view("Download Your Video",
                        "Tap on Download button to start downloading your selected video"),
                    // _screens_view(AppImages.how_to_3, "View WhatsApp Status",
                    //     "View WhatsApp status to show them into downloader and then save them into gallery"),
                  ],
                  onPageChanged: (value) {
                    controller.currentPageNotifier.value = value;
                    controller.pageIndex.value = value;
                  },
                ),
              ),
              // Container(
              //     margin:
              //         EdgeInsets.only(bottom: SizeConfig.blockSizeVertical * 2),
              //     child:
              //     BannerMaxView(
              //       (AppLovinAdListener? event) =>
              //           print("Banner Add Event: $event"),
              //       BannerAdSize.banner,
              //       "60a8c3532e7256a9",
              //     )

              //     // ),
              //     ),
              _buildCircleIndicator(),
            ],
          ),
        ));
  }

  _buildCircleIndicator() {
    return Padding(
      padding: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 2),
      child: CirclePageIndicator(
        selectedDotColor: AppColors.Text_color,
        // selectedDotColor: Colors.black,
        dotColor: AppColors.Text_color,
        itemCount: 3,
        currentPageNotifier: controller.currentPageNotifier,
      ),
    );
  }

  Container _screens_view(String title, String description) {
    return Container(
      child: Stack(
        children: [
          // Container(
          //   height: SizeConfig.blockSizeVertical * 50,
          //   decoration: BoxDecoration(color: Colors.greenAccent[100]),
          // ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   // color: Colors.white,
              //   width: SizeConfig.blockSizeHorizontal * 80,
              //   height: SizeConfig.blockSizeVertical * 50,
              //   child: ClipRRect(
              //       borderRadius: BorderRadius.circular(35),
              //       child: Image.asset(
              //         image,
              //       )),
              // ),
              // verticalSpace(SizeConfig.blockSizeVertical * 1),
              Text(title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 24,
                      color: AppColors.Text_color,
                      fontWeight: FontWeight.bold)),
              verticalSpace(SizeConfig.blockSizeVertical * 1),
              Text(description,
                  overflow: TextOverflow.clip,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      // color: Colors.grey.shade200,
                      color: AppColors.Text_color,
                      fontWeight: FontWeight.bold)),
              verticalSpace(SizeConfig.blockSizeVertical * 1),
              Obx(
                () => controller.pageIndex.value == 3
                    ? RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: 'Note: ',
                            style: TextStyle(
                                fontSize: 18,
                                color: AppColors.Text_color,
                                fontWeight: FontWeight.bold),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                      ' If the status is not showing, compleately close the app and open it again',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey.shade200,
                                      fontWeight: FontWeight.bold))
                            ]),
                      )
                    // Text(
                    //     "Note: If the status is not showing, compleately close the app and open it again",
                    //     overflow: TextOverflow.clip,
                    //     textAlign: TextAlign.center,
                    //     style: TextStyle(
                    //         fontSize: 14,
                    //         color: Colors.grey.shade200,
                    //         fontWeight: FontWeight.bold))
                    : Container(),
              )
            ],
          ),
        ],
      ),
    );
  }
}
