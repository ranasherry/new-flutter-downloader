import 'dart:convert';

import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_downloader/app/data/downloaded_video.dart';
import 'package:video_downloader/app/data/downloading_video.dart';
import 'package:video_downloader/app/data/video_data.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:video_downloader/app/utils/appUtils.dart';
import 'package:video_downloader/app/utils/app_strings.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:path/path.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';

import '../../../utils/images.dart';
import '../../../utils/size_config.dart';

class HomeController extends GetxController {
  // AppLovin_CTL appLovin_CTL = Get.find();
  // GoogleAdsCTL googleAdsCTL = Get.find();
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
  Rx<int> selectedIndex = 0.obs;
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
    // download(0);
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
    // String tempLinnk =
    //     "https://v16m-default.akamaized.net/fb3f826b01d283e5d96cfd0012b9de5e/65088a65/video/tos/useast2a/tos-useast2a-pve-0068/o0AQGeeJEBIVn8MCRboBvOEVQJDQBwHETlsdID/?a=0&ch=0&cr=0&dr=0&lr=all&cd=0%7C0%7C0%7C0&cv=1&br=1714&bt=857&bti=OTg7QGo5QHM0NzZALTAzYCMvcCM1NTNg&cs=0&ds=6&ft=iJOG.y7oZzv0PD18fTvxg9whL-MrBEeC~&mime_type=video_mp4&qs=4&rc=N2Y1aDUzNzRlOzs2ZmVlZEBpam11OGQ6ZjVpbjMzNzczM0BfMGJhMjUuX2MxLjUuNjBeYSMucC5mcjRfLzBgLS1kMTZzcw%3D%3D&l=20230918113511739D64E6A3ED3F0CFB8B&btag=e00088000";
    print("download call");
    var status = await Permission.storage.request();

    if (true) {
      // if (status.isGranted) {
      final baseStorage = await getExternalStorageDirectory();
      FlutterDownloader.loadTasks();

      taskId = await FlutterDownloader.enqueue(
        fileName: videos[index].name + ".mp4",

        url: videos[index].link,
        savedDir: baseStorage!.path,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      // print("Task ID:  $taskId");
      // var size=await getSizeinDouble(videos[index].link);

      DownloadingVideo downloadingTask = DownloadingVideo(
        name: videos[index].name,
        link: videos[index].link,
        taskId: taskId!,
        // size: size,
        progress: 0.0.obs,
        // downloadedSize: "0.0".obs
      );
      downloadingVideos.add(downloadingTask);
      videos.removeAt(index);
      print("video List: $videos");

      //?Temp Implementation
      print("Download path: ${baseStorage!.path}");
      // taskId = await FlutterDownloader.enqueue(
      //   fileName: "abc2" + ".mp4",

      //   url: tempLinnk,
      //   savedDir: baseStorage!.path,
      //   showNotification:
      //       true, // show download progress in status bar (for Android)
      //   openFileFromNotification:
      //       true, // click on notification to open downloaded file (for Android)
      // );
      // // print("Task ID:  $taskId");
      // // var size=await getSizeinDouble(videos[index].link);

      // DownloadingVideo downloadingTask = DownloadingVideo(
      //   name: "abc",
      //   link: tempLinnk,
      //   taskId: taskId!,
      //   // size: size,
      //   progress: 0.0.obs,
      //   // downloadedSize: "0.0".obs
      // );
      // downloadingVideos.add(downloadingTask);
      // videos.removeAt(index);
      print("video List: $videos");
    }
  }

  Future<void> getDir() async {
    final directory = await getExternalStorageDirectory();
    final dir = directory!.path;
    print("External Storage Path: $dir");
    // String pdfDirectory = '$dir/';
    final myDir = Directory(dir);

    //  var _folders1= await myDir.list().first;

    // _folders = myDir.listSync(recursive: true, followLinks: false);
    _folders = myDir.listSync();

    print("Folders: ${_folders.length}");
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
    try {
      final filePath = downloadedVideo.path;
      final mimeType =
          'video/mp4'; // Adjust the MIME type according to your video format

      await Share.shareFiles(
        [filePath],
        text: 'Sharing Video',
        subject: 'Video Subject',
        mimeTypes: [mimeType],
      );
    } catch (e) {
      print("Error sharing video: $e");
      // Handle any errors that occur during sharing.
    }
  }
  // Future<void> shareVideo(DownloadedVideo downloadedVideo) async {
  //   print("Sharing Video: $downloadedVideo");

  //   // await FlutterShare.shareFile(
  //   //   title: 'Sharing File',
  //   //   // text: 'Example share text',
  //   //   filePath: downloadedVideo.path,
  //   // );
  // }

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

  int getRandomNumber() {
    final random = Random();
    return random.nextInt(100) +
        1; // Generates a random number between 1 and 100
  }

