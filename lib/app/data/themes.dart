// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/style.dart';

class Themes {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.white,
    // scaffoldBackgroundColor: AppColors.background_color,
    colorScheme: ColorScheme.light(
      primary: AppColors.selectedTabColor,
      onPrimary: Colors.white,
      // onSecondary: Colors.black12,

      onBackground: Colors.white,
      background: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
  );

  static final customTheme = ThemeData(
    // scaffoldBackgroundColor: AppColors.white,
    scaffoldBackgroundColor: AppColors.background_color,
    // textTheme: StyleSheet.home_text,
    colorScheme: ColorScheme.light(
      primary: AppColors.selectedTabColor,
      onPrimary: Colors.white,
      // onSecondary: Colors.black12,

      onBackground: Colors.white,
      background: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
  );
  static final darkTheme = ThemeData(
    
    colorScheme: ColorScheme.dark(
      primary: AppColors.selectedTabColor,
      onPrimary: Colors.white,
      // onSecondary: Colors.grey,
      onBackground: Colors.white,
      background: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      brightness: Brightness.dark,
    ),
  );
}
