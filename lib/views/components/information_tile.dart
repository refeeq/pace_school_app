// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Informationtile extends StatelessWidget {
  final bool show;
  final String image;
  final String title;
  final String? title2;
  const Informationtile({
    super.key,
    required this.image,
    required this.title,
    this.show = false,
    this.title2,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: GestureDetector(
        onTap: () async {
          if (await canLaunch(title)) {
            await launch(title);
          } else {
            throw 'Could not launch $title';
          }
          // await launchUrl(
          //   Uri.parse(title),
          // );
        },
        child: Image.asset(
          image,
          height: 25,
        ),
      ),
    );
  }
}
