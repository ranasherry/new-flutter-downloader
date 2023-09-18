import 'dart:convert';

import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:video_downloader/app/data/downloaded_video.dart';
import 'package:video_downloader/app/data/downloading_video.dart';
import 'package:video_downloader/app/data/video_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_downloader/app/modules/home/controllers/google_ad_ctl.dart';

import 'package:video_downloader/app/utils/appUtils.dart';
import 'package:video_downloader/app/utils/app_strings.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';

class HomeController extends GetxController {
  // AppLovin_CTL appLovin_CTL = Get.find();
  GoogleAdsCTL googleAdsCTL = Get.find();
  //TODO: Implement HomeController

  final count = 0.obs;
  TextEditingController searchTextCTL = TextEditingController();
  Rx<bool> isBrowsing = false.obs;

  //Variables Related to INAPP WEB_BROWSER
  String currentPage = "";
  Rx<bool> videoFound = true.obs;
  RxList<Video> videos = <Video>[].obs;
  RxList<DownloadingVideo> downloadingVideos = <DownloadingVideo>[].obs;
  RxList<DownloadedVideo> downloadedVideos = <DownloadedVideo>[].obs;
  final videoInfo = FlutterVideoInfo();

  ReceivePort _port = ReceivePort();

  Rx<bool> downloading = false.obs;
  Rx<bool> downloadFailed = false.obs;
  Rx<bool> downloadComplete = false.obs;
  Rx<bool> showLoader = false.obs;
  String? taskId = "";
  // String downloadUrl = "";

  // var downloadProgress = 0.obs;

