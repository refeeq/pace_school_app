import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:school_app/core/models/communication_detail_model.dart';
import 'package:school_app/core/widgets/ios_toast.dart';
import 'package:school_app/views/components/clickable_text.dart';

class _DoubleTick extends StatelessWidget {
  const _DoubleTick();

  static const Color _tick = Color(0xFF1A4A8A);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 12,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(Icons.check, size: 12, color: _tick),
          ),
          Positioned(
            left: 4,
            top: 0,
            child: Icon(Icons.check, size: 12, color: _tick),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    required this.detailModel,
  });

  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final CommunicationDetailModel detailModel;

  static const Color _bubbleText = Color(0xFF000000);
  static const Color _timeText = Color(0xFF3C3C43);
  static const Color _linkBlue = Color(0xFF0555C4);
  static const Color _copyIconTint = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 262),
          child: IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.fromLTRB(13, 10, 13, 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isFirstInGroup ? 18 : 4),
                  topRight: const Radius.circular(18),
                  bottomRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isLastInGroup ? 4 : 18),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.07),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HighlightUrlText(
                    text: message,
                    communicationDetailModel: detailModel,
                    baseTextColor: _bubbleText,
                    baseFontSize: 14,
                    baseHeight: 1.42,
                    baseFontWeight: FontWeight.w500,
                    linkColor: _linkBlue,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat('hh:mm a').format(timestamp),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _timeText,
                          letterSpacing: 0.08,
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (isRead) const _DoubleTick(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Clipboard.setData(ClipboardData(text: message));
                IosToast.show(
                  context,
                  message: 'Message copied',
                  icon: Icons.copy_rounded,
                );
              },
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.copy_rounded, size: 15, color: _copyIconTint),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
