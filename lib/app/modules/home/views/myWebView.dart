import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:video_downloader/app/modules/home/controllers/home_controller.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;
import 'package:video_downloader/app/utils/size_config.dart';

class MyWebView extends StatefulWidget {
  const MyWebView({Key? key}) : super(key: key);

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  HomeController controller = Get.find();
  PullToRefreshController pullToRefreshController = PullToRefreshController();
  final GlobalKey webViewKey = GlobalKey();
  int webViewCounter = 0;

  InAppWebViewController? webViewController;
  final extractVideoInfoJsCode = """
    (function() {
  // Find the video container element
  var videoElement = document.querySelector('div[data-sigil]');

  if (videoElement) {
    // Extract video data
    var dataStore = JSON.parse(videoElement.dataset.store);
    var authorName = dataStore.author;
    var fileName = dataStore.name;
    var sdUrl = dataStore.sd_src;
    var hdUrl = dataStore.hd_src;

    // Create an object to store the video information
    var videoInfo = {
      authorName: authorName || "N/A",
      fileName: fileName || "N/A",
      ext: "mp4",
      sdUrl: sdUrl || null,
      hdUrl: hdUrl || null
    };

    // Send the video information back to your Flutter app
    window.flutter_inappwebview.callHandler('onVideoInfoExtracted', videoInfo);
  } else {
    // Handle the case where video data is not found
    window.flutter_inappwebview.callHandler('onExtractionFail', 'Video data not found');
  }
})();

  """;
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
          useShouldOverrideUrlLoading: true,
          useShouldInterceptFetchRequest: true,
          mediaPlaybackRequiresUserGesture: true,
          useOnLoadResource: true,
          userAgent:
              "Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36"),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  Widget build(BuildContext context) {
    print("SearchTextUrl: ${controller.searchTextCTL.text}");
    return Scaffold(
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight ,
        color: Colors.red,
        child: InAppWebView(
          key: webViewKey,
          initialUrlRequest:
              URLRequest(url: Uri.parse(controller.searchTextCTL.text)),
          initialOptions: options,
          shouldInterceptFetchRequest: (InAppWebViewController controller,
              FetchRequest ajaxRequest) async {
            return ajaxRequest;
          },
          pullToRefreshController: pullToRefreshController,
          onWebViewCreated: (thisController) {
            webViewController = thisController;
            thisController.addJavaScriptHandler(
                callback: (List<dynamic> arguments) {
                  print("Callback Arguments: $arguments");
                },
                handlerName: 'onVideoInfoExtracted');

            thisController.addJavaScriptHandler(
                callback: (List<dynamic> arguments) {
                  print("Callback Arguments Failed: $arguments");
                },
                handlerName: 'onExtractionFail');
          },
          onLoadStart: (thisController, url) {
            controller.currentPage = url.toString();
            print("Current Page: ${controller.currentPage}");
          },
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
                resources: resources,
                action: PermissionRequestResponseAction.GRANT);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;
            if (![
              "http",
              "https",
              "file",
              "chrome",
              "data",
              "javascript",
              "about"
            ].contains(uri.scheme)) {
              // await canLaunchUrlString(widget.onboardUrl)
              //     ? await launchUrlString(widget.onboardUrl)
              //     : throw 'Could not launch ${widget.onboardUrl}';
              // and cancel the request
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;

            // return NavigationActionPolicy.ALLOW;
          },
          onLoadResource: (InAppWebViewController thisController,
              LoadedResource resource) async {
            print("Resources: ${resource.url}");

            if (resource.url.toString().contains("snackvideo")) {
              controller.CheckSnackVideoURL(resource.url.toString());
            }

            if (controller.currentPage.contains("tiktok")) {
              controller.CheckTikTokURL(resource.url.toString());
            } else if (controller.currentPage.contains("instagram")) {
              // controller.CheckInstaURL(resource.url.toString());
              controller.AllMp4LinkExtractor(resource.url.toString());
            } else if (controller.currentPage.contains("pin")) {
              // controller.CheckInstaURL(resource.url.toString());
              controller.AllTSLinkExtractor(resource.url.toString());
            } else if (controller.currentPage.contains("fb") ||
                controller.currentPage.contains("fb.watch") ||
                controller.currentPage.contains("facebook")) {
              controller.AllMp4LinkExtractor(resource.url.toString());
              String jsCode = """
    (function() {
      var el = document.querySelectorAll('div[data-sigil]');
      for (var i = 0; i < el.length; i++) {
        var sigil = el[i].dataset.sigil;
        if (sigil && sigil.indexOf('inlineVideo') > -1) {
          delete el[i].dataset.sigil;
          var jsonData = JSON.parse(el[i].dataset.store);
          el[i].setAttribute('onClick', 'getFBLink("'+jsonData['src']+'","'+jsonData['videoID']+'");');
        }
      }
    })();
  """;

              // Execute the JavaScript code in the WebView
              await thisController.evaluateJavascript(source: jsCode);
            } else if (controller.currentPage.contains("chingari.io")) {
              print("Before Sending URL ${resource.url}");

              if (resource.url.toString().endsWith(".mp4")) {
                // print("Sending URL");
                controller.CheckChingariURL(resource.url.toString());
              }
            } else if (controller.currentPage.contains("bitchute.com")) {
              controller.CheckBitChuteURL(resource.url.toString());
            }

            // http.Response r =
            //     await http.get(Uri.parse(resource.url.toString()));

            // String? content_type = r.headers['content-type'];

            // if (content_type!.contains("video") ||
            //     content_type.contains("mp4") ||
            //     content_type.contains("googleusercontent") ||
            //     content_type.contains("embed")) {
            //   String link = resource.url.toString();

            //   if (link.contains("mp4") && link.contains("video")) {
            //     // link = link.replaceAll("(segment-)+(\\d+)", "SEGMENT");
            //     int b = link.lastIndexOf("?range");
            //     int f = link.indexOf("https");

            //     if (b > 0) {
            //       link = "${link.substring(f, b)}";
            //     }

            //     if (controller.currentPage.contains("vimeo")) {
            //       print("Vimeo URL: $link");
            //       controller.checkVimeoURL(link);
            //     }
            //   }
            // }

            // print("Resources: ${resource.url}");
          },
          onLoadStop: (thisController, url1) async {
            await webViewController?.evaluateJavascript(
                source: extractVideoInfoJsCode);
          },
          onLoadError: (controller, url, code, message) {},
          onProgressChanged: (thisController, progress) async {
            Uri? url = await thisController.getUrl();
            controller.currentPage = url.toString();

            print("Page Progress: $progress");
            if (progress > 50) {
              print("Current Page: ${controller.currentPage}");
              if (controller.currentPage.contains("m.facebook.com") ||
                  controller.currentPage.contains("fb.watch")) {
                controller.CheckFBURL(thisController);
              }

              if (controller.currentPage.contains("m.snackvideo.com")) {
                controller.CheckSnackVideoURLFromWeb(thisController);
              }
              if (controller.currentPage.contains("likee.video")) {
                controller.CheckLikeeVideoURLFromWeb(thisController);
              }
              if (controller.currentPage.contains("sharechat")) {
                controller.CheckShareChatVideoURLFromWeb(thisController);
              }
              if (controller.currentPage.contains("intent:")) {
                String changedUrl = controller.currentPage
                    .toString()
                    .replaceAll("intent://", "");
                print("Changed URL: $changedUrl");
                thisController.loadUrl(
                    urlRequest: URLRequest(url: Uri.parse(changedUrl)));
                controller.CheckShareChatVideoURLFromWeb(thisController);
              }
            }
          },
          onUpdateVisitedHistory: (controller, url, androidIsReload) {},
          onConsoleMessage: (controller, consoleMessage) {
            print(consoleMessage);
          },
        ),
      ),
    );
  }
}
