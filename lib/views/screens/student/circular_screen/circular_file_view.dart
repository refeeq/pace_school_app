import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:open_file/open_file.dart';
import 'package:photo_view/photo_view.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CircularFileView extends StatelessWidget {
  final String url;
  const CircularFileView({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        appBar: const CommonAppBar(),
        body: PhotoView(imageProvider: NetworkImage(url)),
      ),
    );
  }
}

class PDFViewerFromUrl extends StatefulWidget {
  final String url;

  const PDFViewerFromUrl({super.key, required this.url});

  @override
  State<PDFViewerFromUrl> createState() => _PDFViewerFromUrlState();
}

class _PDFViewerFromUrlState extends State<PDFViewerFromUrl> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    downloadAndSavePDF(widget.url);
  }

  Future<void> downloadAndSavePDF(String url) async {
    try {
      var file = await downloadPDF(url);
      setState(() {
        localFilePath = file.path;
      });
    } catch (e) {
      debugPrint("Error downloading PDF: $e");
    }
  }

  Future<File> downloadPDF(String url) async {
    final filename = url.substring(url.lastIndexOf('/') + 1);
    var request = await HttpClient().getUrl(Uri.parse(url));
    var response = await request.close();
    var bytes = await consolidateHttpClientResponseBytes(response);
    var dir = await getApplicationDocumentsDirectory();
    File file = File("${dir.path}/$filename");
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        appBar: CommonAppBar(
          title: "",
          actions: [
            InkWell(
              child: const Padding(
                padding: EdgeInsets.only(right: 18.0),
                child: Text("Download", style: TextStyle(color: Colors.white)),
              ),
              onTap: () async {
                await launchUrlString(widget.url);
                //   downloadFile(widget.url, widget.url.split('/').last, context);
              },
            ),
          ],
        ),
        body: localFilePath != null
            ? PDFView(filePath: localFilePath!)
            : const Center(child: CircularProgressIndicator()),
      ),
    );

    // Scaffold(
    //   appBar: AppBar(
    //     title: const Text('PDF From Url'),
    //   ),
    //   body: const PDF().fromUrl(
    //     url,
    //     placeholder: (double progress) => Center(child: Text('$progress %')),
    //     errorWidget: (dynamic error) => Center(child: Text(error.toString())),
    //   ),
    // );
  }
}