  void callTiktokApi(String link) async {
    print("Called Tiktok Api");
    EasyLoading.show(status: "Loading...");

    final String apiUrl =
        'https://tiktok-download-without-watermark.p.rapidapi.com/analysis?url=${Uri.encodeFull(link)}';
    print("Api Url ${apiUrl}");

    final headers = {
      'X-RapidAPI-Key': '657de138e2msha94d49761460a5fp1666e0jsn8a5f3b481e79',
      'X-RapidAPI-Host': 'tiktok-download-without-watermark.p.rapidapi.com',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        print("Tiktok Api Response 200");

        final data = json.decode(response.body);
        print("Api Response ${data}");
        String playUrl = data['data']['play'];
        String title = data['data']['title'] ?? getRandomNumber().toString();
        if (title.length > 20) {
          title = title.substring(0, 20);
        }
        title = title + "_" + getRandomNumber().toString();
        print("Title_Tiktok: $title");

        print(data);

        Video newVideo = Video(
          name: "VID_" + title,
          contentType: "",
          link: playUrl,
          // size: video_size,
        );
        videos.addIf(videos.every((element) => element.link != link), newVideo);
        _showDownloadDialogue();
        EasyLoading.dismiss();
      } else {
        print("Tiktok Api Falied to load Data");
        EasyLoading.dismiss();
        EasyLoading.showError("Could not fetch");

        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Tiktok Api Catch $error");
      EasyLoading.dismiss();
      EasyLoading.showError("Could not fetch");

      print(error);
    }
  }

  void callFacebookApi(String link) async {
    print("Called Facebook Api");
    EasyLoading.show(status: "Loading...");

    final String apiUrl =
        'https://facebook-video-downloader7.p.rapidapi.com/?url=${Uri.encodeFull(link)}';
    print("Api Url ${apiUrl}");

    final headers = {
      'X-RapidAPI-Key': '657de138e2msha94d49761460a5fp1666e0jsn8a5f3b481e79',
      'X-RapidAPI-Host': 'facebook-video-downloader7.p.rapidapi.com',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        print("Facebook Api Response 200");

        final data = json.decode(response.body);
        print("Api Response ${data}");

        String playUrl = data['sd'];
        String title = data['title'] ?? getRandomNumber().toString();
        if (title.length > 20) {
          title = title.substring(0, 20);
        }
        title = title + "_" + getRandomNumber().toString();
        print("Title_Facebook: $title");

        print(data);

        Video newVideo = Video(
          name: "VID_" + title,
          contentType: "",
          link: playUrl,
          // size: video_size,
        );
        videos.addIf(videos.every((element) => element.link != link), newVideo);
        _showDownloadDialogue();
        EasyLoading.dismiss();
      } else {
        print("Facbook Api Falied to load Data");
        EasyLoading.dismiss();
        EasyLoading.showError("Could not fetch");

        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Facebook Api Catch $error");
      EasyLoading.dismiss();
      EasyLoading.showError("Could not fetch");

      print(error);
    }
  }

  void callInstagramApi(String link) async {
    print("Called Instagram Api");
    EasyLoading.show(status: "Loading...");

    final String apiUrl =
        'https://instagram-downloader-download-instagram-videos-stories.p.rapidapi.com/index?url=${Uri.encodeFull(link)}';
    print("Api Url ${apiUrl}");

    final headers = {
      'X-RapidAPI-Key': '657de138e2msha94d49761460a5fp1666e0jsn8a5f3b481e79',
      'X-RapidAPI-Host':
          'instagram-downloader-download-instagram-videos-stories.p.rapidapi.com',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        print("Instagram Api Response 200");

        final data = json.decode(response.body);
        print("Api Response ${data}");

        String playUrl = data['media'];
        String title = data['title'] ?? getRandomNumber().toString();
        if (title.length > 20) {
          title = title.substring(0, 20);
        }
        title = title + "_" + getRandomNumber().toString();
        print("Title_Instagram: $title");

        print(data);

        Video newVideo = Video(
          name: "VID_" + title,
          contentType: "",
          link: playUrl,
          // size: video_size,
        );
        videos.addIf(videos.every((element) => element.link != link), newVideo);
        _showDownloadDialogue();
        EasyLoading.dismiss();
      } else {
        print("Instagram Api Falied to load Data");
        EasyLoading.dismiss();
        EasyLoading.showError("Could not fetch");

        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Instagram Api Catch $error");
      EasyLoading.dismiss();
      EasyLoading.showError("Could not fetch");

      print(error);
    }
  }

