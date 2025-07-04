// flutter_app/lib/screens/home/home_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:suno_app/models/language.dart';
import 'package:suno_app/services/audio_service.dart';
import 'package:suno_app/services/translation_service.dart'; // To pass audio data later
import 'package:suno_app/data/repositories/settings_repository.dart'; // To load/save selected languages

class HomeViewModel extends ChangeNotifier {
  final AudioService _audioService;
  final TranslationService _translationService;
  final SettingsRepository _settingsRepository;

  bool _isRecording = false;
  Language _sourceLanguage = Language.english; // Default
  Language _targetLanguage = Language.spanish; // Default

  HomeViewModel({
    AudioService? audioService,
    TranslationService? translationService,
    SettingsRepository? settingsRepository,
  }) : _audioService = audioService ?? AudioService(),
       _translationService = translationService ?? TranslationService(),
       _settingsRepository = settingsRepository ?? SettingsRepository() {
    _loadInitialLanguages();
  }

  bool get isRecording => _isRecording;
  Language get sourceLanguage => _sourceLanguage;
  Language get targetLanguage => _targetLanguage;

  Future<void> _loadInitialLanguages() async {
    _sourceLanguage = await _settingsRepository.getSourceLanguage();
    _targetLanguage = await _settingsRepository.getTargetLanguage();
    notifyListeners();
  }

  void setSourceLanguage(Language lang) {
    _sourceLanguage = lang;
    _settingsRepository.saveSourceLanguage(lang);
    notifyListeners();
  }

  void setTargetLanguage(Language lang) {
    _targetLanguage = lang;
    _settingsRepository.saveTargetLanguage(lang);
    notifyListeners();
  }

  Future<void> startRecording() async {
    _isRecording = true;
    notifyListeners();
    await _audioService.startRecording();
    // Potentially, initialize the Rust pipeline here or on app start.
    // await _translationService.initialize(sourceLang: _sourceLanguage.code, targetLang: _targetLanguage.code);
  }

  Future<void> stopRecording() async {
    _isRecording = false;
    notifyListeners();
    final audioData = await _audioService.stopRecording();
    if (audioData != null) {
      // In a real streaming scenario, chunks would be sent continuously.
      // For MVP, we stop, then process the whole chunk.
      // This part would be expanded to handle real-time audio streams.
      // Navigator will push to translation screen, which will then consume this data
      _translationService.setAudioDataForProcessing(
        audioData,
        _audioService.sampleRate,
      );
      _translationService.setLanguages(_sourceLanguage, _targetLanguage);
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }
}