  List<FileSystemEntity> _folders = [];
  @override
  void onInit() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      getDir();
      String dir =
          AppStrings.DOWNLOAD_DIRECTORY + "/" + AppStrings.APP_DOWNLOAD_FOLDER;
      final Directory _appDocDirFolder = Directory(dir);
      if (await _appDocDirFolder.exists()) {
        dir = _appDocDirFolder.path;
      } else {
        final Directory _appDocDirNewFolder =
            await _appDocDirFolder.create(recursive: true);
        dir = _appDocDirNewFolder.path;
      }
      // final dir = await getExternalStorageDirectory();
      // final path = dir!.path;
      // Directory path2 = Directory(path);
      // AppUtil.createFolderInAppDocDir(
      //     path2.path, AppStrings.APP_DOWNLOAD_FOLDER);
    }
    _bindBackgroundIsolate();

    FlutterDownloader.registerCallback(downloadCallback);
    download(0);
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  void _bindBackgroundIsolate() {
    bool isSuccess = IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    if (!isSuccess) {
      _unbindBackgroundIsolate();
      _bindBackgroundIsolate();
      return;
    }
    _port.listen((dynamic data) async {
      // if (debug) {
      //   print('UI Isolate Callback: $data');
      // }

      String? id = data[0];
      DownloadTaskStatus? status = DownloadTaskStatus.values[data[1] as int];
      int? progress = data[2];
      for (DownloadingVideo video in downloadingVideos) {
        if (video.taskId == id) {
          video.progress.value = progress!.toDouble() / 100;
          // var downloadedSize = (video.progress.value) * video.size;
          // var downloadedSizeinMB = downloadedSize / 1024 / 1024;
          // video.downloadedSize.value =
          //     downloadedSize.toStringAsFixed(2) + " MB";
          print("Downloading Progress: ${video.progress.value}");
          // print("Downloaded Size: ${video.downloadedSize.value}");
          if (status == DownloadTaskStatus.failed) {}
          if (status == DownloadTaskStatus.complete) {
            print("Download Complete");
            downloadingVideos.removeWhere((element) => element.taskId == id);
            await getDir();
          }
        }
      }
      if (taskId == id) {
        print("Progress: $progress");

        if (status == DownloadTaskStatus.complete) {}
        if (status == DownloadTaskStatus.failed) {
          print("Download Failed From Port..");
        }
      }
    });
  }

  void _unbindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
  }

  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    send!.send([id, status, progress]);
  }

  void CheckFBURL(InAppWebViewController thisController) async {
    var html = await thisController.evaluateJavascript(
        source:
            "window.document.getElementsByClassName('_53mw')[0].getAttribute('data-store')");
    if (html != null) {
      Map<String, dynamic> dataStore = json.decode(html);

      print("SRC: ${dataStore['src']}");

      // var video_size = 9.0;
      // try {
      //   var response = await dio.Dio().get(dataStore['src']);
      //   final headers = response.headers['content-length'];
      //   print("Header Value: $headers");

      //   video_size = double.parse(headers![0]) / 1048576;
      // } catch (e) {
      //   print("DartIo Exception: $e");
      // }

      Video newVideo = Video(
        name: dataStore['videoID'],
        contentType: "",
        link: dataStore['src'],
        // size: video_size,
      );

      videos.addIf(videos.every((element) => element.link != dataStore['src']),
          newVideo);

      print("Video List $videos");
    }
  }

  void CheckTikTokURL(String url) async {
    // print("CheckFBURL Called");

    if (url.contains("mime_type=video_mp4")) {
      print("tiktok URL: $url");
      String link = url;
      int min = 100000; //min and max values act as your 6 digit range
      int max = 999999;
      var randomizer = new Random();
      var rNum = min + randomizer.nextInt(max - min);

      String name = rNum.toString();
      // var video_size = 9.0;
      // try {
      //   http.Response r = await http.get(Uri.parse(link));
      //   final file_size = r.headers["content-length"];
      //   video_size = double.parse(file_size!) / 1048576;
      // } catch (e) {
      //   print("DartIo Exception: $e");
      // }

      Video newVideo = Video(
        name: name,
        contentType: "",
        link: link,
        // size: video_size,
      );
      videos.addIf(videos.every((element) => element.link != link), newVideo);
    }

    print("Video List $videos");
  }

  void download(int index) async {
    String tempLinnk =
        "https://scontent-fra5-1.xx.fbcdn.net/v/t50.33967-16/375269514_1517457762126345_695448090890486371_n.mp4?_nc_cat=110&ccb=1-7&_nc_sid=985c63&efg=eyJybHIiOjE3MTEsInJsYSI6NTEyLCJ2ZW5jb2RlX3RhZyI6Inhwdl9zZF9wcm9ncmVzc2l2ZSJ9&_nc_ohc=fIso5Ii_aVgAX-NQdpP&rl=1711&vabr=951&_nc_ht=scontent-fra5-1.xx&oh=00_AfAnq-ekPN54vvJKqzhXKZpuyrVbUKmqDql0BLfi2mj4tw&oe=6507502C";
    print("download call");
    var status = await Permission.storage.request();

    if (true) {
      // if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      FlutterDownloader.loadTasks();

      // taskId = await FlutterDownloader.enqueue(
      //   fileName: videos[index].name + ".mp4",

      //   url: videos[index].link,
      //   savedDir: baseStorage!.path,
      //   showNotification:
      //       true, // show download progress in status bar (for Android)
      //   openFileFromNotification:
      //       true, // click on notification to open downloaded file (for Android)
      // );
      // // print("Task ID:  $taskId");
      // // var size=await getSizeinDouble(videos[index].link);

      // DownloadingVideo downloadingTask = DownloadingVideo(
      //   name: videos[index].name,
      //   link: videos[index].link,
      //   taskId: taskId!,
      //   // size: size,
      //   progress: 0.0.obs,
      //   // downloadedSize: "0.0".obs
      // );
      // downloadingVideos.add(downloadingTask);
      // videos.removeAt(index);
      // print("video List: $videos");

      //?Temp Implementation
      print("Download path: ${baseStorage!.path}");
      taskId = await FlutterDownloader.enqueue(
        fileName: "abc2" + ".mp4",

        url: tempLinnk,
        savedDir: baseStorage!.path,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      // print("Task ID:  $taskId");
      // var size=await getSizeinDouble(videos[index].link);

      DownloadingVideo downloadingTask = DownloadingVideo(
        name: "abc",
        link: tempLinnk,
        taskId: taskId!,
        // size: size,
        progress: 0.0.obs,
        // downloadedSize: "0.0".obs
      );
      downloadingVideos.add(downloadingTask);
      // videos.removeAt(index);
      print("video List: $videos");
    }
  }

  Future<void> getDir() async {
    final directory = await getExternalStorageDirectory();
    final dir = directory!.path;
    // String pdfDirectory = '$dir/';
    final myDir = Directory(dir);

    //  var _folders1= await myDir.list().first;

    // _folders = myDir.listSync(recursive: true, followLinks: false);
    _folders = myDir.listSync();
    for (FileSystemEntity file in _folders) {
      FileStat f1 = file.statSync();
      String videoName = basenameWithoutExtension(file.path);

      print("Path: ${file.path}");
      var durationInMilli;

      if (extension(file.path) == ".mp4") {
        try {
          var a = await videoInfo.getVideoInfo(file.path);
          durationInMilli = a!.duration;
        } catch (e) {
          // var a = await videoInfo.getVideoInfo(file.path);
          durationInMilli = 123400;
          print("Error: $e");
        }

        Duration timeDuration =
            Duration(milliseconds: durationInMilli!.toInt());
        String duration = timeDuration.toString().split('.')[0];
        print("Duration: ${timeDuration.toString().split('.')[0]}");
        var video_size = double.parse(f1.size.toString()) / 1048576;

        DownloadedVideo v = DownloadedVideo(
            name: videoName,
            path: file.path,
            size: "${video_size.toStringAsFixed(3)} MB",
            duration: duration);
        downloadedVideos.addIf(
            downloadedVideos.every((element) => element.name != v.name), v);
        // downloadedVideos.add(v);
        print("Downloaded Video: $videoName");
      }
    }
  }

  _getThumbnail(String videoPathUrl) async {
    await Future.delayed(Duration(milliseconds: 200));

    String? thumb;
    try {
      thumb = await VideoThumbnail.thumbnailFile(
        video: videoPathUrl,
        thumbnailPath: (await getTemporaryDirectory()).path.toString(),

        imageFormat: ImageFormat.WEBP,
        maxHeight:
            64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 75,
      );
    } catch (e) {
      print("Thumbnail Exception: $e");
      thumb = "none";
    }

    print("thumbnail: $thumb");
    return thumb;
  }

  void CheckInstaURL(String url) async {
    if (url.contains("mp4") && !url.contains("bytestart")) {
      print("Instagram URL: $url");
      String link = url;
      int min = 100000; //min and max values act as your 6 digit range
      int max = 999999;
      var randomizer = new Random();
      var rNum = min + randomizer.nextInt(max - min);

      String name = rNum.toString();
      // var video_size = 9.0;
      // try {
      //   http.Response r = await http.get(Uri.parse(link));
      //   final file_size = r.headers["content-length"];
      //   video_size = double.parse(file_size!) / 1048576;
      // } catch (e) {
      //   print("DartIo Exception: $e");
      // }

      Video newVideo = Video(
        name: "VID_" + name,
        contentType: "",
        link: link,
        // size: video_size,
      );
      videos.addIf(videos.every((element) => element.link != link), newVideo);
    }
    // print("File Size: $file_size");

    print("Video List $videos");
  }

  void checkVimeoURL(String url) async {
    print("Vimeo URL: $url");
    String link = url;
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);

    String name = rNum.toString();
    // var video_size = 9.0;
    // try {
    //   http.Response r = await http.get(Uri.parse(link));
    //   final file_size = r.headers["content-length"];
    //   video_size = double.parse(file_size!) / 1048576;
    // } catch (e) {
    //   print("DartIo Exception: $e");
    // }

    Video newVideo = Video(
      name: name,
      contentType: "",
      link: link,
      // size: video_size,
    );
    videos.addIf(videos.every((element) => element.link != link), newVideo);

    // print("File Size: $file_size");

    print("Video List $videos");
  }

  void deleteVideo(DownloadedVideo downloadedVideo) {
    print("Deleting Video: $downloadedVideo");
    File(downloadedVideo.path).delete();
    downloadedVideos.remove(downloadedVideo);
  }

  Future<void> shareVideo(DownloadedVideo downloadedVideo) async {
    print("Sharing Video: $downloadedVideo");

    await FlutterShare.shareFile(
      title: 'Sharing File',
      // text: 'Example share text',
      filePath: downloadedVideo.path,
    );
  }

  void CheckSnackVideoURL(String url) async {
    if (url.contains("mp4")) {
      print("SnackVideo URL: $url");
      String link = url;
      int min = 100000; //min and max values act as your 6 digit range
      int max = 999999;
      var randomizer = new Random();
      var rNum = min + randomizer.nextInt(max - min);

      String name = rNum.toString();
      // var video_size = 9.0;
      // try {
      //   http.Response r = await http.get(Uri.parse(link));
      //   final file_size = r.headers["content-length"];
      //   video_size = double.parse(file_size!) / 1048576;
      // } catch (e) {
      //   print("DartIo Exception: $e");
      // }

      Video newVideo = Video(
        name: "VID_" + name,
        contentType: "",
        link: link,
        // size: video_size,
      );
      videos.addIf(videos.every((element) => element.link != link), newVideo);
    }
    // print("File Size: $file_size");

    print("Video List $videos");
  }

  void CheckSnackVideoURLFromWeb(InAppWebViewController thisController) async {
    var html = await thisController.evaluateJavascript(
        source:
            "window.document.getElementsByTagName('video')[0].getAttribute('src')");

    if (html != null) {
      print("Snack SRC: $html");

      String link = html;
      int min = 100000; //min and max values act as your 6 digit range
      int max = 999999;
      var randomizer = new Random();
      var rNum = min + randomizer.nextInt(max - min);

      String name = rNum.toString();
      // var video_size = 9.0;
      // try {
      //   http.Response r = await http.get(Uri.parse(link));
      //   final file_size = r.headers["content-length"];
      //   video_size = double.parse(file_size!) / 1048576;
      // } catch (e) {
      //   print("DartIo Exception: $e");
      // }

      Video newVideo = Video(
        name: "VID_" + name,
        contentType: "",
        link: link,
        // size: video_size,
      );
      videos.addIf(videos.every((element) => element.link != link), newVideo);

      print("Video List $videos");
    }
  }

