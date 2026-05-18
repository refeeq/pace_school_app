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

/// Where the toast is shown: bottom [SnackBar] or top [MaterialBanner]-style strip.
enum ToastPosition { top, bottom }

/// Shared colors for a toast by [ToastType].
(Color backgroundColor, Color textColor) _toastPalette(ToastType type) {
  switch (type) {
    case ToastType.success:
      return (const Color(0xFF34C759), Colors.white);
    case ToastType.error:
      return (const Color(0xFFE53935), Colors.white);
    case ToastType.neutral:
      return (const Color(0xFF1C1C1E), Colors.white);
  }
}

void _showTopToast(String message, BuildContext context, ToastType type) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  final (backgroundColor, textColor) = _toastPalette(type);

  ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();
  ScaffoldMessenger.maybeOf(context)?.hideCurrentMaterialBanner();

  var removed = false;
  late OverlayEntry entry;
  void removeEntry() {
    if (removed) return;
    removed = true;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) => Stack(
      children: [
        Positioned(
          top: MediaQuery.paddingOf(ctx).top + 8,
          left: 16,
          right: 16,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minHeight: 32,
                      minWidth: 32,
                    ),
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.close_rounded,
                      color: textColor.withValues(alpha: 0.88),
                      size: 17,
                    ),
                    onPressed: removeEntry,
                    tooltip: MaterialLocalizations.of(ctx).closeButtonTooltip,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );

  overlay.insert(entry);

  Future<void>.delayed(const Duration(seconds: 2), () {
    removeEntry();
  });
}

/// Shows a transient message. Uses a top [MaterialBanner] when [position] is
/// [ToastPosition.top], otherwise the existing floating bottom [SnackBar].
ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showToast(
  String message,
  BuildContext context, {
  ToastType type = ToastType.neutral,
  ToastPosition position = ToastPosition.bottom,
}) {
  if (position == ToastPosition.top) {
    _showTopToast(message, context, type);
    return null;
  }

  final (backgroundColor, textColor) = _toastPalette(type);

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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    duration: const Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  return ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// iOS-style “Copied” HUD: compact dark translucent capsule centered toward the
/// bottom of the screen. Pointer events pass through ([IgnorePointer]).
void showIosCopyHud(
  BuildContext context, {
  String message = 'Copied to Clipboard',
  Duration dwell = const Duration(milliseconds: 1850),
}) {
  final overlay = Overlay.maybeOf(context);
  if (overlay == null) return;

  ScaffoldMessenger.maybeOf(context)?.hideCurrentSnackBar();

  var removed = false;
  late OverlayEntry entry;

  void removeEntry() {
    if (removed) return;
    removed = true;
    entry.remove();
  }

  entry = OverlayEntry(
    builder: (ctx) {
      final bottomPadding = MediaQuery.paddingOf(ctx).bottom;
      const horizontalInset = 40.0;

      /// Close to Messages / system copy feedback tone.
      const capsuleFill = Color(0xD92C2C2E); // rgba(44,44,46, ~0.85)
      const labelColor = Color(0xFFE8E8ED);

      return IgnorePointer(
        child: SizedBox.expand(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalInset,
                0,
                horizontalInset,
                bottomPadding + 96,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: capsuleFill,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 28,
                      offset: const Offset(0, 10),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 13,
                  ),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: labelColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.22,
                      letterSpacing: -0.28,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  Future<void>.delayed(dwell, removeEntry);
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
    if (date.isBefore(oneMonthFromNow) ||
        date.isAtSameMomentAs(oneMonthFromNow)) {
      return DocumentExpiryStatus.expiringSoon;
    }
    return DocumentExpiryStatus.valid;
  } catch (_) {
    return DocumentExpiryStatus.valid;
  }
}
