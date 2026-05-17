import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFF10B981);
  static const Color accent = Color(0xFFEC4899);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFF87171);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);
  static const Color locked = Color(0xFFFCD34D);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppAPI {
  static const String baseUrl = 'http://localhost:5000/api';
  static const String verifyCoupon = '$baseUrl/coupon/verify';
  static const String trackUser = '$baseUrl/analytics/track';
  static const String getTenses = '$baseUrl/tenses';
  static const String getStories = '$baseUrl/stories';
}

class AppConstants {
  static const String couponCode = 'NEER50';
  static const String demoStoryMarker = 'DEMO';
  static const String unlockedStateKey = 'unlocked_state';
  static const String userIdKey = 'user_id';
}

