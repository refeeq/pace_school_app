// ignore_for_file: deprecated_member_use

import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/models/communication_detail_model.dart';
import '../../core/utils/form_validators.dart';

class HighlightUrlText extends StatelessWidget {
  final CommunicationDetailModel communicationDetailModel;
  final String text;

  /// When set, used for non-link segments; otherwise black.
  final Color? baseTextColor;

  /// Base font size for non-link segments (default matches legacy 14).
  final double baseFontSize;

  /// When set, applied as [TextStyle.height] for non-link segments.
  final double? baseHeight;

  /// When set, used for non-link weight instead of [readStat]-based rules.
  final FontWeight? baseFontWeight;

  /// When set, used for matched URL segments instead of default [Colors.blue].
  final Color? linkColor;

  const HighlightUrlText({
    super.key,
    required this.text,
    required this.communicationDetailModel,
    this.baseTextColor,
    this.baseFontSize = 14,
    this.baseHeight,
    this.baseFontWeight,
    this.linkColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color resolvedBase =
        baseTextColor ?? const Color.fromRGBO(0, 0, 0, 1);
    List<InlineSpan> spans = [];
    RegExp exp = RegExp(r'(https?://|www\.)[^\s]+');

    text.splitMapJoin(
      exp,
      onMatch: (Match match) {
        spans.add(
          TextSpan(
            text: match.group(0),
            style: TextStyle(
              color: linkColor ?? Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launch(match.group(0)!);
              },
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(
          TextSpan(
            text: nonMatch,
            style: TextStyle(
              color: resolvedBase,
              fontFamily: 'Montserrat',
              fontSize: baseFontSize,
              height: baseHeight,
              letterSpacing:
                  0 /*percentages not used in flutter. defaulting to zero*/,
              fontWeight:
                  baseFontWeight ??
                  (communicationDetailModel.readStat == "0"
                      ? FontWeight.w500
                      : FontWeight.normal),
            ),
          ),
        );
        return nonMatch;
      },
    );

    return Text.rich(TextSpan(children: spans));
  }
}

class HighlightUrlTextCircular extends StatelessWidget {
  final String text;

  const HighlightUrlTextCircular({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    List<InlineSpan> spans = [];
    RegExp exp = RegExp(
      r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+@[\w/\-?=%.]+\.[\w/\-?=%.]+|(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+',
    );

    text.splitMapJoin(
      exp,
      onMatch: (Match match) {
        spans.add(
          TextSpan(
            text: match.group(0),
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (isValidEmail(match.group(0)!)) {
                  _launchEmail(match.group(0)!);
                } else {
                  launch(match.group(0)!);
                }
              },
          ),
        );
        return '';
      },
      onNonMatch: (String nonMatch) {
        spans.add(
          TextSpan(
            text: nonMatch,
            style: const TextStyle(
              color: Color.fromRGBO(0, 0, 0, 1),
              fontFamily: 'Montserrat',
              fontSize: 14,
              letterSpacing:
                  0 /*percentages not used in flutter. defaulting to zero*/,
              fontWeight: FontWeight.normal,
            ),
          ),
        );
        return nonMatch;
      },
    );

    return GestureDetector(
      onLongPress: () {
        _showContextMenu(context, text);
      },
      child: Text.rich(TextSpan(children: spans)),
    );
  }

  void _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);

    await launchUrl(emailLaunchUri);
  }

  void _showContextMenu(BuildContext context, String text) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset localPosition = renderBox.localToGlobal(Offset.zero);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(localPosition.dx, localPosition.dy, 0, 0),
      items: [const PopupMenuItem(value: 'copy', child: Text('Copy'))],
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
