import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:launch_review/launch_review.dart';
// import 'package:ripple_animation/ripple_animation.dart';

import 'package:share_plus/share_plus.dart';
import 'package:video_downloader/app/modules/home/controllers/settings_controller.dart';
import 'package:video_downloader/app/routes/app_pages.dart';
import 'package:video_downloader/app/utils/colors.dart';
import 'package:video_downloader/app/utils/size_config.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        titleTextStyle: TextStyle(
            color: AppColors.navColors,
            fontSize: SizeConfig.blockSizeHorizontal * 6),
        title: Text("Settings", style: GoogleFonts.pacifico()),
        leading: InkWell(
          onTap: () {
            Get.back();
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: AppColors.navColors,
          ),
        ),
        elevation: 0.0,
      ),
      body: Container(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockSizeHorizontal * 5,
            vertical: SizeConfig.blockSizeVertical * 1),
        child: ListView(
          children: [
            Column(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 50,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/app_ic.png'),
                  ),
                ),
// Padding(padding: EdgeInsets.all(MediaQuery.of(context).size.height*0.04),child: Text('Profile',style: GoogleFonts.pacifico()))
              ],
            ),
            _myHeadings("General"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.help_outline,
                color: AppColors.navColors,
              ),
              title: Text("How to Download",
                  style: GoogleFonts.pacifico(color: AppColors.white)),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.navColors,
              ),
              onTap: () {
                Get.toNamed(Routes.HOW_TO_SCREEN);
              },
            ),
            Divider(),
            _myHeadings("Download"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.sd_storage,
                color: AppColors.navColors,
              ),
              title: Text("Storage Location",
                  style: GoogleFonts.pacifico(color: AppColors.white)),
              subtitle: Padding(
                padding:
                    EdgeInsets.only(top: SizeConfig.blockSizeVertical * 0.5),
                child: Text("Downloads/video Downloader videos/",
                    style: GoogleFonts.pacifico(color: AppColors.navColors)),
              ),
            ),
            Divider(),
            _myHeadings("Help"),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.privacy_tip_outlined,
                color: AppColors.navColors,
              ),
              title: Text("Privacy Policy",
                  style: GoogleFonts.pacifico(color: AppColors.white)),
              onTap: () {},
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.thumb_up_outlined,
                color: AppColors.navColors,
              ),
              title: Text("Feedback",
                  style: GoogleFonts.pacifico(color: AppColors.white)),
              onTap: () {
                LaunchReview.launch(
                  androidAppId:
                      "videodownloader.newdownloader.fast.video.download.promate",
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.star_border_outlined,
                color: AppColors.navColors,
              ),
              title: Text("Rate us",
                  style: GoogleFonts.pacifico(color: AppColors.white)),
              onTap: () {
                LaunchReview.launch(
                  androidAppId:
                      "videodownloader.newdownloader.fast.video.download.promate",
                );
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.share_outlined, color: AppColors.navColors),
              title: Text("Share",
                  style: GoogleFonts.pacifico(color: AppColors.white)),
              onTap: () {
                Share.share(
                    'Download Your Favourite Videos from this Application https://play.google.com/store/apps/details?id=videodownloader.newdownloader.fast.video.download.promate');
              },
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.exit_to_app_rounded, color: AppColors.navColors),
              title: Text("Exit",
                  style: GoogleFonts.pacifico(color: AppColors.white)),
              onTap: () {
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  Text _myHeadings(String heading) {
    return Text(heading, style: GoogleFonts.pacifico(color: AppColors.navColors)

        // TextStyle(
        //     color: AppColors.black, fontSize: 18, fontWeight: FontWeight.bold, ),

        );
  }
}
