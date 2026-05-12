import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/models/communication_detail_model.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/utils/communication_date_utils.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_detail/widgets/chat_bubble.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_detail/widgets/chat_date_separator.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_detail/widgets/sender_avatar.dart';

sealed class _ChatListEntry {}

class _DateEntry extends _ChatListEntry {
  _DateEntry(this.day);
  final DateTime day;
}

class _MessageEntry extends _ChatListEntry {
  _MessageEntry(this.model, this.isFirstInGroup, this.isLastInGroup);
  final CommunicationDetailModel model;
  final bool isFirstInGroup;
  final bool isLastInGroup;
}

DateTime _messageTime(CommunicationDetailModel m) {
  return tryParseCommunicationDate(m.dateAdded) ??
      DateTime.fromMillisecondsSinceEpoch(0);
}

bool _sameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _senderKey(CommunicationDetailModel m, String fallback) {
  final h = m.head.trim();
  return h.isEmpty ? fallback : h;
}

List<_ChatListEntry> _buildEntries(
  List<CommunicationDetailModel> raw,
  String tileType,
) {
  if (raw.isEmpty) return [];
  final asc = List<CommunicationDetailModel>.from(raw)
    ..sort((a, b) => _messageTime(a).compareTo(_messageTime(b)));

  final rows = <_ChatListEntry>[];
  DateTime? lastSeparatorDay;

  for (var j = 0; j < asc.length; j++) {
    final m = asc[j];
    final t = _messageTime(m);
    final day = DateTime(t.year, t.month, t.day);
    if (lastSeparatorDay == null || !_sameCalendarDay(day, lastSeparatorDay)) {
      rows.add(_DateEntry(day));
      lastSeparatorDay = day;
    }

    final prev = j > 0 ? asc[j - 1] : null;
    final next = j < asc.length - 1 ? asc[j + 1] : null;
    final sk = _senderKey(m, tileType);

    final isFirst =
        prev == null ||
        !_sameCalendarDay(_messageTime(m), _messageTime(prev)) ||
        sk != _senderKey(prev, tileType);
    final bool isLast;
    if (next == null) {
      isLast = true;
    } else {
      isLast =
          !_sameCalendarDay(_messageTime(m), _messageTime(next)) ||
          sk != _senderKey(next, tileType);
    }

    rows.add(_MessageEntry(m, isFirst, isLast));
  }
  return rows;
}

class ListViewWidget extends StatefulWidget {
  final CommunicationTileModel communicationTileModel;
  final String id;
  final String type;
  final List<CommunicationDetailModel> _data;
  final bool _isLoading;

  const ListViewWidget(
    this._data,
    this._isLoading,
    this.id,
    this.type,
    this.communicationTileModel, {
    super.key,
  });

  @override
  State<ListViewWidget> createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  late DataState _dataState;
  late BuildContext _buildContext;

  @override
  Widget build(BuildContext context) {
    _dataState = Provider.of<CommunicationProvider>(
      context,
      listen: false,
    ).communicationDetailState;
    _buildContext = context;

    const screenBg = Color(0xFFF2F2F7);

    return ColoredBox(
      color: screenBg,
      child: Column(
        children: [
          if (_dataState == DataState.More_Fetching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          Expanded(
            child: widget._data.isEmpty
                ? const Center(
                    child: NoDataWidget(
                      imagePath: "assets/images/no_messages.svg",
                      content:
                          "Your communication history indicates that you have no active conversations at this time.",
                    ),
                  )
                : NotificationListener<ScrollNotification>(
                    onNotification: _scrollNotification,
                    child: _ChatMessageList(
                      entries: _buildEntries(
                        widget._data,
                        widget.communicationTileModel.type,
                      ),
                      iconUrl: widget.communicationTileModel.iconUrl,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  bool _scrollNotification(ScrollNotification scrollInfo) {
    final metrices = scrollInfo.metrics;

    if (!widget._isLoading &&
        metrices.atEdge &&
        metrices.pixels > 0 &&
        metrices.pixels >= metrices.maxScrollExtent) {
      log(
        '[Communication] scroll: max extent edge (reverse layout) — '
        'loading older messages via pagination '
        '(studcode=${widget.id}, tileId=${widget.type}, '
        'alreadyShowing=${widget._data.length})',
      );

      Provider.of<CommunicationProvider>(
        _buildContext,
        listen: false,
      ).getCommunicationDetailList(widget.id, widget.type);
    }
    return true;
  }
}

class _ChatMessageList extends StatelessWidget {
  const _ChatMessageList({required this.entries, required this.iconUrl});

  final List<_ChatListEntry> entries;
  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[entries.length - 1 - index];
        if (entry is _DateEntry) {
          return ChatDateSeparator(date: entry.day);
        }
        final msg = entry as _MessageEntry;
        final model = msg.model;
        final time = _messageTime(model);
        final isRead = model.readStat != "0";

        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SenderAvatar(iconUrl: iconUrl, visible: msg.isFirstInGroup),
              const SizedBox(width: 8),
              ChatBubble(
                message: model.notification,
                timestamp: time,
                isRead: isRead,
                isFirstInGroup: msg.isFirstInGroup,
                isLastInGroup: msg.isLastInGroup,
                detailModel: model,
              ),
            ],
          ),
        );
      },
    );
  }
}
