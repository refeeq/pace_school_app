import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class HtmlView extends StatefulWidget {
  final String html;
  final String? baseUrl;

  const HtmlView({super.key, required this.html, this.baseUrl});

  @override
  State<HtmlView> createState() => _HtmlViewState();
}

class _HtmlViewState extends State<HtmlView> {
  late final WebViewController _controller;

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }

  String _injectViewportAndStyles(String html) {
    // Use smaller initial-scale on Android - API HTML is desktop-designed with large fonts
    final initialScale = Platform.isAndroid ? '0.6' : '1.0';
    final viewportMeta =
        '<meta name="viewport" content="width=device-width, initial-scale=$initialScale, maximum-scale=5.0, user-scalable=yes">';
    const responsiveCss = '''
      <style>
        html, body { max-width: 100vw !important; overflow-x: auto !important; -webkit-text-size-adjust: 100%; }
      </style>
    ''';

    final lowerHtml = html.toLowerCase();
    final headContent = viewportMeta + responsiveCss;

    // If there's a head section with opening <head> tag, add viewport
    final headMatch = RegExp(r'<head[^>]*>', caseSensitive: false).firstMatch(html);
    if (headMatch != null) {
      final insertIndex = headMatch.end;
      return html.substring(0, insertIndex) + headContent + html.substring(insertIndex);
    }

    // If there's </head> but no <head>, insert before </head>
    if (lowerHtml.contains('</head>')) {
      final endHeadIndex = lowerHtml.indexOf('</head>');
      return '${html.substring(0, endHeadIndex)}$headContent\n${html.substring(endHeadIndex)}';
    }

    // If there's <html> tag, add head with viewport after it
    final htmlMatch = RegExp(r'<html[^>]*>', caseSensitive: false).firstMatch(html);
    if (htmlMatch != null) {
      final insertIndex = htmlMatch.end;
      return '${html.substring(0, insertIndex)}<head>$headContent</head>${html.substring(insertIndex)}';
    }

    // Fragment - wrap in full document with proper viewport and base URL context
    return '<!DOCTYPE html><html><head>$headContent</head><body>$html</body></html>';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      );

    // Load HTML first - WebView must load content before platform is ready
    final htmlWithViewport = _injectViewportAndStyles(widget.html);
    final baseUrl = widget.baseUrl ?? 'https://gaes.paceeducation.com/';
    _controller.loadHtmlString(htmlWithViewport, baseUrl: baseUrl);

    // Apply Android WebView settings after first frame (when native WebView exists)
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyAndroidSettings());
    }
  }

  Future<void> _applyAndroidSettings() async {
    try {
      final androidController = _controller.platform as AndroidWebViewController;
      await androidController.setUseWideViewPort(true);
      await androidController.enableZoom(true);
    } catch (_) {
      // Platform may not be ready on first frame, retry after short delay
      Future.delayed(const Duration(milliseconds: 100), () async {
        if (!mounted) return;
        try {
          final androidController = _controller.platform as AndroidWebViewController;
          await androidController.setUseWideViewPort(true);
          await androidController.enableZoom(true);
        } catch (_) {}
      });
    }
  }
}
