import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/themes/const_colors.dart';

/// Local filter for the communication message list (UI state only).
enum MessageFilter { all, unread }

/// Horizontal filters — outlined inactive / filled primary active ([main.dart] app bar style).
class MessageFilterPills extends StatelessWidget {
  const MessageFilterPills({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.allBadgeCount,
    required this.unreadBadgeCount,
  });

  final MessageFilter selected;
  final ValueChanged<MessageFilter> onChanged;
  final int allBadgeCount;
  final int unreadBadgeCount;

  @override
  Widget build(BuildContext context) {
    const labels = <MessageFilter, String>{
      MessageFilter.all: 'All',
      MessageFilter.unread: 'Unread',
    };

    return Container(
      decoration: BoxDecoration(
        color: ConstColors.filledColor,
        border: Border(bottom: BorderSide(color: ConstColors.borderColor)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: MessageFilter.values.map((f) {
              final isActive = selected == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onChanged(f),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isActive
                            ? ConstColors.primary
                            : ConstColors.filledColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isActive
                              ? ConstColors.primary
                              : ConstColors.borderColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            labels[f]!,
                            style: GoogleFonts.nunitoSans(
                              textStyle: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.15,
                                color: isActive
                                    ? Colors.white
                                    : ConstColors.primary.withValues(
                                        alpha: 0.75,
                                      ),
                              ),
                            ),
                          ),
                          if (f == MessageFilter.all && allBadgeCount > 0) ...[
                            const SizedBox(width: 6),
                            _Badge(
                              value: allBadgeCount,
                              background: const Color(0xFFE53E3E),
                              foreground: Colors.white,
                            ),
                          ],
                          if (f == MessageFilter.unread &&
                              unreadBadgeCount > 0) ...[
                            const SizedBox(width: 6),
                            _Badge(
                              value: unreadBadgeCount,
                              background: ConstColors.borderColor,
                              foreground: ConstColors.primary.withValues(
                                alpha: 0.75,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.value,
    required this.background,
    required this.foreground,
  });

  final int value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final text = value > 99 ? '99+' : '$value';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.nunitoSans(
          textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: foreground,
          ),
        ),
      ),
    );
  }
}
