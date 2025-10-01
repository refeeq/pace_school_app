// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

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
                return InkWell(
                  child: const Padding(
                    padding: EdgeInsets.only(right: 18.0),
                    child: Text(
                      "Download",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  onTap: () async {
                    Directory appDocDir =
                        await getApplicationDocumentsDirectory();
                    final targetPath = appDocDir.path;
                    var targetFileName = widget.id;

                    await HtmlToPdf.convertFromHtmlContent(
                      htmlContent: value.feeViewRes,
                      configuration: PdfConfiguration(
                        targetDirectory: targetPath,
                        targetName: targetFileName,
                        printSize: PrintSize.A4,
                        printOrientation: PrintOrientation.Landscape,
                        linksClickable: true,
                      ),
                    ).then(
                      (value) => SharePlus.instance.share(
                        ShareParams(
                          files: [XFile(value.path)],
                          subject: 'PDF',
                          text: 'PDF',
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
                imagePath: "assets/images/error.svg",
                content: "Something went wrong. Please try again later.",
              );
          }
        },
      ),
    );
  }
}
