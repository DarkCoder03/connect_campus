import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';
import '../providers/user_provider.dart';
import '../services/cloudinary_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _collegeController = TextEditingController();
  final _majorController = TextEditingController();
  
  final CloudinaryService _cloudinaryService = CloudinaryService();
  
  String _selectedGender = 'Male';
  String _selectedYear = '3rd Year';
  int _selectedAge = 20;
  List<String> _selectedInterests = [];
  bool _isLoading = false;
  bool _isUploading = false;

  final List<String> _years = ['1st Year', '2nd Year', '3rd Year', '4th Year', 'Post Graduate'];
  
  final List<String> _allInterests = [
    'Music', 'Gaming', 'Travel', 'Photography', 'Tech',
    'Fitness', 'Reading', 'Movies', 'Food', 'Art',
    'Sports', 'Dancing', 'Cooking', 'Writing', 'Yoga',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<UserProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio;
      _collegeController.text = user.college;
      _majorController.text = user.major;
      _selectedGender = user.gender;
      _selectedYear = user.year;
      _selectedAge = user.age;
      _selectedInterests = List.from(user.interests);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _collegeController.dispose();
    _majorController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _uploadPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _uploadPhoto(fromCamera: false);
              },
            ),
            if (userProvider.currentUser?.profilePicUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  await userProvider.updateProfile({'profilePicUrl': null});
                  setState(() {});
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadPhoto({required bool fromCamera}) async {
    setState(() => _isUploading = true);

    try {
      File? imageFile;
      if (fromCamera) {
        imageFile = await _cloudinaryService.pickImageFromCamera();
      } else {
        imageFile = await _cloudinaryService.pickImageFromGallery();
      }

      if (imageFile != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final userId = userProvider.currentUser?.uid ?? 'unknown';

        String? imageUrl = await _cloudinaryService.uploadProfilePhoto(
          userId,
          imageFile,
        );

        if (imageUrl != null) {
          await userProvider.updateProfilePhoto(imageUrl);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile photo updated! ✓'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading photo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() => _isUploading = false);
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    bool success = await userProvider.updateProfile({
      'name': _nameController.text.trim(),
      'bio': _bioController.text.trim(),
      'college': _collegeController.text.trim(),
      'major': _majorController.text.trim(),
      'gender': _selectedGender,
      'year': _selectedYear,
      'age': _selectedAge,
      'interests': _selectedInterests,
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully! ✓'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(userProvider.error ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.currentUser;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                        backgroundImage: user?.profilePicUrl != null
                            ? CachedNetworkImageProvider(user!.profilePicUrl!)
                            : null,
                        child: _isUploading
                            ? const CircularProgressIndicator(color: AppTheme.primaryColor)
                            : user?.profilePicUrl == null
                                ? Text(
                                    user?.name.isNotEmpty == true
                                        ? user!.name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _isUploading ? null : _pickAndUploadImage,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton(
                    onPressed: _isUploading ? null : _pickAndUploadImage,
                    child: Text(
                      _isUploading ? 'Uploading...' : 'Change Photo',
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                _buildLabel('Full Name'),
                _buildTextField(_nameController, 'Enter your name', Icons.person_outline),
                const SizedBox(height: 15),

                // Bio
                _buildLabel('Bio'),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  maxLength: 150,
                  decoration: InputDecoration(
                    hintText: 'Write something about yourself...',
                    filled: true,
                    fillColor: AppTheme.lightGrey,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Age
                _buildLabel('Age'),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _selectedAge.toDouble(),
                        min: 18,
                        max: 35,
                        divisions: 17,
                        activeColor: AppTheme.primaryColor,
                        label: '$_selectedAge years',
                        onChanged: (value) {
                          setState(() => _selectedAge = value.round());
                        },
                      ),
                    ),
                    Text(
                      '$_selectedAge',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Gender
                _buildLabel('Gender'),
                Row(
                  children: ['Male', 'Female', 'Other'].map((gender) {
                    final isSelected = _selectedGender == gender;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedGender = gender),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryColor : AppTheme.lightGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              gender,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.darkText,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // College
                _buildLabel('College'),
                _buildTextField(_collegeController, 'Enter your college', Icons.school_outlined),
                const SizedBox(height: 15),

                // Major
                _buildLabel('Major'),
                _buildTextField(_majorController, 'Enter your major', Icons.book_outlined),
                const SizedBox(height: 15),

                // Year
                _buildLabel('Year'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedYear,
                      isExpanded: true,
                      items: _years.map((year) {
                        return DropdownMenuItem(value: year, child: Text(year));
                      }).toList(),
                      onChanged: (value) => setState(() => _selectedYear = value!),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Interests
                _buildLabel('Interests'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _allInterests.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest);
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          interest,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.darkText,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 30),

                // Save Button
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryColor),
                      )
                    : CustomButton(
                        text: 'Save Changes',
                        onPressed: _saveProfile,
                      ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.darkText,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.greyText),
        filled: true,
        fillColor: AppTheme.lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}