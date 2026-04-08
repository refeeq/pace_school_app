import 'package:flutter/material.dart';

class AdmissionStatusColors {
  static const Map<String, Color> statusColors = {
    '1': Colors.orange,
    '2': Colors.lightBlue,
    '3': Colors.purple,
    '4': Colors.green,
    '5': Colors.blue,
    '6': Colors.grey,
    '7': Colors.brown,
    '8': Colors.red,
    '9': Colors.black54,
    '10': Colors.black,
    '11': Colors.yellow,
  };

  static Color getColor(String status) {
    return statusColors[status] ??
        Colors.white; // Default to white if status is not found
  }
}
