import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Helper class for image processing operations including picking, cropping, and compression
class ImageProcessingHelper {
  /// Allowed image extensions
  static const List<String> allowedExtensions = ['jpg', 'jpeg', 'png'];

  /// Maximum file size in bytes (250 KB)
  static const int maxFileSizeBytes = 250 * 1024;

  /// UAE passport aspect ratio: Height 4.5, Width 3.5
  /// ratioX = width (3.5), ratioY = height (4.5)
  static const double aspectRatioX = 3.5; // Width
  static const double aspectRatioY = 4.5; // Height

  /// Formats file size in human-readable format
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  /// Shows a dialog to choose between Gallery and Files
  static Future<ImageSourceOption?> showImageSourceDialog(BuildContext context) async {
    return showDialog<ImageSourceOption>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.of(context).pop(ImageSourceOption.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.folder),
                title: const Text('Files'),
                onTap: () => Navigator.of(context).pop(ImageSourceOption.files),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Picks an image from gallery using image_picker
  static Future<String?> pickImageFromGallery() async {
    try {
      debugPrint('📸 [Image Processing] Picking image from gallery...');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (image != null) {
        final fileSize = await getFileSize(image.path);
        debugPrint('✅ [Image Processing] Image selected from gallery');
        debugPrint('   📁 Path: ${image.path}');
        debugPrint('   📊 Original size: ${_formatFileSize(fileSize)} (${fileSize} bytes)');
        return image.path;
      }
      debugPrint('❌ [Image Processing] No image selected from gallery');
      return null;
    } catch (e) {
      debugPrint('❌ [Image Processing] Error picking image from gallery: $e');
      return null;
    }
  }

  /// Picks an image from files using file_picker
  static Future<String?> pickImageFromFiles() async {
    try {
      debugPrint('📁 [Image Processing] Picking image from files...');
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final extension = path.extension(filePath).toLowerCase().replaceFirst('.', '');
        
        // Validate file extension
        if (allowedExtensions.contains(extension)) {
          final fileSize = await getFileSize(filePath);
          debugPrint('✅ [Image Processing] Image selected from files');
          debugPrint('   📁 Path: $filePath');
          debugPrint('   📊 Original size: ${_formatFileSize(fileSize)} (${fileSize} bytes)');
          debugPrint('   📄 Format: $extension');
          return filePath;
        } else {
          debugPrint('❌ [Image Processing] Invalid file format: $extension');
        }
      }
      debugPrint('❌ [Image Processing] No image selected from files');
      return null;
    } catch (e) {
      debugPrint('❌ [Image Processing] Error picking image from files: $e');
      return null;
    }
  }

