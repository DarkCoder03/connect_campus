import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Notification toggles
  bool _pushNotifications = true;
  bool _newMatches = true;
  bool _messages = true;
  bool _messageLikes = true;
  bool _superLikes = true;
  bool _emailNotifications = false;
  bool _promotions = false;
  bool _newFeatures = true;
  bool _vibrate = true;
  bool _sound = true;

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
          'Notifications',
          style: TextStyle(color: AppTheme.darkText, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Master Toggle
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active, color: Colors.white, size: 30),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Push Notifications',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Master toggle for all notifications',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _pushNotifications,
                    activeColor: Colors.white,
                    activeTrackColor: Colors.white.withValues(alpha: 0.5),
                    onChanged: (value) {
                      setState(() {
                        _pushNotifications = value;
                        if (!value) {
                          _newMatches = false;
                          _messages = false;
                          _messageLikes = false;
                          _superLikes = false;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Activity Notifications
            _buildSectionTitle('Activity Notifications'),
            const SizedBox(height: 10),
            _buildToggleTile(
              'New Matches',
              'When someone likes you back',
              Icons.favorite,
              _newMatches,
              _pushNotifications ? (v) => setState(() => _newMatches = v) : null,
            ),
            _buildToggleTile(
              'Messages',
              'When you receive a new message',
              Icons.chat_bubble,
              _messages,
              _pushNotifications ? (v) => setState(() => _messages = v) : null,
            ),
            _buildToggleTile(
              'Message Likes',
              'When someone likes your message',
              Icons.thumb_up,
              _messageLikes,
              _pushNotifications ? (v) => setState(() => _messageLikes = v) : null,
            ),
            _buildToggleTile(
              'Super Likes',
              'When someone super likes you',
              Icons.star,
              _superLikes,
              _pushNotifications ? (v) => setState(() => _superLikes = v) : null,
            ),
            const SizedBox(height: 25),

            // Email Notifications
            _buildSectionTitle('Email Notifications'),
            const SizedBox(height: 10),
            _buildToggleTile(
              'Email Updates',
              'Receive activity updates via email',
              Icons.email,
              _emailNotifications,
              (v) => setState(() => _emailNotifications = v),
            ),
            _buildToggleTile(
              'Promotions',
              'Special offers and discounts',
              Icons.local_offer,
              _promotions,
              (v) => setState(() => _promotions = v),
            ),
            _buildToggleTile(
              'New Features',
              'Be the first to know about updates',
              Icons.new_releases,
              _newFeatures,
              (v) => setState(() => _newFeatures = v),
            ),
            const SizedBox(height: 25),

            // Sound & Vibration
            _buildSectionTitle('Sound & Vibration'),
            const SizedBox(height: 10),
            _buildToggleTile(
              'Sound',
              'Play sound for notifications',
              Icons.volume_up,
              _sound,
              (v) => setState(() => _sound = v),
            ),
            _buildToggleTile(
              'Vibration',
              'Vibrate for notifications',
              Icons.vibration,
              _vibrate,
              (v) => setState(() => _vibrate = v),
            ),
            const SizedBox(height: 30),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can also manage notifications from your device settings.',
                      style: TextStyle(fontSize: 13, color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
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
    IconData icon,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    final isDisabled = onChanged == null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDisabled ? AppTheme.lightGrey.withValues(alpha: 0.5) : AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDisabled ? AppTheme.greyText : AppTheme.primaryColor,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isDisabled ? AppTheme.greyText : AppTheme.darkText,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDisabled ? AppTheme.greyText.withValues(alpha: 0.7) : AppTheme.greyText,
                  ),
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
}