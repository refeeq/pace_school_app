import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/core/utils/image_processing_helper.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';
import 'package:school_app/views/components/update_bottom_action_bar.dart';

class StudentPhotoRequestScreen extends StatefulWidget {
  const StudentPhotoRequestScreen({super.key});

  @override
  State<StudentPhotoRequestScreen> createState() =>
      _StudentPhotoRequestScreenState();
}

class _StudentPhotoRequestScreenState extends State<StudentPhotoRequestScreen> {
  String? _photoPath;
  bool _initialLoadDone = false;
  bool _isProcessingImage = false;

  @override
  Widget build(BuildContext context) {
    final updateProvider = Provider.of<ParentUpdateProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final isLoading =
        updateProvider.stateFor('student_photo') == AppStates.Initial_Fetching;

    if (!_initialLoadDone &&
        studentProvider.studentsModel != null &&
        studentProvider.studentsModel!.data.isNotEmpty) {
      _initialLoadDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final sp = Provider.of<StudentProvider>(context, listen: false);
        final selected = sp.selectedStudentModel(context);
        final currentDetail = sp.studentDetailModel?.data;
        if (currentDetail == null || currentDetail.studcode != selected.studcode) {
          sp.getStudentDetail(studCode: selected.studcode);
        }
      });
    }

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: const CommonAppBar(title: 'Request Student Photo Update'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            child: SelectStudentWidget(
              onchanged: (index) {
                final sp = Provider.of<StudentProvider>(context, listen: false);
                sp.getStudentDetail(
                  studCode: sp.studentsModel!.data[index].studcode,
                );
              },
            ),
          ),
          Expanded(
            child: Consumer<StudentProvider>(
              builder: (context, sp, _) {
                switch (sp.studentDetail) {
                  case AppStates.Initial_Fetching:
                    return const Center(child: CircularProgressIndicator());
                  case AppStates.Fetched:
                    if (sp.studentDetailModel?.data == null) {
                      return const Center(
                          child: Text('No student details available'));
                    }
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Text(
                            "Upload a new photo for the selected student. The change will be applied after school approval.",
                            style: GoogleFonts.nunitoSans(fontSize: 17),
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade200,
                              backgroundImage: _photoPath != null
                                  ? FileImage(File(_photoPath!))
                                  : null,
                              child: _photoPath == null
                                  ? const Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: OutlinedButton.icon(
                              onPressed: _isProcessingImage ? null : _pickPhoto,
                              icon: _isProcessingImage
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.photo),
                              label: Text(
                                _isProcessingImage
                                    ? 'Processing...'
                                    : _photoPath == null
                                        ? 'Choose photo'
                                        : 'Change photo',
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildPhotoGuidelines(),
                        ],
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: UpdateBottomActionBar(
        label: 'SUBMIT REQUEST',
        isLoading: isLoading,
        onTap: _onSubmit,
      ),
    );
  }

  Widget _buildPhotoGuidelines() {
    const guidelines = [
      'Use a recent, passport-sized photograph of the student only.',
      'The student should be well dressed. School uniform is preferred.',
      'Face must be clearly visible, looking directly at the camera, with a neutral expression.',
      'Use a plain, light-coloured background. No scenery, filters, or busy patterns.',
      'Ensure good lighting. Avoid shadows on the face.',
      'Do not upload selfies, group photos, screenshots, cartoons, or photos with sunglasses, hats, or other people.',
      'Allowed formats: JPG, JPEG, PNG.',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ConstColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ConstColors.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ConstColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Photo guidelines',
                style: GoogleFonts.nunitoSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: ConstColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...guidelines.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•  ',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 13,
                      height: 1.4,
                      color: Colors.black87,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    try {
      setState(() {
        _isProcessingImage = true;
      });

      // Use the image processing helper to pick and process image
      final processedImagePath = await ImageProcessingHelper.pickAndProcessImage(context);

      if (processedImagePath != null) {
        setState(() {
          _photoPath = processedImagePath;
          _isProcessingImage = false;
        });
      } else {
        setState(() {
          _isProcessingImage = false;
        });
        // User cancelled or error occurred - don't show error if user cancelled
        if (mounted) {
          // Only show error if it wasn't a cancellation
          // The helper returns null for cancellation, which is fine
        }
      }
    } catch (e) {
      setState(() {
        _isProcessingImage = false;
      });
      if (mounted) {
        showToast("Failed to process image: ${e.toString()}", context, type: ToastType.error);
      }
    }
  }

  Future<void> _onSubmit() async {
    if (_photoPath == null || _photoPath!.isEmpty) {
      showToast("Please select a photo", context, type: ToastType.error);
      return;
    }

    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    final data = studentProvider.studentDetailModel?.data;

    if (data == null) {
      showToast("Student details not available", context, type: ToastType.error);
      return;
    }

    final updateProvider =
        Provider.of<ParentUpdateProvider>(context, listen: false);
    final success = await updateProvider.submitStudentPhotoRequest(
      admissionNo: data.studcode,
      photoPath: _photoPath!,
      context: context,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}

