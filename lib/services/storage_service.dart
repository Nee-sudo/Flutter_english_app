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

