import 'package:flutter_test/flutter_test.dart';
import 'package:language_stories_app/services/api_service.dart';
import 'package:language_stories_app/utils/constants.dart';

void main() {
  group('ApiService', () {
    test('getTenses returns four tenses', () async {
      final tenses = await ApiService().getTenses();
      expect(tenses.length, 4);
      expect(tenses.first['name'], 'Present Simple');
    });

    test('getStoriesForTense returns demo and premium stories', () async {
      final stories = await ApiService().getStoriesForTense('1');
      expect(stories.length, 2);
      expect(stories.any((s) => s['isDemo'] == true), isTrue);
    });

    test('offline coupon accepts NEER50', () async {
      final api = ApiService();
      final result = await api.verifyCoupon(AppConstants.couponCode);
      expect(result.success, isTrue);
    });
  });
}
