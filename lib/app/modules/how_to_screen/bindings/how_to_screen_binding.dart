import 'package:get/get.dart';

import '../controllers/how_to_screen_controller.dart';

class HowToScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HowToScreenController>(
      () => HowToScreenController(),
    );
  }
}
