import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/contactus_provider.dart';
import 'package:school_app/core/provider/guest_provider.dart';
import 'package:school_app/core/provider/school_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/menu_item.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/screens/guest/guest_admission_register/guest_admission_register_screen.dart';
import 'package:school_app/views/screens/guest/guest_contact_us/guest_contact_us_screen.dart';

import '../../../app.dart';
import '../../components/web_view_screen.dart';
import '../school_information_screen/school_information_screen_view.dart';

class GestMenuScreen extends StatelessWidget {
  const GestMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(
        title: AppEnivrornment.appFullName,
        actions: [
          CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage(AppEnivrornment.appImageName),
          ),
          SizedBox(width: 10.w),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Consumer<GuestProvider>(
          builder: (context, value, child) {
            switch (value.guestMenuState) {
              case AppStates.Unintialized:
                Future(() => value.getGuestMenu());
                return const Center(child: CircularProgressIndicator());
              case AppStates.Initial_Fetching:
                return const Center(child: CircularProgressIndicator());
              case AppStates.Fetched:
                if (value.guestMenueList.isEmpty) {
                  return const NoDataWidget(
                    imagePath: "assets/images/no_data.svg",
                    content: "Something went wrong",
                  );
                } else {
                  return GridView.builder(
                    primary: false,
                    shrinkWrap: true,
                    // primary: false,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.6.h / 3.6.h,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 9.w,
                    ),
                    itemCount: value.guestMenueList.length,
                    itemBuilder: (BuildContext ctx, index) {
                      return Hero(
                        tag: value.guestMenueList[index].id,
                        child: StudentMenuItemWidget(
                          homeTile: value.guestMenueList[index],
                          ontap: () {
                            if (value.guestMenueList[index].weburl != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WebViewScreen(
                                    reponseUrl:
                                        value.guestMenueList[index].weburl!,
                                    title:
                                        value.guestMenueList[index].menuValue,
                                  ),
                                ),
                              );
                            } else if (value.guestMenueList[index].menuKey ==
                                "SchoolInfo") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SchoolInformationScreenView(),
                                ),
                              );
                            } else if (value.guestMenueList[index].menuKey ==
                                "ContactUs") {
                              Provider.of<SchoolProvider>(
                                context,
                                listen: false,
                              ).getSchoolInfo();
                              Provider.of<ContactUsProvider>(
                                context,
                                listen: false,
                              ).updatesubmitContactUs();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GuestContactUsScreen(),
                                ),
                              );
                            } else if (value.guestMenueList[index].menuKey ==
                                "OnlineEnquiry") {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const GuestAdmissionRegisterScreen(),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                }
              case AppStates.Error:
                return const Center(child: Text("No Data"));
              case AppStates.NoInterNetConnectionState:
                return NoInternetConnection(
                  ontap: () async {
                    bool hasInternet =
                        await InternetConnectivity().hasInternetConnection;
                    if (!hasInternet) {
                      showToast("No internet connection!", context);
                    } else {
                      value.getGuestMenu();
                      // Navigator.pop(context);
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
