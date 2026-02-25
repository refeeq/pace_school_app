import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/report_card_model.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/services/report_card_pdf_service.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/report_card_web_view.dart';

class ReportCardViewPage extends StatefulWidget {
  final ReportCardItem report;
  final String admissionNo;

  const ReportCardViewPage({
    super.key,
    required this.report,
    required this.admissionNo,
  });

  @override
  State<ReportCardViewPage> createState() => _ReportCardViewPageState();
}

class _ReportCardViewPageState extends State<ReportCardViewPage> {
  InAppWebViewController? _webViewController;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    log('[ReportCardViewPage] initState: report.id=${widget.report.id}, admissionNo=${widget.admissionNo}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false).getReportCardHtml(
          widget.admissionNo,
          widget.report,
        );
      }
    });
  }

  Future<void> _sharePdf() async {
    final controller = _webViewController;
    if (controller == null || _isGeneratingPdf) return;

    setState(() => _isGeneratingPdf = true);

    try {
      // On Android, use the native print dialog (no direct PDF bytes).
      if (Platform.isAndroid) {
        await ReportCardPdfService.instance.printFromWebView(
          controller,
          admissionNo: widget.admissionNo,
          reportId: widget.report.id,
        );
        // if (!mounted) return;
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(
        //     content: Text('Opened print dialog. Choose \"Save as PDF\" to export.'),
        //   ),
        // );
        return;
      }

      // iOS / macOS: generate PDF bytes and share via share_plus.
      final pdfFile = await ReportCardPdfService.instance.generatePdfFromWebView(
        controller,
        admissionNo: widget.admissionNo,
        reportId: widget.report.id,
      );

      if (!mounted) return;
      if (pdfFile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate PDF')),
        );
        return;
      }

      await ReportCardPdfService.instance.sharePdf(pdfFile);
    } catch (e, st) {
      log('[ReportCardViewPage] _sharePdf ERROR: $e');
      log('[ReportCardViewPage] stackTrace: $st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share or print: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGeneratingPdf = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(
        title: 'Report Card',
        actions: [
          Consumer<StudentProvider>(
            builder: (context, value, _) {
              final html = value.reportCardHtml.data as String?;
              final hasHtml = html != null && html.trim().isNotEmpty;
              final canShare = hasHtml &&
                  _webViewController != null &&
                  !_isGeneratingPdf;

              if (!canShare && !_isGeneratingPdf) return const SizedBox.shrink();

              if (_isGeneratingPdf) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                );
              }

              return IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: _sharePdf,
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
            case AppStates.NoInterNetConnectionState:
              return const Center(
                child: Text('Internet Connection Error'),
              );
            case AppStates.Error:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        value.reportCardHtml.message ?? 'Failed to load report',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Provider.of<StudentProvider>(
                          context,
                          listen: false,
                        ).getReportCardHtml(
                          widget.admissionNo,
                          widget.report,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            case AppStates.Fetched:
              final htmlContent = value.reportCardHtml.data as String?;
              if (htmlContent == null || htmlContent.trim().isEmpty) {
                return const Center(
                  child: Text('No report data available'),
                );
              }
              return ReportCardWebView(
                html: htmlContent,
                onWebViewCreated: (controller) {
                  if (mounted) {
                    setState(() => _webViewController = controller);
                  }
                },
              );
          }
        },
      ),
    );
  }
}
