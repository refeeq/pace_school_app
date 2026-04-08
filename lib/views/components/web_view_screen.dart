import 'package:flutter/material.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String title;
  final String reponseUrl;
  const WebViewScreen({
    super.key,
    required this.reponseUrl,
    required this.title,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(title: widget.title),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: WebViewWidget(controller: _controller),
      ),
      //floatingActionButton: favoriteButton(),
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            const Center(child: CircularProgressIndicator());
          },
          onPageStarted: (String url) {
            const Center(child: CircularProgressIndicator());
          },
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(widget.reponseUrl));
  }
}
