// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:html_to_pdf_plus/html_to_pdf_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/config/app_status.dart';
import '../../core/themes/const_colors.dart';
import 'html_view.dart';

class PdfGenerationScreen extends StatefulWidget {
  final String id;
  const PdfGenerationScreen({super.key, required this.id});
  @override
  PdfGenerationScreenState createState() => PdfGenerationScreenState();
}

class PdfGenerationScreenState extends State<PdfGenerationScreen> {
  String? generatedPdfFilePath;
  final ScreenshotController screenshotController = ScreenshotController();
  bool _isSharing = false;

  String _singlePageReceiptHtml(String html) {
    const style =
        '<style>@page{size:auto;margin:0;}html,body{height:auto!important;min-height:0!important;overflow:visible!important;}</style>';
    final head = RegExp(r'<head[^>]*>', caseSensitive: false).firstMatch(html);
    if (head != null) {
      return html.replaceRange(head.end, head.end, style);
    }
    return '$style$html';
  }

  String _pdfFileName(String id) {
    final cleaned = id.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    return cleaned.isEmpty ? 'receipt' : cleaned;
  }

  Rect _shareOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box != null && box.attached && box.hasSize && !box.size.isEmpty) {
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (!rect.isEmpty) return rect;
    }
    final size = MediaQuery.sizeOf(context);
    return Rect.fromCenter(
      center: Offset(size.width - 28, 28),
      width: 24,
      height: 24,
    );
  }

  Future<void> _downloadReceipt(BuildContext buttonContext, String html) async {
    if (_isSharing) return;
    final origin = _shareOrigin(buttonContext);
    setState(() => _isSharing = true);
    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final pdfFile = await HtmlToPdf.convertFromHtmlContent(
        htmlContent: _singlePageReceiptHtml(html),
        configuration: PdfConfiguration(
          targetDirectory: appDocDir.path,
          targetName: _pdfFileName(widget.id),
          printSize: PrintSize.A4,
          printOrientation: PrintOrientation.Landscape,
          linksClickable: true,
          fitToSinglePage: true,
        ),
      );
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(pdfFile.path)],
          subject: 'PDF',
          text: 'PDF',
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to download the receipt. Please try again.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id),
        elevation: 0.0,
        backgroundColor: ConstColors.primary,
        actions: [
          Consumer<StudentFeeProvider>(
            builder: (context, value, child) {
              if (value.feeViewState == AppStates.Fetched) {
                final html = value.feeViewRes;
                return Builder(
                  builder: (buttonContext) {
                    return InkWell(
                      onTap: html is String && html.isNotEmpty && !_isSharing
                          ? () => _downloadReceipt(buttonContext, html)
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 18.0),
                        child: _isSharing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                "Download",
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    );
                  },
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: Consumer<StudentFeeProvider>(
        builder: (context, value, child) {
          switch (value.feeViewState) {
            case AppStates.Unintialized:
            case AppStates.Initial_Fetching:
              return const Center(child: CircularProgressIndicator());
            case AppStates.Fetched:
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    HtmlView(html: value.feeViewRes),
                    // InkWell(
                    //   onTap: () async {
                    //     final String path =
                    //         (await getExternalStorageDirectory())!.path;
                    //     final pdfFile =
                    //         await FlutterHtmlToPdf.convertFromHtmlContent(
                    //             value.feeViewRes, path, widget.id);
                    //     print("PDF File Path: ${pdfFile.path}");
                    //   },
                    //   child: Container(
                    //     child: Text("Download"),
                    //   ),
                    // ),
                  ],
                ),
              );
            case AppStates.NoInterNetConnectionState:
              return const NoDataWidget(
                imagePath: "assets/images/no_connection.svg",
                content:
                    "No internet connection detected. Please ensure that your device is connected to a Wi-Fi or cellular network.",
              );
            case AppStates.Error:
              return const NoDataWidget(
                imagePath: "assets/images/no_data.svg",
                content: "Something went wrong. Please try again later.",
              );
          }
        },
      ),
    );
  }
}
