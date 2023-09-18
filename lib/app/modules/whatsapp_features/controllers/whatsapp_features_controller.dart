import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';
import 'package:video_downloader/app/data/whatsapp_images.dart';
import 'package:video_downloader/app/data/whatsapp_videos.dart';
import 'package:video_downloader/app/utils/appUtils.dart';
import 'package:video_downloader/app/utils/app_strings.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class WhatsappFeaturesController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;
  //TODO: Implement WhatsappFeaturesController
  List<FileSystemEntity> _folders = [];
  var tempText = "This is Text".obs;
  // RxList<String> statusIMGPath = <String>[].obs;
  RxList<String> statusIMGPathDownloaded = <String>[].obs;
  RxList<String> statusVIDPathDownloaded = <String>[].obs;
  RxList<WhatsappImages> whatsappImages = <WhatsappImages>[].obs;
  RxList<WhatsappVideo> whatsappVideos = <WhatsappVideo>[].obs;
  final videoInfo = FlutterVideoInfo();

  @override
  void onInit() async {
    tabController = TabController(length: 2, vsync: this);

    var status = await Permission.storage.request();
    if (status.isGranted) {
      bool isChecked = await checkDownloadedIMG();
      bool isCheckedVideos = await checkDownloadedVideos();
      // bool isChecked = true;
      // bool isCheckedVideos = true;
      if (isChecked && isCheckedVideos) {
        print("before getting status");

        getStatuses();
      }
      // getStatuses();
    }
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  void getStatuses() async {
    print("getting status");

    final String WHATSAPP_STATUSES_LOCATION = "/WhatsApp/Media/.Statuses";
    // final directory = await getExternalStorageDirectory();
    final directory = await getExternalStorageDirectory();
    // final dir = directory!.parent.path + WHATSAPP_STATUSES_LOCATION;
    // final dir = directory!.absolute.path+ WHATSAPP_STATUSES_LOCATION;
    final dir = "/storage/emulated/0" + WHATSAPP_STATUSES_LOCATION;
    // String pdfDirectory = '$dir/';
    try {
      print("inside loop");

      final myDir = Directory(dir);
      // final myDir = Directory(directory!.path);

      _folders = myDir.listSync();

      for (FileSystemEntity file in _folders) {
        print("inside loop");

        FileStat f1 = file.statSync();
        String statusName = basename(file.path);
        // videos.every((element) => element.link != dataStore['src'])

        if (extension(file.path) == ".jpg") {
          if (statusIMGPathDownloaded
              .every((element) => basename(element) != basename(file.path))) {
            WhatsappImages WImg = WhatsappImages(
                name: statusName, path: file.path, isdownloaded: false.obs);
            whatsappImages.add(WImg);
            print("Status Path: ${file.path}  false");
          } else {
            WhatsappImages WImg = WhatsappImages(
                name: statusName, path: file.path, isdownloaded: true.obs);
            whatsappImages.add(WImg);
            print("Status Path: ${file.path} true");
          }
          // statusIMGPath.add(file.path);
        } else if (extension(file.path) == ".mp4") {
          String videoName = basenameWithoutExtension(file.path);
          var a = await videoInfo.getVideoInfo(file.path);
          var durationInMilli = a!.duration;
          Duration timeDuration =
              Duration(milliseconds: durationInMilli!.toInt());
          String duration = timeDuration.toString().split('.')[0];
          print("Duration: ${timeDuration.toString().split('.')[0]}");
          var video_size = double.parse(f1.size.toString()) / 1048576;

          String thumb = await _getThumbnail(file.path);
          if (statusVIDPathDownloaded
              .every((element) => basename(element) != basename(file.path))) {
            WhatsappVideo whatsappVideo = WhatsappVideo(
                name: videoName,
                path: file.path,
                thumbnail: thumb,
                duration: duration,
                size: video_size.toStringAsFixed(3),
                isdownloaded: false.obs);
            whatsappVideos.add(whatsappVideo);
            print("Status Path: ${file.path}  false");
          } else {
            WhatsappVideo whatsappVideo = WhatsappVideo(
                name: videoName,
                path: file.path,
                thumbnail: thumb,
                duration: duration,
                size: video_size.toStringAsFixed(3),
                isdownloaded: true.obs);
            whatsappVideos.add(whatsappVideo);
            print("Status Path: ${file.path} true");
          }
        }
        // print("$statusIMGPath");

      }
    } catch (e) {}
  }

  _getThumbnail(videoPathUrl) async {
    await Future.delayed(Duration(milliseconds: 200));
    String? thumb;
    try {
      thumb = await VideoThumbnail.thumbnailFile(
        video: videoPathUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,

        imageFormat: ImageFormat.WEBP,
        maxHeight:
            64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 75,
      );
    } catch (e) {
      print("Thumbnail Exception: $e");
      thumb = "none";
    }

    print("thumbnail: $thumb");
    return thumb;
  }

  void copyIMGStatus(int index) async {
    EasyLoading.show(status: "Downloading");
    File sourceFile = File(whatsappImages[index].path);

    // final directory = await getExternalStorageDirectory();
    // final directory = await getDownloadsDirectory();
    final whatsAppIMG = "whatsapp_images";
    // String dir = directory!.path + "/" + whatsAppIMG;
    String dir = AppStrings.APP_DOWNLOAD_DIRECTORY +
        "/" +
        AppStrings.WHATSAPP_IMAGE_FOLDER;
    final Directory _appDocDirFolder = Directory(dir);
    if (await _appDocDirFolder.exists()) {
      dir = _appDocDirFolder.path;
    } else {
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      dir = _appDocDirNewFolder.path;
    }

    // String dir=await AppUtil.createFolderInAppDocDir(
    //     AppStrings.WHATSAPP_IMAGE_FOLDER, AppStrings.APP_DOWNLOAD_DIRECTORY);

    String statusName = basename(whatsappImages[index].path);
    try {
      File newFile = await sourceFile.copy(dir + "/" + statusName);
      var result = await ImageGallerySaver.saveFile(newFile.path);
      if (await newFile.exists()) {
        whatsappImages[index].isdownloaded.value = true;
        EasyLoading.dismiss();
        EasyLoading.showSuccess("Downloaded Successfully");
      }
      print("Copied Path: ${newFile.path}");
      // print("Copied Path: ${result}");
    } catch (e) {
      EasyLoading.showError("Downloading Failed");

      print("copy exception: $e");
    }
  }
  

  Future<bool> checkDownloadedIMG() async {
    print("Checkig Downloaded Images");
    final String WHATSAPP_STATUSES_LOCATION = "/WhatsApp/Media/.Statuses";

    final dir = AppStrings.APP_DOWNLOAD_DIRECTORY +
        "/" +
        AppStrings.WHATSAPP_IMAGE_FOLDER;
    // String pdfDirectory = '$dir/';

    try {
      final myDir = Directory(dir);
      _folders = myDir.listSync();

      for (FileSystemEntity file in _folders) {
        FileStat f1 = file.statSync();
        String statusName = basename(file.path);
        // videos.every((element) => element.link != dataStore['src'])

        if (extension(file.path) == ".jpg") {
          statusIMGPathDownloaded.add(file.path);
          // statusIMGPath.add(file.path);
        }
        print("Downloaded Images $statusIMGPathDownloaded");
        return true;

        // print("Status Path: ${file.path}");
      }
    } catch (e) {
      print("e");
      return true;
    }
    return true;
  }

  void copyVideoStatus(int index) async {
    EasyLoading.show(status: "Downloading");
    File sourceFile = File(whatsappVideos[index].path);

    // final directory = await getExternalStorageDirectory();
    // final directory = await getDownloadsDirectory();

    // String dir = directory!.path + "/" + whatsAppIMG;
    String dir = AppStrings.APP_DOWNLOAD_DIRECTORY +
        "/" +
        AppStrings.WHATSAPP_Video_FOLDER;
    final Directory _appDocDirFolder = Directory(dir);
    if (await _appDocDirFolder.exists()) {
      dir = _appDocDirFolder.path;
    } else {
      final Directory _appDocDirNewFolder =
          await _appDocDirFolder.create(recursive: true);
      dir = _appDocDirNewFolder.path;
    }

    // String dir=await AppUtil.createFolderInAppDocDir(
    //     AppStrings.WHATSAPP_IMAGE_FOLDER, AppStrings.APP_DOWNLOAD_DIRECTORY);

    String statusName = basename(whatsappVideos[index].path);
    try {
      File newFile = await sourceFile.copy(dir + "/" + statusName);
      var result = await ImageGallerySaver.saveFile(newFile.path);
      if (await newFile.exists()) {
        whatsappVideos[index].isdownloaded.value = true;
        EasyLoading.dismiss();
        EasyLoading.showSuccess("Downloaded Successfully");
      }
      print("Video Copied Path: ${newFile.path}");
      // print("Copied Path: ${result}");
    } catch (e) {
      print("copy exception: $e");
    }
  }

  Future<bool> checkDownloadedVideos() async {
    final String WHATSAPP_STATUSES_LOCATION = "/WhatsApp/Media/.Statuses";

    final dir = AppStrings.APP_DOWNLOAD_DIRECTORY +
        "/" +
        AppStrings.WHATSAPP_Video_FOLDER;
    // String pdfDirectory = '$dir/';

    try {
      final myDir = Directory(dir);
      _folders = myDir.listSync();

      for (FileSystemEntity file in _folders) {
        FileStat f1 = file.statSync();
        String statusName = basename(file.path);
        // videos.every((element) => element.link != dataStore['src'])

        if (extension(file.path) == ".mp4") {
          statusVIDPathDownloaded.add(file.path);
          // statusIMGPath.add(file.path);
        }
        print("Downloaded Whatsapp Videos $statusVIDPathDownloaded");

        // print("Status Path: ${file.path}");
      }
    } catch (e) {
      print("e");
    }

    return true;
  }
}
