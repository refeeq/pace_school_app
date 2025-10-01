import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationIcon extends StatelessWidget {
  final bool isSelected;
  const NotificationIcon({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box('notificationCount').listenable(),
      builder: (context, value, child) {
        final count = Hive.box("notificationCount").get('count') ?? 0;
        return Badge.count(
          isLabelVisible:
              Hive.box("notificationCount").isNotEmpty && count != 0,
          count: count,
          child: Image.asset(
            isSelected
                ? "assets/bottom/notification_selected.png"
                : "assets/bottom/notification_unselected.png",
            height: 35,
            width: 35,
          ),
        );
      },
    );
  }
}
