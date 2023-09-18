import 'package:get/get.dart';

class WhatsappVideo {
  String name;

  String path;
  String thumbnail;
  String duration;
  String size;
  Rx<bool> isdownloaded;

  WhatsappVideo({
    required this.name,
    required this.path,
    required this.thumbnail,
    required this.duration,
    required this.size,
    required this.isdownloaded
  });
}
