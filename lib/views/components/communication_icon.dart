import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CommunicationIcon extends StatelessWidget {
  final bool isSelected;
  const CommunicationIcon({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("communication").listenable(),
      builder: (context, value, child) => Badge.count(
        isLabelVisible: Hive.box("communication").isNotEmpty &&
            Hive.box("communication").get('count') != 0,
        count: Hive.box("communication").get('count') ?? 0,
        child: Image.asset(
          isSelected
              ? "assets/bottom/message_selected.png"
              : "assets/bottom/message_unselected.png",
          height: 35,
          width: 35,
        ),
      ),
    );
  }
}
