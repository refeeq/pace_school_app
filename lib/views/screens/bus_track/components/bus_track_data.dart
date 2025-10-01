import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:school_app/app.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/screens/bus_track/components/tracking_component.dart';
import 'package:school_app/views/screens/bus_track/models/bus_track_data_model.dart';
import 'package:school_app/views/screens/bus_track/models/live_trip.dart';
import 'package:school_app/views/screens/bus_track/models/student_track_model.dart';

class BusTrackData extends StatelessWidget {
  final BusTrackDataModel busTrackDataModel;
  const BusTrackData({super.key, required this.busTrackDataModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: ConstColors.backgroundColor),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: [
              if (busTrackDataModel.type != "OT")
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: ConstColors.filledColor,
                          border: Border.all(color: ConstColors.borderColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.bus,
                                size: 14,
                                color: Color.fromARGB(255, 212, 129, 4),
                              ),
                              const SizedBox(width: 10),
                              const Text("Pickup"),
                              const SizedBox(width: 5),
                              Text(
                                busTrackDataModel.transportData!.busNo1!,
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .merge(
                                      const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: ConstColors.filledColor,
                          border: Border.all(color: ConstColors.borderColor),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              const Icon(
                                FontAwesomeIcons.bus,
                                size: 14,
                                color: Color.fromARGB(255, 212, 129, 4),
                              ),
                              const SizedBox(width: 10),
                              const Text("Drop-off"),
                              const SizedBox(width: 5),
                              Text(
                                busTrackDataModel.transportData!.busNo2!,
                                style: Theme.of(context).textTheme.bodyLarge!
                                    .merge(
                                      const TextStyle(
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              // if (busTrackDataModel.type != "OT")
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset("assets/bus_button.png", height: 30, width: 30),
                    const SizedBox(width: 5),
                    Text(
                      "Live Trips",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
              if (busTrackDataModel.type != "OT")
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16,
                  ),
                  child:
                      busTrackDataModel.liveTrips!.isEmpty ||
                          busTrackDataModel.liveTrips!.isEmpty
                      ? Container(
                          width: MediaQuery.sizeOf(context).width,
                          decoration: ShapeDecoration(
                            color: ConstColors.filledColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: ConstColors.borderColor,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(30.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [Text("No Live Trips Found")],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          primary: false,
                          itemCount: busTrackDataModel.liveTrips!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Container(
                                width: MediaQuery.sizeOf(context).width,
                                decoration: ShapeDecoration(
                                  color: ConstColors.filledColor,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 1,
                                      color: ConstColors.borderColor,
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                child: ListTile(
                                  leading: Image.asset(
                                    "assets/bus.png",
                                    height: 40,
                                    width: 40,
                                  ),
                                  onTap: () {
                                    String schoolIdentifier = AppEnivrornment
                                        .environment
                                        .toString()
                                        .split('.')
                                        .last;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TrackingComponent(
                                          topic:
                                              //  "$schoolIdentifier/transport/bus/19",
                                              "$schoolIdentifier/transport/bus/${busTrackDataModel.liveTrips![index].busNo}",
                                        ),
                                      ),
                                    );
                                  },
                                  title: Text(
                                    "Bus Number ${busTrackDataModel.liveTrips![index].busNo!}",
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    right: 16.0,
                    bottom: 16,
                  ),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width,
                    decoration: ShapeDecoration(
                      color: ConstColors.filledColor,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          width: 1,
                          color: ConstColors.borderColor,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        "This feature is not available for own transport students.",
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "History",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              busTrackDataModel.studentTrack != null ||
                      busTrackDataModel.studentTrack!.isNotEmpty
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: ShapeDecoration(
                            color: ConstColors.filledColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: ConstColors.borderColor,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Center(
                                child: Image.asset(
                                  "assets/images/image.png",
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.2,
                                ),
                              ),
                              Center(
                                child: Text(
                                  "No Data Found",
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        // primary: false,
                        shrinkWrap: true,
                        itemCount: busTrackDataModel.studentTrack!.length,
                        itemBuilder: (context, index) {
                          StudentTrackModel item =
                              busTrackDataModel.studentTrack![index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              bottom: 16,
                            ),
                            child: Container(
                              width: MediaQuery.sizeOf(context).width,
                              decoration: ShapeDecoration(
                                color: ConstColors.filledColor,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1,
                                    color: ConstColors.borderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          DateFormat(
                                            'd MMM yyyy',
                                          ).format(item.entryTime!),
                                          style: GoogleFonts.roboto(
                                            color: const Color(0xFF26273A),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(
                                              FontAwesomeIcons.bus,
                                              size: 14,
                                              color: Color.fromARGB(
                                                255,
                                                212,
                                                129,
                                                4,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              item.busNO,
                                              style: GoogleFonts.roboto(
                                                color: const Color(0xFF26273A),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              decoration: ShapeDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.1,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: SvgPicture.asset(
                                                  "assets/login.svg",
                                                  color: Colors.green,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'IN',
                                                  style: GoogleFonts.roboto(
                                                    color: const Color(
                                                      0x9926273A,
                                                    ),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  item.entryTime == null
                                                      ? "-- --"
                                                      : DateFormat(
                                                          'h:mm a',
                                                        ).format(
                                                          item.entryTime!,
                                                        ),
                                                  style: GoogleFonts.roboto(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              decoration: ShapeDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(
                                                  8.0,
                                                ),
                                                child: SvgPicture.asset(
                                                  "assets/logout.svg",
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  'OUT',
                                                  style: GoogleFonts.roboto(
                                                    color: const Color(
                                                      0x9926273A,
                                                    ),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                                Text(
                                                  item.entryTime == null
                                                      ? "-- --"
                                                      : DateFormat(
                                                          'h:mm a',
                                                        ).format(
                                                          item.entryTime!,
                                                        ),
                                                  style: GoogleFonts.roboto(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      0,
                                                      0,
                                                      0,
                                                    ),
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  void showCustomModalSheet(BuildContext context, List<LiveTrip> liveTrips) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Live Trips",
                    style: Theme.of(context).textTheme.headlineSmall!.merge(
                      const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: CircleAvatar(
                      backgroundColor: ConstColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
              Divider(color: ConstColors.borderColor),
              ListView.builder(
                shrinkWrap: true,
                primary: false,
                itemCount: liveTrips.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ConstColors.filledColor,
                        border: Border.all(color: ConstColors.borderColor),
                      ),
                      child: ListTile(
                        leading: Image.asset(
                          "assets/bus.png",
                          height: 40,
                          width: 40,
                        ),
                        onTap: () {
                          String schoolIdentifier = AppEnivrornment.environment
                              .toString()
                              .split('.')
                              .last;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackingComponent(
                                topic:
                                    //  "$schoolIdentifier/transport/bus/19",
                                    "$schoolIdentifier/transport/bus/${liveTrips[index].busNo}",
                              ),
                            ),
                          );
                        },
                        title: Text("Bus Number ${liveTrips[index].busNo!}"),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
