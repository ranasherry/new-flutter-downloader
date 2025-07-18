import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_downloader/app/data/downloaded_video.dart';
import 'package:video_downloader/app/modules/home/controllers/download_progress_ctl.dart';
import 'package:video_downloader/app/modules/home/controllers/downloaded_controller.dart';
import 'package:video_downloader/app/modules/home/controllers/home_controller.dart';
import 'package:video_downloader/app/routes/app_pages.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';

import 'package:video_downloader/app/utils/size_config.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../../../provider/admob_ads_provider.dart';
import '../../../utils/app_strings.dart';

class DownloadedScreen extends GetView<HomeController> {
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
    print("Downloaded Screen");
    controller.getDir();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Obx(() => isBannerLoaded.value &&
                    AdMobAdsProvider.instance.isAdEnable.value
                ? Container(
                    height: AdSize.banner.height.toDouble(),
                    child: AdWidget(ad: myBanner))
                : Container()),
            controller.downloadedVideos.isEmpty
                ? _noDownloaded()
                : _downloadedItems()
          ],
        ));
  }

  Widget _downloadedItems() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 2),
        child: Obx(() => GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    crossAxisCount:
                        2, // Adjust the cross-axis count as per your design
                  ),
                  itemCount: controller.downloadedVideos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Get.toNamed(Routes.VideoPlayer, arguments: [
                          controller.downloadedVideos[index].path
                        ]);
                        print(
                            "Path ${controller.downloadedVideos[index].path}");
                      },
                      child: _downloadedItem(index, context),
                    );
                  },
                )
            // ListView.builder(
            //     itemCount: controller.downloadedVideos.length,
            //     itemBuilder: (BuildContext context, int index) {
            //       return InkWell(
            //           onTap: () {
            //             Get.toNamed(Routes.VideoPlayer,
            //                 arguments: [controller.downloadedVideos[index].path]);
            //           },
            //           child: _downloadedItem(index));
            //     })
            ),
      ),
    );
  }

  Widget _downloadedItem(int index, BuildContext context) {
    return Stack(
      children: [
        Container(
          // width: SizeConfig.screenWidth *0.3,
          // padding: EdgeInsets.symmetric(
          //     horizontal: SizeConfig.blockSizeHorizontal * 2,
          //     vertical: SizeConfig.blockSizeVertical),
          // margin: EdgeInsets.symmetric(
          //     // horizontal: SizeConfig.blockSizeHorizontal * 2,
          //     vertical: SizeConfig.blockSizeVertical * 0.75),
          decoration: BoxDecoration(
              // color: AppColors.inputFieldColor,
              // color: AppColors.appleColor,
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.end,
                  //   children: [
                  //     // Container(
                  //     //   width: SizeConfig.screenWidth *0.4,
                  //     //   color: AppColors.appleColor,
                  //     //   child: PopupMenuButton(
                  //     //   elevation: 20,
                  //     //   // offset: Offset.infinite,
                  //     //   offset: Offset.fromDirection(
                  //     //     380,
                  //     //   ),
                  //     //   onSelected: (value) {
                  //     //     if (value == 0) {
                  //     //       controller.shareVideo(controller.downloadedVideos[index]);
                  //     //     } else if (value == 1) {
                  //     //       // controller.shareVideo(controller.downloadedVideos[index]);
                  //     //       controller.deleteVideo(controller.downloadedVideos[index]);
                  //     //     }
                  //     //   },
                  //     //   itemBuilder: (context) => [
                  //     //         PopupMenuItem(
                  //     //           child: Text("Share"),
                  //     //           value: 0,
                  //     //         ),
                  //     //         PopupMenuItem(
                  //     //           child: Text("Delete"),
                  //     //           value: 1,
                  //     //         ),
                  //     //         // PopupMenuItem(
                  //     //         //   child: Text("Rename"),
                  //     //         //   value: 2,
                  //     //         // ),
                  //     //         // PopupMenuItem(
                  //     //         //   child: Text("Copy URL"),
                  //     //         //   value: 2,
                  //     //         // ),
                  //     //         // PopupMenuItem(
                  //     //         //   child: Text("Go to website"),
                  //     //         //   value: 2,
                  //     //         // ),
                  //     //       ]),
                  //     // ),
                  //   ],
                  // ),
                  GestureDetector(
                    onLongPress: () =>
                        _showMenu(context, controller.downloadedVideos[index]),
                    child: Container(
                      // width: SizeConfig.blockSizeHorizontal * 20,
                      // height: SizeConfig.blockSizeVertical * 7,
                      // color: Colors.amber,
                      child: Stack(
                        children: [
                          Container(
                            width: SizeConfig.blockSizeHorizontal * 40,
                            height: SizeConfig.blockSizeVertical * 15,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FutureBuilder(
                                  future: _getImage(
                                      controller.downloadedVideos[index].path),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData) {
                                        return Hero(
                                          tag: controller
                                              .downloadedVideos[index].name,
                                          child: Image.file(
                                            File(snapshot.data.toString()),
                                            fit: BoxFit.cover,
                                          ),
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
                                  }),

                              //  Image.asset(
                              //   img,
                              //   fit: BoxFit.cover,
                              // ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: SizeConfig.blockSizeVertical * 0.25,
                                  horizontal: SizeConfig.blockSizeHorizontal),
                              decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(10),
                                      topLeft: Radius.circular(10))),
                              child: Text(
                                "${controller.downloadedVideos[index].duration}",
                                style: TextStyle(
                                    color: AppColors.white, fontSize: 10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  verticalSpace(SizeConfig.blockSizeVertical * 0.5),

                  // horizontalSpace(SizeConfig.blockSizeHorizontal * 5),
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // width: SizeConfig.blockSizeHorizontal * 50,
                        width: SizeConfig.screenWidth * 0.3,
                        child: Center(
                          child: Text(
                            "${controller.downloadedVideos[index].name}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      verticalSpace(SizeConfig.blockSizeVertical * 0.5),
                      Text(
                        "Size ${controller.downloadedVideos[index].size}",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              // Spacer(),
              // PopupMenuButton(
              //     elevation: 20,
              //     // offset: Offset.infinite,
              //     offset: Offset.fromDirection(
              //       380,
              //     ),
              //     onSelected: (value) {
              //       if (value == 0) {
              //         controller.shareVideo(controller.downloadedVideos[index]);
              //       } else if (value == 1) {
              //         // controller.shareVideo(controller.downloadedVideos[index]);
              //         controller.deleteVideo(controller.downloadedVideos[index]);
              //       }
              //     },
              //     itemBuilder: (context) => [
              //           PopupMenuItem(
              //             child: Text("Share"),
              //             value: 0,
              //           ),
              //           PopupMenuItem(
              //             child: Text("Delete"),
              //             value: 1,
              //           ),
              //           // PopupMenuItem(
              //           //   child: Text("Rename"),
              //           //   value: 2,
              //           // ),
              //           // PopupMenuItem(
              //           //   child: Text("Copy URL"),
              //           //   value: 2,
              //           // ),
              //           // PopupMenuItem(
              //           //   child: Text("Go to website"),
              //           //   value: 2,
              //           // ),
              //         ])
              // GestureDetector(
              //   onTap: (){

              //   },
              //   child: Icon(Icons.more_vert))
            ],
          ),
        ),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: PopupMenuButton(
        //             elevation: 20,
        //             // offset: Offset.infinite,
        //             offset: Offset.fromDirection(
        //               380,
        //             ),
        //             onSelected: (value) {
        //               if (value == 0) {
        //                 controller.shareVideo(controller.downloadedVideos[index]);
        //               } else if (value == 1) {
        //                 // controller.shareVideo(controller.downloadedVideos[index]);
        //                 controller.deleteVideo(controller.downloadedVideos[index]);
        //               }
        //             },
        //             itemBuilder: (context) => [
        //                   PopupMenuItem(
        //                     child: Text("Share"),
        //                     value: 0,
        //                   ),
        //                   PopupMenuItem(
        //                     child: Text("Delete"),
        //                     value: 1,
        //                   ),
        //                   // PopupMenuItem(
        //                   //   child: Text("Rename"),
        //                   //   value: 2,
        //                   // ),
        //                   // PopupMenuItem(
        //                   //   child: Text("Copy URL"),
        //                   //   value: 2,
        //                   // ),
        //                   // PopupMenuItem(
        //                   //   child: Text("Go to website"),
        //                   //   value: 2,
        //                   // ),
        //                 ]),
        // )
      ],
    );
  }

  Widget _noDownloaded() {
    return Expanded(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset(
            //   AppImages.downloaded_empty_box,
            //   width: SizeConfig.blockSizeHorizontal * 50,
            // ),
            verticalSpace(SizeConfig.blockSizeVertical * 2),
            Image.asset(
              AppImages.empty_folder,
              color: Colors.grey,
              scale: 4,
            ),
            Text(
              "Nothing Found!",
              style: TextStyle(
                  fontSize: SizeConfig.blockSizeHorizontal * 6,
                  color: Colors.grey),
            ),
            verticalSpace(SizeConfig.blockSizeVertical * 1),
            Text(
              "No current downloads in progress",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: SizeConfig.blockSizeHorizontal * 4),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, DownloadedVideo downloadedVideo) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(10),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.share),
              title: Text('Share'),
              onTap: () {
                controller.shareVideo(downloadedVideo);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                // onDelete(); // Call delete callback
                controller.deleteVideo(downloadedVideo);
                Navigator.pop(context);
              },
            ),
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
      maxWidth: 512,
      maxHeight:
          512, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 100,
    );
    return thumb;
  }
}
