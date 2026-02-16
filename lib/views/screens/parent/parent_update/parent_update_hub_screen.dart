import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/screens/parent/parent_update/address_update_screen.dart';
import 'package:school_app/views/screens/parent/parent_update/parent_eid_request_screen.dart';
import 'package:school_app/views/screens/parent/parent_update/parent_photo_request_screen.dart';
import 'package:school_app/views/screens/parent/parent_update/parent_update_history_screen.dart';
import 'package:school_app/views/screens/parent/parent_profile/verify_email.dart';
import 'package:school_app/views/screens/parent/parent_profile/verify_mobile.dart';
import 'package:school_app/views/screens/student/student_profile/student_eid_request_screen.dart';
import 'package:school_app/views/screens/student/student_profile/student_passport_request_screen.dart';
import 'package:school_app/views/screens/student/student_profile/student_photo_request_screen.dart';

class ParentUpdateHubScreen extends StatelessWidget {
  const ParentUpdateHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: 'Change Requests'),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _SectionHeader(title: 'Student Information'),
          _HubTile(
            title: 'Student Passport',
            subtitle: 'Update student\'s passport details',
            icon: Icons.travel_explore,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const StudentPassportRequestScreen(),
                ),
              );
            },
          ),
          _HubTile(
            title: 'Student Emirates ID',
            subtitle: 'Update student\'s Emirates ID',
            icon: Icons.credit_card,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentEidRequestScreen(),
                ),
              );
            },
          ),
          _HubTile(
            title: 'Student Photo',
            subtitle: 'Update student\'s photograph',
            icon: Icons.photo,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StudentPhotoRequestScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Parent Information'),
          _HubTile(
            title: 'Father Photo',
            subtitle: 'Update father\'s photograph',
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ParentPhotoRequestScreen(relation: 'Father'),
                ),
              );
            },
          ),
          _HubTile(
            title: 'Mother Photo',
            subtitle: 'Update mother\'s photograph',
            icon: Icons.person_outline,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ParentPhotoRequestScreen(relation: 'Mother'),
                ),
              );
            },
          ),
          _HubTile(
            title: 'Father Emirates ID',
            subtitle: 'Update father\'s Emirates ID',
            icon: Icons.badge,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ParentEidRequestScreen(relation: 'Father'),
                ),
              );
            },
          ),
          _HubTile(
            title: 'Mother Emirates ID',
            subtitle: 'Update mother\'s Emirates ID',
            icon: Icons.badge_outlined,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const ParentEidRequestScreen(relation: 'Mother'),
                ),
              );
            },
          ),
          _HubTile(
            title: 'Father Email',
            subtitle: 'Update father\'s email address. OTP verification required.',
            icon: Icons.email,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerifyEmail(relation: 'Father'),
                ),
              );
            },
          ),
          _HubTile(
            title: 'Phone Number',
            subtitle: 'Update father\'s phone number. OTP verification required.',
            icon: Icons.phone,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VerifyMobile(relation: 'Father'),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Family Address'),
          _HubTile(
            title: 'Family Address',
            subtitle: 'Update family address details',
            icon: Icons.home,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressUpdateScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _SectionHeader(title: 'Request History'),
          _HubTile(
            title: 'View History',
            subtitle: 'Track submitted requests',
            icon: Icons.history,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ParentUpdateHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _HubTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: ConstColors.primary),
        title: Text(
          title,
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.nunitoSans(fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
