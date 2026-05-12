import 'package:flutter/material.dart';
import 'package:school_app/core/themes/const_colors.dart';

/// Message-row avatar: matches [CommunicationListItem] (network icon or fallback).
class SenderAvatar extends StatelessWidget {
  const SenderAvatar({super.key, required this.iconUrl, required this.visible});

  final String iconUrl;
  final bool visible;

  static const double _diameter = 28;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox(width: _diameter);
    }
    final hasIcon = iconUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: _diameter / 2,
      backgroundColor: ConstColors.primary.withValues(alpha: 0.1),
      backgroundImage: hasIcon ? NetworkImage(iconUrl) : null,
      child: hasIcon
          ? null
          : Icon(Icons.person_outline, color: ConstColors.primary, size: 14),
    );
  }
}
