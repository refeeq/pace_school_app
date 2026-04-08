import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Displays report card HTML in InAppWebView using loadData.
/// Exposes the controller for PDF generation / printing.
class ReportCardWebView extends StatefulWidget {
  final String html;
  final void Function(InAppWebViewController controller) onWebViewCreated;

  const ReportCardWebView({
    super.key,
    required this.html,
    required this.onWebViewCreated,
  });

  @override
  State<ReportCardWebView> createState() => _ReportCardWebViewState();
}

class _ReportCardWebViewState extends State<ReportCardWebView> {
  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialData: InAppWebViewInitialData(
        data: widget.html,
        mimeType: 'text/html',
        encoding: 'utf-8',
        baseUrl: WebUri('about:blank'),
      ),
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        domStorageEnabled: true,
        useWideViewPort: true,
        loadWithOverviewMode: true,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        useOnLoadResource: true,
      ),
      onWebViewCreated: (controller) {
        widget.onWebViewCreated(controller);
      },
    );
  }
}
