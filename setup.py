#!/usr/bin/env python3
"""
Flutter Language Stories App - Automatic Setup Script
This script creates all necessary folder structure and files.
Run: python3 setup.py
"""

import os
import json
from pathlib import Path

def create_file(path, content):
    """Create a file with the given content."""
    # Create parent directories if they don't exist
    Path(path).parent.mkdir(parents=True, exist_ok=True)
    
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"✅ Created: {path}")

def create_directory(path):
    """Create a directory."""
    Path(path).mkdir(parents=True, exist_ok=True)
    print(f"📁 Created directory: {path}")

# Define all files to create
files_to_create = {
    # Flutter files
    "lib/main.dart": '''import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/state_provider.dart';
import 'screens/home_screen.dart';
import 'utils/constants.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()..init()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Stories',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
''',
    
    "lib/utils/constants.dart": '''import 'package:flutter/material.dart';

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
  static const String verifyCoupon = '\\$baseUrl/coupon/verify';
  static const String trackUser = '\\$baseUrl/analytics/track';
}

class AppConstants {
  static const String couponCode = 'NEER50';
  static const String demoStoryMarker = 'DEMO';
  static const String unlockedStateKey = 'unlocked_state';
  static const String userIdKey = 'user_id';
}
''',

    "lib/models/tense_model.dart": '''class Tense {
  final String id;
  final String name;
  final String description;
  final String emoji;

  Tense({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
  });

  factory Tense.fromJson(Map<String, dynamic> json) {
    return Tense(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      emoji: json['emoji'] ?? '📖',
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'description': description,
    'emoji': emoji,
  };
}
''',

    "lib/models/story_model.dart": '''class Story {
  final String id;
  final String tenseId;
  final String title;
  final String englishText;
  final String hindiText;
  final bool isDemo;
  final String? category;

  Story({
    required this.id,
    required this.tenseId,
    required this.title,
    required this.englishText,
    required this.hindiText,
    required this.isDemo,
    this.category,
  });

  factory Story.fromJson(Map<String, dynamic> json) => Story(
    id: json['_id'] ?? json['id'] ?? '',
    tenseId: json['tenseId'] ?? '',
    title: json['title'] ?? '',
    englishText: json['englishText'] ?? '',
    hindiText: json['hindiText'] ?? '',
    isDemo: json['isDemo'] ?? false,
    category: json['category'],
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'tenseId': tenseId,
    'title': title,
    'englishText': englishText,
    'hindiText': hindiText,
    'isDemo': isDemo,
    'category': category,
  };
}
''',

    "lib/models/user_state_model.dart": '''class UserState {
  final String userId;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  UserState({
    required this.userId,
    required this.isUnlocked,
    this.unlockedAt,
  });

  factory UserState.fromJson(Map<String, dynamic> json) => UserState(
    userId: json['userId'] ?? '',
    isUnlocked: json['isUnlocked'] ?? false,
    unlockedAt: json['unlockedAt'] != null
        ? DateTime.parse(json['unlockedAt'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  UserState copyWith({
    String? userId,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) => UserState(
    userId: userId ?? this.userId,
    isUnlocked: isUnlocked ?? this.isUnlocked,
    unlockedAt: unlockedAt ?? this.unlockedAt,
  );
}
''',

    # Backend files
    "backend/package.json": '''{
  "name": "language-stories-backend",
  "version": "1.0.0",
  "description": "Backend API for Language Stories app",
  "main": "src/server.js",
  "type": "module",
  "scripts": {
    "start": "node src/server.js",
    "dev": "nodemon src/server.js"
  },
  "dependencies": {
    "express": "^4.18.2",
    "mongoose": "^7.5.0",
    "dotenv": "^16.3.1",
    "cors": "^2.8.5",
    "body-parser": "^1.20.2",
    "uuid": "^9.0.0"
  },
  "devDependencies": {
    "nodemon": "^3.0.1"
  }
}
''',

    "backend/.env": '''MONGO_URI=mongodb://localhost:27017/language_stories
PORT=5000
NODE_ENV=development
COUPON_CODE=NEER50
''',

    "backend/.env.example": '''MONGO_URI=mongodb://localhost:27017/language_stories
PORT=5000
NODE_ENV=development
COUPON_CODE=NEER50
''',
}

def main():
    print("🚀 Flutter Language Stories App - Setup Script")
    print("=" * 50)
    
    # Get current directory
    cwd = os.getcwd()
    print(f"📍 Working directory: {cwd}")
    
    # Create directories
    directories = [
        "lib",
        "lib/utils",
        "lib/models",
        "lib/screens",
        "lib/widgets",
        "lib/services",
        "web",
        "backend",
        "backend/src",
        "backend/src/routes",
        "backend/src/controllers",
        "backend/src/models",
        "backend/src/middleware",
        "backend/src/config",
    ]
    
    print("\n📁 Creating directories...")
    for directory in directories:
        create_directory(directory)
    
    # Create files
    print("\n📝 Creating files...")
    for file_path, content in files_to_create.items():
        create_file(file_path, content)
    
    print("\n✨ Setup complete!")
    print("\n📋 Next steps:")
    print("1. cd flutter_app && flutter pub get")
    print("2. cd backend && npm install")
    print("3. flutter run -d web")
    print("4. npm start (in backend directory)")

if __name__ == "__main__":
    main()
