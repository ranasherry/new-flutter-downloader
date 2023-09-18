import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerCTL extends GetxController {
  //TODO: Implement HomeController
  VideoPlayerController? videoController;

  ChewieController? chewieController;
  String url = "";

  @override
  void onInit() async {
    dynamic argumentData = Get.arguments;
    if (argumentData != null) {
      print('MEMBER PROFILE CTL ${argumentData[0]}');
      url = argumentData[0];
    }
    initializePlayer();
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    if (videoController != null) videoController?.dispose();
    if (chewieController != null) {
      chewieController!.dispose();
    }
  }

  Future<void> initializePlayer() async {
    final File file = File(url);
    if (await file.exists()) {
      videoController = await VideoPlayerController.file(file);
      await Future.wait([videoController!.initialize()]);
      chewieController = ChewieController(
          videoPlayerController: videoController!,
          autoPlay: true,
          looping: true,
          materialProgressColors: ChewieProgressColors(
              playedColor: Colors.red.shade100,
              handleColor: Colors.red.shade400,
              backgroundColor: Colors.grey,
              bufferedColor: Colors.black),
          placeholder: Container(
            color: Colors.black,
          ),
          // overlay:  Container(
          //   color: Colors.greenAccent,
          // ),
          autoInitialize: true);
      update();
    }
  }
}
