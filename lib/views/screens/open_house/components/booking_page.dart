import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/screens/open_house/bloc/open_house_bloc.dart';
import 'package:school_app/views/screens/open_house/components/slot_details_card.dart';
import 'package:school_app/views/screens/open_house/cubit/open_house_cubit.dart';
import 'package:school_app/views/screens/open_house/model/add_open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/slot_model.dart';
import 'package:school_app/views/screens/open_house/model/teacher_model.dart';

class BookingPage extends StatefulWidget {
  final OpenHouseModel openHouseModel;
  final TeacherModel teacherModel;
  const BookingPage({
    super.key,
    required this.teacherModel,
    required this.openHouseModel,
  });

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<SlotDetail> getSlotsBookedByMe(List<SlotDetail> slotDetails) {
    return slotDetails
        .where((slot) => slot.bookStat == 1 && slot.bookedByMe == 1)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final empId = widget.teacherModel.empId;
    final slotDetails = widget.teacherModel.slotDetails;
    return Scaffold(
      appBar: const CommonAppBar(),
      body: BlocProvider(
        create: (context) => SlotSelectionCubit(),
        child: BlocBuilder<SlotSelectionCubit, List<AddOpenHouseModel>>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 18.h),
                        Center(
                          child: CircleAvatar(
                            radius: 50.r, // Responsive radius
                            backgroundImage: NetworkImage(
                              widget
                                  .teacherModel
                                  .photo, // Replace with actual image URL
                            ),
                          ),
                        ),

                        SizedBox(height: 10.h), // Space between image and name
                        Center(
                          child: Text(
                            widget.teacherModel.empName,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 5.h), // Space between name and title
                        Text(
                          widget.teacherModel.subjects,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(
                          height: 10.h,
                        ), // Space between title and qualifications
                        Padding(
                          padding: EdgeInsets.only(left: 12.0.w),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              "Available Slots",
                              style: TextStyle(
                                fontSize: 16.sp, // Responsive font size
                                color: Colors.grey[600], // Light gray color
                                fontWeight:
                                    FontWeight.w500, // Medium font weight
                              ),
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(12.0.w),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width,
                            padding: EdgeInsets.all(16.0.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                12.0.r,
                              ), // Rounded corners
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 8.0.r,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final width = constraints.maxWidth;
                                const itemWidth =
                                    100.0; // Set desired item width

                                // Calculate number of columns based on available width
                                final crossCount = (width / itemWidth).floor();
                                return GridView.builder(
                                  primary: false,
                                  shrinkWrap: true,
                                  // padding: const EdgeInsets.all(8.0),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossCount,
                                        childAspectRatio: itemWidth / 50,
                                        mainAxisSpacing: 8.0,
                                        crossAxisSpacing: 8.0,
                                      ),
                                  itemCount: widget
                                      .teacherModel
                                      .slotDetails
                                      .length, // Example item count
                                  itemBuilder: (context, index) {
                                    return SlotDetailsCard(
                                      list: slotDetails,
                                      empId: empId,
                                      openHouseId:
                                          widget.openHouseModel.openHouseId,
                                      slot: widget
                                          .teacherModel
                                          .slotDetails[index],
                                    );
                                  },
                                );
                              },
                            ),
                          ),

                          //  Wrap(
                          //   spacing: 6.0, // Optional: spacing between items
                          //   runSpacing:
                          //       6.0, // Optional: spacing between rows
                          //   children: widget.teacherModel.slotDetails
                          //       .map((e) => SlotDetailsCard(
                          //             list: slotDetails,
                          //             empId: empId,
                          //             openHouseId:
                          //                 widget.openHouseModel.openHouseId,
                          //             slot: e,
                          //           ))
                          //       .toList(),
                          // )),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.0.w),
                  child: InkWell(
                    onTap: () {
                      BlocProvider.of<OpenHouseBloc>(context).add(
                        AddOpenHouseEvent(
                          ohMainId: widget.openHouseModel.openHouseId,
                          studeCode: Provider.of<StudentProvider>(
                            context,
                            listen: false,
                          ).selectedStudentModel(context).studcode,
                          openHouseModels: context
                              .read<SlotSelectionCubit>()
                              .state,
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(color: ConstColors.borderColor),
                        color: ConstColors.primary.withValues(
                          alpha: 0.5,
                        ), // Button color,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            "Book Now",
                            style: Theme.of(context).textTheme.titleMedium!
                                .apply(
                                  color:
                                      !context
                                          .watch<SlotSelectionCubit>()
                                          .isDataNotEmpty()
                                      ? ConstColors.primary
                                      : ConstColors.filledColor,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
