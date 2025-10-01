import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/html_view.dart';
import 'package:screenshot/screenshot.dart';

class ProgressReportPage extends StatefulWidget {
  final String title;

  const ProgressReportPage({super.key, required this.title});

  @override
  _ProgressReportPageState createState() => _ProgressReportPageState();
}

class _ProgressReportPageState extends State<ProgressReportPage> {
  String newHtmlContent = "";
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(
        title: widget.title,
        actions: [
          if (newHtmlContent.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () async {
                var image = await _screenshotController.capture();
                final pdf = await _generatePdf(context, image!);
                await Printing.sharePdf(
                  bytes: await pdf.save(),
                  filename: 'progress_report.pdf',
                );
              },
            ),
        ],
      ),
      body: Consumer<StudentProvider>(
        builder: (context, value, child) {
          switch (value.progressReport.status) {
            case AppStates.Unintialized:
            case AppStates.Initial_Fetching:
              return const Center(child: CircularProgressIndicator());
            case AppStates.Fetched:
              Future(
                () => setState(() {
                  newHtmlContent = value.progressReport.data;
                }),
              );
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Screenshot(
                  controller: _screenshotController,
                  child: HtmlView(html: value.progressReport.data),
                ),
              );
            case AppStates.NoInterNetConnectionState:
              return const Center(child: Text("Internet Connection Error"));
            case AppStates.Error:
              return Center(child: Text("${value.progressReport.message}"));
            default:
              return Container();
          }
        },
      ),
    );
  }

  Future<pw.Document> _generatePdf(
    BuildContext context,
    Uint8List imageData,
  ) async {
    final pdf = pw.Document();

    final image = pw.MemoryImage(imageData);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image, fit: pw.BoxFit.fill));
        },
      ),
    );

    return pdf;
  }
}
