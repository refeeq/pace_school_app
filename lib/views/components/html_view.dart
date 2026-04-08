import 'dart:developer';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

class HtmlView extends StatefulWidget {
  final String html;
  final String? baseUrl;
  /// When non-null, used as viewport initial-scale (e.g. to fit A4 content to device width).
  /// If null, uses platform default (0.6 Android / 1.0 iOS).
  final double? initialScale;

  const HtmlView({
    super.key,
    required this.html,
    this.baseUrl,
    this.initialScale,
  });

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
    // Use custom scale if provided (e.g. A4 fit-to-width), else platform default
    final scaleValue = widget.initialScale ??
        (Platform.isAndroid ? 0.6 : 1.0);
    final initialScale = scaleValue.toStringAsFixed(2);
    log('[HtmlView] _injectViewportAndStyles: htmlLength=${html.length}, initialScale=$initialScale, overflowX=${widget.initialScale != null ? "hidden" : "auto"}');
    final viewportMeta =
        '<meta name="viewport" content="width=device-width, initial-scale=$initialScale, maximum-scale=5.0, user-scalable=yes">';
    final overflowX = widget.initialScale != null ? 'hidden' : 'auto';
    final responsiveCss = '''
      <style>
        html, body { max-width: 100vw !important; overflow-x: $overflowX !important; -webkit-text-size-adjust: 100%; }
      </style>
    ''';

    final lowerHtml = html.toLowerCase();
    final headContent = viewportMeta + responsiveCss;

    // If there's a head section with opening <head> tag, add viewport
    final headMatch = RegExp(r'<head[^>]*>', caseSensitive: false).firstMatch(html);
    if (headMatch != null) {
      log('[HtmlView] _injectViewportAndStyles: injecting after <head>');
      final insertIndex = headMatch.end;
      return html.substring(0, insertIndex) + headContent + html.substring(insertIndex);
    }

    // If there's </head> but no <head>, insert before </head>
    if (lowerHtml.contains('</head>')) {
      log('[HtmlView] _injectViewportAndStyles: injecting before </head>');
      final endHeadIndex = lowerHtml.indexOf('</head>');
      return '${html.substring(0, endHeadIndex)}$headContent\n${html.substring(endHeadIndex)}';
    }

    // If there's <html> tag, add head with viewport after it
    final htmlMatch = RegExp(r'<html[^>]*>', caseSensitive: false).firstMatch(html);
    if (htmlMatch != null) {
      log('[HtmlView] _injectViewportAndStyles: injecting after <html>');
      final insertIndex = htmlMatch.end;
      return '${html.substring(0, insertIndex)}<head>$headContent</head>${html.substring(insertIndex)}';
    }

    // Fragment - wrap in full document with proper viewport and base URL context
    log('[HtmlView] _injectViewportAndStyles: fragment - wrapping in full document');
    return '<!DOCTYPE html><html><head>$headContent</head><body>$html</body></html>';
  }

  @override
  void initState() {
    super.initState();
    log('[HtmlView] initState: htmlLength=${widget.html.length}, baseUrl=${widget.baseUrl}, initialScale=${widget.initialScale}');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress % 25 == 0 || progress == 100) {
              log('[HtmlView] onProgress: $progress%');
            }
          },
          onPageStarted: (String url) {
            log('[HtmlView] onPageStarted: url=$url');
          },
          onPageFinished: (String url) {
            log('[HtmlView] onPageFinished: url=$url');
          },
          onWebResourceError: (WebResourceError error) {
            log('[HtmlView] onWebResourceError: ${error.description}, errorCode=${error.errorCode}');
          },
        ),
      );

    // Load HTML first - WebView must load content before platform is ready
    final htmlWithViewport = _injectViewportAndStyles(widget.html);
    final baseUrl = widget.baseUrl ?? 'https://gaes.paceeducation.com/';
    log('[HtmlView] loadHtmlString: baseUrl=$baseUrl, injectedHtmlLength=${htmlWithViewport.length}');
    _controller.loadHtmlString(htmlWithViewport, baseUrl: baseUrl);

    // Apply Android WebView settings after first frame (when native WebView exists)
    if (Platform.isAndroid) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _applyAndroidSettings());
    }
  }

  Future<void> _applyAndroidSettings() async {
    try {
      log('[HtmlView] _applyAndroidSettings: applying setUseWideViewPort, enableZoom');
      final androidController = _controller.platform as AndroidWebViewController;
      await androidController.setUseWideViewPort(true);
      await androidController.enableZoom(true);
      log('[HtmlView] _applyAndroidSettings: success');
    } catch (e) {
      log('[HtmlView] _applyAndroidSettings: error=$e, will retry');
      // Platform may not be ready on first frame, retry after short delay
      Future.delayed(const Duration(milliseconds: 100), () async {
        if (!mounted) return;
        try {
          final androidController = _controller.platform as AndroidWebViewController;
          await androidController.setUseWideViewPort(true);
          await androidController.enableZoom(true);
          log('[HtmlView] _applyAndroidSettings: retry success');
        } catch (e) {
          log('[HtmlView] _applyAndroidSettings: retry failed: $e');
        }
      });
    }
  }
}
