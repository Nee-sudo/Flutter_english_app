import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/api_uri.dart';

class AdminApiService {
  static final AdminApiService _instance = AdminApiService._internal();

  factory AdminApiService() => _instance;

  AdminApiService._internal();

  final _client = http.Client();

  Map<String, String> _headers(String adminKey) => {
        'Content-Type': 'application/json',
        'x-admin-key': adminKey,
      };

  Map<String, dynamic> _decodeJson(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {}
    return {};
  }

  Future<List<Map<String, dynamic>>> listAdminTenses(String adminKey) async {
    final res = await _client
        .get(
          apiUri('admin/tenses'),
          headers: _headers(adminKey),
        )
        .timeout(const Duration(seconds: 12));

    final data = _decodeJson(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to list tenses');
    }

    final list = data['data'];
    if (list is List) {
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> listAdminStories(
    String adminKey, {
    required String tenseId,
  }) async {
    final res = await _client
        .get(
          apiUri('admin/stories?tenseId=$tenseId'),
          headers: _headers(adminKey),
        );
    final data = await _decodeJson(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to list stories');
    }

    final list = data['data'];
    if (list is List) {
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createStory(
    String adminKey, {
    required String tenseId,
    required String title,
    required String englishText,
    required String hindiText,
    required bool isDemo,
    String? category,
  }) async {
    final res = await _client
        .post(
          apiUri('admin/stories'),
          headers: _headers(adminKey),
          body: jsonEncode({
            'tenseId': tenseId,
            'title': title,
            'englishText': englishText,
            'hindiText': hindiText,
            'isDemo': isDemo,
            if (category != null) 'category': category,
          }),
        )
        .timeout(const Duration(seconds: 12));

    final data = await _decodeJson(res.body);

    if (res.statusCode != 201 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to create story');
    }

    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> updateStory(
    String adminKey, {
    required String storyId,
    required String title,
    required String englishText,
    required String hindiText,
    required bool isDemo,
    String? category,
    String? tenseId,
  }) async {
    final res = await _client
        .put(
          apiUri('admin/stories/$storyId'),
          headers: _headers(adminKey),
          body: jsonEncode({
            'title': title,
            'englishText': englishText,
            'hindiText': hindiText,
            'isDemo': isDemo,
            if (category != null) 'category': category,
            if (tenseId != null) 'tenseId': tenseId,
          }),
        )
        .timeout(const Duration(seconds: 12));

    final data = await _decodeJson(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to update story');
    }

    return Map<String, dynamic>.from(data);
  }

  Future<void> deleteStory(String adminKey, {required String storyId}) async {
    final res = await _client
        .delete(
          apiUri('admin/stories/$storyId'),
          headers: _headers(adminKey),
        )
        .timeout(const Duration(seconds: 12));

    final data = await _decodeJson(res.body);

    if (res.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Failed to delete story');
    }
  }
}

