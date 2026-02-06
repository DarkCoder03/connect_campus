import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ChatNotificationsScreen extends StatefulWidget {
  const ChatNotificationsScreen({super.key});

  @override
  State<ChatNotificationsScreen> createState() => _ChatNotificationsScreenState();
}

class _ChatNotificationsScreenState extends State<ChatNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Timeline/Activity updates
  final List<Map<String, dynamic>> _activities = [
    {
      'id': '1',
      'type': 'match',
      'name': 'Priya Sharma',
      'message': 'You matched with Priya!',
      'time': '2 min ago',
      'avatar': 'P',
      'isRead': false,
    },
    {
      'id': '2',
      'type': 'like',
      'name': 'Rahul Verma',
      'message': 'liked your profile',
      'time': '15 min ago',
      'avatar': 'R',
      'isRead': false,
    },
    {
      'id': '3',
      'type': 'superlike',
      'name': 'Ananya Patel',
      'message': 'super liked you! ⭐',
      'time': '1 hour ago',
      'avatar': 'A',
      'isRead': false,
    },
    {
      'id': '4',
      'type': 'view',
      'name': 'Arjun Nair',
      'message': 'viewed your profile',
      'time': '3 hours ago',
      'avatar': 'A',
      'isRead': true,
    },
    {
      'id': '5',
      'type': 'match',
      'name': 'Sneha Gupta',
      'message': 'You matched with Sneha!',
      'time': '1 day ago',
      'avatar': 'S',
      'isRead': true,
    },
  ];

  // Stranger/Message requests
  final List<Map<String, dynamic>> _requests = [
    {
      'id': '1',
      'name': 'Meera Joshi',
      'message': 'Hey! I noticed we have similar interests. Would love to connect!',
      'time': '5 min ago',
      'avatar': 'M',
      'college': 'Delhi University',
      'mutualFriends': 3,
      'isOnline': true,
    },
    {
      'id': '2',
      'name': 'Karan Mehta',
      'message': 'Hi! Would love to connect with you 😊',
      'time': '30 min ago',
      'avatar': 'K',
      'college': 'IIT Bombay',
      'mutualFriends': 1,
      'isOnline': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.darkText),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppTheme.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.darkText),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all),
                    SizedBox(width: 10),
                    Text('Mark all as read'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline),
                    SizedBox(width: 10),
                    Text('Clear all'),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'mark_read':
                  setState(() {
                    for (var activity in _activities) {
                      activity['isRead'] = true;
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All marked as read')),
                  );
                  break;
                case 'clear':
                  _showClearAllDialog();
                  break;
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: AppTheme.greyText,
          indicatorColor: AppTheme.primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_active, size: 18),
                  const SizedBox(width: 6),
                  const Text('Activity'),
                  if (_activities.where((a) => !a['isRead']).isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_activities.where((a) => !a['isRead']).length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, size: 18),
                  const SizedBox(width: 6),
                  const Text('Requests'),
                  if (_requests.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_requests.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildActivityTab(),
          _buildRequestsTab(),
        ],
      ),
    );
  }

  // ============ ACTIVITY TAB ============
  Widget _buildActivityTab() {
    if (_activities.isEmpty) {
      return _buildEmptyState(
        icon: Icons.notifications_off_outlined,
        title: 'No Activity Yet',
        subtitle: 'When someone likes you or you match, it will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return _buildActivityTile(activity, index);
      },
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity, int index) {
    IconData icon;
    Color color;

    switch (activity['type']) {
      case 'match':
        icon = Icons.favorite;
        color = Colors.pink;
        break;
      case 'like':
        icon = Icons.thumb_up;
        color = Colors.red;
        break;
      case 'superlike':
        icon = Icons.star;
        color = Colors.blue;
        break;
      case 'view':
        icon = Icons.visibility;
        color = Colors.purple;
        break;
      default:
        icon = Icons.notifications;
        color = AppTheme.primaryColor;
    }

    return Dismissible(
      key: Key(activity['id']),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        setState(() {
          _activities.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notification removed')),
        );
      },
      child: Container(
        color: activity['isRead']
            ? Colors.transparent
            : AppTheme.primaryColor.withValues(alpha: 0.05),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Text(
                  activity['avatar'],
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(icon, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          title: RichText(
            text: TextSpan(
              style: const TextStyle(color: AppTheme.darkText, fontSize: 15),
              children: [
                TextSpan(
                  text: activity['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' ${activity['message']}'),
              ],
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              activity['time'],
              style: const TextStyle(color: AppTheme.greyText, fontSize: 12),
            ),
          ),
          trailing: !activity['isRead']
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            setState(() {
              activity['isRead'] = true;
            });
            _showProfilePreview(activity);
          },
        ),
      ),
    );
  }

  // ============ REQUESTS TAB ============
  Widget _buildRequestsTab() {
    if (_requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.person_add_disabled,
        title: 'No Message Requests',
        subtitle: 'When someone outside your matches messages you, it will appear here.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _requests.length,
      itemBuilder: (context, index) {
        final request = _requests[index];
        return _buildRequestTile(request, index);
      },
    );
  }

  Widget _buildRequestTile(Map<String, dynamic> request, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // User info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        request['avatar'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    if (request['isOnline'])
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            request['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            request['time'],
                            style: const TextStyle(
                              color: AppTheme.greyText,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.school, size: 14, color: AppTheme.greyText),
                          const SizedBox(width: 4),
                          Text(
                            request['college'],
                            style: const TextStyle(
                              color: AppTheme.greyText,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Message preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.lightGrey,
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '"${request['message']}"',
              style: const TextStyle(fontStyle: FontStyle.italic),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _declineRequest(request, index),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Decline'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _acceptRequest(request, index),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============ HELPER METHODS ============

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              style: const TextStyle(color: AppTheme.greyText, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _acceptRequest(Map<String, dynamic> request, int index) {
    setState(() {
      _requests.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You accepted ${request['name']}\'s request'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _declineRequest(Map<String, dynamic> request, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Decline Request?'),
        content: Text(
            'Are you sure you want to decline ${request['name']}\'s message request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _requests.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${request['name']}\'s request declined')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }

  void _showProfilePreview(Map<String, dynamic> activity) {
    Color color;
    String actionText;

    switch (activity['type']) {
      case 'match':
        color = Colors.pink;
        actionText = '💕 You matched!';
        break;
      case 'like':
        color = Colors.red;
        actionText = '❤️ Liked you';
        break;
      case 'superlike':
        color = Colors.blue;
        actionText = '⭐ Super liked you';
        break;
      case 'view':
        color = Colors.purple;
        actionText = '👀 Viewed your profile';
        break;
      default:
        color = AppTheme.primaryColor;
        actionText = 'Activity';
    }

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
            CircleAvatar(
              radius: 50,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Text(
                activity['avatar'],
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              activity['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                actionText,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    label: const Text('Skip'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('You liked ${activity['name']} back! ❤️'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.favorite),
                    label: const Text('Like Back'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear All Notifications?'),
        content: const Text(
            'This will remove all activity notifications. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _activities.clear();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications cleared')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}