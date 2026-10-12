import 'package:shared_preferences/shared_preferences.dart';
import '../routes/app_routes.dart';

class AppSession {
  static const _guestKey = 'guest_session_started';
  static const _onboardingKey = 'onboarding_completed';
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<void> startGuestSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, true);
    await prefs.setBool(_onboardingKey, true);
  }

  static Future<String> initialRoute({required bool authenticated}) async {
    final prefs = await SharedPreferences.getInstance();
    if (authenticated) {
      await startGuestSession();
    }
    if (authenticated || prefs.getBool(_guestKey) == true) {
      return AppRoutes.entryPoint;
    }
    return prefs.getBool(_onboardingKey) == true
        ? AppRoutes.introLogin
        : AppRoutes.onboarding;
  }
}
