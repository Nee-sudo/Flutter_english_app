# Complete Flutter Language Stories App - Code Bundle

This document contains all code files ready to be placed in the project directory.

## FILE STRUCTURE & CONTENT

### 1. pubspec.yaml (Update existing file)
```yaml
name: language_stories_app
description: A Flutter web app for learning languages through stories with demo and premium content.
publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  http: ^1.1.0
  shared_preferences: ^2.2.0
  google_fonts: ^6.0.0
  uuid: ^4.0.0
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

---

## FLUTTER FILES (lib/ directory)

### 2. lib/main.dart
```dart
import 'package:flutter/material.dart';
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
```

### 3. lib/utils/constants.dart
```dart
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
```

### 4. lib/models/tense_model.dart
```dart
class Tense {
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
```

### 5. lib/models/story_model.dart
```dart
class Story {
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
```

### 6. lib/models/user_state_model.dart
```dart
class UserState {
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
```

---

## SERVICES (lib/services/ directory)

### 7. lib/services/storage_service.dart
```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_state_model.dart';
import '../utils/constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User State Management
  Future<void> saveUserState(UserState state) async {
    await _prefs.setString(
      AppConstants.unlockedStateKey,
      jsonEncode(state.toJson()),
    );
  }

  UserState? getUserState() {
    final jsonStr = _prefs.getString(AppConstants.unlockedStateKey);
    if (jsonStr == null) return null;
    try {
      return UserState.fromJson(jsonDecode(jsonStr));
    } catch (e) {
      return null;
    }
  }

  // User ID Management
  Future<void> saveUserId(String userId) async {
    await _prefs.setString(AppConstants.userIdKey, userId);
  }

