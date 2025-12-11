// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:school_app/app.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateAlertDialog extends StatelessWidget {
  const UpdateAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Update Required'),
      content: const Text('Please update your app.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            _launchStoreURL();
            Navigator.of(context).pop();
          },
          child: const Text('Update'),
        ),
      ],
    );
  }

  void _launchStoreURL() async {
    final String appStoreUrl = Platform.isIOS
        ? 'https://apps.apple.com/app/${AppEnivrornment.appId}'
        : 'https://play.google.com/store/apps/details?id=${AppEnivrornment.bundleName}';

    if (await canLaunch(appStoreUrl)) {
      await launch(appStoreUrl);
    } else {
      throw 'Could not launch $appStoreUrl';
    }
  }
}
