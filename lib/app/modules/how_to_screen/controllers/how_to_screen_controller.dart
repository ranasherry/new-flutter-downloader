import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HowToScreenController extends GetxController {
  //TODO: Implement HowToScreenController
  final count = 0.obs;
  final pageController = PageController();
  final currentPageNotifier = ValueNotifier<int>(0);
  var pageIndex = 0.obs;
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
}
