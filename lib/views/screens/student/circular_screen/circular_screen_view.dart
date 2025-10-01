// ignore_for_file: unused_import, prefer_const_literals_to_create_immutables

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/models/circular_list_model.dart';
import 'package:school_app/core/models/parent_profile_list_model.dart';
import 'package:school_app/core/provider/circular_provider.dart';
import 'package:school_app/core/provider/leave_provider.dart';
import 'package:school_app/core/themes/const_box_decoration.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/themes/const_gradient.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/choose_student_tile.dart';
import 'package:school_app/views/components/clickable_text.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/no_data_widget.dart';
import 'package:school_app/views/components/no_internet_connection.dart';
import 'package:school_app/views/components/shimmer_container.dart';
import 'package:school_app/views/components/shimmer_student_profile.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/components/student_tile.dart';
import 'package:school_app/views/screens/student/circular_screen/circular_file_view.dart';

import '../../../../core/provider/student_provider.dart';

class CircularScreenView extends StatefulWidget {
  const CircularScreenView({super.key});

  @override
  State<CircularScreenView> createState() => _CircularScreenViewState();
}

class CircularTile extends StatelessWidget {
  final CircularModel circularModel;
  const CircularTile({super.key, required this.circularModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: ConstColors.filledColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ConstColors.borderColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: [
                  const SizedBox(height: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              circularModel.circularHead,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 19,
                                fontWeight: FontWeight.w600,
                                // textStyle:
                                //     Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(height: 5),
                            HighlightUrlTextCircular(
                              text: circularModel.circular.toString(),
                            ),
                            // Text(
                            //   circularModel.circular.toString(),
                            //   style: GoogleFonts.nunitoSans(),
                            // ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          log(circularModel.file);
                          if (circularModel.file.contains(".jpg")) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CircularFileView(url: circularModel.file),
                              ),
                            );
                          } else if (circularModel.file.contains(".pdf")) {
                            log("is pdf");
                            Navigator.push(
                              context,
                              MaterialPageRoute<dynamic>(
                                builder: (_) =>
                                    PDFViewerFromUrl(url: circularModel.file),
                              ),
                            );
                          } else {
                            showToast("No file found", context);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            color: ConstColors.primary,
                          ),
                          height: 40,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "VIEW",
                                  style: GoogleFonts.nunitoSans(
                                    textStyle: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Image.asset(
                                  'assets/Icons/ic_right.png',
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                    width: 8.0,
                    child: CustomPaint(painter: TrianglePainter()),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: ConstColors.primary,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(6.0),
                        bottomLeft: Radius.circular(6.0),
                      ),
                    ),
                    width: 120.0,
                    height: 30.0,
                    child: Center(
                      child: Text(
                        circularModel.circularDate,
                        style: GoogleFonts.nunitoSans(
                          textStyle: Theme.of(
                            context,
                          ).textTheme.labelMedium!.apply(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0;
    Path path = Path();
    path.moveTo(0.0, size.height);
    path.lineTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _CircularScreenViewState extends State<CircularScreenView> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'Circular',
      child: Container(
        decoration: BoxDecoration(gradient: ConstGradient.linearGradient),
        child: Scaffold(
          backgroundColor: ConstColors.backgroundColor,
          appBar: const CommonAppBar(title: "Circular"),
          body: Column(
            children: [
              SelectStudentWidget(
                onchanged: (index) {
                  Provider.of<CircularProvider>(
                    context,
                    listen: false,
                  ).getCircularList(
                    studCode: Provider.of<StudentProvider>(
                      context,
                      listen: false,
                    ).selectedStudentModel(context).studcode,
                  );
                },
              ),
              Expanded(
                child: Consumer<CircularProvider>(
                  builder: (context, value, child) {
                    switch (value.circularListState) {
                      case AppStates.Unintialized:
                      case AppStates.Initial_Fetching:
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
                                  height: index.isEven ? 150 : 100,
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
                      case AppStates.Fetched:
                        if (value.circularListModel == null) {
                          return const Center(
                            child: NoDataWidget(
                              imagePath: "assets/images/no_circular.svg",
                              content:
                                  "There are no new circulars waiting for you at the moment.",
                            ),
                          );
                        } else {
                          return value.circularListModel!.isEmpty
                              ? const Center(
                                  child: NoDataWidget(
                                    imagePath: "assets/images/no_circular.svg",
                                    content:
                                        "There are no new circulars waiting for you at the moment.",
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: value.circularListModel!.length,
                                    itemBuilder: (context, index) =>
                                        CircularTile(
                                          circularModel:
                                              value.circularListModel![index],
                                        ),
                                  ),
                                );
                        }

                      case AppStates.Error:
                        return const Text("Error");
                      case AppStates.NoInterNetConnectionState:
                        return NoInternetConnection(
                          ontap: () async {
                            bool hasInternet = await InternetConnectivity()
                                .hasInternetConnection;
                            if (!hasInternet) {
                              showToast("No internet connection!", context);
                            } else {
                              Provider.of<CircularProvider>(
                                context,
                                listen: false,
                              ).getCircularList(
                                studCode: Provider.of<StudentProvider>(
                                  context,
                                  listen: false,
                                ).selectedStudentModel(context).studcode,
                              );
                              // Navigator.pop(context);
                            }
                          },
                        );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    Provider.of<CircularProvider>(context, listen: false).getCircularList(
      studCode: Provider.of<StudentProvider>(
        context,
        listen: false,
      ).selectedStudentModel(context).studcode,
    );
    super.didChangeDependencies();
  }
}
