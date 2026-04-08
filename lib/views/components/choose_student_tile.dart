import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/models/students_model.dart';
import 'package:school_app/core/themes/const_colors.dart';

class ChooseStudentTile extends StatelessWidget {
  final bool showArrow;
  final StudentModel studentModel;

  const ChooseStudentTile({
    super.key,
    required this.studentModel,
    required this.showArrow,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: ConstColors.filledColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: ConstColors.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 38,
                child: CircleAvatar(
                  radius: 35,
                  backgroundImage: NetworkImage(studentModel.photo),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FittedBox(
                      child: Text(
                        studentModel.fullname,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.nunitoSans(
                          textStyle: Theme.of(context).textTheme.titleLarge!
                              .apply(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeightDelta: 2,
                                fontFamily: 'SourceSansPro',
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Class ${studentModel.datumClass}-${studentModel.section}  ',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.nunitoSans(
                        textStyle: Theme.of(context).textTheme.titleMedium!
                            .apply(
                              color: const Color.fromARGB(255, 0, 0, 0),
                              fontFamily: 'SourceSansPro',
                            ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: ConstColors.blueColorTwo,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              top: 5.0,
                              bottom: 5,
                              left: 15,
                              right: 15,
                            ),
                            child: Text(
                              "Admission No: ${studentModel.studcode}",
                              textAlign: TextAlign.left,
                              style: GoogleFonts.nunitoSans(
                                textStyle: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .apply(color: ConstColors.blueColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              showArrow
                  ? const Icon(Icons.arrow_forward_ios)
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
