import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:school_app/core/themes/const_colors.dart';

Widget loader() {
  return Center(
    child: Image.asset(
      "assets/images/load.gif",
      height: 90,
      color: ConstColors.primary,
    ),
  );
}

Future<void> openFile(String filePath) async {
  final result = await OpenFile.open(filePath);
  debugPrint('Open file result: ${result.type}');
}

Future showAlertLoader(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      content: Center(
        child: Image.asset(
          "assets/images/load.gif",
          height: 90,
          color: ConstColors.primary,
        ),
      ),
    ),
  );
}

/// Type of toast for styling: success (green), error (red), or neutral.
enum ToastType { success, error, neutral }

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showToast(
  String message,
  BuildContext context, {
  ToastType type = ToastType.neutral,
}) {
  Color backgroundColor;
  Color textColor;
  switch (type) {
    case ToastType.success:
      backgroundColor = const Color(0xFF34C759); // iOS green
      textColor = Colors.white;
      break;
    case ToastType.error:
      backgroundColor = const Color(0xFFE53935); // iOS-style red
      textColor = Colors.white;
      break;
    case ToastType.neutral:
      backgroundColor = const Color(0xFF1C1C1E); // Dark gray
      textColor = Colors.white;
      break;
  }

  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(
        fontSize: 15,
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
    ),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    duration: const Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }
}

String formatDateTime(DateTime dateTime) {
  final DateFormat formatter = DateFormat('MMMM d, yyyy \'at\' hh:mm a');
  return formatter.format(dateTime);
}

String formatDateString(String dateString) {
  // Parse the string into a DateTime object
  DateTime parsedDate = DateTime.parse(dateString);

  // Format the date to the desired format
  String formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(parsedDate);

  return formattedDate;
}

/// Parses RGB colour string (e.g. "0,255,0" or "231, 139, 0") to Flutter Color.
Color parseRgbColor(String rgbString) {
  if (rgbString.isEmpty) return Colors.black;
  final parts = rgbString.replaceAll(' ', '').split(',');
  if (parts.length != 3) return Colors.black;
  try {
    final r = int.parse(parts[0]).clamp(0, 255);
    final g = int.parse(parts[1]).clamp(0, 255);
    final b = int.parse(parts[2]).clamp(0, 255);
    return Color.fromRGBO(r, g, b, 1);
  } catch (_) {
    return Colors.black;
  }
}

/// Result of checking a document expiry date.
enum DocumentExpiryStatus { valid, expiringSoon, expired }

/// Parses dd/mm/yyyy date string and returns expiry status.
/// - expired: date has passed
/// - expiringSoon: date is within 1 month from now
/// - valid: otherwise
DocumentExpiryStatus getDocumentExpiryStatus(String dateStr) {
  if (dateStr.isEmpty) return DocumentExpiryStatus.valid;
  try {
    final parts = dateStr.split('/');
    if (parts.length != 3) return DocumentExpiryStatus.valid;
    final day = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final year = int.parse(parts[2]);
    final date = DateTime(year, month, day);
    final now = DateTime.now();
    if (date.isBefore(now)) return DocumentExpiryStatus.expired;
    final oneMonthFromNow = DateTime(now.year, now.month + 1, now.day);
    if (date.isBefore(oneMonthFromNow) || date.isAtSameMomentAs(oneMonthFromNow)) {
      return DocumentExpiryStatus.expiringSoon;
    }
    return DocumentExpiryStatus.valid;
  } catch (_) {
    return DocumentExpiryStatus.valid;
  }
}
