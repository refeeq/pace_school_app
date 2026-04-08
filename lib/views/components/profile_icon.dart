import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProfileIcon extends StatelessWidget {
  final bool isSelected;
  const ProfileIcon({super.key, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box("documentExpiry").listenable(),
      builder: (context, value, child) {
        final count = Hive.box("documentExpiry").get('count') ?? 0;
        return Badge.count(
          isLabelVisible: Hive.box("documentExpiry").isNotEmpty && count != 0,
          count: count,
          backgroundColor: const Color.fromARGB(255, 175, 38, 36),
          textColor: Colors.white,
          child: Image.asset(
            isSelected
                ? "assets/bottom/profile_selected.png"
                : "assets/bottom/profile_unselected.png",
            height: 35,
            width: 35,
          ),
        );
      },
    );
  }
}
