import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Generates PDF from WebView content using native createPdf and shares via share_plus.
class ReportCardPdfService {
  ReportCardPdfService._();
  static final ReportCardPdfService instance = ReportCardPdfService._();

  /// Generates PDF from the WebView's current content and saves to temp directory.
  /// Returns the PDF file, or null if generation failed.
  Future<File?> generatePdfFromWebView(
    InAppWebViewController controller, {
    required String admissionNo,
    required String reportId,
  }) async {
    // createPdf is only implemented on iOS / macOS.
    if (!kIsWeb &&
        !(Platform.isIOS || Platform.isMacOS)) {
      log('[ReportCardPdfService] generatePdfFromWebView: createPdf not supported on this platform');
      return null;
    }

    try {
      log('[ReportCardPdfService] generatePdfFromWebView: calling createPdf');
      final bytes = await controller.createPdf();

      if (bytes == null || bytes.isEmpty) {
        log('[ReportCardPdfService] createPdf returned null or empty');
        return null;
      }

      log('[ReportCardPdfService] PDF bytes length=${bytes.length}');

      final tempDir = await getTemporaryDirectory();
      final fileName = 'Report_Card_${admissionNo}_${reportId}.pdf';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);

      log('[ReportCardPdfService] PDF saved to ${file.path}');
      return file;
    } catch (e, st) {
      log('[ReportCardPdfService] generatePdfFromWebView ERROR: $e');
      log('[ReportCardPdfService] stackTrace: $st');
      return null;
    }
  }

  /// Opens the native print dialog for the current WebView content (Android/iOS/macOS).
  /// On Android, this is the only way to create a PDF from a WebView using native APIs.
  Future<void> printFromWebView(
    InAppWebViewController controller, {
    required String admissionNo,
    required String reportId,
  }) async {
    try {
      log('[ReportCardPdfService] printFromWebView: starting print job');
      final jobName = 'Report Card $admissionNo - $reportId';

      // On Android, inject print-specific CSS to:
      // - Force A4 page size and margins.
      // - Avoid page breaks inside tables / important sections.
      // - Prevent images/tables from overflowing page width.
      // - Reduce the chance of extra blank pages.
      //
      // This CSS only applies for printing and does not affect on-screen layout.
      if (!kIsWeb && Platform.isAndroid) {
        const androidPrintCss = r'''
          (function() {
            try {
              var existing = document.getElementById('android-print-style');
              if (existing) {
                return;
              }
              var style = document.createElement('style');
              style.id = 'android-print-style';
              style.type = 'text/css';
              style.appendChild(document.createTextNode(`
                @page {
                  size: A4 portrait;
                  margin: 10mm 8mm 10mm 8mm;
                }

                @media print {
                  html, body {
                    margin: 0;
                    padding: 0;
                    width: 210mm;
                    max-width: 210mm;
                    -webkit-print-color-adjust: exact;
                    print-color-adjust: exact;
                  }

                  body {
                    box-sizing: border-box;
                  }

                  /* Generic page containers, if present */
                  .page, .report-page {
                    width: 100%;
                    max-width: 100%;
                    box-sizing: border-box;
                    page-break-after: always;
                    page-break-inside: avoid;
                  }

                  .page:last-child,
                  .report-page:last-child {
                    page-break-after: auto;
                  }

                  /* Avoid breaking important sections across pages */
                  .no-break,
                  .report-header,
                  .report-footer,
                  .report-summary,
                  .report-table-section {
                    page-break-inside: avoid;
                  }

                  table {
                    width: 100% !important;
                    max-width: 100% !important;
                    border-collapse: collapse;
                    page-break-inside: avoid;
                  }

                  thead, tbody, tr, th, td {
                    page-break-inside: avoid;
                  }

                  img {
                    max-width: 100% !important;
                    height: auto !important;
                    page-break-inside: avoid;
                  }

                  * {
                    box-sizing: border-box;
                    overflow-wrap: break-word;
                    word-wrap: break-word;
                  }

                  /* Explicit manual page-break helpers if backend uses them */
                  .page-break {
                    page-break-before: always;
                  }
                }
              `));
              (document.head || document.getElementsByTagName('head')[0]).appendChild(style);
            } catch (e) {
              console.log('Android print CSS injection error', e);
            }
          })();
        ''';

        log('[ReportCardPdfService] printFromWebView: injecting Android print CSS');
        await controller.evaluateJavascript(source: androidPrintCss);

        // Give the WebView a short time window to reflow layout
        // before snapshotting content for the print/PDF output.
        await Future.delayed(const Duration(milliseconds: 700));
      }

      final settings = PrintJobSettings(
        handledByClient: false,
        jobName: jobName,
        mediaSize: PrintJobMediaSize.ISO_A4,
        headerAndFooter: false,
        margins: EdgeInsets.zero,
        scalingFactor: 0.93,
      );

      await controller.printCurrentPage(settings: settings);
      log('[ReportCardPdfService] printFromWebView: print dialog opened');
    } catch (e, st) {
      log('[ReportCardPdfService] printFromWebView ERROR: $e');
      log('[ReportCardPdfService] stackTrace: $st');
      rethrow;
    }
  }

  /// Shares the PDF file via the system share sheet.
  Future<void> sharePdf(File pdfFile) async {
    try {
      log('[ReportCardPdfService] sharePdf: ${pdfFile.path}');
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        subject: 'Report Card',
        text: 'Report Card',
      );
      log('[ReportCardPdfService] share completed');

      try {
        await pdfFile.delete();
      } catch (_) {}
    } catch (e, st) {
      log('[ReportCardPdfService] sharePdf ERROR: $e');
      log('[ReportCardPdfService] stackTrace: $st');
      rethrow;
    }
  }
}
