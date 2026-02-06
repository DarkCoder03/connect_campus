import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';
import 'filter_screen.dart';
import 'user_profile_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen>
    with TickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();

  List<UserModel> _profiles = [];
  int _currentIndex = 0;
  bool _isLoading = true;

  // Filter settings
  Map<String, dynamic> _filters = {
    'minAge': 18,
    'maxAge': 30,
    'maxDistance': 50,
    'colleges': <String>[],
    'interests': <String>[],
    'yearFilter': 'All',
    'showVerifiedOnly': false,
  };

  // Animation controllers
  late AnimationController _swipeController;
  late AnimationController _buttonPulseController;
  late Animation<double> _pulseAnimation;

  Offset _cardOffset = Offset.zero;
  double _cardAngle = 0;
  SwipeDirection? _swipeDirection;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _buttonPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _buttonPulseController, curve: Curves.easeInOut),
    );

    _loadProfiles();
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  Future<void> _loadProfiles() async {
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = userProvider.currentUser;

    if (currentUser != null) {
      List<String> excludeIds = [
        ...currentUser.likedUsers,
        ...currentUser.dislikedUsers,
        currentUser.uid,
      ];

      List<UserModel> users = await _databaseService.getDiscoverUsers(
        currentUserId: currentUser.uid,
        excludeIds: excludeIds,
        limit: 20,
      );

      setState(() {
        _profiles = users;
        _currentIndex = 0;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _onPanStart(DragStartDetails details) {
    _swipeController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _cardOffset += details.delta;
      _cardAngle = _cardOffset.dx / 300 * 0.4;

      if (_cardOffset.dx > 50) {
        _swipeDirection = SwipeDirection.right;
      } else if (_cardOffset.dx < -50) {
        _swipeDirection = SwipeDirection.left;
      } else if (_cardOffset.dy < -50) {
        _swipeDirection = SwipeDirection.up;
      } else {
        _swipeDirection = null;
      }
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    final speed = velocity.distance;

    if (speed > 500 || _cardOffset.dx.abs() > 100 || _cardOffset.dy < -100) {
      if (_swipeDirection == SwipeDirection.right) {
        _animateSwipe(SwipeDirection.right);
      } else if (_swipeDirection == SwipeDirection.left) {
        _animateSwipe(SwipeDirection.left);
      } else if (_swipeDirection == SwipeDirection.up) {
        _animateSwipe(SwipeDirection.up);
      } else {
        _resetCard();
      }
    } else {
      _resetCard();
    }
  }

  void _animateSwipe(SwipeDirection direction) {
    HapticFeedback.mediumImpact();

    late Offset endOffset;

    switch (direction) {
      case SwipeDirection.left:
        endOffset =
            Offset(-MediaQuery.of(context).size.width * 1.5, _cardOffset.dy);
        break;
      case SwipeDirection.right:
        endOffset =
            Offset(MediaQuery.of(context).size.width * 1.5, _cardOffset.dy);
        break;
      case SwipeDirection.up:
        endOffset =
            Offset(_cardOffset.dx, -MediaQuery.of(context).size.height);
        break;
    }

    final animation = Tween<Offset>(
      begin: _cardOffset,
      end: endOffset,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeOut,
    ));

    animation.addListener(() {
      setState(() {
        _cardOffset = animation.value;
      });
    });

    _swipeController.forward(from: 0).then((_) {
      _handleSwipeComplete(direction);
    });
  }

  Future<void> _handleSwipeComplete(SwipeDirection direction) async {
    if (_currentIndex >= _profiles.length) return;

    final profile = _profiles[_currentIndex];
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUserId = userProvider.currentUser?.uid;

    if (currentUserId == null) return;

    bool isMatch = false;

    switch (direction) {
      case SwipeDirection.left:
        HapticFeedback.lightImpact();
        await _databaseService.dislikeUser(currentUserId, profile.uid);
        _showSwipeFeedback('Passed', AppTheme.greyText, Icons.close);
        break;
      case SwipeDirection.right:
        HapticFeedback.mediumImpact();
        isMatch = await _databaseService.likeUser(currentUserId, profile.uid);
        _showSwipeFeedback(
            'Liked ${profile.name}! ❤️', AppTheme.success, Icons.favorite);
        break;
      case SwipeDirection.up:
        HapticFeedback.heavyImpact();
        isMatch =
            await _databaseService.superLikeUser(currentUserId, profile.uid);
        _showSwipeFeedback(
            'Super Liked ${profile.name}! ⭐', AppTheme.info, Icons.star);
        break;
    }

    // Reload user to update counts
    await userProvider.loadUser(currentUserId);

    if (isMatch) {
      // Special haptic pattern for match
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.heavyImpact();

      Future.delayed(const Duration(milliseconds: 500), () {
        _showMatchDialog(profile);
      });
    }

    setState(() {
      _currentIndex++;
      _cardOffset = Offset.zero;
      _cardAngle = 0;
      _swipeDirection = null;
    });
  }

  void _resetCard() {
    final animation = Tween<Offset>(
      begin: _cardOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.elasticOut,
    ));

    final angleAnimation = Tween<double>(
      begin: _cardAngle,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.elasticOut,
    ));

    animation.addListener(() {
      setState(() {
        _cardOffset = animation.value;
        _cardAngle = angleAnimation.value;
      });
    });

    _swipeController.forward(from: 0).then((_) {
      setState(() => _swipeDirection = null);
    });
  }

  void _showSwipeFeedback(String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showMatchDialog(UserModel profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _MatchDialog(profile: profile),
    );
  }

  void _openUserProfile(UserModel user) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(user: user),
      ),
    );
  }

  void _openFilters() async {
    HapticFeedback.lightImpact();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(currentFilters: _filters),
      ),
    );

    if (result != null) {
      setState(() {
        _filters = result;
      });
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // App bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Discover',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkText,
                      ),
                    ),
                    Text(
                      '${_profiles.length - _currentIndex} people nearby',
                      style: const TextStyle(
                        color: AppTheme.greyText,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        _loadProfiles();
                      },
                      icon: const Icon(Icons.refresh, color: AppTheme.darkText),
                    ),
                    Stack(
                      children: [
                        IconButton(
                          onPressed: _openFilters,
                          icon: const Icon(Icons.tune, color: AppTheme.darkText),
                        ),
                        if (_hasActiveFilters())
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: AppTheme.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Card stack
          Expanded(
            child: _isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppTheme.primaryColor),
                  )
                : _currentIndex >= _profiles.length
                    ? _buildEmptyState()
                    : Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background cards
                          if (_currentIndex + 2 < _profiles.length)
                            Positioned(
                              top: 30,
                              child: Transform.scale(
                                scale: 0.9,
                                child: Opacity(
                                  opacity: 0.5,
                                  child: _buildCard(_profiles[_currentIndex + 2],
                                      isBackground: true),
                                ),
                              ),
                            ),
                          if (_currentIndex + 1 < _profiles.length)
                            Positioned(
                              top: 15,
                              child: Transform.scale(
                                scale: 0.95,
                                child: Opacity(
                                  opacity: 0.8,
                                  child: _buildCard(_profiles[_currentIndex + 1],
                                      isBackground: true),
                                ),
                              ),
                            ),

                          // Current card
                          GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            onTap: () =>
                                _openUserProfile(_profiles[_currentIndex]),
                            child: Transform.translate(
                              offset: _cardOffset,
                              child: Transform.rotate(
                                angle: _cardAngle,
                                child: _buildCard(
                                  _profiles[_currentIndex],
                                  showOverlay: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          ),

          // Action buttons
          if (!_isLoading && _currentIndex < _profiles.length)
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton(
                    icon: Icons.close,
                    color: AppTheme.greyText,
                    size: 60,
                    onTap: () => _animateSwipe(SwipeDirection.left),
                  ),
                  const SizedBox(width: 20),
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: _buildActionButton(
                          icon: Icons.star,
                          color: AppTheme.info,
                          size: 50,
                          onTap: () => _animateSwipe(SwipeDirection.up),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  _buildActionButton(
                    icon: Icons.favorite,
                    color: AppTheme.primaryColor,
                    size: 60,
                    onTap: () => _animateSwipe(SwipeDirection.right),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  bool _hasActiveFilters() {
    return _filters['minAge'] != 18 ||
        _filters['maxAge'] != 30 ||
        _filters['maxDistance'] != 50 ||
        (_filters['colleges'] as List).isNotEmpty ||
        (_filters['interests'] as List).isNotEmpty ||
        _filters['yearFilter'] != 'All' ||
        _filters['showVerifiedOnly'] == true;
  }

  Widget _buildCard(UserModel user,
      {bool isBackground = false, bool showOverlay = false}) {
    final List<Color> cardColors = [
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.accentColor,
      const Color(0xFF00BFA6),
      const Color(0xFF845EC2),
      const Color(0xFFFF9671),
    ];

    int colorIndex = user.uid.hashCode % cardColors.length;

    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: cardColors[colorIndex.abs()].withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image or gradient
            user.profilePicUrl != null
                ? CachedNetworkImage(
                    imageUrl: user.profilePicUrl!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: cardColors[colorIndex.abs()],
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cardColors[colorIndex.abs()],
                            cardColors[colorIndex.abs()].withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(
                            fontSize: 80,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cardColors[colorIndex.abs()],
                          cardColors[colorIndex.abs()].withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 80,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

            // Gradient overlay for text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),

            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (user.isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.verified,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      if (user.isOnline)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.circle, color: Colors.white, size: 8),
                              SizedBox(width: 4),
                              Text(
                                'Online',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const Spacer(),

                  // User info
                  Row(
                    children: [
                      Text(
                        '${user.name}, ${user.age}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (user.isVerified) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.verified,
                            color: Colors.blue, size: 24),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),

                  // College & Major
                  Row(
                    children: [
                      const Icon(Icons.school, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${user.college} • ${user.major}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Year
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        user.year,
                        style:
                            const TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Bio
                  if (user.bio.isNotEmpty)
                    Text(
                      user.bio,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, height: 1.4),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 12),

                  // Interests
                  if (user.interests.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: user.interests.take(4).map((interest) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            interest,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        );
                      }).toList(),
                    ),

                  // Tap to view profile hint
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Tap to view profile',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Swipe overlays
            if (showOverlay && _swipeDirection != null)
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: _getOverlayColor().withValues(alpha: 0.3),
                ),
                child: Center(
                  child: Transform.rotate(
                    angle: _swipeDirection == SwipeDirection.left
                        ? -0.3
                        : _swipeDirection == SwipeDirection.right
                            ? 0.3
                            : 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: _getOverlayColor(), width: 4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _getOverlayText(),
                        style: TextStyle(
                          color: _getOverlayColor(),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getOverlayColor() {
    switch (_swipeDirection) {
      case SwipeDirection.left:
        return AppTheme.greyText;
      case SwipeDirection.right:
        return AppTheme.success;
      case SwipeDirection.up:
        return AppTheme.info;
      default:
        return Colors.transparent;
    }
  }

  String _getOverlayText() {
    switch (_swipeDirection) {
      case SwipeDirection.left:
        return 'NOPE';
      case SwipeDirection.right:
        return 'LIKE';
      case SwipeDirection.up:
        return 'SUPER';
      default:
        return '';
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }

  Widget _buildEmptyState() {
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
                Icons.search_off,
                size: 60,
                color: AppTheme.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No More Profiles',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'You\'ve seen everyone nearby!\nCheck back later for new people.',
              style: TextStyle(
                color: AppTheme.greyText,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _loadProfiles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum SwipeDirection { left, right, up }

// Match Dialog
class _MatchDialog extends StatefulWidget {
  final UserModel profile;

  const _MatchDialog({required this.profile});

  @override
  State<_MatchDialog> createState() => _MatchDialogState();
}

class _MatchDialogState extends State<_MatchDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _heartController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.5)),
    );

    _heartAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartController, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _heartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _heartAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _heartAnimation.value,
                          child: const Text(
                            '💕',
                            style: TextStyle(fontSize: 60),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "It's a Match!",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'You and ${widget.profile.name} liked each other!',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),

                    // Avatars
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, provider, child) {
                            return CircleAvatar(
                              radius: 45,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.3),
                              backgroundImage:
                                  provider.currentUser?.profilePicUrl != null
                                      ? CachedNetworkImageProvider(
                                          provider.currentUser!.profilePicUrl!)
                                      : null,
                              child: provider.currentUser?.profilePicUrl == null
                                  ? Text(
                                      provider.currentUser?.name.isNotEmpty ==
                                              true
                                          ? provider.currentUser!.name[0]
                                          : 'U',
                                      style: const TextStyle(
                                          fontSize: 30, color: Colors.white),
                                    )
                                  : null,
                            );
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          child: const Icon(Icons.favorite,
                              color: Colors.white, size: 40),
                        ),
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white.withValues(alpha: 0.3),
                          backgroundImage:
                              widget.profile.profilePicUrl != null
                                  ? CachedNetworkImageProvider(
                                      widget.profile.profilePicUrl!)
                                  : null,
                          child: widget.profile.profilePicUrl == null
                              ? Text(
                                  widget.profile.name[0],
                                  style: const TextStyle(
                                      fontSize: 30, color: Colors.white),
                                )
                              : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Buttons
                    ElevatedButton(
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                        // Navigate to chat
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: const Text('Send Message',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: const Text('Keep Swiping',
                          style: TextStyle(color: Colors.white70)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}