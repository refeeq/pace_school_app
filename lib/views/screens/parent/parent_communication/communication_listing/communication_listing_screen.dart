import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communicatio_tile_model.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/communication_sub_message.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_detail/communication_detail.dart';

class CommunicationListingScreen extends StatefulWidget {
  final String studentId;
  const CommunicationListingScreen({super.key, required this.studentId});

  @override
  State<CommunicationListingScreen> createState() =>
      _CommunicationListingScreenState();
}

class _CommunicationListingScreenState
    extends State<CommunicationListingScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   backgroundColor: ConstColors.primary,
        //   elevation: 0,
        //   title: Text(
        //     "Communication",
        //     style: TextStyle(
        //       fontWeight: FontWeight.w300,
        //       color: Colors.white,
        //     ),
        //   ),
        // ),
        body: Consumer<CommunicationProvider>(
          builder: (context, provider, child) {
            switch (provider.communicationListState) {
              case AppStates.Unintialized:
              case AppStates.Initial_Fetching:
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
                              width: 50,
                              height: 50,
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
                                child: Column(
                                  children: [
                                    Container(
                                      height: 10,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Container(
                                      height: (index / 2 == 0) ? 20 : 40,
                                      width: MediaQuery.of(context).size.width,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
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
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 10,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );

              case AppStates.Fetched:
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.communicationList.length,
                  itemBuilder: (context, index) {
                    CommunicationTileModel model =
                        provider.communicationList[index];

                    return // Figma Flutter Generator 01chatitemWidget - INSTANCE
                    InkWell(
                      onTap: () {
                        var count = Hive.box("communication").get('count');
                        setState(() {
                          count = count - model.cnt;
                          model.cnt = 0;
                        });
                        Hive.box("communication").put("new", '');
                        Hive.box("communication").put('count', count);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommunicationDetailScreen(
                              studCode: widget.studentId,
                              communicationTileModel: model,
                            ),
                          ),
                        );
                      },
                      child: CommunicationSubMessage(model: model),
                    );
                  },
                );
              case AppStates.Error:
                return const Center(child: Text("Error"));
              case AppStates.NoInterNetConnectionState:
                return NoInternetConnection(
                  ontap: () async {
                    bool hasInternet =
                        await InternetConnectivity().hasInternetConnection;
                    if (!hasInternet) {
                      showToast("No internet connection!", context);
                    } else {
                      Provider.of<CommunicationProvider>(
                        context,
                        listen: false,
                      ).getCommunicationList(widget.studentId);
                      //     Navigator.pop(context);
                    }
                  },
                );
            }
          },
        ),
      ),
    );
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
