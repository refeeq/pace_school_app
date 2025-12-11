import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/components/slect_student.dart';

import '../../../../../core/provider/student_provider.dart';
import '../listing_widget.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        appBar: CommonAppBar(title: widget.communicationTileModel.type),
        body: Column(
          children: [
            Container(
              color: Colors.white,
              child: SelectStudentWidget(
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
                      // Future(
                      //   () {
                      //     provider.getCommunicationDetailList(
                      //         widget.studCode, widget.communicationTileModel.id,
                      //         isRefresh: true);
                      //   },
                      // );
                      return Shimmer(
                        linearGradient: ConstGradient.shimmerGradient,
                        child: ShimmerLoading(
                          isLoading: true,
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
                                      borderRadius: BorderRadius.circular(100),
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
                      return const Center(
                        child: NoDataWidget(
                          imagePath: "assets/images/no_messages.svg",
                          content:
                              "Your communication history indicates that you have no active conversations at this time.",
                        ),
                      );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    // Provider.of<CommunicationProvider>(context, listen: false).getStudentList();
    Future(() {
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
