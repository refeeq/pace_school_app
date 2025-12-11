import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/screens/open_house/cubit/open_house_cubit.dart';
import 'package:school_app/views/screens/open_house/model/slot_model.dart';

class SlotDetailsCard extends StatelessWidget {
  final List<SlotDetail> list;
  final int empId;
  final SlotDetail slot;
  final String openHouseId;

  const SlotDetailsCard({
    super.key,
    required this.empId,
    required this.list,
    required this.slot,
    required this.openHouseId,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SlotSelectionCubit>();
    final isBooked = slot.bookStat == 1 && slot.bookedByMe == 0;
    final isSelected = cubit.isDataPresent(empId, slot.slotId.toString());
    final isAlreadyBookedByMe = slot.bookStat == 1 && slot.bookedByMe == 1;
    final isAlreadyBookedByMeOne = list.any(
      (element) => element.bookedByMe == 1,
    );

    // Determine screen width and set column count based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final int columns = screenWidth < 360
        ? 2
        : 3; // 2 columns for narrow screens, 3 otherwise

    // Calculate width for each card based on the number of columns
    const double padding = 16.0; // Padding between columns
    final double cardWidth =
        (screenWidth - ((columns + 1) * padding)) / columns;

    Color determineColor() {
      if (isSelected) {
        return Colors.lightGreen;
      } else if (isAlreadyBookedByMe) {
        return Colors.green;
      } else if (isBooked) {
        return const Color(0xFFF5F6F8);
      } else {
        return Colors.white;
      }
    }

    Color determineFontColor() {
      if (isSelected) {
        return Colors.white;
      } else if (isAlreadyBookedByMe) {
        return Colors.white;
      } else if (isBooked) {
        return Colors.black45;
      } else {
        return Colors.black;
      }
    }

    Color determineBorderColor() {
      if (isSelected) {
        return Colors.transparent;
      } else if (isAlreadyBookedByMe) {
        return Colors.transparent;
      } else if (isBooked) {
        return const Color(0xFFF5F6F8);
      } else {
        return Colors.black26;
      }
    }

    return GestureDetector(
      onTap: () {
        log(slot.slotId.toString());
        if (isBooked) {
          showToast("Already booked by another user", context);
        } else if (isAlreadyBookedByMeOne) {
          showToast("You are already Booked", context);
        } else {
          cubit.addOrRemoveData(
            empId,
            slot.slotId.toString(),
            slot.bookStat,
            openHouseId,
            Provider.of<StudentProvider>(
              context,
              listen: false,
            ).selectedStudentModel(context).studcode,
          );
        }
      },
      child: Container(
        width: cardWidth, // Set calculated width for each card
        decoration: BoxDecoration(
          color: determineColor(),
          border: Border.all(color: determineBorderColor(), width: 1.5),
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Text(
              slot.slotFrom,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: determineFontColor()),
            ),
          ),
        ),
      ),
    );
  }
}
