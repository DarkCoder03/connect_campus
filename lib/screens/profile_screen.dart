import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/cloudinary_service.dart';
import 'edit_profile_screen.dart';
import 'photo_gallery_screen.dart';
import 'location_screen.dart';
import 'notification_screen.dart';
import 'privacy_screen.dart';
import 'help_support_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isUploadingBanner = false;

  Future<void> _uploadBanner({required bool fromCamera}) async {
    setState(() => _isUploadingBanner = true);

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
          '${userId}_banner',
          imageFile,
        );

        if (imageUrl != null) {
          await userProvider.updateProfile({'bannerUrl': imageUrl});
          HapticFeedback.heavyImpact();

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Banner updated! ✓'),
                  ],
                ),
                backgroundColor: AppTheme.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }

    setState(() => _isUploadingBanner = false);
  }

  void _showBannerOptions() {
    HapticFeedback.mediumImpact();
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
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.greyText.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Change Banner Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                _uploadBanner(fromCamera: true);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library, color: AppTheme.primaryColor),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
                _uploadBanner(fromCamera: false);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.currentUser;

        if (userProvider.isLoading && user == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        // Get banner URL from user data
        String? bannerUrl;
        try {
          final userData = user?.toMap();
          bannerUrl = userData?['bannerUrl'];
        } catch (e) {
          bannerUrl = null;
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // Banner with profile picture
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                backgroundColor: AppTheme.primaryColor,
                actions: [
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings, color: Colors.white, size: 20),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Banner image
                      GestureDetector(
                        onTap: _showBannerOptions,
                        child: _isUploadingBanner
                            ? Container(
                                decoration: const BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(color: Colors.white),
                                      SizedBox(height: 10),
                                      Text(
                                        'Uploading...',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : bannerUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: bannerUrl,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => _buildDefaultBanner(),
                                    errorWidget: (context, url, error) => _buildDefaultBanner(),
                                  )
                                : _buildDefaultBanner(),
                      ),

                      // Edit banner hint
                      Positioned(
                        top: 100,
                        right: 16,
                        child: GestureDetector(
                          onTap: _showBannerOptions,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, color: Colors.white, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Edit Banner',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                            stops: const [0.3, 1.0],
                          ),
                        ),
                      ),

                      // Profile picture and name
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            // Profile picture with border
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 55,
                                    backgroundColor: AppTheme.primaryColor,
                                    backgroundImage: user?.profilePicUrl != null
                                        ? CachedNetworkImageProvider(user!.profilePicUrl!)
                                        : null,
                                    child: user?.profilePicUrl == null
                                        ? Text(
                                            user?.name.isNotEmpty == true
                                                ? user!.name[0].toUpperCase()
                                                : 'U',
                                            style: const TextStyle(
                                              fontSize: 45,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          )
                                        : null,
                                  ),
                                  // Verified badge
                                  if (user?.isVerified == true)
                                    Positioned(
                                      bottom: 5,
                                      right: 5,
                                      child: Container(
                                        padding: const EdgeInsets.all(3),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.verified,
                                          color: Colors.blue,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Name
                            Text(
                              user?.name ?? 'User',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // College and year
                            Text(
                              '${user?.college ?? "Your College"} • ${user?.year ?? ""}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Stats cards
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              'Matches',
                              '${user?.matches.length ?? 0}',
                              Icons.favorite,
                              AppTheme.primaryColor,
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: AppTheme.lightGrey,
                            ),
                            _buildStatItem(
                              'Likes',
                              '${user?.likedUsers.length ?? 0}',
                              Icons.thumb_up,
                              AppTheme.secondaryColor,
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: AppTheme.lightGrey,
                            ),
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PhotoGalleryScreen(),
                                  ),
                                );
                              },
                              child: _buildStatItem(
                                'Photos',
                                '${user?.photoUrls.length ?? 0}',
                                Icons.photo_library,
                                AppTheme.accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Quick actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickAction(
                              'Edit Profile',
                              Icons.edit,
                              AppTheme.primaryColor,
                              () {
                                HapticFeedback.mediumImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const EditProfileScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildQuickAction(
                              'My Photos',
                              Icons.photo_library,
                              AppTheme.secondaryColor,
                              () {
                                HapticFeedback.mediumImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PhotoGalleryScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Settings list
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSettingsTile(
                              Icons.location_on_outlined,
                              'Location',
                              'Set your location',
                              () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LocationScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              Icons.notifications_outlined,
                              'Notifications',
                              'Manage notifications',
                              () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const NotificationScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              Icons.security,
                              'Privacy',
                              'Privacy settings',
                              () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PrivacyScreen(),
                                  ),
                                );
                              },
                            ),
                            _buildDivider(),
                            _buildSettingsTile(
                              Icons.help_outline,
                              'Help & Support',
                              'Get help',
                              () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HelpSupportScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Logout button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _buildSettingsTile(
                          Icons.logout,
                          'Log Out',
                          'Sign out of your account',
                          () => _showLogoutDialog(context, userProvider),
                          color: AppTheme.error,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // App version
                      Text(
                        'ConnectCampus v1.0.0',
                        style: TextStyle(
                          color: AppTheme.greyText.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.darkText,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.greyText,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAction(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: color ?? AppTheme.darkText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: color?.withValues(alpha: 0.7) ?? AppTheme.greyText,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: color ?? AppTheme.greyText,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 70,
      endIndent: 20,
      color: AppTheme.lightGrey,
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider userProvider) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: AppTheme.error),
            SizedBox(width: 10),
            Text('Log Out'),
          ],
        ),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryColor),
                ),
              );

              await userProvider.signOut();

              if (context.mounted) {
                Navigator.pop(context); // Close loading
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}