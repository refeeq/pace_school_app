import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/themes/const_colors.dart';

/// One conversation row — mirrors [CommunicationSubMessage] card styling.
class CommunicationListItem extends StatelessWidget {
  const CommunicationListItem({
    super.key,
    required this.model,
    required this.timeLabel,
    required this.onTap,
  });

  final CommunicationTileModel model;
  final String timeLabel;
  final VoidCallback onTap;

  static const Color _titleColorUnread = Color.fromRGBO(22, 28, 42, 1);
  static const Color _titleColorRead = Color.fromRGBO(42, 47, 60, 1);

  /// Darker than before for clearer contrast against white card.
  static const Color _mutedTime = Color.fromARGB(255, 100, 108, 128);
  static const Color _previewUnread = Color.fromRGBO(55, 75, 200, 1);
  static const Color _previewRead = Color.fromRGBO(74, 80, 98, 1);
  static const Color _badgePurple = Color(0xFF7C4DFF);

  static _TagKind? _tagKind(String type) {
    final t = type.toLowerCase();
    if (t.contains('alert')) return _TagKind.alert;
    if (t.contains('notice')) return _TagKind.notice;
    if (t.contains('update')) return _TagKind.update;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final unread = model.cnt > 0;
    final tag = _tagKind(model.type);
    final hasIcon = model.iconUrl.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: ConstColors.filledColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ConstColors.borderColor.withValues(alpha: 0.85),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Container(
              constraints: const BoxConstraints(minHeight: 90),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: ConstColors.primary.withValues(alpha: 0.1),
                    backgroundImage: hasIcon
                        ? NetworkImage(model.iconUrl)
                        : null,
                    child: hasIcon
                        ? null
                        : Icon(
                            Icons.person_outline,
                            color: ConstColors.primary,
                            size: 26,
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                model.type,
                                style: GoogleFonts.nunitoSans(
                                  textStyle: TextStyle(
                                    color: unread
                                        ? _titleColorUnread
                                        : _titleColorRead,
                                    fontSize: 16,
                                    letterSpacing: -0.2,
                                    fontWeight: unread
                                        ? FontWeight.w800
                                        : FontWeight.w700,
                                    height: 1.2,
                                  ),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeLabel,
                              style: GoogleFonts.nunitoSans(
                                textStyle: const TextStyle(
                                  letterSpacing: 0.05,
                                  color: _mutedTime,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                model.lastMessage.isEmpty
                                    ? ''
                                    : model.lastMessage,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    color: unread
                                        ? _previewUnread
                                        : _previewRead,
                                    fontWeight: unread
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    fontSize: 13.5,
                                    height: 1.35,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ),
                            ),
                            if (model.cnt > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: _badgePurple,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  model.cnt > 99 ? '99+' : '${model.cnt}',
                                  style: GoogleFonts.nunitoSans(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ] else if (tag != null)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: _TagChip(kind: tag),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum _TagKind { alert, notice, update }

class _TagChip extends StatelessWidget {
  const _TagChip({required this.kind});

  final _TagKind kind;

  @override
  Widget build(BuildContext context) {
    final (String text, Color bg, Color fg) = switch (kind) {
      _TagKind.alert => (
        'Alert',
        const Color(0xFFFEE2E2),
        const Color(0xFFB91C1C),
      ),
      _TagKind.notice => (
        'Notice',
        const Color(0xFFEDE9FE),
        const Color(0xFF6D28D9),
      ),
      _TagKind.update => (
        'Update',
        ConstColors.blueColorTwo,
        ConstColors.blueColor,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.25)),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunitoSans(
          textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: fg,
            letterSpacing: 0.25,
          ),
        ),
      ),
    );
  }
}
