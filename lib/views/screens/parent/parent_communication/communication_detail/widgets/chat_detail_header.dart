import 'package:flutter/material.dart';

class ChatDetailHeader extends StatelessWidget {
  const ChatDetailHeader({
    super.key,
    required this.senderName,
    required this.iconUrl,
    required this.subtitle,
    required this.onBackTap,
    required this.onMoreTap,
  });

  final String senderName;

  /// Same [CommunicationTileModel.iconUrl] as the chat list tile.
  final String iconUrl;
  final String subtitle;
  final VoidCallback onBackTap;
  final VoidCallback onMoreTap;

  static const Color _headerBg = Color(0xFF1A4A8A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _headerBg,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Material(
              color: const Color.fromRGBO(255, 255, 255, 0.15),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onBackTap,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _HeaderLeadAvatar(iconUrl: iconUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                  if (subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color.fromRGBO(255, 255, 255, 0.55),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Material(
              color: const Color.fromRGBO(255, 255, 255, 0.12),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onMoreTap,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                  child: Icon(Icons.more_vert, color: Colors.white, size: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Same image / fallback semantics as the list tile, sized for the blue header bar.
class _HeaderLeadAvatar extends StatelessWidget {
  const _HeaderLeadAvatar({required this.iconUrl});

  final String iconUrl;

  static const Color _fallbackFill = Color.fromRGBO(255, 255, 255, 0.15);

  @override
  Widget build(BuildContext context) {
    final hasIcon = iconUrl.trim().isNotEmpty;
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color.fromRGBO(255, 255, 255, 0.25),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: hasIcon
          ? Image.network(
              iconUrl,
              width: 38,
              height: 38,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            )
          : _fallback(),
    );
  }

  Widget _fallback() {
    return const ColoredBox(
      color: _fallbackFill,
      child: Center(
        child: Icon(Icons.person_outline, color: Colors.white, size: 20),
      ),
    );
  }
}
