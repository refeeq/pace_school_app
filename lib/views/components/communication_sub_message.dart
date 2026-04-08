import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/themes/const_colors.dart';

class CommunicationSubMessage extends StatelessWidget {
  const CommunicationSubMessage({super.key, required this.model});

  final CommunicationTileModel model;

  @override
  Widget build(BuildContext context) {
    final dateTime =
        model.dateAdded.isEmpty ? null : _tryParseDate(model.dateAdded);
    final dateTimeString = dateTime != null
        // Example: 15/7/26, 3:39 pm
        ? DateFormat('d/M/yy, h:mm a').format(dateTime).toLowerCase()
        : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(minHeight: 90),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: ConstColors.primary.withValues(alpha: 0.1),
              backgroundImage: NetworkImage(model.iconUrl),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          model.type,
                          style: const TextStyle(
                            color: Color.fromRGBO(38, 41, 51, 1),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateTimeString,
                        style: const TextStyle(
                          letterSpacing: - 0.1,
                          // color: Color.fromRGBO(114, 134, 233, 1),
                          color: Color.fromARGB(255, 170, 173, 184),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
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
                          model.lastMessage.isEmpty ? '' : model.lastMessage,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: model.cnt == 0
                                ? const Color.fromRGBO(138, 142, 155, 1)
                                : const Color.fromRGBO(114, 134, 233, 1),
                            fontWeight: model.cnt == 0
                                ? FontWeight.normal
                                : FontWeight.w600,
                            fontSize: 13,
                            height: 1.3,
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
                            color: const Color(0xFF7C4DFF), // purple-style badge
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            model.cnt > 99 ? '99+' : model.cnt.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static DateTime? _tryParseDate(String dateAdded) {
    try {
      return DateFormat('dd-MM-yyyy hh:mm:ss a').parse(dateAdded);
    } catch (_) {
      return null;
    }
  }
}
