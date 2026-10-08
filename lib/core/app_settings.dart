import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings extends ChangeNotifier {
  AppSettings._();
  static final instance = AppSettings._();
  bool darkMode = false;
  bool onboardingCompleted = false;
  String language = 'en';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool('darkMode') ?? false;
    onboardingCompleted = prefs.getBool('onboardingCompleted') ?? false;
    language = prefs.getString('language') ?? 'en';
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    darkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
  }

  Future<void> setLanguage(String value) async {
    language = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
  }

  Future<void> completeOnboarding() async {
    onboardingCompleted = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted', true);
  }
}
