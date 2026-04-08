import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CommunicationIcon extends StatelessWidget {
  final bool isSelected;
  const CommunicationIcon({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("communication").listenable(),
      builder: (context, value, child) {
        final dynamic rawCount = Hive.box("communication").get('count');
        final int safeCount = (rawCount is int ? rawCount : 0).clamp(0, 999999);

        return Badge.count(
          isLabelVisible:
              Hive.box("communication").isNotEmpty && safeCount > 0,
          count: safeCount,
          child: Image.asset(
            isSelected
                ? "assets/bottom/message_selected.png"
                : "assets/bottom/message_unselected.png",
            height: 35,
            width: 35,
          ),
        );
      },
    );
  }
}