  void callPinterestApi(String link) async {
    print("Called Pinterest Api");
    EasyLoading.show(status: "Loading...");

    final String apiUrl =
        'https://pinterest-video-and-image-downloader.p.rapidapi.com/pinterest?url=${Uri.encodeFull(link)}';
    print("Api Url ${apiUrl}");

    final headers = {
      'X-RapidAPI-Key': '657de138e2msha94d49761460a5fp1666e0jsn8a5f3b481e79',
      'X-RapidAPI-Host': 'pinterest-video-and-image-downloader.p.rapidapi.com',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        print("Pinterest Api Response 200");

        final data = json.decode(response.body);
        print("Api Response ${data}");

        String playUrl = data['data']['url'];
        String title = data['data']['title'] ?? getRandomNumber().toString();
        if (title.length > 20) {
          title = title.substring(0, 20);
        }
        title = title + "_" + getRandomNumber().toString();
        print("Title_Pinterest: $title");

        print(data);

        Video newVideo = Video(
          name: "VID_" + title,
          contentType: "",
          link: playUrl,
          // size: video_size,
        );
        videos.addIf(videos.every((element) => element.link != link), newVideo);
        _showDownloadDialogue();
        EasyLoading.dismiss();
      } else {
        print("Pinterest Api Falied to load Data");
        EasyLoading.dismiss();
        EasyLoading.showError("Could not fetch");

        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Pinterest Api Catch $error");
      EasyLoading.dismiss();
      EasyLoading.showError("Could not fetch");

      print(error);
    }
  }

  void callLikeeApi(String link) async {
    print("Called Likee Api");
    EasyLoading.show(status: "Loading...");

    final String apiUrl =
        'https://likee-downloader-download-likee-videos.p.rapidapi.com/process?url=${Uri.encodeFull(link)}';
    print("Api Url ${apiUrl}");

    final headers = {
      'X-RapidAPI-Key': '657de138e2msha94d49761460a5fp1666e0jsn8a5f3b481e79',
      'X-RapidAPI-Host':
          'likee-downloader-download-likee-videos.p.rapidapi.com',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        print("Likee Api Response 200");

        final data = json.decode(response.body);
        print("Api Response ${data}");

        String playUrl = data['withoutWater'];
        String title = data['nick_name'] ?? getRandomNumber().toString();
        if (title.length > 20) {
          title = title.substring(0, 20);
        }
        title = title + "_" + getRandomNumber().toString();
        print("Title_Likee: $title");

        print(data);

        Video newVideo = Video(
          name: "VID_" + title,
          contentType: "",
          link: playUrl,
          // size: video_size,
        );
        videos.addIf(videos.every((element) => element.link != link), newVideo);
        _showDownloadDialogue();
        EasyLoading.dismiss();
      } else {
        print("Likee Api Falied to load Data");
        EasyLoading.dismiss();
        EasyLoading.showError("Could not fetch");

        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Likee Api Catch $error");
      EasyLoading.dismiss();
      EasyLoading.showError("Could not fetch");

      print(error);
    }
  }

