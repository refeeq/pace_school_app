import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/models/student_menu_model.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InternalWebPage extends StatefulWidget {
  final StudentMenu studentMenu;
  const InternalWebPage({super.key, required this.studentMenu});

  @override
  State<InternalWebPage> createState() => _InternalWebPageState();
}

class _InternalWebPageState extends State<InternalWebPage> {
  WebViewController? _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    if (_controller != null) return;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            log("Loading progress: $progress%");
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true; // Show loader when page starts loading
            });
            log("Page started loading: $url");
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false; // Hide loader when page finishes loading
            });
            log("Page finished loading: $url");
          },
          onWebResourceError: (WebResourceError error) {
            log("Error loading page: $error");
          },
        ),
      )
      ..loadRequest(Uri.parse(_getUrlWithStudentCode()));
  }

  String _getUrlWithStudentCode() {
    final studentCode = Provider.of<StudentProvider>(
      context,
      listen: false,
    ).selectedStudentModel(context).studcode;
    return "${widget.studentMenu.weburl!}&admission_no=$studentCode";
  }

  void _reloadWebView() {
    setState(() {
      _isLoading = true; // Show loader when reloading
    });
    _controller?.loadRequest(Uri.parse(_getUrlWithStudentCode()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: widget.studentMenu.menuValue),
      body: Column(
        children: [
          SelectStudentWidget(
            onchanged: (index) {
              _reloadWebView(); // Reload WebView when student selection changes
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  if (_controller != null)
                    WebViewWidget(controller: _controller!),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
