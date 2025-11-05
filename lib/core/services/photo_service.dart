import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

class PhotoService {
  static final ImagePicker _picker = ImagePicker();
  
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const double maxWidth = 1200.0;
  static const double maxHeight = 1200.0;
  static const int maxPhotos = 5;

  // Pick images from gallery
  static Future<List<File>> pickImages() async {
    try {
      final List<XFile>? pickedFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: 85,
      );

      if (pickedFiles == null || pickedFiles.isEmpty) return [];

      final List<File> validFiles = [];
      
      for (final xFile in pickedFiles) {
        final file = File(xFile.path);
        final compressedFile = await _compressImage(file);
        
        if (compressedFile != null) {
          validFiles.add(compressedFile);
        }
        
        if (validFiles.length >= maxPhotos) break;
      }

      return validFiles;
    } catch (e) {
      throw Exception('Failed to pick images: $e');
    }
  }

  // Take photo with camera
  static Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: 85,
      );

      if (photo == null) return null;

      final file = File(photo.path);
      return await _compressImage(file);
    } catch (e) {
      throw Exception('Failed to take photo: $e');
    }
  }

  // Compress image to reduce file size
  static Future<File?> _compressImage(File file) async {
    try {
      final originalSize = await file.length();
      
      // If file is already small enough, return as is
      if (originalSize <= maxFileSize) {
        return file;
      }

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;

      // Calculate scaling factor to fit within max dimensions
      double scale = 1.0;
      if (image.width > maxWidth || image.height > maxHeight) {
        final widthScale = maxWidth / image.width;
        final heightScale = maxHeight / image.height;
        scale = widthScale < heightScale ? widthScale : heightScale;
      }

      final newWidth = (image.width * scale).round();
      final newHeight = (image.height * scale).round();

      final resizedImage = img.copyResize(
        image,
        width: newWidth,
        height: newHeight,
      );

      // Convert to JPEG for better compression
      final compressedBytes = img.encodeJpg(resizedImage, quality: 85);
      
      // Create compressed file
      final compressedFile = File(file.path.replaceAll(RegExp(r'\.(png|jpg|jpeg)$'), '_compressed.jpg'));
      await compressedFile.writeAsBytes(compressedBytes);

      // Check if compressed file is within limits
      final compressedSize = await compressedFile.length();
      if (compressedSize > maxFileSize) {
        // If still too large, delete and return null
        await compressedFile.delete();
        return null;
      }

      return compressedFile;
    } catch (e) {
      // If compression fails, return original file
      return file;
    }
  }

  // Convert file to base64 string
  static Future<String> fileToBase64(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);
      
      // Determine MIME type
      final extension = file.path.split('.').last.toLowerCase();
      String mimeType;
      
      switch (extension) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        default:
          mimeType = 'image/jpeg';
      }
      
      return 'data:$mimeType;base64,$base64String';
    } catch (e) {
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  // Validate file size
  static Future<bool> isValidFileSize(File file) async {
    final size = await file.length();
    return size <= maxFileSize;
  }

  // Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    final size = await file.length();
    return size / (1024 * 1024);
  }
}