  /// Validates if the file is a supported image format
  static bool isValidImageFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase().replaceFirst('.', '');
    return allowedExtensions.contains(extension);
  }

  /// Crops an image to UAE passport ratio (Height 4.5, Width 3.5)
  /// Shows an interactive preview where users can adjust the crop area
  static Future<String?> cropImage(String imagePath, BuildContext context) async {
    try {
      final originalSize = await getFileSize(imagePath);
      debugPrint('✂️ [Image Processing] Starting crop operation...');
      debugPrint('   📁 Input path: $imagePath');
      debugPrint('   📊 Input size: ${_formatFileSize(originalSize)} (${originalSize} bytes)');
      debugPrint('   📐 Aspect ratio: ${aspectRatioX}:${aspectRatioY} (Width:Height)');
      
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        aspectRatio: const CropAspectRatio(ratioX: aspectRatioX, ratioY: aspectRatioY),
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Adjust Crop Area - UAE Passport Ratio (Height 4.5, Width 3.5)',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
            hideBottomControls: false,
            showCropGrid: true,
            cropFrameColor: Colors.blue,
            cropGridColor: Colors.white.withOpacity(0.5),
            cropGridStrokeWidth: 2,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: Colors.blue,
            dimmedLayerColor: Colors.black.withOpacity(0.8),
            cropFrameStrokeWidth: 3,
          ),
          IOSUiSettings(
            title: 'Adjust Crop Area',
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            aspectRatioLockDimensionSwapEnabled: false,
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            hidesNavigationBar: false,
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            showActivitySheetOnDone: false,
            showCancelConfirmationDialog: false,
          ),
        ],
      );

      if (croppedFile != null) {
        final croppedSize = await getFileSize(croppedFile.path);
        debugPrint('✅ [Image Processing] Crop completed successfully');
        debugPrint('   📁 Output path: ${croppedFile.path}');
        debugPrint('   📊 Cropped size: ${_formatFileSize(croppedSize)} (${croppedSize} bytes)');
        debugPrint('   📉 Size reduction: ${_formatFileSize(originalSize - croppedSize)} (${((originalSize - croppedSize) / originalSize * 100).toStringAsFixed(1)}%)');
        return croppedFile.path;
      } else {
        debugPrint('⚠️ [Image Processing] Crop cancelled by user');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [Image Processing] Error cropping image: $e');
      return null;
    }
  }

  /// Gets file size in bytes
  static Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    return await file.length();
  }

  /// Compresses an image to maximum 250KB
  static Future<String?> compressImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('❌ [Image Processing] Image file does not exist: $imagePath');
        return null;
      }

      // Get original file size
      final originalSize = await getFileSize(imagePath);
      debugPrint('🗜️ [Image Processing] Starting compression...');
      debugPrint('   📁 Input path: $imagePath');
      debugPrint('   📊 Input size: ${_formatFileSize(originalSize)} (${originalSize} bytes)');
      debugPrint('   🎯 Target size: ${_formatFileSize(maxFileSizeBytes)} (${maxFileSizeBytes} bytes)');
      
      // If already under 250KB, return original
      if (originalSize <= maxFileSizeBytes) {
        debugPrint('✅ [Image Processing] Image already under ${_formatFileSize(maxFileSizeBytes)}, no compression needed');
        return imagePath;
      }

      // Get temporary directory for compressed image
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(imagePath);
      final extension = path.extension(imagePath);
      final targetPath = path.join(tempDir.path, '${fileName}_compressed$extension');

      // Start with quality 85
      int quality = 85;
      int minWidth = 800;
      int minHeight = 600;
      int iteration = 0;
      int lastSize = originalSize;
      int currentSize = originalSize;

      debugPrint('   🔄 Compression iterations:');

      // Try compressing with different quality levels
      while (quality >= 30 && currentSize > maxFileSizeBytes) {
        iteration++;
        debugPrint('   ⚙️ Iteration $iteration: Quality=$quality, Dimensions=${minWidth}x${minHeight}');
        
        final compressedFile = await FlutterImageCompress.compressAndGetFile(
          imagePath,
          targetPath,
          quality: quality,
          minWidth: minWidth,
          minHeight: minHeight,
        );

        if (compressedFile == null) {
          debugPrint('❌ [Image Processing] Failed to compress image');
          return null;
        }

        currentSize = await getFileSize(compressedFile.path);
        final sizeReduction = originalSize - currentSize;
        final reductionPercent = (sizeReduction / originalSize * 100);
        
        debugPrint('      📊 Result size: ${_formatFileSize(currentSize)} (${currentSize} bytes)');
        debugPrint('      📉 Reduction: ${_formatFileSize(sizeReduction)} (${reductionPercent.toStringAsFixed(1)}%)');

        // If still too large, reduce quality and dimensions
        if (currentSize > maxFileSizeBytes) {
          if (currentSize >= lastSize) {
            // Size didn't reduce, need to be more aggressive
            quality -= 15;
            minWidth = (minWidth * 0.75).round();
            minHeight = (minHeight * 0.75).round();
          } else {
            quality -= 10;
            if (quality < 50) {
              minWidth = (minWidth * 0.8).round();
              minHeight = (minHeight * 0.8).round();
            }
          }
          lastSize = currentSize;
        } else {
          // Successfully compressed to under 250KB
          debugPrint('✅ [Image Processing] Compression completed successfully');
          debugPrint('   📁 Output path: ${compressedFile.path}');
          debugPrint('   📊 Final size: ${_formatFileSize(currentSize)} (${currentSize} bytes)');
          debugPrint('   📉 Total reduction: ${_formatFileSize(originalSize - currentSize)} (${((originalSize - currentSize) / originalSize * 100).toStringAsFixed(1)}%)');
          debugPrint('   ⚙️ Final settings: Quality=$quality, Dimensions=${minWidth}x${minHeight}');
          return compressedFile.path;
        }
      }

      // If still too large after all attempts, return the best compressed version
      final finalFile = File(targetPath);
      if (await finalFile.exists()) {
        final finalSize = await getFileSize(targetPath);
        debugPrint('⚠️ [Image Processing] Compression completed but still above target');
        debugPrint('   📁 Output path: $targetPath');
        debugPrint('   📊 Final size: ${_formatFileSize(finalSize)} (${finalSize} bytes)');
        debugPrint('   ⚙️ Final settings: Quality=$quality, Dimensions=${minWidth}x${minHeight}');
        return targetPath;
      }

      debugPrint('⚠️ [Image Processing] Compression failed, returning original');
      return imagePath;
    } catch (e) {
      debugPrint('❌ [Image Processing] Error compressing image: $e');
      return null;
    }
  }

  /// Complete image processing pipeline: pick -> validate -> crop -> compress
  /// Returns the processed image path or null if failed
  static Future<String?> processImage({
    required BuildContext context,
    required ImageSourceOption source,
  }) async {
    try {
      debugPrint('🚀 [Image Processing] ========================================');
      debugPrint('🚀 [Image Processing] Starting image processing pipeline');
      debugPrint('🚀 [Image Processing] Source: ${source.name}');
      debugPrint('🚀 [Image Processing] ========================================');
      
      // Step 1: Pick image based on source
      String? imagePath;
      if (source == ImageSourceOption.gallery) {
        imagePath = await pickImageFromGallery();
      } else if (source == ImageSourceOption.files) {
        imagePath = await pickImageFromFiles();
      } else {
        debugPrint('❌ [Image Processing] Invalid source: $source');
        return null;
      }

      if (imagePath == null) {
        debugPrint('❌ [Image Processing] No image selected');
        return null;
      }

      final originalSize = await getFileSize(imagePath);
      debugPrint('📋 [Image Processing] Selected image details:');
      debugPrint('   📁 Path: $imagePath');
      debugPrint('   📊 Size: ${_formatFileSize(originalSize)} (${originalSize} bytes)');

      // Step 2: Validate image format
      if (!isValidImageFormat(imagePath)) {
        debugPrint('❌ [Image Processing] Invalid image format');
        return null;
      }
      debugPrint('✅ [Image Processing] Image format validated');

      // Step 3: Crop image to UAE passport ratio with interactive preview
      // Users can adjust the crop area in the preview screen
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      final croppedPath = await cropImage(imagePath, context);
      if (croppedPath == null) {
        // User cancelled cropping, return null
        debugPrint('⚠️ [Image Processing] Crop cancelled by user');
        return null;
      }

      // Step 4: Compress image to max 250KB
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      final compressedPath = await compressImage(croppedPath);
      if (compressedPath == null) {
        // If compression fails, use cropped image
        debugPrint('⚠️ [Image Processing] Compression failed, using cropped image');
        return croppedPath;
      }

      final finalSize = await getFileSize(compressedPath);
      debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('✅ [Image Processing] ========================================');
      debugPrint('✅ [Image Processing] Image processing completed successfully');
      debugPrint('✅ [Image Processing] ========================================');
      debugPrint('📊 [Image Processing] Final Summary:');
      debugPrint('   📁 Original path: $imagePath');
      debugPrint('   📊 Original size: ${_formatFileSize(originalSize)} (${originalSize} bytes)');
      debugPrint('   📁 Final path: $compressedPath');
      debugPrint('   📊 Final size: ${_formatFileSize(finalSize)} (${finalSize} bytes)');
      debugPrint('   📉 Total reduction: ${_formatFileSize(originalSize - finalSize)} (${((originalSize - finalSize) / originalSize * 100).toStringAsFixed(1)}%)');
      debugPrint('   📐 Aspect ratio: ${aspectRatioX}:${aspectRatioY} (Width:Height)');
      debugPrint('✅ [Image Processing] ========================================');

      return compressedPath;
    } catch (e) {
      debugPrint('❌ [Image Processing] Error processing image: $e');
      debugPrint('❌ [Image Processing] Stack trace: ${StackTrace.current}');
      return null;
    }
  }

  /// Shows image source selection dialog and processes the selected image
  static Future<String?> pickAndProcessImage(BuildContext context) async {
    debugPrint('🎯 [Image Processing] User initiated image selection');
    // Show dialog to select source
    final source = await showImageSourceDialog(context);
    
    if (source == null) {
      debugPrint('⚠️ [Image Processing] User cancelled source selection');
      return null;
    }

    debugPrint('✅ [Image Processing] User selected: ${source.name}');
    // Process image based on selected source
    return await processImage(context: context, source: source);
  }
}

/// Enum for image source selection (Gallery or Files)
enum ImageSourceOption {
  gallery,
  files,
}
