import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/themes/const_colors.dart';

class BorderWithTextWidget extends StatelessWidget {
  final String title;
  final Widget widget;
  const BorderWithTextWidget({
    super.key,
    required this.title,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: GoogleFonts.nunitoSans(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,

            // height: 200,
            decoration: ShapeDecoration(
              //  color: const Color(0x0C24265F),
              color: ConstColors.filledColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(width: 1, color: ConstColors.borderColor),
                borderRadius: BorderRadius.circular(6),
              ),

              // shape: BoxShape.rectangle,
            ),
            child: Padding(padding: const EdgeInsets.all(12.0), child: widget),
          ),
        ],
      ),
    );
    // return Stack(
    //   children: <Widget>[
    //     Container(
    //       width: double.infinity,
    //       // height: 200,
    //       margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
    //       padding: EdgeInsets.only(
    //         bottom: 10,
    //         top: 10,
    //       ),
    //       decoration: BoxDecoration(
    //         border: Border.all(color: Colors.grey, width: 1),
    //         borderRadius: BorderRadius.circular(10),
    //         // shape: BoxShape.rectangle,
    //       ),
    //       child: Padding(padding: const EdgeInsets.all(8.0), child: widget),
    //     ),
    //     Positioned(
    //       left: 14,
    //       top: 12,
    //       child: Container(
    //         padding: EdgeInsets.only(bottom: 0, left: 5, right: 5),
    //         color: Colors.white,
    //         child: Text(
    //           title,
    //           style: GoogleFonts.nunitoSans(
    //             color: Colors.black,
    //             fontWeight: FontWeight.bold,
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
