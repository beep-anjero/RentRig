import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

abstract interface class IImageService {
  Future<XFile?> pickImageFromGallery();
  Future<String> uploadToolImage(File imageFile, String userId);
  Future<void> deleteImage(String imageUrl);
}

class ImageService implements IImageService {
  static const String _cloudName = 'do9c4liq3';
  static const String _uploadPreset = 'rentrig';
  
  final CloudinaryPublic _cloudinary;
  final ImagePicker _picker;

  ImageService({
    CloudinaryPublic? cloudinary,
    ImagePicker? picker,
  })  : _cloudinary = cloudinary ?? CloudinaryPublic(_cloudName, _uploadPreset),
        _picker = picker ?? ImagePicker();

  @override
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  @override
  Future<String> uploadToolImage(File imageFile, String userId) async {
    try {
      final String identifier = '${userId}_${DateTime.now().millisecondsSinceEpoch}';
      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'rentrig/equipment',
          resourceType: CloudinaryResourceType.Image,
          publicId: identifier,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  @override
  Future<void> deleteImage(String imageUrl) async {
    try {
    } catch (e) {
    }
  }
}

