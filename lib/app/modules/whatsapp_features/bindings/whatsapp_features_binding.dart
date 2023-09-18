import 'package:get/get.dart';

import '../controllers/whatsapp_features_controller.dart';

class WhatsappFeaturesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WhatsappFeaturesController>(
      () => WhatsappFeaturesController(),
    );
  }
}
