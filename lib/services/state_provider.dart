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

