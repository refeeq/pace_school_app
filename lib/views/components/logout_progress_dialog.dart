import 'package:flutter/material.dart';
import 'package:school_app/core/themes/const_colors.dart';

/// Shown while local data is cleared during logout; keep in sync with
/// [showDialog](barrierDismissible: false) callers.
class LogoutProgressDialog extends StatelessWidget {
  const LogoutProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: ConstColors.whiteColor,
        elevation: 6,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  color: ConstColors.primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Signing out...',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: ConstColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
