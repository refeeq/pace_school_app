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
import 'package:school_app/views/components/update_bottom_action_bar.dart';

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
      body: SingleChildScrollView(
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
            const SizedBox(height: 20),
            _buildPhotoGuidelines(),
          ],
        ),
      ),
      bottomNavigationBar: UpdateBottomActionBar(
        label: 'SUBMIT REQUEST',
        isLoading: isLoading,
        onTap: _onSubmit,
      ),
    );
  }

  Widget _buildPhotoGuidelines() {
    final relation = widget.relation.toLowerCase();
    final guidelines = [
      'Use a recent, passport-sized photograph of the $relation only.',
      'Dress professionally. Formal or smart casual attire is preferred.',
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

