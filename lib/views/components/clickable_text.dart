// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/communication_detail_model.dart';

class HighlightUrlText extends StatelessWidget {
  final CommunicationDetailModel communicationDetailModel;
  final String text;

  const HighlightUrlText(
      {super.key, required this.text, required this.communicationDetailModel});

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];
    RegExp exp = RegExp(r'(https?://|www\.)[^\s]+');

    text.splitMapJoin(exp, onMatch: (Match match) {
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            launch(match.group(0)!);
          },
      ));
      return '';
    }, onNonMatch: (String nonMatch) {
      spans.add(TextSpan(
        text: nonMatch,
        style: TextStyle(
          color: const Color.fromRGBO(0, 0, 0, 1),
          fontFamily: 'Montserrat',
          fontSize: 14,
          letterSpacing:
              0 /*percentages not used in flutter. defaulting to zero*/,
          fontWeight: communicationDetailModel.readStat == "0"
              ? FontWeight.w500
              : FontWeight.normal,
        ),
      ));
      return nonMatch;
    });

    return Text.rich(TextSpan(children: spans));
  }
}

class HighlightUrlTextCircular extends StatelessWidget {
  final String text;

  const HighlightUrlTextCircular({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];
    RegExp exp = RegExp(
        r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+@[\w/\-?=%.]+\.[\w/\-?=%.]+|(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');

    text.splitMapJoin(exp, onMatch: (Match match) {
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          color: Colors.blue,
          decoration: TextDecoration.underline,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (_isEmail(match.group(0)!)) {
              _launchEmail(match.group(0)!);
            } else {
              launch(match.group(0)!);
            }
          },
      ));
      return '';
    }, onNonMatch: (String nonMatch) {
      spans.add(TextSpan(
        text: nonMatch,
        style: const TextStyle(
          color: Color.fromRGBO(0, 0, 0, 1),
          fontFamily: 'Montserrat',
          fontSize: 14,
          letterSpacing:
              0 /*percentages not used in flutter. defaulting to zero*/,
          fontWeight: FontWeight.normal,
        ),
      ));
      return nonMatch;
    });

    return GestureDetector(
      onLongPress: () {
        _showContextMenu(context, text);
      },
      child: Text.rich(TextSpan(children: spans)),
    );
  }

  bool _isEmail(String input) {
    // Regular expression to validate an Email
    final RegExp emailRegex =
        RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');
    return emailRegex.hasMatch(input);
  }

  void _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );

    await launchUrl(emailLaunchUri);
  }

  void _showContextMenu(BuildContext context, String text) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(localPosition.dx, localPosition.dy, 0, 0),
      items: [
        const PopupMenuItem(
          value: 'copy',
          child: Text('Copy'),
        ),
      ],
    ).then((value) {
      if (value == 'copy') {
        log(text);
        Clipboard.setData(ClipboardData(text: text));
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Text copied to clipboard')),
        // );
      }
    });
  }
}
