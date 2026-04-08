import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/models/communication_detail_model.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/clickable_text.dart';
import 'package:school_app/views/components/no_data_widget.dart';

import '../../../../core/models/students_model.dart';

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
  ScrollController scrollController = ScrollController();
  late StudentModel studentModel;
  // int unreadCount = 0;
  int get unreadCount {
    return widget._data.where((message) => message.readStat == "0").length;
  }

  @override
  Widget build(BuildContext context) {
    studentModel = Provider.of<StudentProvider>(
      context,
      listen: false,
    ).selectedStudentModel(context);
    _dataState = Provider.of<CommunicationProvider>(
      context,
      listen: false,
    ).communicationDetailState;
    _buildContext = context;
    return SafeArea(child: _scrollNotificationWidget(context));
  }

  bool _scrollNotification(ScrollNotification scrollInfo) {
    final metrices = scrollInfo.metrics;

    if (!widget._isLoading &&
        metrices.atEdge &&
        metrices.pixels > 0 &&
        metrices.pixels >= metrices.maxScrollExtent) {
      log("scrollDown reverse");

      Provider.of<CommunicationProvider>(
        _buildContext,
        listen: false,
      ).getCommunicationDetailList(widget.id, widget.type);
    }
    return true;
  }

  Widget _scrollNotificationWidget(context) {
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_dataState == DataState.More_Fetching)
              Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: const Center(child: CircularProgressIndicator()),
              ),
            widget._data.isEmpty
                ? const Center(
                    child: NoDataWidget(
                      imagePath: "assets/images/no_messages.svg",
                      content:
                          "Your communication history indicates that you have no active conversations at this time.",
                    ),
                  )
                : Expanded(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _scrollNotification,
                      child: SingleChildScrollView(
                        reverse: true,
                        child: ListView.separated(
                          primary: false,
                          separatorBuilder: (context, index) {
                            return Container();
                          },
                          shrinkWrap: true,
                          reverse: true,
                          itemCount: widget._data.length,
                          itemBuilder: (context, index) {
                            // int inx = widget._data.length - index - 1;
                            CommunicationDetailModel model =
                                widget._data[index];

                            // Figma Flutter Generator Group14Widget - GROUP
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(
                                        196,
                                        196,
                                        196,
                                        1,
                                      ),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          widget.communicationTileModel.iconUrl,
                                        ),
                                        fit: BoxFit.fitWidth,
                                      ),
                                      borderRadius: const BorderRadius.all(
                                        Radius.elliptical(56, 56),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(0),
                                            topRight: Radius.circular(10),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          color: ConstColors.secondary,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 10,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            HighlightUrlText(
                                              text: model.notification,
                                              communicationDetailModel: model,
                                            ),
                                            // Text(
                                            //   model.notification,

                                            // ),
                                            Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                model.dateAdded,
                                                textAlign: TextAlign.left,
                                                style: GoogleFonts.nunitoSans(
                                                  textStyle: const TextStyle(
                                                    color: Color.fromRGBO(
                                                      0,
                                                      0,
                                                      0,
                                                      1,
                                                    ),
                                                    fontSize: 12,
                                                    letterSpacing:
                                                        0 /*percentages not used in flutter. defaulting to zero*/,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    height:
                                                        1.5 /*PERCENT not supported*/,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
          ],
        ),
        // unreadCount != 0
        //     ? Align(
        //         alignment: Alignment.bottomRight,
        //         child: Padding(
        //           padding: const EdgeInsets.only(bottom: 130, right: 10.0),
        //           child: SizedBox(
        //             height: 50,
        //             width: 50,
        //             child: Stack(
        //               //  alignment: AlignmentDirectional.center,
        //               children: [
        //                 Align(
        //                   alignment: Alignment.topCenter,
        //                   child: Padding(
        //                     padding: const EdgeInsets.all(8.0),
        //                     child: CircleAvatar(
        //                         backgroundColor: ConstColors.secondary,
        //                         child: Icon(
        //                           Icons.arrow_downward,
        //                           color: Colors.white,
        //                         )),
        //                   ),
        //                 ),
        //                 Container(
        //                     decoration: BoxDecoration(
        //                         color: Colors.blue,
        //                         borderRadius: BorderRadius.circular(5)),
        //                     child: Padding(
        //                       padding: const EdgeInsets.all(2.0),
        //                       child: Text(
        //                         unreadCount.toString(),
        //                         style: TextStyle(
        //                           color: Colors.white,
        //                         ),
        //                       ),
        //                     )),
        //               ],
        //             ),
        //           ),
        //         ),
        //       )
        //     : SizedBox()
      ],
    );
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
