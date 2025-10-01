// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/school_provider.dart';
import 'package:school_app/core/themes/const_box_decoration.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/information_tile.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/shimmer_container.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';

class SchoolInformationScreenView extends StatelessWidget {
  final circleMarkers = <CircleMarker>[
    CircleMarker(
      point: const LatLng(51.5, -0.09),
      color: Colors.blue.withOpacity(0.7),
      borderStrokeWidth: 2,
      useRadiusInMeter: true,
      radius: 2000, // 2000 meters | 2 km
    ),
  ];
  SchoolInformationScreenView({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
      child: Scaffold(
        backgroundColor: ConstColors.backgroundColor,
        appBar: const CommonAppBar(title: 'School Information'),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: ConstBoxDecoration.whiteDecoration,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Consumer<SchoolProvider>(
              builder: (context, value, child) {
                switch (value.schoolInfoState) {
                  case AppStates.Unintialized:
                    Future(() {
                      value.getSchoolInfo();
                    });
                    return Shimmer(
                      linearGradient: ConstGradient.shimmerGradient,
                      child: const Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 100,
                              child: ShimmerContainer(
                                height: 100,
                                radius: 15,
                                text: '',
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ShimmerContainer(height: 50, radius: 15, text: ''),
                          SizedBox(height: 20),
                          ShimmerContainer(height: 100, radius: 15, text: ''),
                          SizedBox(width: 5),
                          ShimmerContainer(height: 100, radius: 15, text: ''),
                          SizedBox(width: 5),
                          ShimmerContainer(height: 100, radius: 15, text: ''),
                          SizedBox(height: 20),
                          Row(children: []),
                        ],
                      ),
                    );
                  case AppStates.Initial_Fetching:
                    return Shimmer(
                      linearGradient: ConstGradient.shimmerGradient,
                      child: const Column(
                        children: [
                          Center(
                            child: SizedBox(
                              width: 100,
                              child: ShimmerContainer(
                                height: 100,
                                radius: 15,
                                text: '',
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          ShimmerContainer(height: 50, radius: 15, text: ''),
                          SizedBox(height: 20),
                          ShimmerContainer(height: 50, radius: 15, text: ''),
                          SizedBox(width: 5),
                          ShimmerContainer(height: 50, radius: 15, text: ''),
                          SizedBox(width: 5),
                          ShimmerContainer(height: 50, radius: 15, text: ''),
                        ],
                      ),
                    );
                  case AppStates.Fetched:
                    if (value.schoolInfoModel == null) {
                      return const NoDataWidget(
                        imagePath: "assets/images/no_data.svg",
                        content: "Something went wrong",
                      );
                    } else {
                      return SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Image.network(
                                value.schoolInfoModel!.logo,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(height: 100),
                                height: 100,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "${value.schoolInfoModel!.name}",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const Divider(),

                            // Row(
                            //   mainAxisAlignment:
                            //       MainAxisAlignment.spaceBetween,
                            //   children: [
                            //     Column(
                            //       crossAxisAlignment:
                            //           CrossAxisAlignment.start,
                            //       children: [
                            //         Text(
                            //           "School Name",
                            //           style: Theme.of(context)
                            //               .textTheme
                            //               .labelMedium,
                            //         ),
                            //         Text("School Name"),
                            //       ],
                            //     ),
                            //     Column(
                            //       crossAxisAlignment:
                            //           CrossAxisAlignment.start,
                            //       children: [
                            //         Text(
                            //           "School Name",
                            //           style: Theme.of(context)
                            //               .textTheme
                            //               .labelMedium,
                            //         ),
                            //         Text("School Name"),
                            //       ],
                            //     ),
                            //   ],
                            // ),
                            const SizedBox(height: 20),
                            Text(
                              "About",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              value.schoolInfoModel!.description ?? "",
                              style: GoogleFonts.nunitoSans(fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Location",
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      InkWell(
                                        onTap: () {
                                          MapsLauncher.launchCoordinates(
                                            double.parse(
                                              value
                                                  .schoolInfoModel!
                                                  .location_lat
                                                  .toString(),
                                            ),
                                            double.parse(
                                              value
                                                  .schoolInfoModel!
                                                  .location_long
                                                  .toString(),
                                            ),
                                          );
                                        },
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Icon(
                                              CupertinoIcons.map_pin_ellipse,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 2),
                                            Expanded(
                                              child: Text(
                                                value
                                                        .schoolInfoModel!
                                                        .address ??
                                                    "",
                                                style: GoogleFonts.nunitoSans(
                                                  fontSize: 14,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Curriculum",
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.school,
                                            color: ConstColors.primary,
                                          ),
                                          const SizedBox(width: 2),
                                          Expanded(
                                            child: Text(
                                              value
                                                      .schoolInfoModel!
                                                      .curriculum ??
                                                  "",
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Connect with us",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (value.schoolInfoModel!.whatsapp != null)
                                  Informationtile(
                                    image: 'assets/Icons/whatsapp.png',
                                    title:
                                        "https://api.whatsapp.com/send?phone=${value.schoolInfoModel!.whatsapp}",
                                    show: true,
                                    title2: "WhatsApp",
                                  ),
                                if (value.schoolInfoModel!.facebook != null)
                                  Informationtile(
                                    image: 'assets/Icons/facebook.png',
                                    title: value.schoolInfoModel!.facebook!,
                                    show: true,
                                    title2: "Facebook",
                                  ),
                                if (value.schoolInfoModel!.instagram != null)
                                  Informationtile(
                                    image: 'assets/Icons/instagram.png',
                                    title: value.schoolInfoModel!.instagram!,
                                    show: true,
                                    title2: "Instagram",
                                  ),
                                if (value.schoolInfoModel!.youtube != null)
                                  Informationtile(
                                    image: 'assets/Icons/youtube.png',
                                    title: value.schoolInfoModel!.youtube!,
                                    show: true,
                                    title2: "Youtube",
                                  ),
                                if (value.schoolInfoModel!.contact != null)
                                  Informationtile(
                                    image: 'assets/Icons/phone-call.png',
                                    title: value.schoolInfoModel!.contact!,
                                  ),
                                if (value.schoolInfoModel!.website != null)
                                  Informationtile(
                                    image: 'assets/Icons/world-wide-web.png',
                                    title: value.schoolInfoModel!.website!,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      );
                    }
                  case AppStates.Error:
                    return const Text("error");
                  case AppStates.NoInterNetConnectionState:
                    return NoInternetConnection(
                      ontap: () async {
                        bool hasInternet =
                            await InternetConnectivity().hasInternetConnection;
                        if (!hasInternet) {
                          showToast("No internet connection!", context);
                        } else {
                          value.getSchoolInfo();
                          //      Navigator.pop(context);
                        }
                      },
                    );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
