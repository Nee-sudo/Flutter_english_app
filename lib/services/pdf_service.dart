import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import '../utils/api_uri.dart';

class PdfService {
  static final PdfService _instance = PdfService._internal();

  factory PdfService() {
    return _instance;
  }

  PdfService._internal();

  /// Download stories as PDF with selected language
  Future<bool> downloadStoriesPdf({
    required String language,
    String? userId,
  }) async {
    try {
      if (!['english', 'hindi'].contains(language)) {
        throw Exception('Invalid language. Must be "english" or "hindi"');
      }

      // Step 1: Generate PDF on backend
      final generateUrl = apiUri('pdf/generate');
      final response = await html.window.fetch(
        generateUrl,
        {
          'method': 'POST',
          'headers': {'Content-Type': 'application/json'},
          'body': '''
          {
            "language": "$language",
            "userId": "${userId ?? 'anonymous'}"
          }
          ''',
        },
      );

      if (response.status != 200) {
        throw Exception('Failed to generate PDF: ${response.status}');
      }

      final jsonResponse = await response.json() as Map<dynamic, dynamic>;

      if (jsonResponse['downloadToken'] == null) {
        throw Exception('No download token received');
      }

      final downloadToken = jsonResponse['downloadToken'] as String;

      // Step 2: Download PDF using the token
      final downloadUrl = apiUri('pdf/download/$downloadToken');
      final downloadLink = html.AnchorElement(href: downloadUrl)
        ..setAttribute('download', 'stories-$language.pdf')
        ..click();

      return true;
    } catch (error) {
      if (kDebugMode) {
        print('Error downloading PDF: $error');
      }
      rethrow;
    }
  }

  /// Check if running on web platform
  static bool isWeb() {
    return kIsWeb;
  }
}
