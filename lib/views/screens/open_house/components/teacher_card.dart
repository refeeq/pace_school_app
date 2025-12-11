import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/screens/open_house/model/open_house_model.dart';
import 'package:school_app/views/screens/open_house/model/slot_model.dart';
import 'package:school_app/views/screens/open_house/model/teacher_model.dart';

class TeacherCard extends StatelessWidget {
  final void Function() onTap;
  final OpenHouseModel openHouseModel;
  final TeacherModel teacherModel;
  const TeacherCard({
    super.key,
    required this.teacherModel,
    required this.openHouseModel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    List<SlotDetail> getSlotsBookedByMe(List<SlotDetail> slotDetails) {
      return slotDetails
          .where((slot) => slot.bookStat == 1 && slot.bookedByMe == 1)
          .toList();
    }

    return Padding(
      padding: EdgeInsets.all(16.0.w), // Responsive padding
      child: Container(
        padding: EdgeInsets.all(16.0.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0.r), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8.0.r,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Profile picture with online indicator
                CircleAvatar(
                  radius: 25.r,
                  backgroundImage: NetworkImage(
                    teacherModel.photo, // Replace with actual image URL
                  ),
                ),
                SizedBox(width: 12.w),
                // Doctor's name and rating
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacherModel.empName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        teacherModel.subjects,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Availability and Consultation Fee
            if (getSlotsBookedByMe(teacherModel.slotDetails).isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8.0.r),
                ),
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        primary: false,
                        itemCount: getSlotsBookedByMe(
                          teacherModel.slotDetails,
                        ).length,
                        itemBuilder: (context, index) => Text(
                          'Appointment at ${getSlotsBookedByMe(teacherModel.slotDetails)[index].slotFrom}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(height: 16.h),
            // Book Appointment Button
            getSlotsBookedByMe(teacherModel.slotDetails).isEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ConstColors.primary.withValues(
                          alpha: 0.5,
                        ), // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: onTap,
                      child: Text(
                        'Book Appointment',
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
