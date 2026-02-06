import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  // Privacy settings
  bool _showOnlineStatus = true;
  bool _showLastSeen = true;
  bool _showDistance = true;
  bool _showAge = true;
  bool _readReceipts = true;
  bool _activityStatus = true;
  String _profileVisibility = 'Everyone';
  String _whoCanMessage = 'Matches Only';

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
          'Privacy',
          style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Visibility
            _buildSectionTitle('Profile Visibility'),
            const SizedBox(height: 10),
            _buildDropdownTile(
              'Who can see my profile',
              _profileVisibility,
              ['Everyone', 'Only my college', 'Matches Only'],
              (value) => setState(() => _profileVisibility = value!),
            ),
            _buildDropdownTile(
              'Who can message me',
              _whoCanMessage,
              ['Everyone', 'Matches Only', 'No one'],
              (value) => setState(() => _whoCanMessage = value!),
            ),
            const SizedBox(height: 25),

            // Show/Hide Information
            _buildSectionTitle('Show Information'),
            const SizedBox(height: 10),
            _buildToggleTile(
              'Show Online Status',
              'Let others see when you\'re online',
              _showOnlineStatus,
              (v) => setState(() => _showOnlineStatus = v),
            ),
            _buildToggleTile(
              'Show Last Seen',
              'Let others see your last active time',
              _showLastSeen,
              (v) => setState(() => _showLastSeen = v),
            ),
            _buildToggleTile(
              'Show Distance',
              'Display how far away you are',
              _showDistance,
              (v) => setState(() => _showDistance = v),
            ),
            _buildToggleTile(
              'Show Age',
              'Display your age on profile',
              _showAge,
              (v) => setState(() => _showAge = v),
            ),
            const SizedBox(height: 25),

            // Activity
            _buildSectionTitle('Activity'),
            const SizedBox(height: 10),
            _buildToggleTile(
              'Read Receipts',
              'Let others know when you\'ve read their messages',
              _readReceipts,
              (v) => setState(() => _readReceipts = v),
            ),
            _buildToggleTile(
              'Activity Status',
              'Show what you\'re doing in the app',
              _activityStatus,
              (v) => setState(() => _activityStatus = v),
            ),
            const SizedBox(height: 25),

            // Account Actions
            _buildSectionTitle('Account'),
            const SizedBox(height: 10),
            _buildActionTile(
              'Blocked Users',
              'Manage your blocked list',
              Icons.block,
              () => _showBlockedUsers(),
            ),
            _buildActionTile(
              'Hidden Profiles',
              'Profiles you\'ve hidden',
              Icons.visibility_off,
              () => _showHiddenProfiles(),
            ),
            _buildActionTile(
              'Download My Data',
              'Get a copy of your data',
              Icons.download,
              () => _downloadData(),
            ),
            const SizedBox(height: 10),
            _buildActionTile(
              'Deactivate Account',
              'Temporarily hide your account',
              Icons.pause_circle_outline,
              () => _showDeactivateDialog(),
              color: Colors.orange,
            ),
            _buildActionTile(
              'Delete Account',
              'Permanently delete your account',
              Icons.delete_forever,
              () => _showDeleteDialog(),
              color: Colors.red,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.darkText,
      ),
    );
  }

  Widget _buildToggleTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: AppTheme.primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(color: AppTheme.primaryColor),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap, {
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: color ?? AppTheme.darkText),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color ?? AppTheme.darkText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.greyText),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: color ?? AppTheme.greyText,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showBlockedUsers() {
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
            const Icon(Icons.block, size: 50, color: AppTheme.greyText),
            const SizedBox(height: 16),
            const Text(
              'No Blocked Users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Users you block will appear here',
              style: TextStyle(color: AppTheme.greyText),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showHiddenProfiles() {
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
            const Icon(Icons.visibility_off, size: 50, color: AppTheme.greyText),
            const SizedBox(height: 16),
            const Text(
              'No Hidden Profiles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Profiles you hide will appear here',
              style: TextStyle(color: AppTheme.greyText),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _downloadData() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your data will be sent to your email within 24 hours'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _showDeactivateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Deactivate Account?'),
        content: const Text(
          'Your profile will be hidden from others. You can reactivate anytime by logging in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deactivated'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 10),
            Text('Delete Account?'),
          ],
        ),
        content: const Text(
          'This action is permanent and cannot be undone. All your data, matches, and messages will be deleted forever.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account scheduled for deletion'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}