  void callTwitterApi(String link) async {
    print("Called Twitter Api");
    EasyLoading.show(status: "Loading...");

    final String apiUrl =
        'https://twitter-downloader-download-twitter-videos-gifs-and-images.p.rapidapi.com/status?url=${Uri.encodeFull(link)}';
    print("Api Url ${apiUrl}");

    final headers = {
      'X-RapidAPI-Key': '657de138e2msha94d49761460a5fp1666e0jsn8a5f3b481e79',
      'X-RapidAPI-Host':
          'twitter-downloader-download-twitter-videos-gifs-and-images.p.rapidapi.com',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      print("status code ${response.statusCode}");
      print("status response body ${response.body}");
      if (response.statusCode == 200) {
        print("Twitter Api Response 200");

        final data = json.decode(response.body);
        print("Api Response ${data}");

        String playUrl = data['media']['video']['videoVariants'][2]['url'];
        String title = data['description'] ?? getRandomNumber().toString();
        if (title.length > 20) {
          title = title.substring(0, 20);
        }
        title = title + "_" + getRandomNumber().toString();
        print("Title_Twitter: $title");
        print(data);
        // title = "twiter";
        Video newVideo = Video(
          name: "VID_" + title,
          contentType: "",
          link: playUrl,
          // size: video_size,
        );
        videos.addIf(videos.every((element) => element.link != link), newVideo);
        _showDownloadDialogue();
        EasyLoading.dismiss();
      } else {
        print("Twitter Api Falied to load Data");
        EasyLoading.dismiss();
        EasyLoading.showError("Could not fetch");

        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Twitter Api Catch $error");
      EasyLoading.dismiss();
      EasyLoading.showError("Could not fetch");

      print(error);
    }
  }

  void callVimeoApi(String link) async {
    print("Called Vimeo Api");
    EasyLoading.show(status: "Loading...");

    final String apiUrl =
        'https://vidsnap.p.rapidapi.com/fetch?url=${Uri.encodeFull(link)}';
    print("Api Url ${apiUrl}");

    final headers = {
      'X-RapidAPI-Key': '657de138e2msha94d49761460a5fp1666e0jsn8a5f3b481e79',
      'X-RapidAPI-Host': 'vidsnap.p.rapidapi.com',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      print("status code ${response.statusCode}");
      print("status response body ${response.body}");
      if (response.statusCode == 200) {
        print("Vimeo Api Response 200");

        final data = json.decode(response.body);
        print("Api Response ${data}");

        String playUrl = data['formats'][0]['videoData'][0]['url'];
        String title =
            data['formats'][0]['title'] ?? getRandomNumber().toString();
        if (title.length > 20) {
          title = title.substring(0, 20);
        }
        title = title + "_" + getRandomNumber().toString();
        print("Title_Vimeo: $title");
        print(data);
        // title = "twiter";
        Video newVideo = Video(
          name: "VID_" + title,
          contentType: "",
          link: playUrl,
          // size: video_size,
        );
        videos.addIf(videos.every((element) => element.link != link), newVideo);
        _showDownloadDialogue();
        EasyLoading.dismiss();
      } else {
        print("Vimeo Api Falied to load Data");
        EasyLoading.dismiss();
        EasyLoading.showError("Could not fetch");

        throw Exception('Failed to load data');
      }
    } catch (error) {
      print("Vimeo Api Catch $error");
      EasyLoading.dismiss();
      EasyLoading.showError("Could not fetch");

      print(error);
    }
  }

  void _showDownloadDialogue() async {
    // controller.watchUrl.value = "";

    Get.bottomSheet(Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 5,
          vertical: SizeConfig.blockSizeVertical * 2),
      // height: SizeConfig.blockSizeVertical * 25,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      child: Column(
        children: [
          Container(
            // height: SizeConfig.blockSizeVertical * 0.5,
            width: SizeConfig.blockSizeHorizontal * 5,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5), color: Colors.black),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Download Options",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Icon(Icons.close))
            ],
          ),
          verticalSpace(SizeConfig.blockSizeVertical * 2),
          Obx(() => Expanded(
                child: ListView.builder(
                    // shrinkWrap: true,
                    itemCount: videos.length,
                    itemBuilder: (BuildContext, index) {
                      return _downloadFileItem(index);
                    }),
              ))
        ],
      ),
    ));
  }

  Container _downloadFileItem(int index) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockSizeHorizontal * 3,
          vertical: SizeConfig.blockSizeVertical * 1.5),
      margin: EdgeInsets.symmetric(vertical: SizeConfig.blockSizeVertical),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          border: Border.all()),
      child: Row(
        children: [
          // Container(
          //   padding: EdgeInsets.all(5),
          //   decoration: BoxDecoration(color: Colors.green),
          //   child: Text("SD", style: TextStyle(color: Colors.white),),
          // ),
          horizontalSpace(SizeConfig.blockSizeHorizontal * 2),
          Container(
            width: SizeConfig.blockSizeHorizontal * 15,
            height: SizeConfig.blockSizeVertical * 5,
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FutureBuilder(
                    future: _getImage(videos[index].link),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          return Image.file(
                            File(snapshot.data.toString()),
                            fit: BoxFit.cover,
                          );
                        } else {
                          return Center(
                            child: Image.asset(
                              AppImages.thumbnail_demo,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      } else {
                        return Center(
                          child: Image.asset(
                            AppImages.thumbnail_demo,
                            fit: BoxFit.fitHeight,
                          ),
                        );
                      }
                    })),
          ),
          horizontalSpace(SizeConfig.blockSizeHorizontal * 3),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(videos[index].name),
              FutureBuilder(
                  future: getSize(videos[index].link),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        return Text("${snapshot.data.toString()} MB");

                        // Image.file(
                        //   File(snapshot.data.toString()),
                        //   fit: BoxFit.cover,
                        // );
                      } else {
                        return Text("Calculating Size...");
                      }
                    } else {
                      return Text("Calculating Size...");
                    }
                  }),

              // Text("${controller.videos[index].size.toStringAsFixed(3)} MB")
            ],
          ),
          Spacer(),
          InkWell(
              onTap: () {
                // controller.download(urls);
                download(index);

                Get.back();
                // controller.appLovin_CTL.showInterAd();
              },
              child: Icon(Icons.download)),
        ],
      ),
    );
  }

  _getImage(videoPathUrl) async {
    await Future.delayed(Duration(milliseconds: 500));
    String? thumb = await VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,

      imageFormat: ImageFormat.JPEG,
      maxHeight:
          64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    );
    print("thumbnail: $thumb");
    return thumb;
  }
}
