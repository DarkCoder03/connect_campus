import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // Your Cloudinary credentials
  static const String cloudName = 'dt3hblwfv';
  static const String uploadPreset = 'connect_campus';

  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    cloudName,
    uploadPreset,
    cache: false,
  );

  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick image from camera
  Future<File?> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  // Upload profile photo to Cloudinary
  Future<String?> uploadProfilePhoto(String userId, File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'connect_campus/profiles/$userId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      print('Uploaded to Cloudinary: ${response.secureUrl}');
      return response.secureUrl;
    } catch (e) {
      print('Error uploading to Cloudinary: $e');
      return null;
    }
  }

  // Upload multiple photos
  Future<List<String>> uploadMultiplePhotos(String userId, List<File> imageFiles) async {
    List<String> urls = [];
    
    for (int i = 0; i < imageFiles.length; i++) {
      try {
        CloudinaryResponse response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            imageFiles[i].path,
            folder: 'connect_campus/profiles/$userId',
            resourceType: CloudinaryResourceType.Image,
          ),
        );
        urls.add(response.secureUrl);
        print('Uploaded photo ${i + 1}: ${response.secureUrl}');
      } catch (e) {
        print('Error uploading image $i: $e');
      }
    }
    
    return urls;
  }

  // Upload chat image
  Future<String?> uploadChatImage(String chatId, File imageFile) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: 'connect_campus/chats/$chatId',
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl;
    } catch (e) {
      print('Error uploading chat image: $e');
      return null;
    }
  }

  // Get optimized thumbnail URL
  String getThumbnailUrl(String originalUrl, {int width = 150, int height = 150}) {
    if (originalUrl.contains('cloudinary.com')) {
      return originalUrl.replaceFirst(
        '/upload/',
        '/upload/w_$width,h_$height,c_fill,f_auto,q_auto/',
      );
    }
    return originalUrl;
  }

  // Get medium quality image URL
  String getMediumQualityUrl(String originalUrl) {
    if (originalUrl.contains('cloudinary.com')) {
      return originalUrl.replaceFirst(
        '/upload/',
        '/upload/w_500,q_auto,f_auto/',
      );
    }
    return originalUrl;
  }

  // Get high quality image URL
  String getHighQualityUrl(String originalUrl) {
    if (originalUrl.contains('cloudinary.com')) {
      return originalUrl.replaceFirst(
        '/upload/',
        '/upload/w_1024,q_auto,f_auto/',
      );
    }
    return originalUrl;
  }
}