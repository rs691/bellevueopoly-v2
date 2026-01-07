import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  Future<void> logCheckIn({
    required String businessId,
    required String businessName,
    required int points,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'check_in_success',
        parameters: {
          'business_id': businessId,
          'business_name': businessName,
          'points_awarded': points,
        },
      );
      debugPrint('📊 Analytics: Logged check_in_success for $businessName');
    } catch (e) {
      debugPrint('❌ Analytics Error: $e');
    }
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }
}
