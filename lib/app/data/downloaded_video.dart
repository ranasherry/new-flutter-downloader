import 'dart:io';

import 'package:get/get.dart';

class DownloadedVideo {
  String name;
  String path;
  String size;
  String duration;
  // File thumbnail;

  DownloadedVideo({
    required this.name,
    required this.path,
    required this.size,
    required this.duration,

    // required this.thumbnail,
  });
}
