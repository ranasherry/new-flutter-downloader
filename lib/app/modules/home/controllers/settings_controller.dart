import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_downloader/app/utils/app_strings.dart';

class SettingsController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;
  TextEditingController searchTextCTL = TextEditingController();
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}
  void increment() => count.value++;

  // Future<void> openDownloadDirectory(BuildContext context) async {
  //   final directory = await getExternalStorageDirectory();
  //   final dir = directory!.path;
  //   // String dir =
  //   //     AppStrings.DOWNLOAD_DIRECTORY + "/" + AppStrings.APP_DOWNLOAD_FOLDER;
  //   final Directory videoDir = Directory(dir);

  //   if (await videoDir.exists()) {
  //     // Process.run(
  //     //   "explorer",
  //     //   [dir],
  //     //   workingDirectory: dir,
  //     // );
  //     // OpenFile.open(videoDir.path); // Open the directory using OpenFile
  //   } else {
  //     Get.snackbar("Error", "Download directory does not exist.");
  //   }
  // }
}
