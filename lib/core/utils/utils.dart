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

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showToast(
  String message,
  BuildContext context,
) {
  final snackBar = SnackBar(
    content: Text(message, style: const TextStyle(fontSize: 16)),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  // return Fluttertoast.showToast(
  //     msg: message,
  //     toastLength: Toast.LENGTH_SHORT,
  //     gravity: ToastGravity.BOTTOM,
  //     timeInSecForIosWeb: 1,
  //     backgroundColor: Colors.white,
  //     textColor: ConstColors.primary,
  //     fontSize: 16.0);
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