//!Implementation of Video Size

  getSize(String url) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      http.Response r = await http.get(Uri.parse(url));
      final file_size = r.headers["content-length"];
      var video_size = double.parse(file_size!) / 1048576;
      return video_size.toStringAsFixed(3);
    } catch (e) {
      print("DartIo Exception: $e");
      return "Calculation Failed";
    }
  }

  getSizeinDouble(String url) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      http.Response r = await http.get(Uri.parse(url));
      final file_size = r.headers["content-length"];
      var video_size = double.parse(file_size!) / 1048576;
      return video_size.toStringAsFixed(3);
    } catch (e) {
      print("DartIo Exception: $e");
      return "Calculation Failed";
    }
  }

  void CheckLikeeVideoURLFromWeb(InAppWebViewController thisController) async {
    var html = await thisController.evaluateJavascript(
        source:
            "window.document.getElementsByTagName('video')[0].getAttribute('src')");

    if (html != null) {
      print("Likee SRC: $html");

      String link = html;
      int min = 100000; //min and max values act as your 6 digit range
      int max = 999999;
      var randomizer = new Random();
      var rNum = min + randomizer.nextInt(max - min);

      String name = rNum.toString();

      Video newVideo = Video(
        name: "VID_" + name,
        contentType: "",
        link: link,
        // size: video_size,
      );
      videos.addIf(videos.every((element) => element.link != link), newVideo);

      print("Video List $videos");
    }
  }

  void CheckShareChatVideoURLFromWeb(
      InAppWebViewController thisController) async {
    var html = await thisController.evaluateJavascript(
        source:
            "window.document.getElementsByTagName('video')[0].getAttribute('src')");

    if (html != null) {
      print("ShareChat SRC: $html");

      String link = html;
      int min = 100000; //min and max values act as your 6 digit range
      int max = 999999;
      var randomizer = new Random();
      var rNum = min + randomizer.nextInt(max - min);

      String name = rNum.toString();

      Video newVideo = Video(
        name: "VID_" + name,
        contentType: "",
        link: link,
        // size: video_size,
      );
      videos.addIf(videos.every((element) => element.link != link), newVideo);

      print("Video List $videos");
    }
  }

  void CheckChingariURL(String url) {
    print("Chingari URL: $url");
    String link = url;
    int min = 100000; //min and max values act as your 6 digit range
    int max = 999999;
    var randomizer = new Random();
    var rNum = min + randomizer.nextInt(max - min);

    String name = rNum.toString();
    // var video_size = 9.0;
    // try {
    //   http.Response r = await http.get(Uri.parse(link));
    //   final file_size = r.headers["content-length"];
    //   video_size = double.parse(file_size!) / 1048576;
    // } catch (e) {
    //   print("DartIo Exception: $e");
    // }

    Video newVideo = Video(
      name: name,
      contentType: "",
      link: link,
      // size: video_size,
    );
    videos.addIf(videos.every((element) => element.link != link), newVideo);

    print("Video List from Chingari $videos");
  }

  void CheckBitChuteURL(String url) {
    if (url.contains("mp4")) {
      print("SnackVideo URL: $url");
      String link = url;
      int min = 100000; //min and max values act as your 6 digit range
      int max = 999999;
      var randomizer = new Random();
      var rNum = min + randomizer.nextInt(max - min);

      String name = rNum.toString();
      // var video_size = 9.0;
      // try {
      //   http.Response r = await http.get(Uri.parse(link));
      //   final file_size = r.headers["content-length"];
      //   video_size = double.parse(file_size!) / 1048576;
      // } catch (e) {
      //   print("DartIo Exception: $e");
      // }

      Video newVideo = Video(
        name: "VID_" + name,
        contentType: "",
        link: link,
        // size: video_size,
      );
      videos.addIf(videos.every((element) => element.link != link), newVideo);
    }
    // print("File Size: $file_size");

    print("Video List $videos");
  }
}
