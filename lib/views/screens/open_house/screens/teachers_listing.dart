import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/screens/open_house/components/booking_page.dart';
import 'package:school_app/views/screens/open_house/components/slot_details_card.dart';
import 'package:school_app/views/screens/open_house/components/teacher_card.dart';
import 'package:school_app/views/screens/open_house/cubit/open_house_cubit.dart';
import 'package:school_app/views/screens/open_house/model/add_open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/open_house_model.dart';

class TeachersListing extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final OpenHouseModel open_house_model;
  // ignore: non_constant_identifier_names
  const TeachersListing({super.key, required this.open_house_model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(title: open_house_model.ohDate),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<SlotSelectionCubit, List<AddOpenHouseModel>>(
                builder: (context, slotState) {
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: open_house_model.trSlotDetails.length,
                    itemBuilder: (context, index) {
                      final empId = open_house_model.trSlotDetails[index].empId;
                      final slotDetails =
                          open_house_model.trSlotDetails[index].slotDetails;
                      context
                          .watch<SlotSelectionCubit>()
                          .dataPresentWithTeacherCode(empId, slotDetails);
                      return TeacherCard(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingPage(
                                openHouseModel: open_house_model,
                                teacherModel:
                                    open_house_model.trSlotDetails[index],
                              ),
                            ),
                          );
                        },
                        openHouseModel: open_house_model,
                        teacherModel: open_house_model.trSlotDetails[index],
                      );
                       },
                  );
                },
              ),
            ),

         ],
        ),
      ),
    );
  }
}
