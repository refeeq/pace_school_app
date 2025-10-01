// ignore_for_file: must_be_immutable

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/notification_model.dart';
import 'package:school_app/core/provider/notification_provider.dart';
import 'package:school_app/core/themes/const_box_decoration.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/notification_tile_widget.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';

class ParentNotificationScreenView extends StatefulWidget {
  const ParentNotificationScreenView({super.key});

  @override
  State<ParentNotificationScreenView> createState() =>
      _ParentNotificationScreenViewState();
}

class _ListViewWidget extends StatelessWidget {
  final List<NotificationModel> _data;
  bool _isLoading;
  late DataState _dataState;
  late BuildContext _buildContext;
  _ListViewWidget(this._data, this._isLoading);
  @override
  Widget build(BuildContext context) {
    _dataState = Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).dataState;
    _buildContext = context;
    return SafeArea(child: _scrollNotificationWidget());
  }

  bool _scrollNotification(ScrollNotification scrollInfo) {
    if (!_isLoading &&
        scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
      _isLoading = true;
      Provider.of<NotificationProvider>(
        _buildContext,
        listen: false,
      ).getAllNotifications();
    }
    return true;
  }

  Widget _scrollNotificationWidget() {
    return _data.isEmpty
        ? const Center(
            child: NoDataWidget(
              imagePath: "assets/images/no_notification.svg",
              content:
                  "According to our records, you don't have any notifications to read or respond to. Enjoy your day!",
            ),
          )
        : Column(
            children: [
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: _scrollNotification,
                  child: ListView.builder(
                    itemCount: _data.length,
                    itemBuilder: (context, index) {
                      return NotificationTileWidget(model: _data[index]);
                    },
                  ),
                ),
              ),
              if (_dataState == DataState.More_Fetching)
                const Center(child: CircularProgressIndicator()),
            ],
          );
  }
}

class _ParentNotificationScreenViewState
    extends State<ParentNotificationScreenView> {
  int notificationCount = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        appBar: AppBar(
          title: const Text("Notification"),
          actions: [
            notificationCount > 0
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          int c = await Hive.box(
                            "notificationCount",
                          ).get("count");
                          showModalBottomSheet(
                            backgroundColor: ConstColors.backgroundColor,
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(15.0),
                              ),
                            ),
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.27,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: InkWell(
                                        onTap: () => Navigator.pop(context),
                                        child: const CircleAvatar(
                                          backgroundColor: Color.fromARGB(
                                            255,
                                            108,
                                            111,
                                            122,
                                          ),
                                          radius: 14,
                                          child: Center(
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Text(
                                      "Read all notifications?",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Center(
                                      child: Text(
                                        "$c unread notifications",
                                        textAlign: TextAlign.justify,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12,
                                        right: 12,
                                      ),
                                      child: GestureDetector(
                                        onTap: () async {
                                          Provider.of<NotificationProvider>(
                                            context,
                                            listen: false,
                                          ).readNotification("0");
                                          await Hive.box(
                                            'notificationCount',
                                          ).get('count');
                                          await Hive.box(
                                            "notificationCount",
                                          ).put("count", 0);
                                          setState(() {
                                            notificationCount = 0;
                                          });
                                          Provider.of<NotificationProvider>(
                                            context,
                                            listen: false,
                                          ).getAllNotifications(
                                            isRefresh: true,
                                          );

                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: ConstColors.primary,
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          height: 44,
                                          child: const Center(
                                            child: Text(
                                              "Mark all as read",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: Color.fromRGBO(
                                                  255,
                                                  255,
                                                  255,
                                                  1,
                                                ),
                                                fontFamily: 'SourceSansPro',
                                                fontSize: 18,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                    InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 12,
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: ConstColors.filledColor,
                                            border: Border.all(
                                              color: ConstColors.borderColor,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              5,
                                            ),
                                          ),
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          height: 44,
                                          child: Center(
                                            child: Text(
                                              "Cancel",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: ConstColors.primary,
                                                fontSize: 18,
                                                letterSpacing: 0,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 15),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            "Read All",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        body: Container(
          decoration: ConstBoxDecoration.whiteDecoration,
          child: Consumer<NotificationProvider>(
            builder: (context, controller, child) {
              switch (controller.getAllNotificationState) {
                case DataState.Uninitialized:
                case DataState.Initial_Fetching:
                  return Shimmer(
                    linearGradient: ConstGradient.shimmerGradient,
                    child: ListView.builder(
                      primary: false,
                      itemCount: 10,
                      shrinkWrap: true,
                      itemBuilder: (context, index) => ShimmerLoading(
                        isLoading: true,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 15,
                            bottom: 5,
                          ),
                          child: Container(
                            height: index.isEven ? 100 : 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              gradient: ConstGradient.shimmerGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                case DataState.More_Fetching:
                case DataState.Refreshing:
                  return _ListViewWidget(controller.notificationList, true);
                case DataState.Fetched:
                case DataState.Error:
                case DataState.No_More_Data:
                  return _ListViewWidget(controller.notificationList, false);
                case DataState.NoInterNetConnectionState:
                  return NoInternetConnection(
                    ontap: () async {
                      bool hasInternet =
                          await InternetConnectivity().hasInternetConnection;
                      if (!hasInternet) {
                        showToast("No internet connection!", context);
                      } else {
                        Provider.of<NotificationProvider>(
                          context,
                          listen: false,
                        ).getAllNotifications(isRefresh: true);
                        Provider.of<NotificationProvider>(
                          context,
                          listen: false,
                        ).getAllNotificationCount();
                        //   Navigator.pop(context);
                      }
                    },
                  );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    getCount();
    log("Api call");
    // if (Provider.of<NotificationProvider>(context).getAllNotificationState !=
    //     DataState.Initial_Fetching) {
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).getAllNotifications(isRefresh: true);
    Provider.of<NotificationProvider>(
      context,
      listen: false,
    ).getAllNotificationCount();
    // }

    super.didChangeDependencies();
  }

  Future<void> getCount() async {
    setState(() {
      notificationCount = Hive.box("notificationCount").get("count");
    });
  }
}
