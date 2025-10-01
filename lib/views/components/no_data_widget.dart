import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class NoDataWidget extends StatelessWidget {
  final String imagePath;
  final String content;
  const NoDataWidget({
    super.key,
    required this.imagePath,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(imagePath),
            const SizedBox(
              height: 10,
            ),
            Text(
              content,
              style: GoogleFonts.nunitoSans(
                textStyle: Theme.of(context).textTheme.titleLarge,
              ),
              textAlign: TextAlign.center,
            )
          ],
        ));
  }
}
