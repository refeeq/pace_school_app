import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class PdfCache {
  static Future<File> getFile(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${dir.path}/pdf_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }

    final ext = _safeExt(url);
    final name = md5.convert(utf8.encode(url)).toString();
    final file = File('${cacheDir.path}/$name$ext');

    if (await file.exists() && (await file.length()) > 0) {
      final bytes = await file.readAsBytes();
      if (_looksLikePdf(bytes)) return file;
      await file.delete();
    }

    final request = await HttpClient().getUrl(Uri.parse(url));
    request.followRedirects = true;
    request.maxRedirects = 5;
    final response = await request.close();
    if (response.statusCode != 200) {
      throw Exception('Download failed (${response.statusCode})');
    }
    final bytes = await consolidateHttpClientResponseBytes(response);
    if (!_looksLikePdf(bytes)) {
      throw Exception('Invalid PDF data');
    }
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  static String _safeExt(String url) {
    final lower = url.toLowerCase();
    if (lower.contains('.pdf')) return '.pdf';
    return '.bin';
  }

  static bool _looksLikePdf(Uint8List bytes) {
    if (bytes.length < 4) return false;
    return bytes[0] == 0x25 && // %
        bytes[1] == 0x50 && // P
        bytes[2] == 0x44 && // D
        bytes[3] == 0x46; // F
  }
}

