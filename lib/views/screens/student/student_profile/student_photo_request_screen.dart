import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/provider/student_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/views/components/common_app_bar.dart';
import 'package:school_app/views/components/slect_student.dart';

class StudentPhotoRequestScreen extends StatefulWidget {
  const StudentPhotoRequestScreen({super.key});

  @override
  State<StudentPhotoRequestScreen> createState() =>
      _StudentPhotoRequestScreenState();
}

class _StudentPhotoRequestScreenState extends State<StudentPhotoRequestScreen> {
  String? _photoPath;
  bool _initialLoadDone = false;

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
                              onPressed: _pickPhoto,
                              icon: const Icon(Icons.photo),
                              label: Text(
                                _photoPath == null
                                    ? 'Choose photo'
                                    : 'Change photo',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Allowed formats: JPG, JPEG, PNG",
                            style: GoogleFonts.nunitoSans(fontSize: 12),
                          ),
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GestureDetector(
          onTap: isLoading ? null : _onSubmit,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isLoading ? Colors.grey : ConstColors.primary,
            ),
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
                      "SUBMIT REQUEST",
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
    );
  }

  Future<void> _pickPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _photoPath = result.files.single.path!;
        });
      }
    } catch (e) {
      showToast("Failed to pick image", context, type: ToastType.error);
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

