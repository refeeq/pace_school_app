import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HtmlView extends StatefulWidget {
  final String html;
  const HtmlView({super.key, required this.html});

  @override
  State<HtmlView> createState() => _HtmlViewState();
}

class _HtmlViewState extends State<HtmlView> {
  late final WebViewController _controller;
  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }

  @override
  void initState() {
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
      ..loadHtmlString(widget.html);
    super.initState();
  }
}
