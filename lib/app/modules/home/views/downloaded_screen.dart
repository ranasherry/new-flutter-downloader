import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_downloader/app/modules/home/controllers/download_progress_ctl.dart';
import 'package:video_downloader/app/modules/home/controllers/downloaded_controller.dart';
import 'package:video_downloader/app/modules/home/controllers/home_controller.dart';
import 'package:video_downloader/app/routes/app_pages.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';

import 'package:video_downloader/app/utils/size_config.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class DownloadedScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    print("Downloaded Screen");
    controller.getDir();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: controller.downloadedVideos.isEmpty
            ? _noDownloaded()
            : _downloadedItems());
  }

  Widget _downloadedItems() {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        children: [
          Container(
              width: SizeConfig.screenWidth,
              height: controller.googleAdsCTL.myBanner!.size.height.toDouble(),
              child: Center(
                child: AdWidget(
                  ad: controller.googleAdsCTL.myBannerDownloaded!,
                ),
              )),
          Expanded(
            child: Obx(() => ListView.builder(
                itemCount: controller.downloadedVideos.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                      onTap: () {
                        Get.toNamed(Routes.VideoPlayer, arguments: [
                          controller.downloadedVideos[index].path
                        ]);
                      },
                      child: _downloadedItem(index));
                })),
          ),
        ],
      ),
    );
  }

  Container _downloadedItem(int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 2,
          vertical: SizeConfig.blockSizeVertical),
      margin: EdgeInsets.symmetric(
          // horizontal: SizeConfig.blockSizeHorizontal * 2,
          vertical: SizeConfig.blockSizeVertical * 0.75),
      decoration: BoxDecoration(
          color: AppColors.inputFieldColor,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          Container(
            width: SizeConfig.blockSizeHorizontal * 20,
            height: SizeConfig.blockSizeVertical * 7,
            // color: Colors.amber,
            child: Stack(
              children: [
                Container(
                  width: SizeConfig.blockSizeHorizontal * 20,
                  height: SizeConfig.blockSizeVertical * 7,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FutureBuilder(
                        future:
                            _getImage(controller.downloadedVideos[index].path),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return Hero(
                                tag: controller.downloadedVideos[index].name,
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
                        color: AppColors.black,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topLeft: Radius.circular(10))),
                    child: Text(
                      "${controller.downloadedVideos[index].duration}",
                      style: TextStyle(color: AppColors.white, fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          horizontalSpace(SizeConfig.blockSizeHorizontal * 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${controller.downloadedVideos[index].name}",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
          Spacer(),
          PopupMenuButton(
              elevation: 20,
              // offset: Offset.infinite,
              offset: Offset.fromDirection(
                380,
              ),
              onSelected: (value) {
                if (value == 0) {
                  controller.shareVideo(controller.downloadedVideos[index]);
                } else if (value == 1) {
                  // controller.shareVideo(controller.downloadedVideos[index]);
                  controller.deleteVideo(controller.downloadedVideos[index]);
                }
              },
              itemBuilder: (context) => [
                    PopupMenuItem(
                      child: Text("Share"),
                      value: 0,
                    ),
                    PopupMenuItem(
                      child: Text("Delete"),
                      value: 1,
                    ),
                    // PopupMenuItem(
                    //   child: Text("Rename"),
                    //   value: 2,
                    // ),
                    // PopupMenuItem(
                    //   child: Text("Copy URL"),
                    //   value: 2,
                    // ),
                    // PopupMenuItem(
                    //   child: Text("Go to website"),
                    //   value: 2,
                    // ),
                  ])
          // GestureDetector(
          //   onTap: (){

          //   },
          //   child: Icon(Icons.more_vert))
        ],
      ),
    );
  }

  Widget _noDownloaded() {
    return Column(
      children: [
        Container(
            width: SizeConfig.screenWidth,
            height: controller.googleAdsCTL.myBanner!.size.height.toDouble(),
            child: Center(
              child: AdWidget(
                ad: controller.googleAdsCTL.myBannerNoDownloaded!,
              ),
            )),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   AppImages.downloaded_empty_box,
              //   width: SizeConfig.blockSizeHorizontal * 50,
              // ),
              verticalSpace(SizeConfig.blockSizeVertical * 2),
              Text(
                "Nothing Found!",
                style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 6,
                    color: Colors.grey.shade300),
              ),
              verticalSpace(SizeConfig.blockSizeVertical * 1),
              Text(
                "No current downloads in progress",
                style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: SizeConfig.blockSizeHorizontal * 4),
              ),
            ],
          ),
        ),
      ],
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
    return thumb;
  }
}
