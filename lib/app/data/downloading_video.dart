import 'package:get/get.dart';

class DownloadingVideo {
  String name;
  String link;
  String taskId;
  // double size;
  Rx<double> progress;
  // Rx<String> downloadedSize;
  DownloadingVideo(
      {required this.name,
      required this.link,
      required this.taskId,
      // required this.size,
      required this.progress,
      // required this.downloadedSize
      });
}
