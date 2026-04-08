import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:school_app/app.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/platform_check.dart';
import 'package:url_launcher/url_launcher.dart';

/// Full-screen blocking UI when the backend requires a newer app version.
/// User can only open the store to update; no "Later" or back.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  static String _storeUrl() {
    try {
      if (isIOS) {
        final appUrl = AppEnivrornment.appUrl;
        if (appUrl.isNotEmpty) {
          return appUrl;
        }
        final appId = AppEnivrornment.appId;
        if (appId.isNotEmpty) {
          return 'https://apps.apple.com/app/id$appId';
        }
        return 'https://apps.apple.com';
      }
      final bundleName = AppEnivrornment.bundleName;
      if (bundleName.isNotEmpty) {
        return 'https://play.google.com/store/apps/details?id=$bundleName';
      }
      return 'https://play.google.com';
    } catch (e) {
      log('[FORCE_UPDATE] ❌ Error building store URL: $e');
      return isIOS ? 'https://apps.apple.com' : 'https://play.google.com';
    }
  }

  Future<void> _openStore(BuildContext context) async {
    final url = _storeUrl();
    log('[FORCE_UPDATE] 🏪 User tapped Update button');
    log('[FORCE_UPDATE] 🏪 Opening store URL: $url');
    final uri = Uri.tryParse(url);
    if (uri == null) {
      log('[FORCE_UPDATE] ❌ Invalid store URL: $url');
      return;
    }
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        log('[FORCE_UPDATE] ✅ Store opened successfully');
      } else {
        log('[FORCE_UPDATE] ❌ Cannot launch store URL');
      }
    } catch (e) {
      log('[FORCE_UPDATE] ❌ Error opening store: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      log('[FORCE_UPDATE] 🎨 ForceUpdateScreen is being displayed');
    } catch (_) {
      // Logging error shouldn't break the UI
    }

    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: 40,
                vertical: isSmallScreen ? 32 : 48,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Lottie Animation
                    SizedBox(
                      height: isSmallScreen ? 240 : 300,
                      width: double.infinity,
                      child: _buildLottieAnimation(),
                    ),
                    
                    SizedBox(height: isSmallScreen ? 32 : 40),
                    
                    // Title - Clean and Professional
                    Text(
                      'Update Required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: ConstColors.primary,
                        letterSpacing: -0.3,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: isSmallScreen ? 12 : 16),
                    
                    // Description - Minimal and Clear
                    Text(
                      'A new version is available.\nPlease update to continue.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700],
                        height: 1.5,
                        letterSpacing: 0.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: isSmallScreen ? 36 : 44),
                    
                    // Update Button - Clean and Professional
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _openStore(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ConstColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLottieAnimation() {
    return Lottie.asset(
      'assets/animations/Update-app.json',
      fit: BoxFit.contain,
      repeat: true,
      animate: true,
      errorBuilder: (context, error, stackTrace) {
        log('[FORCE_UPDATE] ❌ Error loading Lottie animation: $error');
        log('[FORCE_UPDATE] Attempted path: assets/animations/Update-app.json');
        // Try alternative path with capital A
        try {
          return Lottie.asset(
            'assets/animations/Update-app.json',
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
            errorBuilder: (_, __, ___) {
              // Final fallback to icon
              return Container(
                decoration: BoxDecoration(
                  color: ConstColors.primary.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.system_update_rounded,
                  size: 80,
                  color: ConstColors.primary,
                ),
              );
            },
          );
        } catch (e) {
          log('[FORCE_UPDATE] ❌ Alternative path also failed: $e');
          // Fallback to simple icon
          return Container(
            decoration: BoxDecoration(
              color: ConstColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.system_update_rounded,
              size: 80,
              color: ConstColors.primary,
            ),
          );
        }
      },
    );
  }
}
