import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:html_to_pdf_plus/html_to_pdf_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/utils/error_message_utils.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';

class ReportCardDetailPage extends StatefulWidget {
  final String title;

  const ReportCardDetailPage({super.key, required this.title});

  @override
  State<ReportCardDetailPage> createState() => _ReportCardDetailPageState();
}

class _ReportCardDetailPageState extends State<ReportCardDetailPage> {
  Uint8List? _pdfBytes;
  String? _errorMessage;
  PdfControllerPinch? _pdfController;
  bool _isConverting = false;

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  String _sanitizeFilename(String title) {
    if (title.trim().isEmpty) return 'report_card';
    return title
        .trim()
        .replaceAll(RegExp(r'[/\\:*?"<>|]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
  }

  Future<void> _convertHtmlToPdf(String htmlContent) async {
    if (_isConverting) return;
    setState(() {
      _isConverting = true;
      _pdfBytes = null;
      _errorMessage = null;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'report_card_${DateTime.now().millisecondsSinceEpoch}';

      final pdfFile = await HtmlToPdf.convertFromHtmlContent(
        htmlContent: htmlContent,
        configuration: PdfConfiguration(
          targetDirectory: tempDir.path,
          targetName: fileName,
          printSize: PrintSize.A4,
          printOrientation: PrintOrientation.Portrait,
          linksClickable: true,
        ),
      );

      final bytes = await pdfFile.readAsBytes();
      if (mounted) {
        setState(() {
          _isConverting = false;
          _pdfBytes = bytes;
          _pdfController?.dispose();
          _pdfController = PdfControllerPinch(
            document: PdfDocument.openData(bytes),
            initialPage: 1,
          );
        });
      }

      try {
        await pdfFile.delete();
      } catch (_) {}
    } catch (e) {
      if (mounted) {
        setState(() {
          _isConverting = false;
          _errorMessage = toUserFriendlyErrorMessage(
            e,
            fallback: 'Unable to generate the report card. Please try again.',
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(
        title: widget.title,
        actions: [
          if (_pdfBytes != null)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () async {
                final filename = _sanitizeFilename(widget.title);
                await Printing.sharePdf(
                  bytes: _pdfBytes!,
                  filename: '$filename.pdf',
                );
              },
            ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, value, child) {
          switch (value.reportCardHtml.status) {
            case AppStates.Unintialized:
            case AppStates.Initial_Fetching:
              return const Center(child: CircularProgressIndicator());
            case AppStates.Fetched:
              final htmlContent = value.reportCardHtml.data as String?;
              if (htmlContent == null || htmlContent.isEmpty) {
                return const Center(
                    child: Text('No report card data available'));
              }

              if (_errorMessage != null) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _convertHtmlToPdf(htmlContent),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (_pdfBytes == null && !_isConverting) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _convertHtmlToPdf(htmlContent);
                });
              }
              if (_pdfBytes == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return PdfViewPinch(
                controller: _pdfController!,
                builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
                  options: const DefaultBuilderOptions(
                    loaderSwitchDuration: Duration(milliseconds: 200),
                  ),
                  documentLoaderBuilder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  pageLoaderBuilder: (_) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorBuilder: (_, error) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Unable to display the report card. Please try again.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _convertHtmlToPdf(htmlContent),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            case AppStates.NoInterNetConnectionState:
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No internet connection. Please check your network and try again.',
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            case AppStates.Error:
              final message = sanitizeErrorMessage(
                value.reportCardHtml.message,
                fallback: 'Unable to load the report card. Please try again.',
              );
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
