import 'package:flutter/services.dart';

class HapticUtils {
  // Light tap feedback
  static void lightTap() {
    HapticFeedback.lightImpact();
  }

  // Medium tap feedback
  static void mediumTap() {
    HapticFeedback.mediumImpact();
  }

  // Heavy tap feedback
  static void heavyTap() {
    HapticFeedback.heavyImpact();
  }

  // Selection changed feedback
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  // Vibrate feedback
  static void vibrate() {
    HapticFeedback.vibrate();
  }

  // Success feedback (heavy + light)
  static Future<void> success() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }

  // Error feedback (heavy + heavy)
  static Future<void> error() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.heavyImpact();
  }

  // Button press feedback
  static void buttonPress() {
    HapticFeedback.mediumImpact();
  }

  // Swipe feedback
  static void swipe() {
    HapticFeedback.lightImpact();
  }

  // Match found feedback
  static Future<void> matchFound() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
  }
}