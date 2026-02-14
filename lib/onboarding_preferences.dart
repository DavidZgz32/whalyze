import 'package:shared_preferences/shared_preferences.dart';

/// Helper para leer/escribir si el usuario ya completó el onboarding.
class OnboardingPreferences {
  OnboardingPreferences._();

  static const String _keyOnboardingDone = 'onboarding_done';

  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboardingDone) ?? false;
  }

  static Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboardingDone, true);
  }
}
