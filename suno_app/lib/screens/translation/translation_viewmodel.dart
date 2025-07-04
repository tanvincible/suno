// flutter_app/lib/screens/translation/translation_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:suno_app/models/language.dart';
import 'package:suno_app/models/translation_result.dart';
import 'package:suno_app/services/translation_service.dart';

class TranslationViewModel extends ChangeNotifier {
  final TranslationService _translationService;

  TranslationResult? _translationResult;
  bool _isProcessing = false;
  String _statusMessage = 'Initializing translation engine...';
  String? _errorMessage;
  Language _sourceLanguage = Language.english; // Will be set by service
  Language _targetLanguage = Language.spanish; // Will be set by service

  TranslationResult? get translationResult => _translationResult;
  bool get isProcessing => _isProcessing;
  String get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  Language get sourceLanguage => _sourceLanguage;
  Language get targetLanguage => _targetLanguage;

  TranslationViewModel({required TranslationService translationService})
    : _translationService = translationService;

  Future<void> processAudio() async {
    _isProcessing = true;
    _statusMessage = 'Preparing for translation with Gemma 3N...';
    _errorMessage = null;
    notifyListeners();

    try {
      _sourceLanguage = _translationService.currentSourceLanguage;
      _targetLanguage = _translationService.currentTargetLanguage;

      // Initialize the Rust core first if not already done
      // This should ideally happen once per app lifecycle or when languages change
      if (!_translationService.isInitialized) {
        _statusMessage = 'Loading AI models... This might take a moment.';
        notifyListeners();
        await _translationService.initialize(
          sourceLang: _sourceLanguage.code,
          targetLang: _targetLanguage.code,
        );
      }

      _statusMessage = 'Analyzing audio with Whisper...';
      notifyListeners();

      final result = await _translationService
          .processQueuedAudio(); // This will use the audio data set previously
      _translationResult = result;

      if (_translationResult != null) {
        _statusMessage = 'Translation complete!';
      } else {
        _errorMessage = 'No translation result received.';
      }
    } catch (e) {
      _errorMessage = 'Translation failed: ${e.toString()}';
      _statusMessage = 'An error occurred.';
      debugPrint('Translation error: $e');
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
