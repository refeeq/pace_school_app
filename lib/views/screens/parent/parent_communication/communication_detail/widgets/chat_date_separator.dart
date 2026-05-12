import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatDateSeparator extends StatelessWidget {
  const ChatDateSeparator({super.key, required this.date});

  final DateTime date;

  String _label(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dDay = DateTime(d.year, d.month, d.day);
    if (dDay == today) return 'Today';
    if (dDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    }
    if (d.year == now.year) {
      return DateFormat('dd MMM').format(d);
    }
    return DateFormat('dd MMM yyyy').format(d);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _label(date),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C2C2E),
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}
