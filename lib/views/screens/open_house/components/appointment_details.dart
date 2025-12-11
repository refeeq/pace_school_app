import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/screens/open_house/model/active_open_house_model.dart';

class AppointmentDetailsDialog extends StatelessWidget {
  final ActiveOpenHouseModel activeOpenHouseModel;
  const AppointmentDetailsDialog({
    super.key,
    required this.activeOpenHouseModel,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: ShapeDecoration(
          color: ConstColors.filledColor,
          shape: RoundedRectangleBorder(
            side: BorderSide(width: 1, color: ConstColors.borderColor),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0.8.sh, // Make the dialog height responsive
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, // Set the desired width
                        height: 40, // Set the desired height
                        decoration: BoxDecoration(
                          shape: BoxShape.circle, // Make the container circular
                          image: DecorationImage(
                            image: NetworkImage(activeOpenHouseModel.photo),
                            fit: BoxFit
                                .cover, // Ensure the image covers the entire circle
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          activeOpenHouseModel.teacher,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.subject, size: 25, color: Colors.grey),
                      SizedBox(width: 5.w),
                      Text(
                        activeOpenHouseModel.subject,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        size: 25,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDateString(
                                activeOpenHouseModel.ohDate.toString(),
                              ),
                              style: const TextStyle(fontSize: 12),
                            ),
                            Text(
                              "${activeOpenHouseModel.from} - ${activeOpenHouseModel.to}",
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  QrImageView(
                    data: activeOpenHouseModel.slotId.toString(),
                    version: QrVersions.auto,
                    size: 180.0,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
