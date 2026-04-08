import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileTile extends StatelessWidget {
  final bool isRed;
  final String label;
  final String value;
  final bool canEdit;
  /// Optional custom color for the value text. Overrides isRed when set.
  final Color? valueColor;
  const ProfileTile({
    super.key,
    required this.label,
    required this.value,
    this.isRed = false,
    this.canEdit = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.nunitoSans(
                  textStyle: const TextStyle(
                    color: Color(0xFF777F84),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ": ",
                    style: GoogleFonts.nunitoSans(
                      textStyle: const TextStyle(
                        color: Color(0xFF777F84),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      value.isEmpty ? " _ " : value,
                      style: GoogleFonts.nunitoSans(
                        textStyle: TextStyle(
                          color: valueColor ??
                              (isRed ? Colors.red : const Color(0xFF000203)),
                          fontSize: 14,
                          fontWeight: (valueColor != null || isRed)
                              ? FontWeight.w800
                              : FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  
                  if (canEdit) ...[
                  SizedBox(width: 5,),
                  Icon(Icons.edit, size: 18),]
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
