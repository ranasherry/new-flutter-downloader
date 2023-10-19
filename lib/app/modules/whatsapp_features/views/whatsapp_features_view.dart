import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/images.dart';
import 'package:video_downloader/app/utils/size_config.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import '../controllers/whatsapp_features_controller.dart';

class WhatsappFeaturesView extends GetView<WhatsappFeaturesController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: Text('WhatsappFeaturesView'),
        //   centerTitle: true,
        // ),
        body: Container(
      width: SizeConfig.screenWidth,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockSizeHorizontal * 5),
            // width: SizeConfig.screenWidth * 0.77,
            height: SizeConfig.blockSizeVertical * 8,
            child: TabBar(
                controller: controller.tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: AppColors.Text_color,
                labelPadding: EdgeInsets.zero,
                tabs: [
                  Tab(
                    text: "Images",
                  ),
                  Tab(
                    text: "Videos",
                  ),
                ]),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockSizeHorizontal * 5),

              // width: SizeConfig.screenWidth * 0.77,
              // height: SizeConfig.blockSizeVertical*70,
              child: TabBarView(
                  controller: controller.tabController,
                  children: [_ImageStatusesTab(), _videoStatusTab()]),
            ),
          )
        ],
      ),
    ));
  }

  Widget _videoStatusTab() {
    return Obx(() => controller.whatsappVideos.isEmpty
        ? _noVideos()
        : Container(
            padding: EdgeInsets.symmetric(
                // horizontal: SizeConfig.blockSizeHorizontal * 5,
                vertical: SizeConfig.blockSizeVertical * 2),
            child: Container(
              child: Obx(() => ListView.builder(
                  itemCount: controller.whatsappVideos.length,
                  itemBuilder: (BuildContext context, int index) {
                    return _VideoItem(index);
                  })),
            ),
          ));
  }

  Container _VideoItem(int index) {
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
                            _getImage(controller.whatsappVideos[index].path),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              return Hero(
                                tag: controller.whatsappVideos[index].name,
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
                        color: AppColors.Text_color,
                        borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                            topLeft: Radius.circular(10))),
                    child: Text(
                      "${controller.whatsappVideos[index].duration}",
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
              Container(
                width: SizeConfig.blockSizeHorizontal * 30,
                child: Text(
                  "${controller.whatsappVideos[index].name}",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              verticalSpace(SizeConfig.blockSizeVertical * 0.5),
              Text(
                "Size ${controller.whatsappVideos[index].size} MB",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ],
          ),
          Spacer(),
          // PopupMenuButton(
          //     elevation: 20,
          //     // offset: Offset.infinite,
          //     offset: Offset.fromDirection(
          //       380,
          //     ),
          //     itemBuilder: (context) => [
          //           PopupMenuItem(
          //             child: Text("Share"),
          //             value: 1,
          //           ),
          //           PopupMenuItem(
          //             child: Text("Delete"),
          //             value: 2,
          //           ),
          //           PopupMenuItem(
          //             child: Text("Rename"),
          //             value: 2,
          //           ),
          //           PopupMenuItem(
          //             child: Text("Copy URL"),
          //             value: 2,
          //           ),
          //           PopupMenuItem(
          //             child: Text("Go to website"),
          //             value: 2,
          //           ),
          //         ])
          Obx(() => !controller.whatsappVideos[index].isdownloaded.value
              ? GestureDetector(
                  onTap: () {
                    controller.copyVideoStatus(index);
                  },
                  child: Icon(Icons.download))
              : Icon(Icons.download_done))
        ],
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
    return thumb;
  }

  Widget _ImageStatusesTab() {
    return Obx(() => controller.whatsappImages.isEmpty
        ? _noImage()
        : Padding(
            padding: EdgeInsets.symmetric(
                // horizontal: SizeConfig.blockSizeHorizontal * 5,
                vertical: SizeConfig.blockSizeVertical * 2),
            child: Obx(() => GridView.builder(
                itemCount: controller.whatsappImages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: SizeConfig.blockSizeHorizontal * 5,
                    mainAxisSpacing: SizeConfig.blockSizeHorizontal * 5),
                itemBuilder: (BuildContext context, int index) {
                  return _statusImageItem(index);
                })),
          ));
  }

  Widget _statusImageItem(int index) {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Container(
            child: Image.file(
              File(
                controller.whatsappImages[index].path,
              ),
              fit: BoxFit.fill,
            ),
          ),
        ),
        Obx(() => controller.whatsappImages[index].isdownloaded.value == false
            ? Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: SizeConfig.blockSizeHorizontal * 2,
                      right: SizeConfig.blockSizeHorizontal * 2),
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal,
                      vertical: SizeConfig.blockSizeHorizontal),
                  decoration:
                      BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: InkWell(
                    onTap: () {
                      controller.copyIMGStatus(index);
                    },
                    child: Icon(
                      Icons.download,
                      color: Colors.white,
                      size: SizeConfig.blockSizeHorizontal * 5,
                    ),
                  ),
                ),
              )
            : Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  margin: EdgeInsets.only(
                      bottom: SizeConfig.blockSizeHorizontal * 2,
                      right: SizeConfig.blockSizeHorizontal * 2),
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockSizeHorizontal,
                      vertical: SizeConfig.blockSizeHorizontal),
                  decoration:
                      BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                  child: InkWell(
                    onTap: () {
                      // controller.copyIMGStatus(index);
                    },
                    child: Icon(
                      Icons.download_done,
                      color: Colors.white,
                      size: SizeConfig.blockSizeHorizontal * 5,
                    ),
                  ),
                ),
              ))
      ],
    );
  }

  Center _noImage() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(
          //   AppImages.downloaded_empty_box,
          //   width: SizeConfig.blockSizeHorizontal * 50,
          // ),
          verticalSpace(SizeConfig.blockSizeVertical * 2),
          Image.asset(AppImages.empty_folder,
            color: Colors.grey,
            scale: 4,
            ),
          Text(
            "Nothing Found!",
            style: TextStyle(fontSize: 24),
          ),
          verticalSpace(SizeConfig.blockSizeVertical * 1),
          Text(
            "No Images to Show",
            style: TextStyle(color: AppColors.Text_color, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Center _noVideos() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset(
          //   AppImages.downloaded_empty_box,
          //   width: SizeConfig.blockSizeHorizontal * 50,
          // ),
          verticalSpace(SizeConfig.blockSizeVertical * 2),
          Image.asset(AppImages.empty_folder,
            color: Colors.grey,
            scale: 4,
            ),
          Text(
            "Nothing Found!",
            style: TextStyle(fontSize: 24),
          ),
          verticalSpace(SizeConfig.blockSizeVertical * 1),
          Text(
            "No Videos to Show",
            style: TextStyle(color: AppColors.Text_color, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void findingStatus() {
    String status = "";
    String video = "";
    try {
      Directory("android");
      TextStyle textStyle = TextStyle(color: Get.textTheme.headline1!.color);
    } catch (e) {
      print(e);
    }
  }
}
