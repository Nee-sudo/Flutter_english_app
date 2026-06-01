import 'package:flutter/material.dart';

/// Design tokens for the app.
///
/// Notes:
/// - Keep semantic colors separate from brand colors.
/// - Favor WCAG-friendly contrast by using dark text on light surfaces and
///   vice-versa for dark theme.
class AppColors {
  // Brand (existing)
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFF10B981); // Green
  static const Color accent = Color(0xFFEC4899); // Pink

  // Extended palette
  static const Color blue = Color(0xFF3B82F6);
  static const Color teal = Color(0x14B8A6);
  static const Color amber = Color(0xFFF59E0B);
  static const Color lime = Color(0xFFA3E635);
  static const Color violet = Color(0xFF8B5CF6);

  // Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);

  // Error (kept for compatibility)
  static const Color error = Color(0xFFF87171);


  // Surfaces / neutrals (light)
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textDark = Color(0xFF111827);
  static const Color textLight = Color(0xFF6B7280);
  static const Color border = Color(0xFFE5E7EB);

  // Existing locked tone
  static const Color locked = Color(0xFFFCD34D);
}

class AppDarkColors {
  static const Color background = Color(0xFF0B1220);
  static const Color surface = Color(0xFF111B2E);
  static const Color textDark = Color(0xFFE5E7EB);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color border = Color(0xFF233049);

  static const Color overlay = Color(0x66000000);
}

class AppSpacing {
  // 8px/4px grid
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
}

class AppElevation {
  // Note: keep this non-const to avoid “methods in constant expressions”.
  static List<BoxShadow> get cardSoft => [
        BoxShadow(
          color: const Color(0xFF000000).withOpacity(0.06),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ];
}


class AppMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 240);
  static const Duration slow = Duration(milliseconds: 320);
}

class AppConstants {
  static const String couponCode = 'NEER50';
  static const String demoStoryMarker = 'DEMO';
  static const String unlockedStateKey = 'unlocked_state';
  static const String userIdKey = 'user_id';
}

class AppAPI {
  /// Override at build time: `--dart-define=API_BASE_URL=https://your-api.com/api`
  /// Vercel (same deploy): `/api` — set automatically by vercel-build.sh
  /// Local Express: `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5000/api`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );
  static const String verifyCoupon = '$baseUrl/coupon/verify';
  static const String trackUser = '$baseUrl/analytics/track';
  static const String getTenses = '$baseUrl/tenses';
  static const String getStories = '$baseUrl/stories';
}


