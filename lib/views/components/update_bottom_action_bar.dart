import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/themes/const_colors.dart';

/// Primary action pinned to the bottom: safe area, keyboard inset, and elevation
/// so the control stays visible and easy to find on notched devices.
class UpdateBottomActionBar extends StatelessWidget {
  const UpdateBottomActionBar({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.height = 48,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, 12 + bottomInset),
      child: SafeArea(
        top: false,
        child: Material(
          elevation: 6,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          color: isLoading ? Colors.grey : ConstColors.primary,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: isLoading ? null : onTap,
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: height,
              width: double.infinity,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        label,
                        style: GoogleFonts.nunitoSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
