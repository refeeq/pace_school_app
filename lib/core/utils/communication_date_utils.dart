import 'package:intl/intl.dart';

/// Parses [dateAdded] strings returned by communication APIs.
DateTime? tryParseCommunicationDate(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return null;

  final iso = DateTime.tryParse(s);
  if (iso != null) return iso;

  final patterns = [
    'dd-MM-yyyy hh:mm:ss a',
    'dd-MM-yyyy HH:mm:ss',
    'dd-MM-yyyy',
    'yyyy-MM-dd HH:mm:ss',
    'yyyy-MM-dd',
    'dd/MM/yyyy HH:mm:ss',
    'dd/MM/yyyy',
  ];
  for (final pattern in patterns) {
    try {
      return DateFormat(pattern).parse(s);
    } catch (_) {}
  }
  return null;
}

/// Parsed date/time for layout (e.g. date on one line, time below).
/// Returns `null` when [raw] is empty or cannot be parsed.
({String date, String time})? communicationDateTimeParts(String raw) {
  if (raw.trim().isEmpty) return null;
  final dt = tryParseCommunicationDate(raw);
  if (dt == null) return null;
  return (
    date: DateFormat('dd-MM-yyyy').format(dt),
    time: DateFormat('hh:mm a').format(dt).toLowerCase(),
  );
}

/// Single-line display: `18-09-2023 03:45 pm`
String formatCommunicationDateDdMmYyyy(String dateAdded) {
  final parts = communicationDateTimeParts(dateAdded);
  if (parts == null) {
    if (dateAdded.trim().isEmpty) return '';
    return dateAdded;
  }
  return '${parts.date} ${parts.time}';
}
