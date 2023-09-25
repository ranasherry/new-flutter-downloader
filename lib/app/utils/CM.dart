import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/size_config.dart';

class ComFunction {
  static bool validateEmail(String email) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(email);
    return emailValid;
  }

  static hideKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static showExitDialog({
    required String title,
    required String msg,
  }) {
    Get.defaultDialog(
        title: title,
        middleText: msg,
        textConfirm: "Yes",
        textCancel: "No",
        onCancel: () {
          // Get.back();
        },
        onConfirm: () {
          SystemNavigator.pop();
        },
        titleStyle: TextStyle(color: Colors.blue),
        confirmTextColor: AppColors.white);
  }

  static showInfoDialog({
    required String title,
    required String msg,
  }) {
    Get.defaultDialog(
        title: title,
        middleText: msg,
        radius: 10,
        textConfirm: "OK",
        onConfirm: () {
          Get.back();
        },
        titleStyle: TextStyle(color: Colors.blue),
        confirmTextColor: AppColors.white);
  }

  // static showToast(String message) {
  //   Fluttertoast.showToast(
  //       msg: message,
  //       toastLength: Toast.LENGTH_SHORT,
  //       gravity: ToastGravity.CENTER,
  //       backgroundColor: AppColor.primaryBlue,
  //       textColor: AppColor.white,
  //       fontSize: 16.0);
  // }

  static showProgressLoader(String msg) {
    EasyLoading.show(status: msg);
  }

  static hideProgressLoader() {
    EasyLoading.dismiss();
  }

  static void initializeLoader() {
    EasyLoading.instance
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 60
      ..radius = 20
      ..backgroundColor = AppColors.white
      ..indicatorColor = Colors.blue
      ..textColor = Colors.white
      ..userInteractions = true
      ..dismissOnTap = false
      ..indicatorType = EasyLoadingIndicatorType.circle;
  }
}

Container NativeAdMethed(NativeAd? nativeAd, RxBool isNativeAdLoaded) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical * 1.5),
    child: Obx(() => isNativeAdLoaded.value
        ? Container(width: 320, height: 280, child: AdWidget(ad: nativeAd!))
        : Container(
            width: 320,
            height: 280,
            // color: Colors.grey,

            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey)),
            child: Center(
                child: Text(
              "Ads Placement",
              style: TextStyle(color: Colors.white, fontSize: 22),
            )),
          )),
  );
}
