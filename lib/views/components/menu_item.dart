import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/models/student_menu_model.dart';

class StudentMenuItemWidget extends StatefulWidget {
  final Function() ontap;
  final StudentMenu homeTile;
  const StudentMenuItemWidget({
    super.key,
    required this.homeTile,
    required this.ontap,
  });

  @override
  State<StudentMenuItemWidget> createState() => _StudentMenuItemWidgetState();
}

class _StudentMenuItemWidgetState extends State<StudentMenuItemWidget> {
  bool selected = false;

  @override
  Widget build(BuildContext context) {
    selected = false;
    return GestureDetector(
      onTap: () {
        widget.ontap();
        setState(() {
          selected = true;
        });
      },
      child: AnimatedContainer(
        curve: Curves.fastOutSlowIn,
        padding: selected ? EdgeInsets.all(2.r) : EdgeInsets.zero,
        duration: const Duration(microseconds: 3),
        child: Column(
          children: [
            Container(
              height: 85.h,
              width: 85.h,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 10.r,
                    offset: const Offset(4, 0), // Shadow position
                  ),
                ],
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0.r),
                child: Column(
                  //crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Image.network(
                        widget.homeTile.iconUrl,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(height: 45.h),
                        height: 45.h,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.h),
            Align(
              alignment: Alignment.center,
              child: Text(
                widget.homeTile.menuValue,
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  textStyle: Theme.of(
                    context,
                  ).textTheme.titleSmall!.apply(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
