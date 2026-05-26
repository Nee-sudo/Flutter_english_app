import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/api_uri.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal();

  final _client = http.Client();

  Future<({bool success, String message})> verifyCoupon(String coupon) async {
    final normalized = coupon.trim().toUpperCase();
    if (normalized.isEmpty) {
      return (success: false, message: 'Coupon code is required');
    }

    try {
      final response = await _client
          .post(
            apiUri('coupon/verify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'coupon': normalized}),
          )
          .timeout(const Duration(seconds: 8));

      final data = _decodeJson(response.body);

      if (response.statusCode == 200) {
        return (
          success: true,
          message: (data['message'] as String?) ?? 'Valid coupon',
        );
      }

      if (response.statusCode >= 500) {
        return _verifyCouponOffline(normalized);
      }

      return (
        success: false,
        message: (data['message'] as String?) ?? 'Invalid coupon',
      );
    } catch (_) {
      return _verifyCouponOffline(normalized);
    }
  }

  ({bool success, String message}) _verifyCouponOffline(String coupon) {
    if (coupon == AppConstants.couponCode.toUpperCase()) {
      return (
        success: true,
        message: 'Coupon verified (offline mode). All stories unlocked!',
      );
    }
    return (
      success: false,
      message:
          'Could not reach server. Use coupon ${AppConstants.couponCode} or start the backend.',
    );
  }

  Map<String, dynamic> _decodeJson(String body) {
    if (body.isEmpty) return {};
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : {};
    } catch (_) {
      return {};
    }
  }

  Future<bool> trackUser(String userId, String ipAddress) async {
    try {
      final response = await _client.post(
        apiUri('analytics/track'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'ipAddress': ipAddress}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<({bool success, String message})> generatePdf(
    String language, {
    String? userId,
    String? tenseId,
  }) async {
    try {
      if (!['english', 'hindi'].contains(language)) {
        return (
          success: false,
          message: 'Invalid language. Must be "english" or "hindi"',
        );
      }

      final response = await _client
          .post(
            apiUri('pdf/generate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'language': language,
              'userId': userId ?? 'anonymous',
              if (tenseId != null) 'tenseId': tenseId,
            }),
          )
          .timeout(const Duration(seconds: 60));

      final data = _decodeJson(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final downloadToken = data['downloadToken'] as String?;
        
        if (downloadToken != null && downloadToken.isNotEmpty) {
          // Use token-based download
          openDownloadUrl(
            apiUri('pdf/download/$downloadToken').toString(),
            'stories-$language.pdf',
          );
        }

        return (
          success: true,
          message: (data['message'] as String?) ?? 'PDF download started',
        );
      }

      return (
        success: false,
        message: (data['error'] as String?) ??
            (data['message'] as String?) ??
            'Failed to generate PDF',
      );
    } catch (e) {
      return (success: false, message: 'Error: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchList(String path) async {
    final response = await _client
        .get(apiUri(path))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return [];

    final data = _decodeJson(response.body);
    final list = data['data'];
    if (list is List) {
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> getTenses() async {
    final fromApi = await _fetchList('tenses');
    if (fromApi.isNotEmpty) return fromApi;

    // If the backend is down or returns empty lists, keep the UI stable
    // instead of failing hard.
    return _mockTenses();
  }

  Future<List<Map<String, dynamic>>> getStoriesForTense(String tenseId) async {
    final fromApi = await _fetchList('stories?tenseId=$tenseId');
    if (fromApi.isNotEmpty) return fromApi;

    // If the backend is down, return demo placeholders so UI doesn't crash.
    return _mockStoriesForTense(tenseId);
  }

  List<Map<String, dynamic>> _mockTenses() => [
      {
        '_id': '1',
        'name': 'Present Simple',
        'description': 'Habitual actions and facts',
        'emoji': '⏰',
      },
      {
        '_id': '2',
        'name': 'Past Continuous',
        'description': 'Actions in progress in the past',
        'emoji': '📚',
      },
      {
        '_id': '3',
        'name': 'Future Perfect',
        'description': 'Completed actions in the future',
        'emoji': '🚀',
      },
      {
        '_id': '4',
        'name': 'Present Perfect Continuous',
        'description': 'Ongoing actions from past to present',
        'emoji': '🔄',
      },
    ];

  List<Map<String, dynamic>> _mockStoriesForTense(String tenseId) {
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
          'title': "The Student's Day",
          'englishText': 'Rahul studies every day. He wakes up early. He reads books. He writes assignments. He helps his friends.',
          'hindiText': 'राहुल हर दिन पढ़ता है। वह जल्दी उठता है। वह किताबें पढ़ता है। वह काम लिखता है। वह अपने दोस्तों की मदद करता है।',
          'isDemo': false,
        },
      ],
      '2': [
        {
          '_id': '2-1',
          'tenseId': '2',
          'title': "Demo: Yesterday's Event",
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
          'title': "Demo: Future Plans",
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
