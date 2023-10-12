import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_downloader/app/modules/home/controllers/video_player_ctls.dart';
import 'package:video_downloader/app/utils/size_config.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Column(
      children: [
        // verticalSpace(SizeConfig.blockSizeVertical),
        GetBuilder<VideoPlayerCTL>(
          init: VideoPlayerCTL(),
          builder: (controller) => Expanded(
            child: Center(
              child: controller.videoController != null &&
                      controller.chewieController!.videoPlayerController.value
                          .isInitialized
                  ? Chewie(controller: controller.chewieController!)
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: [CircularProgressIndicator()],
                    ),
            ),
          ),
        )
      ],
    ) ,
    );
    
    
  }
}
