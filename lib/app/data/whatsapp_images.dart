import 'package:get/get.dart';

class WhatsappImages {
  String name;

  String path;
  Rx<bool> isdownloaded;

  WhatsappImages({
    required this.name,
    required this.path,
    required this.isdownloaded
  });
}
