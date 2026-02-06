import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isWhite;

  const AppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
    this.isWhite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: isWhite
                ? null
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.secondaryColor,
                    ],
                  ),
            color: isWhite ? Colors.white : null,
            borderRadius: BorderRadius.circular(size * 0.25),
            boxShadow: [
              BoxShadow(
                color: (isWhite ? Colors.black : AppTheme.primaryColor)
                    .withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Heart shape
              Icon(
                Icons.favorite,
                size: size * 0.5,
                color: isWhite ? AppTheme.primaryColor : Colors.white,
              ),
              // Connection dots
              Positioned(
                top: size * 0.2,
                right: size * 0.2,
                child: Container(
                  width: size * 0.15,
                  height: size * 0.15,
                  decoration: BoxDecoration(
                    color: isWhite
                        ? AppTheme.secondaryColor
                        : AppTheme.tertiaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                bottom: size * 0.2,
                left: size * 0.2,
                child: Container(
                  width: size * 0.12,
                  height: size * 0.12,
                  decoration: BoxDecoration(
                    color: isWhite
                        ? AppTheme.secondaryColor
                        : AppTheme.tertiaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          SizedBox(height: size * 0.2),
          Text(
            'ConnectCampus',
            style: TextStyle(
              fontSize: size * 0.28,
              fontWeight: FontWeight.bold,
              color: isWhite ? Colors.white : AppTheme.darkText,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            'Find your campus connection',
            style: TextStyle(
              fontSize: size * 0.14,
              color: isWhite
                  ? Colors.white.withValues(alpha: 0.8)
                  : AppTheme.greyText,
            ),
          ),
        ],
      ],
    );
  }
}

// Animated logo for splash screen
class AnimatedAppLogo extends StatefulWidget {
  final double size;

  const AnimatedAppLogo({super.key, this.size = 100});

  @override
  State<AnimatedAppLogo> createState() => _AnimatedAppLogoState();
}

class _AnimatedAppLogoState extends State<AnimatedAppLogo>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateAnimation = Tween<double>(begin: 0, end: 1).animate(_rotateController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating glow effect
              AnimatedBuilder(
                animation: _rotateAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotateAnimation.value * 2 * 3.14159,
                    child: Container(
                      width: widget.size * 1.3,
                      height: widget.size * 1.3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.0),
                            AppTheme.primaryColor.withValues(alpha: 0.3),
                            AppTheme.secondaryColor.withValues(alpha: 0.3),
                            AppTheme.primaryColor.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Main logo
              AppLogo(size: widget.size, showText: false, isWhite: true),
            ],
          ),
        );
      },
    );
  }
}