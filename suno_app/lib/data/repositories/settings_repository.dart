import 'package:shared_preferences/shared_preferences.dart';
import 'package:suno_app/models/language.dart';

class SettingsRepository {
  static const String _sourceLangKey = 'sourceLanguage';
  static const String _targetLangKey = 'targetLanguage';
  static const String _offlineModeKey = 'offlineModeEnabled';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<Language> getSourceLanguage() async {
    final prefs = await _getPrefs();
    final langCode = prefs.getString(_sourceLangKey) ?? Language.english.code;
    return Language.values.firstWhere(
      (lang) => lang.code == langCode,
      orElse: () => Language.english,
    );
  }

  Future<void> saveSourceLanguage(Language lang) async {
    final prefs = await _getPrefs();
    await prefs.setString(_sourceLangKey, lang.code);
  }

  Future<Language> getTargetLanguage() async {
    final prefs = await _getPrefs();
    final langCode = prefs.getString(_targetLangKey) ?? Language.spanish.code;
    return Language.values.firstWhere(
      (lang) => lang.code == langCode,
      orElse: () => Language.spanish,
    );
  }

  Future<void> saveTargetLanguage(Language lang) async {
    final prefs = await _getPrefs();
    await prefs.setString(_targetLangKey, lang.code);
  }

  Future<bool> getOfflineModeEnabled() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_offlineModeKey) ??
        true; // Default to true for offline-first
  }

  Future<void> saveOfflineModeEnabled(bool enabled) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_offlineModeKey, enabled);
  }
}
