import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'package:video_downloader/app/modules/home/controllers/download_progress_ctl.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';
import 'package:video_downloader/app/utils/size_config.dart';

import '../controllers/home_controller.dart';

class DownloadProgressScreen extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: controller.downloadingVideos.length <= 0
            ? _noDownloadInProgress()
            : downloadInProgress());
  }

  Container downloadInProgress() {
    return Container(
      padding:
          EdgeInsets.symmetric(horizontal: SizeConfig.blockSizeHorizontal * 2),
      child: Column(
        children: [
          Expanded(
            child: Obx(() => ListView.builder(
                itemCount: controller.downloadingVideos.length,
                itemBuilder: (BuildContext context, int index) {
                  // double downSize = controller.downloadingVideos[index].size /
                  //     controller.downloadingVideos[0].progress.value;
                  return _downloadingItem(
                      AppImages.thumbnail_demo,
                      "${controller.downloadingVideos[index].name}",
                      // controller.downloadingVideos[index].size
                      //     .toStringAsFixed(2),
                      "${controller.downloadingVideos[index].progress.value}",
                      index);
                })),
          ),
        ],
      ),
    );
  }

  Container _downloadingItem(
      String img, String name, String progress, int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 2,
          vertical: SizeConfig.blockSizeVertical),
      margin: EdgeInsets.symmetric(
          // horizontal: SizeConfig.blockSizeHorizontal * 2,
          vertical: SizeConfig.blockSizeVertical * 0.75),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5), // Shadow color
              spreadRadius: 1, // How far the shadow spreads
              blurRadius: 2, // The blur radius for the shadow
              offset: Offset(0, 2), // Offset of the shadow (x, y)
            ),
          ],
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Row(
        children: [
          Container(
            width: SizeConfig.blockSizeHorizontal * 20,
            height: SizeConfig.blockSizeVertical * 7,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                img,
                fit: BoxFit.cover,
              ),
            ),
          ),
          horizontalSpace(SizeConfig.blockSizeHorizontal * 5),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                    fontWeight: FontWeight.bold),
              ),
              // verticalSpace(SizeConfig.blockSizeVertical * 0.5),
              // Obx(() => Container(
              //       width: SizeConfig.blockSizeHorizontal * 50,
              //       child: Text(
              //         " ${controller.downloadingVideos[index].downloadedSize} / ${controller.downloadingVideos[index].size} MBs",
              //         style: TextStyle(
              //             fontSize: 14,
              //             fontWeight: FontWeight.bold,
              //             overflow: TextOverflow.fade,
              //             color: Colors.grey),
              //       ),
              //     )),
              verticalSpace(SizeConfig.blockSizeVertical),
              Row(
                children: [
                  Obx(() => Container(
                        width: SizeConfig.blockSizeHorizontal * 50,
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[400],
                          color: AppColors.primaryColor,
                          value: controller
                              .downloadingVideos[index].progress.value,
                        ),
                      )),
                  horizontalSpace(SizeConfig.blockSizeHorizontal * 5),
                  // InkWell(
                  //   onTap: () {},
                  //   child: Icon(
                  //     Icons.pause,
                  //     color: Colors.grey[400],
                  //   ),
                  // ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _noDownloadInProgress() {
    return Column(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image.asset(
              //   AppImages.progress_empty_box,
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
                    fontSize: SizeConfig.blockSizeHorizontal * 4,
                    color: Colors.grey.shade300),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
