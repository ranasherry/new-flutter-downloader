import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

import '../controllers/home_controller.dart';

class BrowseView extends GetView<HomeController> {
  TabsController _tabsController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E),
      body: Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: SizeConfig.screenWidth,
                  height:
                      controller.googleAdsCTL.myBanner!.size.height.toDouble(),
                  child: Center(
                    child: AdWidget(
                      ad: controller.googleAdsCTL.myBannerBrowseScreen!,
                    ),
                  )),
              verticalSpace(SizeConfig.blockSizeVertical),
              controller.isBrowsing.value
                  ? Container()
                  : _textInput(controller.searchTextCTL, "Past your URL here",
                      TextInputType.text, false),
              verticalSpace(SizeConfig.blockSizeVertical * 2),
              controller.isBrowsing.value
                  ? Expanded(
                      child: Container(child: MyWebView()),
                    )
                  : Container(
                      // color: Colors.red,

                      ),
              verticalSpace(SizeConfig.blockSizeVertical),
              controller.isBrowsing.value ? Container() : _nativeAd()
            ],
          )),
      floatingActionButton: Obx(() => controller.isBrowsing.value
          ? FloatingActionButton(
              backgroundColor: controller.videos.length > 0
                  ? Colors.green[400]
                  : Colors.grey,
              onPressed: () {
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
                    })

                // Image.file(
                //   File(controller.videos[index].thumbnail),
                //   fit: BoxFit.cover,
                // ),

                ),
          ),
          // Image.asset(AppImages.thumbnail_demo, width: SizeConfig.blockSizeHorizontal*13,height: SizeConfig.blockSizeVertical*6,),
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

  Widget _selectApp(String name, String img, int index, int color) {
    return InkWell(
      onTap: () {
        controller.googleAdsCTL.showInterstitialAd();
        if (index == 0) {
          controller.isBrowsing.value = true;
          controller.searchTextCTL.text = "https://facebook.com/";
        } else if (index == 1) {
          controller.isBrowsing.value = true;
          controller.searchTextCTL.text = "https://vimeo.com";
        } else if (index == 2) {
          controller.isBrowsing.value = true;
          controller.searchTextCTL.text = "https://dailymotion.com";
          // ComFunction.showInfoDialog(
          //     title: "Coming Soon!", msg: "DailyMotion is Coming Soon");
        } else if (index == 3) {
          ComFunction.showInfoDialog(
              title: "Coming Soon!", msg: "Likee is Coming Soon");

          // controller.isBrowsing.value = true;
          // controller.searchTextCTL.text = "https://sck.io/p/VYCtBuhv";
        } else if (index == 4) {
          controller.isBrowsing.value = true;
          controller.searchTextCTL.text = "https://www.instagram.com";
        } else if (index == 5) {
          ComFunction.showInfoDialog(
              title: "Coming Soon!", msg: "Twitter is Coming Soon");

          // controller.isBrowsing.value = true;

          // controller.searchTextCTL.text = "https://mobile.twitter.com";
        } else if (index == 6) {
          controller.isBrowsing.value = true;
          controller.searchTextCTL.text =
              "https://www.tiktok.com/trending?lang=en";
        } else if (index == 7) {
          _tabsController.tabIndex.value = 4;
          // Get.toNamed(Routes.WHATSAPP_FEATURES);
        }
        // controller.appLovin_CTL.showInterAd();
      },
      child: Card(
        elevation: 5,
        child: Container(
          // color: Colors.amber,
          // margin: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical),
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockSizeHorizontal * 3,
              vertical: SizeConfig.blockSizeVertical * 0.5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(5),
              ),
              color: Colors.grey[200]
              // border: Border.all(),
              ),

          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.grey[100], shape: BoxShape.circle),
                child: Image.asset(
                  img,
                  width: SizeConfig.blockSizeHorizontal * 8,
                  height: SizeConfig.blockSizeHorizontal * 8,
                ),
              ),
              verticalSpace(SizeConfig.blockSizeHorizontal * 1),
              FittedBox(
                child: Text(
                  "$name",
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _textInput(TextEditingController ctl, String hint,
      TextInputType inputType, isPassword) {
    return Card(
      elevation: 5,
      shape:
          RoundedRectangleBorder(side: BorderSide(color: AppColors.navColors)),
      margin:
          EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 3),
      child: Container(
        // margin: EdgeInsets.symmetric(
        //     horizontal: SizeConfig.blockSizeHorizontal * 3),
        // height: SizeConfig.blockSizeVertical * 4,
        // width: SizeConfig.blockSizeHorizontal * 30,
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.grey.shade300,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color
              spreadRadius: 1, // How far the shadow spreads
              blurRadius: 2, // The blur radius for the shadow
              offset: Offset(0, 3), // Offset of the shadow (x, y)
            ),
          ],
        ),
        child: Row(
          children: [
            // Image.asset(
            //   AppImages.dailymotion_ic,
            //   height: SizeConfig.blockSizeVertical * 3,
            // ),
            horizontalSpace(SizeConfig.blockSizeHorizontal * 3),
            Expanded(
              child: TextFormField(
                controller: ctl,
                obscureText: isPassword,
                keyboardType: inputType,
                cursorColor: Colors.black,
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: SizeConfig.blockSizeHorizontal * 4),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  // contentPadding: EdgeInsets.all(9),
                  //hintStyle: TextStyle(color: Colors.blue),

                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  hintText: hint,
                ),
              ),
            ),
            controller.isBrowsing.value
                ? InkWell(
                    onTap: () {
                      controller.searchTextCTL.text = "";
                      controller.isBrowsing.value = false;
                      controller.videos.clear();
                    },
                    child: Icon(Icons.close))
                : InkWell(
                    onTap: () {
                      String link = controller.searchTextCTL.text.toLowerCase();

                      if (link.contains("youtube") ||
                          link.contains("google") ||
                          link.contains("googlevideo") ||
                          link.contains("youtu.be") ||
                          link.contains("ytimg")) {
                        ComFunction.showInfoDialog(
                            title: "Invalid URL",
                            msg: "Please enter a valid URL");
                      } else {
                        controller.isBrowsing.value = true;
                      }
                    },
                    child: Icon(Icons.arrow_forward_ios)),
          ],
        ),
      ),
    );
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

  Widget _nativeAd() {
    return Obx(() => controller.googleAdsCTL.isNativeOnBrowseLoaded.value
        ? Align(
            alignment: Alignment.topCenter,
            child: Container(
                color: Colors.grey,
                alignment: Alignment.center,
                width: 320,
                // height: 120,
                height: 220,
                //                 width: 500,
                // height: 500,
                // color: Colors.red,
                margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * 5),
                child: AdWidget(
                    ad: controller.googleAdsCTL.myNativeBrowseScreen!)),
          )
        : Container());
  }
}
