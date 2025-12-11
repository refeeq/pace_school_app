import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/communication_student_model.dart';
import 'package:school_app/core/provider/communication_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/communication_main_message.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/screens/parent/parent_communication/communication_listing/communication_listing_screen.dart';

class ParentCommunication extends StatelessWidget {
  const ParentCommunication({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: ConstColors.primary,
          elevation: 0,
          title: Text(
            "Communication",
            style: GoogleFonts.nunitoSans(
              textStyle: const TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: Consumer<CommunicationProvider>(
          builder: (context, provider, child) {
            switch (provider.studentListState) {
              case AppStates.Unintialized:
                Future(() => provider.getStudentList());
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
                                  width: MediaQuery.of(context).size.width,
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
                                  width: MediaQuery.of(context).size.width,
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
              case AppStates.Fetched:
                return Column(
                  children: [
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.communicationStudentList.length,
                        itemBuilder: (context, index) {
                          CommunicationStudentModel model =
                              provider.communicationStudentList[index];
                          return InkWell(
                            onTap: () {
                              provider.getCommunicationList(model.studcode);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CommunicationListingScreen(
                                        studentId: model.studcode,
                                      ),
                                ),
                              );
                            },
                            child: CommunicationMainMessage(model: model),
                          );
                        },
                      ),
                    ),
                  ],
                );
              case AppStates.Error:
                return const NoDataWidget(
                  imagePath: "assets/images/no_data.svg",
                  content: "Something went wrong",
                );
              case AppStates.NoInterNetConnectionState:
                return NoInternetConnection(
                  ontap: () async {
                    bool hasInternet =
                        await InternetConnectivity().hasInternetConnection;
                    if (!hasInternet) {
                      showToast("No internet connection!", context);
                    } else {
                      provider.getStudentList();
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
}
