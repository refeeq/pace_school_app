import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:school_app/core/models/leave_list_model.dart';

import '../../../../core/themes/const_colors.dart';
import '../../../../core/utils/utils.dart';
import '../circular_screen/circular_screen_view.dart';

class LeaveTileWidget extends StatelessWidget {
  final LeaveListModel model;
  const LeaveTileWidget({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    // return Padding(
    //     padding: const EdgeInsets.only(bottom: 8.0),
    //     child: Container(
    //       width: MediaQuery.of(context).size.width,
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(10),
    //         border: Border.all(
    //           color: Color(0xffe5e5ec),
    //           width: 1,
    //         ),
    //       ),
    //       height: 115,
    //       child: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Column(
    //           children: [
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   crossAxisAlignment: CrossAxisAlignment.center,
    //                   children: [
    //                     Text(
    //                       "Awaiting",
    //                       style: TextStyle(
    //                         color: Color.fromARGB(239, 170, 168, 164),
    //                         fontSize: 16,
    //                         fontWeight: FontWeight.w500,
    //                       ),
    //                     ),
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(10),
    //                         color: Color(0xffffefc5),
    //                       ),
    //                       padding: const EdgeInsets.only(
    //                         left: 10,
    //                         right: 10,
    //                         top: 5,
    //                         bottom: 5,
    //                       ),
    //                       child: Row(
    //                         mainAxisSize: MainAxisSize.min,
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           Text(
    //                             "Awaiting",
    //                             style: TextStyle(
    //                               color: Color(0xffbe8700),
    //                               fontSize: 16,
    //                               fontFamily: "Inter",
    //                               fontWeight: FontWeight.w500,
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 SizedBox(
    //                   height: 10,
    //                 ),
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     Text(
    //                       "Awaiting",
    //                       style: TextStyle(
    //                         color: Color.fromARGB(238, 0, 0, 0),
    //                         fontSize: 18,
    //                         fontFamily: "Inter",
    //                         fontWeight: FontWeight.w800,
    //                       ),
    //                     ),
    //                     Container(
    //                       decoration: BoxDecoration(
    //                         borderRadius: BorderRadius.circular(10),
    //                         color: Color.fromARGB(87, 173, 172, 169),
    //                       ),
    //                       padding: const EdgeInsets.all(
    //                         5,
    //                       ),
    //                       child: Row(
    //                         mainAxisSize: MainAxisSize.min,
    //                         mainAxisAlignment: MainAxisAlignment.center,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [Icon(Icons.arrow_forward_ios_rounded)],
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     )

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: ConstColors.filledColor,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: ConstColors.borderColor, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            model.leaveReasonType,
                            style: GoogleFonts.nunitoSans(
                              textStyle: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Applied On : ${DateFormat("dd/MM/y").format(model.dateAdded)}",
                            style: GoogleFonts.nunitoSans(),
                          ),
                          const SizedBox(height: 5),
                          Text(model.leaveReason.toString()),
                          model.leaveStatus == "Pending"
                              ? const SizedBox()
                              : const Divider(),
                          model.leaveStatus == "Pending"
                              ? const SizedBox()
                              : const SizedBox(height: 5),
                          model.leaveStatus == "Pending"
                              ? const SizedBox()
                              : Text(
                                  "Remark : ${model.changeMark}",
                                  style: GoogleFonts.nunitoSans(),
                                ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        // log(circularModel.file);
                        // if (circularModel.file.contains(".jpg")) {
                        //   Navigator.push(
                        //       context,
                        //       MaterialPageRoute(
                        //         builder: (context) =>
                        //             CircularFileView(url: circularModel.file),
                        //       ));
                        // } else if (circularModel.file.contains(".pdf")) {
                        //   log("is pdf");
                        //   Navigator.push(
                        //     context,
                        //     MaterialPageRoute<dynamic>(
                        //       builder: (_) => PDFViewerFromUrl(
                        //         url: circularModel.file,
                        //       ),
                        //     ),
                        //   );
                        // } else {
                        //   showToast("No file found");
                        // }
                      },
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15),
                          ),
                          color: HexColor(model.color),
                        ),
                        height: 40,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                model.leaveStatus,
                                style: const TextStyle(color: Colors.white),
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
                  //   width: 150.0,
                  height: 30.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Center(
                      child: Text(
                        "From ${DateFormat("dd/MM/y").format(model.leaveFrom)} To ${DateFormat("dd/MM/y").format(model.leaveTo)}",
                        style: GoogleFonts.nunitoSans(
                          textStyle: Theme.of(
                            context,
                          ).textTheme.labelMedium!.apply(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
