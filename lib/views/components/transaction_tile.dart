import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/models/transaction_model.dart';
import 'package:school_app/core/provider/student_fee_provider.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/pdf_generator.dart';

class TransactionTileStudent extends StatelessWidget {
  final Transaction transaction;
  const TransactionTileStudent({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (transaction.no == "0" || transaction.doctType == '') {
          showToast("No Recipt found", context);
        } else {
          Provider.of<StudentFeeProvider>(context, listen: false).viewRcpt(
            type: transaction.doctType,
            studCode: transaction.studcode,
            no: transaction.no,
          );

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PdfGenerationScreen(id: transaction.no),
            ),
          );
        }
      },
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: ShapeDecoration(
                  color: !transaction.amt.startsWith("-")
                      ? const Color(0xFFFDEDEE)
                      : const Color(0xFFEAF7EE),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Transform.rotate(
                  angle: !transaction.amt.startsWith("-") ? 180 : 45,
                  child: Icon(
                    Icons.arrow_downward,
                    color: !transaction.amt.startsWith("-")
                        ? const Color(0xFF934A65)
                        : const Color(0xFFA6D1AE),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.type.trim(),
                          style: TextStyle(
                            color: const Color(0xFF26273A),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          transaction.desc.split(':')[0].trim(),
                          style: TextStyle(
                            color: const Color(0x9926273A),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          transaction.desc.split(':')[1].trim(),
                          style: TextStyle(
                            color: const Color(0xFF26273A),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'AED ${transaction.amt}',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: !transaction.amt.startsWith("-")
                                ? Colors.red
                                : Colors.green,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          transaction.accDate,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            color: const Color(0x9926273A),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
    //   child: InkWell(
    //     onTap: () async {
    //       if (transaction.no == "0" || transaction.doctType == '') {
    //         showToast("No Recipt found", context);
    //       } else {
    //         Provider.of<StudentFeeProvider>(context, listen: false).viewRcpt(
    //           type: transaction.doctType,
    //           studCode: transaction.studcode,
    //           no: transaction.no,
    //         );

    //         Navigator.push(
    //             context,
    //             MaterialPageRoute(
    //               builder: (context) => PdfGenerationScreen(
    //                 id: transaction.no,
    //               ),
    //             ));
    //       }
    //     },
    //     child: Container(
    //       width: double.infinity,
    //       decoration: ShapeDecoration(
    //         color: Colors.white,
    //         shape: RoundedRectangleBorder(
    //           side: const BorderSide(width: 1, color: Color(0x99E0E8F1)),
    //           borderRadius: BorderRadius.circular(15),
    //         ),
    //       ),
    //       child: Padding(
    //         padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
    //         child: Row(
    //           mainAxisSize: MainAxisSize.max,
    //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //           children: [
    //             Padding(
    //               padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
    //               child: Column(
    //                 mainAxisSize: MainAxisSize.max,
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 crossAxisAlignment: CrossAxisAlignment.start,
    //                 children: [
    //                   Text(
    //                     transaction.accDate,
    //                     style: GoogleFonts.nunitoSans(
    //                       textStyle: Theme.of(context).textTheme.titleSmall,
    //                     ),
    //                   ),
    //                   Padding(
    //                     padding:
    //                         const EdgeInsetsDirectional.fromSTEB(0, 08, 12, 0),
    //                     child: Text('AED ${transaction.amt}',
    //                         style: GoogleFonts.nunitoSans(
    //                           fontWeight: FontWeight.bold,
    //                           textStyle: Theme.of(context).textTheme.titleSmall,
    //                         )),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //             Column(
    //               crossAxisAlignment: CrossAxisAlignment.end,
    //               children: [
    //                 Padding(
    //                   padding:
    //                       const EdgeInsetsDirectional.fromSTEB(0, 08, 12, 0),
    //                   child: Text(
    //                     transaction.desc,
    //                     style: GoogleFonts.nunitoSans(
    //                       textStyle: Theme.of(context).textTheme.titleMedium,
    //                     ),
    //                   ),
    //                 ),
    //                 Padding(
    //                   padding:
    //                       const EdgeInsetsDirectional.fromSTEB(0, 08, 12, 0),
    //                   child: Container(
    //                     decoration: BoxDecoration(
    //                         color: HexColor(transaction.label),
    //                         borderRadius: BorderRadius.circular(15)),
    //                     child: Padding(
    //                       padding: const EdgeInsets.only(
    //                         top: 3.0,
    //                         bottom: 3,
    //                         left: 10,
    //                         right: 10,
    //                       ),
    //                       child: Text(transaction.type,
    //                           style: GoogleFonts.nunitoSans(
    //                             textStyle: Theme.of(context)
    //                                 .textTheme
    //                                 .titleSmall!
    //                                 .apply(color: Colors.white),
    //                           )),
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}
