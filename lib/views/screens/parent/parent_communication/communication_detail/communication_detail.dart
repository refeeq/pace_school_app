import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/models/communication_detail_model.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/communication_date_utils.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_detail/widgets/chat_detail_header.dart';

import '../listing_widget.dart';

String _headerSubtitle(List<CommunicationDetailModel> list) {
  if (list.isEmpty) return '';
  CommunicationDetailModel? latest;
  DateTime? maxT;
  for (final m in list) {
    final t = tryParseCommunicationDate(m.dateAdded);
    if (t == null) continue;
    if (maxT == null || t.isAfter(maxT)) {
      maxT = t;
      latest = m;
    }
  }
  return (latest?.head ?? '').trim();
}

class CommunicationDetailScreen extends StatefulWidget {
  final String studCode;
  final CommunicationTileModel communicationTileModel;
  const CommunicationDetailScreen({
    super.key,
    required this.communicationTileModel,
    required this.studCode,
  });

  @override
  State<CommunicationDetailScreen> createState() =>
      _CommunicationDetailScreenState();
}

class _CommunicationDetailScreenState extends State<CommunicationDetailScreen> {
  static const Color _screenBg = Color(0xFFF2F2F7);
  static const Color _headerBlue = Color(0xFF1A4A8A);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _headerBlue,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: _screenBg,
      ),
      child: Scaffold(
        backgroundColor: _screenBg,
        body: Column(
          children: [
            ColoredBox(
              color: _headerBlue,
              child: SafeArea(
                bottom: false,
                child: Consumer<CommunicationProvider>(
                  builder: (context, comm, child) {
                    return ChatDetailHeader(
                      senderName: widget.communicationTileModel.type,
                      iconUrl: widget.communicationTileModel.iconUrl,
                      subtitle: _headerSubtitle(comm.communicationDetailList),
                      onBackTap: () => Navigator.of(context).pop(),
                      onMoreTap: () {},
                    );
                  },
                ),
              ),
            ),
            ColoredBox(
              color: _headerBlue,
              child: SelectStudentWidget(
                showCommunicationUnread: true,
                onPrimaryBackground: true,
                onchanged: (index) {
                  Provider.of<CommunicationProvider>(
                    context,
                    listen: false,
                  ).getCommunicationDetailList(
                    Provider.of<StudentProvider>(
                      context,
                      listen: false,
                    ).selectedStudentModel(context).studcode,
                    widget.communicationTileModel.id,
                    isRefresh: true,
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<CommunicationProvider>(
                builder: (context, provider, child) {
                  switch (provider.communicationDetailState) {
                    case DataState.Initial_Fetching:
                    case DataState.Uninitialized:
                      return Shimmer(
                        linearGradient: ConstGradient.shimmerGradient,
                        child: ShimmerLoading(
                          isLoading: true,
                          child: ColoredBox(
                            color: _screenBg,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: 20,
                                itemBuilder: (context, index) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                        gradient: const LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Color(0xfff1efef),
                                            Color(0xfff8f7f7),
                                            Color(0xffe7e5e5),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(5.0),
                                        child: Container(
                                          height: (index / 2 == 0) ? 50 : 100,
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(0),
                                              topRight: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                Color(0xfff1efef),
                                                Color(0xfff8f7f7),
                                                Color(0xffe7e5e5),
                                              ],
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );

                    case DataState.Refreshing:
                    case DataState.More_Fetching:
                      return ListViewWidget(
                        provider.communicationDetailList,
                        true,
                        widget.studCode,
                        widget.communicationTileModel.id,
                        widget.communicationTileModel,
                      );
                    case DataState.Fetched:
                    case DataState.Error:
                    case DataState.No_More_Data:
                      return ListViewWidget(
                        provider.communicationDetailList,
                        false,
                        widget.studCode,
                        widget.communicationTileModel.id,
                        widget.communicationTileModel,
                      );
                    case DataState.NoInterNetConnectionState:
                      return const ColoredBox(
                        color: _screenBg,
                        child: Center(
                          child: NoDataWidget(
                            imagePath: "assets/images/no_messages.svg",
                            content:
                                "Your communication history indicates that you have no active conversations at this time.",
                          ),
                        ),
                      );
                  }
                },
              ),
            ),
            ColoredBox(
              color: _screenBg,
              child: SizedBox(height: MediaQuery.of(context).padding.bottom),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    Future(() {
      if (!mounted) return;
      Provider.of<CommunicationProvider>(
        context,
        listen: false,
      ).getCommunicationDetailList(
        Provider.of<StudentProvider>(
          context,
          listen: false,
        ).selectedStudentModel(context).studcode,
        widget.communicationTileModel.id,
        isRefresh: true,
      );
    });
    super.didChangeDependencies();
  }
}