  String? getUserId() {
    return _prefs.getString(AppConstants.userIdKey);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
```

### 8. lib/services/api_service.dart
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final _client = http.Client();

  // Verify Coupon Code
  Future<({bool success, String message})> verifyCoupon(String coupon) async {
    try {
      final response = await _client.post(
        Uri.parse(AppAPI.verifyCoupon),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'coupon': coupon}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (success: true, message: data['message'] ?? 'Valid coupon');
      } else {
        final data = jsonDecode(response.body);
        return (success: false, message: data['message'] ?? 'Invalid coupon');
      }
    } catch (e) {
      return (success: false, message: 'Error: ${e.toString()}');
    }
  }

  // Track User
  Future<bool> trackUser(String userId, String ipAddress) async {
    try {
      final response = await _client.post(
        Uri.parse(AppAPI.trackUser),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'ipAddress': ipAddress,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Get sample tenses (mock data for now)
  Future<List<Map<String, dynamic>>> getTenses() async {
    return [
      {
        '_id': '1',
        'name': 'Present Simple',
        'description': 'Habitual actions and facts',
        'emoji': '⏰'
      },
      {
        '_id': '2',
        'name': 'Past Continuous',
        'description': 'Actions in progress in the past',
        'emoji': '📚'
      },
      {
        '_id': '3',
        'name': 'Future Perfect',
        'description': 'Completed actions in the future',
        'emoji': '🚀'
      },
      {
        '_id': '4',
        'name': 'Present Perfect Continuous',
        'description': 'Ongoing actions from past to present',
        'emoji': '🔄'
      },
    ];
  }

  // Get stories for a tense (mock data)
  Future<List<Map<String, dynamic>>> getStoriesForTense(String tenseId) async {
    final mockStories = {
      '1': [
        {
          '_id': '1-1',
          'tenseId': '1',
          'title': 'Demo: Daily Routine',
          'englishText': 'I wake up at 7 AM. I brush my teeth. I have breakfast. I go to school. I play football. I study. I go to sleep.',
          'hindiText': 'मैं सुबह 7 बजे जागता हूँ। मैं अपने दाँत ब्रश करता हूँ। मैं नाश्ता करता हूँ। मैं स्कूल जाता हूँ। मैं फुटबॉल खेलता हूँ। मैं पढ़ता हूँ। मैं सो जाता हूँ।',
          'isDemo': true,
        },
        {
          '_id': '1-2',
          'tenseId': '1',
          'title': 'The Student\'s Day',
          'englishText': 'Rahul studies every day. He wakes up early. He reads books. He writes assignments. He helps his friends.',
          'hindiText': 'राहुल हर दिन पढ़ता है। वह जल्दी उठता है। वह किताबें पढ़ता है। वह काम लिखता है। वह अपने दोस्तों की मदद करता है।',
          'isDemo': false,
        },
      ],
      '2': [
        {
          '_id': '2-1',
          'tenseId': '2',
          'title': 'Demo: Yesterday\'s Event',
          'englishText': 'I was playing cricket when it started raining. My friends were running towards the shelter. The ball was flying in the air.',
          'hindiText': 'मैं क्रिकेट खेल रहा था जब बारिश होने लगी। मेरे दोस्त छत की ओर दौड़ रहे थे। गेंद हवा में उड़ रही थी।',
          'isDemo': true,
        },
        {
          '_id': '2-2',
          'tenseId': '2',
          'title': 'The Unexpected Visit',
          'englishText': 'While I was studying, my cousin was watching TV. My mother was cooking dinner. My father was reading news.',
          'hindiText': 'जबकि मैं पढ़ रहा था, मेरा चचेरा भाई टीवी देख रहा था। मेरी माँ रात का खाना बना रही थी। मेरे पिता समाचार पढ़ रहे थे।',
          'isDemo': false,
        },
      ],
      '3': [
        {
          '_id': '3-1',
          'tenseId': '3',
          'title': 'Demo: Future Plans',
          'englishText': 'By next year, I will have completed my studies. I will have learned English. I will have achieved my dreams.',
          'hindiText': 'अगले साल तक, मैं अपनी पढ़ाई पूरी कर चुका होऊँगा। मैं अंग्रेजी सीख चुका होऊँगा। मैंने अपने सपने पूरे कर लिए होंगे।',
          'isDemo': true,
        },
        {
          '_id': '3-2',
          'tenseId': '3',
          'title': 'Success Story',
          'englishText': 'By the time you read this, I will have finished the project. My team will have delivered the solution. Everyone will have celebrated the success.',
          'hindiText': 'जब तक तुम यह पढ़ोगे, मैं परियोजना पूरी कर चुका होऊँगा। मेरी टीम समाधान दे चुकी होगी। सभी सफलता का जश्न मना चुके होंगे।',
          'isDemo': false,
        },
      ],
      '4': [
        {
          '_id': '4-1',
          'tenseId': '4',
          'title': 'Demo: Ongoing Activity',
          'englishText': 'I have been learning English for 5 years. She has been working here since 2020. They have been living in this city for a long time.',
          'hindiText': 'मैं 5 साल से अंग्रेजी सीख रहा हूँ। वह 2020 से यहाँ काम कर रही है। वे लंबे समय से इस शहर में रह रहे हैं।',
          'isDemo': true,
        },
        {
          '_id': '4-2',
          'tenseId': '4',
          'title': 'Life Journey',
          'englishText': 'He has been studying hard for the exam. His parents have been supporting him throughout. His teachers have been guiding him.',
          'hindiText': 'वह परीक्षा के लिए कड़ी मेहनत कर रहा है। उसके माता-पिता पूरे समय उसका समर्थन कर रहे हैं। उसके शिक्षकों ने उसका मार्गदर्शन किया है।',
          'isDemo': false,
        },
      ],
    };

    return mockStories[tenseId] ?? [];
  }
}
```

### 9. lib/services/state_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user_state_model.dart';
import '../models/tense_model.dart';
import '../models/story_model.dart';
import 'storage_service.dart';
import 'api_service.dart';

class AppStateProvider extends ChangeNotifier {
  final _storageService = StorageService();
  final _apiService = ApiService();

  late UserState _userState;
  late List<Tense> _tenses = [];
  late Map<String, List<Story>> _storiesByTense = {};
  bool _isLoading = false;
  String? _errorMessage;

  UserState get userState => _userState;
  List<Tense> get tenses => _tenses;
  Map<String, List<Story>> get storiesByTense => _storiesByTense;
  bool get isLoading => _isLoading;
  bool get isUnlocked => _userState.isUnlocked;
  String? get errorMessage => _errorMessage;

  Future<void> init() async {
    await _storageService.init();
    _loadUserState();
    await _loadTenses();
    notifyListeners();
  }

  void _loadUserState() {
    _userState = _storageService.getUserState() ??
        UserState(
          userId: const Uuid().v4(),
          isUnlocked: false,
        );

    // Save if new user
    if (_storageService.getUserState() == null) {
      _storageService.saveUserState(_userState);
    }
  }

  Future<void> _loadTenses() async {
    _isLoading = true;
    try {
      final tensesData = await _apiService.getTenses();
      _tenses = tensesData.map((t) => Tense.fromJson(t)).toList();
      await _loadAllStories();
    } catch (e) {
      _errorMessage = 'Failed to load tenses: ${e.toString()}';
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadAllStories() async {
    for (var tense in _tenses) {
      final storiesData = await _apiService.getStoriesForTense(tense.id);
      _storiesByTense[tense.id] =
          storiesData.map((s) => Story.fromJson(s)).toList();
    }
  }

  Future<bool> verifyCoupon(String coupon) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _apiService.verifyCoupon(coupon);

    if (result.success) {
      _userState = _userState.copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      await _storageService.saveUserState(_userState);
      
      // Track user
      await _apiService.trackUser(_userState.userId, 'web-user');
    } else {
      _errorMessage = result.message;
    }

    _isLoading = false;
    notifyListeners();
    return result.success;
  }

  List<Story> getStoriesForTense(String tenseId) {
    return _storiesByTense[tenseId] ?? [];
  }

  bool canViewStory(Story story) {
    return story.isDemo || _userState.isUnlocked;
  }

  void resetUnlock() {
    _userState = _userState.copyWith(isUnlocked: false);
    _storageService.saveUserState(_userState);
    notifyListeners();
  }
}
```

---

## SCREENS (lib/screens/ directory)

### 10. lib/screens/home_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/state_provider.dart';
import '../widgets/tense_card.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primary,
        title: const Text(
          '📖 Language Stories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<AppStateProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Learn English Tenses',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Click on a tense to explore stories',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textLight,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Unlock Status
                  Container(
                    padding: EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: provider.isUnlocked
                          ? AppColors.secondary
                          : AppColors.locked,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          provider.isUnlocked ? Icons.check_circle : Icons.lock,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            provider.isUnlocked
                                ? '✨ Premium unlocked! Full access enabled.'
                                : '🔒 Demo stories only. Enter coupon to unlock.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg),

                  // Tenses Grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isMobile ? 1 : 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: isMobile ? 1.0 : 1.2,
                    ),
                    itemCount: provider.tenses.length,
                    itemBuilder: (context, index) {
                      return TenseCard(tense: provider.tenses[index]);
                    },
                  ),
                  SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

### 11. lib/screens/story_view_screen.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/tense_model.dart';
import '../models/story_model.dart';
import '../services/state_provider.dart';
import '../widgets/story_display.dart';
import '../widgets/paywall_modal.dart';
import '../utils/constants.dart';

class StoryViewScreen extends StatefulWidget {
  final Tense tense;

  const StoryViewScreen({
    Key? key,
    required this.tense,
  }) : super(key: key);

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> {
  Story? _selectedStory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AppStateProvider>();
      final stories = provider.getStoriesForTense(widget.tense.id);
      if (stories.isNotEmpty) {
        setState(() => _selectedStory = stories.first);
      }
    });
  }

  void _selectStory(Story story) {
    final provider = context.read<AppStateProvider>();
    if (!provider.canViewStory(story)) {
      _showPaywallModal(story);
      return;
    }
    setState(() => _selectedStory = story);
  }

  void _showPaywallModal(Story story) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaywallModal(story: story),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Consumer<AppStateProvider>(
      builder: (context, provider, _) {
        final stories = provider.getStoriesForTense(widget.tense.id);

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              '${widget.tense.emoji} ${widget.tense.name}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: isMobile
              ? _buildMobileLayout(context, stories, provider)
              : _buildDesktopLayout(context, stories, provider),
        );
      },
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    List<Story> stories,
    AppStateProvider provider,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stories List
          Padding(
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Stories',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                ...stories.map((story) => _buildStoryItem(story, provider)),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg),

          // Story Display
          if (_selectedStory != null)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: StoryDisplay(story: _selectedStory!),
            ),
          SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    List<Story> stories,
    AppStateProvider provider,
  ) {
    return Row(
      children: [
        // Stories Sidebar
        Expanded(
          flex: 1,
          child: Container(
            color: AppColors.surface,
            padding: EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stories',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.builder(
                    itemCount: stories.length,
                    itemBuilder: (_, i) => _buildStoryItem(stories[i], provider),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Story Display
        Expanded(
          flex: 2,
          child: _selectedStory != null
              ? Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: StoryDisplay(story: _selectedStory!),
                )
              : const Center(
                  child: Text('Select a story to view'),
                ),
        ),
      ],
    );
  }

  Widget _buildStoryItem(Story story, AppStateProvider provider) {
    final canView = provider.canViewStory(story);
    final isSelected = _selectedStory?.id == story.id;

    return GestureDetector(
      onTap: () => _selectStory(story),
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.sm),
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  if (story.isDemo)
                    Text(
                      '🎁 Demo',
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white70 : AppColors.textLight,
                      ),
                    ),
                ],
              ),
            ),
            if (!canView)
              Icon(
                Icons.lock,
                color: isSelected ? Colors.white : AppColors.locked,
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## WIDGETS (lib/widgets/ directory)

### 12. lib/widgets/tense_card.dart
```dart
import 'package:flutter/material.dart';
import '../models/tense_model.dart';
import '../screens/story_view_screen.dart';
import '../utils/constants.dart';

class TenseCard extends StatelessWidget {
  final Tense tense;

  const TenseCard({
    Key? key,
    required this.tense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoryViewScreen(tense: tense),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withOpacity(0.8),
                AppColors.accent.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tense.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              SizedBox(height: AppSpacing.md),
              Text(
                tense.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.sm),
              Text(
                tense.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 13. lib/widgets/story_display.dart
```dart
import 'package:flutter/material.dart';
import '../models/story_model.dart';
import '../utils/constants.dart';

class StoryDisplay extends StatefulWidget {
  final Story story;

  const StoryDisplay({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<StoryDisplay> createState() => _StoryDisplayState();
}

class _StoryDisplayState extends State<StoryDisplay> {
  bool _showEnglish = true;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          Text(
            widget.story.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.md),

          // Toggle Button
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _showEnglish = true),
                  icon: const Icon(Icons.language),
                  label: const Text('English'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showEnglish
                        ? AppColors.primary
                        : AppColors.border,
                    foregroundColor: _showEnglish
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => setState(() => _showEnglish = false),
                  icon: const Icon(Icons.translate),
                  label: const Text('हिंदी'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: !_showEnglish
                        ? AppColors.secondary
                        : AppColors.border,
                    foregroundColor: !_showEnglish
                        ? Colors.white
                        : AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.lg),

          // Story Content
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _showEnglish
                  ? widget.story.englishText
                  : widget.story.hindiText,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                height: 1.8,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.justify,
            ),
          ),
        ],
      ),
    );
  }
}
```

### 14. lib/widgets/paywall_modal.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/story_model.dart';
import '../services/state_provider.dart';
import '../utils/constants.dart';

class PaywallModal extends StatefulWidget {
  final Story story;

  const PaywallModal({
    Key? key,
    required this.story,
  }) : super(key: key);

  @override
  State<PaywallModal> createState() => _PaywallModalState();
}

class _PaywallModalState extends State<PaywallModal> {
  late TextEditingController _couponController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _couponController = TextEditingController();
  }

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon(BuildContext context) async {
    if (_couponController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a coupon code')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final provider = context.read<AppStateProvider>();
    final success = await provider.verifyCoupon(_couponController.text);

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ All stories unlocked!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${provider.errorMessage}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Lock Icon
            Center(
              child: Container(
                padding: EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.locked.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 48,
                  color: AppColors.locked,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md),

            // Title
            Center(
              child: Text(
                'Premium Content',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm),

            // Description
            Center(
              child: Text(
                'Enter your coupon code to unlock all stories',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textLight,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Coupon Input
            TextField(
              controller: _couponController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                hintText: 'Enter coupon code',
                prefixIcon: const Icon(Icons.ticket),
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Hint
            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '💡 Tip: Try "NEER50" for access',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textLight,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Unlock Button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : () => _applyCoupon(context),
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Icon(Icons.lock_open),
              label: Text(_isLoading ? 'Verifying...' : 'Unlock All Stories'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                disabledBackgroundColor: AppColors.border,
              ),
            ),

            // Close Button
            SizedBox(height: AppSpacing.md),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## WEB INDEX (web/index.html)
```html
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="Learn English tenses through interactive stories">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="Language Stories">
  <link rel="icon" type="image/png" href="favicon.png"/>
  
  <title>Language Stories - Learn English Tenses</title>
  <link rel="manifest" href="manifest.json">
  <link rel="stylesheet" type="text/css" href="splash/style.css">
  <link rel="image/png" href="splash/img-1.2x.png">
  <link rel="image/png" href="splash/img-2.0x.png">
  <link rel="image/png" href="splash/img-3.0x.png">
  
  <style>
    html, body {
      width: 100%;
      height: 100%;
      margin: 0;
      padding: 0;
      background-color: #F8F9FA;
    }
    
    body {
      font-family: 'Roboto', sans-serif;
    }
    
    #loading {
      display: flex;
      align-items: center;
      justify-content: center;
      height: 100vh;
      background: linear-gradient(135deg, #6366F1 0%, #EC4899 100%);
      color: white;
      font-size: 24px;
      font-weight: bold;
    }
  </style>
</head>
<body>
  <div id="loading">Loading...</div>
  
  <script>
    window.addEventListener('flutter-first-frame', function() {
      document.getElementById('loading').style.display = 'none';
    });
  </script>
  <script src="flutter.js" defer></script>
</body>
</html>
```

---

## BACKEND FILES (backend/ directory)

### 15. backend/package.json
```json
{
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
```

### 16. backend/.env.example
```
MONGO_URI=mongodb://localhost:27017/language_stories
PORT=5000
NODE_ENV=development
COUPON_CODE=NEER50
```

### 17. backend/src/server.js
```javascript
import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import couponRoutes from './routes/coupon.routes.js';
import analyticsRoutes from './routes/analytics.routes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

// MongoDB Connection
mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/language_stories')
  .then(() => console.log('✅ MongoDB connected'))
  .catch(err => console.log('❌ MongoDB error:', err));

// Routes
app.use('/api/coupon', couponRoutes);
app.use('/api/analytics', analyticsRoutes);

// Health Check
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'Server is running' });
});

// Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on http://localhost:${PORT}`);
});
```

### 18. backend/src/config/database.js
```javascript
import mongoose from 'mongoose';
import dotenv from 'dotenv';

dotenv.config();

export const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/language_stories', {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ MongoDB connected');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
};
```

### 19. backend/src/models/schemas.js
```javascript
import mongoose from 'mongoose';

// Tense Schema
export const TenseSchema = new mongoose.Schema({
  name: { type: String, required: true, unique: true },
  description: String,
  emoji: String,
  createdAt: { type: Date, default: Date.now },
});

// Story Schema
export const StorySchema = new mongoose.Schema({
  tenseId: { type: mongoose.Schema.Types.ObjectId, ref: 'Tense', required: true },
  title: { type: String, required: true },
  englishText: { type: String, required: true },
  hindiText: { type: String, required: true },
  isDemo: { type: Boolean, default: false },
  category: String,
  createdAt: { type: Date, default: Date.now },
});

// User Schema
export const UserSchema = new mongoose.Schema({
  userId: { type: String, required: true, unique: true },
  couponAppliedAt: { type: Date, default: Date.now },
  ipAddress: String,
  userAgent: String,
  createdAt: { type: Date, default: Date.now },
});

// Analytics Schema
export const AnalyticsSchema = new mongoose.Schema({
  totalUnlockedUsers: { type: Number, default: 0 },
  totalCouponAttempts: { type: Number, default: 0 },
  lastUpdated: { type: Date, default: Date.now },
});

export const Tense = mongoose.model('Tense', TenseSchema);
export const Story = mongoose.model('Story', StorySchema);
export const User = mongoose.model('User', UserSchema);
export const Analytics = mongoose.model('Analytics', AnalyticsSchema);
```

### 20. backend/src/routes/coupon.routes.js
```javascript
import express from 'express';
import { verifyCoupon } from '../controllers/coupon.controller.js';

const router = express.Router();

router.post('/verify', verifyCoupon);

export default router;
```

### 21. backend/src/routes/analytics.routes.js
```javascript
import express from 'express';
import { trackUser, getAnalytics } from '../controllers/analytics.controller.js';

const router = express.Router();

router.post('/track', trackUser);
router.get('/stats', getAnalytics);

export default router;
```

### 22. backend/src/controllers/coupon.controller.js
```javascript
import dotenv from 'dotenv';

dotenv.config();

export const verifyCoupon = (req, res) => {
  const { coupon } = req.body;

  if (!coupon) {
    return res.status(400).json({
      valid: false,
      message: 'Coupon code is required',
    });
  }

  const validCoupon = process.env.COUPON_CODE || 'NEER50';

  if (coupon.toUpperCase() === validCoupon) {
    return res.status(200).json({
      valid: true,
      message: 'Coupon code is valid. All stories unlocked!',
    });
  } else {
    return res.status(400).json({
      valid: false,
      message: 'Invalid coupon code. Please try again.',
    });
  }
};
```

### 23. backend/src/controllers/analytics.controller.js
```javascript
import { User, Analytics } from '../models/schemas.js';

export const trackUser = async (req, res) => {
  try {
    const { userId, ipAddress } = req.body;

    if (!userId) {
      return res.status(400).json({
        success: false,
        message: 'User ID is required',
      });
    }

    // Check if user already exists
    const existingUser = await User.findOne({ userId });
    if (existingUser) {
      return res.status(200).json({
        success: true,
        message: 'User already tracked',
        totalUsers: await User.countDocuments(),
      });
    }

    // Create new user record
    const newUser = new User({
      userId,
      ipAddress,
      userAgent: req.headers['user-agent'],
    });

    await newUser.save();

    // Update analytics
    let analytics = await Analytics.findOne();
    if (!analytics) {
      analytics = new Analytics({ totalUnlockedUsers: 1 });
    } else {
      analytics.totalUnlockedUsers += 1;
      analytics.lastUpdated = new Date();
    }
    await analytics.save();

    res.status(200).json({
      success: true,
      message: 'User tracked successfully',
      totalUsers: await User.countDocuments(),
    });
  } catch (error) {
    console.error('Track user error:', error);
    res.status(500).json({
      success: false,
      message: 'Error tracking user',
      error: error.message,
    });
  }
};

export const getAnalytics = async (req, res) => {
  try {
    const analytics = await Analytics.findOne();
    const totalUsers = await User.countDocuments();

    res.status(200).json({
      success: true,
      data: {
        totalUnlockedUsers: analytics?.totalUnlockedUsers || 0,
        totalUsers,
        lastUpdated: analytics?.lastUpdated,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error fetching analytics',
      error: error.message,
    });
  }
};
```

---

## SETUP COMMANDS

### For Flutter Frontend:
```bash
cd Project_31_Flutter_notes
flutter pub get
flutter run -d web
```

### For Node.js Backend:
```bash
cd backend
npm install
cp .env.example .env
# Edit .env with your MongoDB URI
npm start
```

### Access the App:
```
Frontend: http://localhost:5000 (if served via Express) or http://localhost:your-flutter-port
Backend API: http://localhost:5000/api
```

---

## DEMO STORIES INCLUDED:
1. Present Simple - "Demo: Daily Routine"
2. Past Continuous - "Demo: Yesterday's Event"
3. Future Perfect - "Demo: Future Plans"
4. Present Perfect Continuous - "Demo: Ongoing Activity"

All demo stories are accessible without coupon. Use coupon "NEER50" to unlock premium stories.
