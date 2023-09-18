import 'package:get/get.dart';
import 'package:video_downloader/app/modules/home/controllers/video_player_ctls.dart';



class VideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoPlayerCTL>(
      () => VideoPlayerCTL(),
    );
  }
}
