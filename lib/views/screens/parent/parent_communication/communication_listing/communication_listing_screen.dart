import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/utils/communication_date_utils.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_detail/communication_detail.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_listing/communication_list_item.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_listing/message_filter_pills.dart';

class CommunicationListingScreen extends StatefulWidget {
  const CommunicationListingScreen({
    super.key,
    required this.studentId,
    this.searchQuery = '',
    this.messageFilter = MessageFilter.all,
  });

  final String studentId;
  final String searchQuery;
  final MessageFilter messageFilter;

  @override
  State<CommunicationListingScreen> createState() =>
      _CommunicationListingScreenState();
}

class _CommunicationListingScreenState
    extends State<CommunicationListingScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CommunicationProvider>(
      builder: (context, provider, child) {
        switch (provider.communicationListState) {
          case AppStates.Unintialized:
          case AppStates.Initial_Fetching:
            return Shimmer(
              linearGradient: ConstGradient.shimmerGradient,
              child: ShimmerLoading(
                isLoading: true,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  child: ListView.builder(
                    itemCount: 12,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: ConstColors.borderColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 10,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: ConstColors.borderColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 10,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: ConstColors.borderColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
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

          case AppStates.Fetched:
            final raw = List<CommunicationTileModel>.from(
              provider.communicationList,
            );
            final filtered = raw
                .where((m) => _matchesSearch(m, widget.searchQuery))
                .where((m) => _matchesFilter(m, widget.messageFilter))
                .toList();
            filtered.sort((a, b) {
              final da = tryParseCommunicationDate(a.dateAdded);
              final db = tryParseCommunicationDate(b.dateAdded);
              if (da == null && db == null) return 0;
              if (da == null) return 1;
              if (db == null) return -1;
              return db.compareTo(da);
            });

            if (filtered.isEmpty) {
              return Center(
                child: Text(
                  'No messages match your filters.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    textStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: ConstColors.primary.withValues(alpha: 0.5),
                      height: 1.4,
                    ),
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: _buildGroupedItems(context, filtered),
            );

          case AppStates.Error:
            return Center(
              child: Text(
                'Error',
                style: GoogleFonts.nunitoSans(
                  textStyle: TextStyle(
                    color: ConstColors.primary.withValues(alpha: 0.7),
                  ),
                ),
              ),
            );
          case AppStates.NoInterNetConnectionState:
            return NoInternetConnection(
              ontap: () async {
                final hasInternet =
                    await InternetConnectivity().hasInternetConnection;
                if (!context.mounted) return;
                if (!hasInternet) {
                  showToast('No internet connection!', context);
                } else {
                  Provider.of<CommunicationProvider>(
                    context,
                    listen: false,
                  ).getCommunicationList(widget.studentId);
                }
              },
            );
        }
      },
    );
  }

  List<Widget> _buildGroupedItems(
    BuildContext context,
    List<CommunicationTileModel> items,
  ) {
    final widgets = <Widget>[];
    String? lastSep;
    for (final model in items) {
      final sep = _separatorLabel(model.dateAdded);
      if (sep != lastSep) {
        lastSep = sep;
        widgets.add(_DateSeparatorRow(label: sep));
      }
      widgets.add(
        CommunicationListItem(
          model: model,
          timeLabel: _formatListTime(model.dateAdded),
          onTap: () => _onTileTap(context, model),
        ),
      );
    }
    return widgets;
  }

  Future<void> _onTileTap(
    BuildContext context,
    CommunicationTileModel model,
  ) async {
    final studentProvider = Provider.of<StudentProvider>(
      context,
      listen: false,
    );
    final comm = Provider.of<CommunicationProvider>(context, listen: false);
    final studCode = studentProvider.selectedStudentModel(context).studcode;

    final openedCount = model.cnt;
    final dynamic rawTotal = Hive.box('communication').get('count');
    final int currentTotal = rawTotal is int ? rawTotal : 0;
    final int hiveAfterOpen = (currentTotal - openedCount).clamp(0, 999999);

    setState(() {
      model.cnt = 0;
    });

    Hive.box('communication').put('new', '');
    Hive.box('communication').put('count', hiveAfterOpen);

    final remainingForStudent = comm.communicationList.fold<int>(
      0,
      (sum, tile) => sum + tile.cnt,
    );
    comm.setStudentUnread(studCode, remainingForStudent);

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => CommunicationDetailScreen(
          studCode: studCode,
          communicationTileModel: model,
        ),
      ),
    );

    if (!context.mounted) return;

    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!context.mounted) return;

    final codeAfterPop = studentProvider.selectedStudentModel(context).studcode;

    await comm.getCommunicationList(codeAfterPop);
    await comm.getStudentList();
  }

  @override
  void didChangeDependencies() {
    Provider.of<CommunicationProvider>(
      context,
      listen: false,
    ).getCommunicationList(widget.studentId);
    super.didChangeDependencies();
  }
}

bool _matchesSearch(CommunicationTileModel m, String q) {
  final t = q.trim().toLowerCase();
  if (t.isEmpty) return true;
  return m.lastMessage.toLowerCase().contains(t) ||
      m.type.toLowerCase().contains(t);
}

bool _matchesFilter(CommunicationTileModel m, MessageFilter f) {
  switch (f) {
    case MessageFilter.all:
      return true;
    case MessageFilter.unread:
      return m.cnt > 0;
  }
}

String _separatorLabel(String dateAdded) {
  final dt = tryParseCommunicationDate(dateAdded);
  if (dt == null) return '';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final d = DateTime(dt.year, dt.month, dt.day);
  if (d == today) return 'Today';
  if (d == today.subtract(const Duration(days: 1))) return 'Yesterday';
  return DateFormat('dd MMM yyyy').format(dt);
}

String _formatListTime(String dateAdded) {
  final dt = tryParseCommunicationDate(dateAdded);
  if (dt == null) {
    return dateAdded.trim().isEmpty ? '' : dateAdded;
  }
  return DateFormat('h:mm a').format(dt).toLowerCase();
}

class _DateSeparatorRow extends StatelessWidget {
  const _DateSeparatorRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: ConstColors.borderColor,
              thickness: 1,
              height: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: GoogleFonts.nunitoSans(
                textStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                  color: ConstColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
          Expanded(
            child: Divider(
              color: ConstColors.borderColor,
              thickness: 1,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}
