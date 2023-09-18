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
  InAppWebViewGroupOptions options = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        useShouldOverrideUrlLoading: true,
        useShouldInterceptFetchRequest: true,
        mediaPlaybackRequiresUserGesture: false,
        useOnLoadResource: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
      ios: IOSInAppWebViewOptions(
        allowsInlineMediaPlayback: true,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: SizeConfig.screenWidth,
        height: SizeConfig.screenHeight,
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

            return NavigationActionPolicy.ALLOW;
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
              controller.CheckInstaURL(resource.url.toString());
            }
            else if(controller.currentPage.contains("chingari.io")){
                print("Before Sending URL ${resource.url}");

              if(resource.url.toString().endsWith(".mp4")){
                // print("Sending URL");
                   controller.CheckChingariURL(resource.url.toString());
              }
             

            }else if(controller.currentPage.contains("bitchute.com")){
              controller.CheckBitChuteURL(resource.url.toString());



              }

                http.Response r =
                await http.get(Uri.parse(resource.url.toString()));

            String? content_type = r.headers['content-type'];

            if (content_type!.contains("video") ||
                content_type.contains("mp4") ||
                content_type.contains("googleusercontent") ||
                content_type.contains("embed")) {
              String link = resource.url.toString();

              if (link.contains("mp4") && link.contains("video")) {
                // link = link.replaceAll("(segment-)+(\\d+)", "SEGMENT");
                int b = link.lastIndexOf("?range");
                int f = link.indexOf("https");
                if (b > 0) {
                  link = "${link.substring(f, b)}";
                }

                if (controller.currentPage.contains("vimeo")) {
                  print("Vimeo URL: $link");
                  controller.checkVimeoURL(link);
                }
              }
            }

            // print("Resources: ${resource.url}");
          },
          onLoadStop: (thisController, url1) async {},
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
