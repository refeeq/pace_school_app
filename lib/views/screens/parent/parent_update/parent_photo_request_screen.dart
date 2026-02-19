import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/core/config/app_status.dart';
import 'package:school_app/core/provider/parent_update_provider.dart';
import 'package:school_app/core/themes/const_colors.dart';
import 'package:school_app/core/utils/utils.dart';
import 'package:school_app/core/utils/image_processing_helper.dart';
import 'package:school_app/views/components/common_app_bar.dart';

class ParentPhotoRequestScreen extends StatefulWidget {
  final String relation; // "Father" or "Mother"

  const ParentPhotoRequestScreen({super.key, required this.relation});

  @override
  State<ParentPhotoRequestScreen> createState() =>
      _ParentPhotoRequestScreenState();
}

class _ParentPhotoRequestScreenState extends State<ParentPhotoRequestScreen> {
  String? _photoPath;
  bool _isProcessingImage = false;

  @override
  Widget build(BuildContext context) {
    final updateProvider = Provider.of<ParentUpdateProvider>(context);
    final key =
        widget.relation.toLowerCase() == 'mother' ? 'mother_photo' : 'father_photo';
    final isLoading = updateProvider.stateFor(key) == AppStates.Initial_Fetching;

    return Scaffold(
      backgroundColor: ConstColors.backgroundColor,
      appBar: CommonAppBar(title: 'Request ${widget.relation} Photo Update'),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Upload a new photo for ${widget.relation.toLowerCase()}. The change will be applied after school approval.",
              style: GoogleFonts.nunitoSans(fontSize: 17),
            ),
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    _photoPath != null ? FileImage(File(_photoPath!)) : null,
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
            const SizedBox(height: 8),
            Text(
              "Allowed formats: JPG, JPEG, PNG",
              style: GoogleFonts.nunitoSans(fontSize: 12),
            ),
          ],
        ),
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

    final updateProvider =
        Provider.of<ParentUpdateProvider>(context, listen: false);

    final bool success;
    if (widget.relation.toLowerCase() == 'mother') {
      success = await updateProvider.submitMotherPhotoRequest(
        photoPath: _photoPath!,
        context: context,
      );
    } else {
      success = await updateProvider.submitFatherPhotoRequest(
        photoPath: _photoPath!,
        context: context,
      );
    }

    if (success && mounted) {
      Navigator.pop(context);
    }
  }
}

