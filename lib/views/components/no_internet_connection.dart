import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/themes/const_colors.dart';

class NoInternetConnection extends StatefulWidget {
  final Function() ontap;
  const NoInternetConnection({super.key, required this.ontap});

  @override
  State<NoInternetConnection> createState() => _NoInternetConnectionState();
}

class _NoInternetConnectionState extends State<NoInternetConnection> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset("assets/images/no_connection.svg"),
            // SizedBox(
            //   height: MediaQuery.of(context).size.height * 0.2,
            // ),
            const Center(
              child: Text(
                "Oops!",
                style: TextStyle(
                  fontSize: 44.4,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Roboto',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No internet connection detected. Please ensure that your device is connected to a Wi-Fi or cellular network.",
              style: GoogleFonts.nunitoSans(
                textStyle: const TextStyle(
                  fontSize: 22.4,
                  color: Colors.black,
                  fontWeight: FontWeight.normal,
                  fontFamily: 'Roboto',
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            IconButton(
              icon: const Icon(Icons.refresh, size: 50, color: Colors.blue),
              onPressed: widget.ontap,
            ),
          ],
        ),
      ),
    );
  }
}
