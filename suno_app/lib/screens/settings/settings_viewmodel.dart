// flutter_app/lib/screens/settings/settings_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:suno_app/data/repositories/settings_repository.dart';
import 'package:suno_app/models/language.dart';
import 'package:suno_app/services/model_management_service.dart';

class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;
  final ModelManagementService _modelManagementService;

  Language _sourceLanguage = Language.english;
  Language _targetLanguage = Language.spanish;
  bool _offlineModeEnabled = true;
  String _appVersion =
      '1.0.0'; // In a real app, fetch from pubspec.yaml or build config
  bool _areModelsDownloaded = false;
  bool _isCheckingModels = false;
  String _modelStatus = 'Checking...';

  Language get sourceLanguage => _sourceLanguage;
  Language get targetLanguage => _targetLanguage;
  bool get offlineModeEnabled => _offlineModeEnabled;
  String get appVersion => _appVersion;
  bool get areModelsDownloaded => _areModelsDownloaded;
  bool get isCheckingModels => _isCheckingModels;
  String get modelStatus => _modelStatus;

  SettingsViewModel({
    required SettingsRepository settingsRepository,
    required ModelManagementService modelManagementService,
  }) : _settingsRepository = settingsRepository,
       _modelManagementService = modelManagementService {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _sourceLanguage = await _settingsRepository.getSourceLanguage();
    _targetLanguage = await _settingsRepository.getTargetLanguage();
    _offlineModeEnabled = await _settingsRepository.getOfflineModeEnabled();
    await _checkModelStatus(); // Initial check
    notifyListeners();
  }

  Future<void> _checkModelStatus() async {
    _isCheckingModels = true;
    notifyListeners();
    _areModelsDownloaded = await _modelManagementService.areModelsDownloaded();
    _modelStatus = _areModelsDownloaded
        ? 'Gemma 3N models are ready for offline use.'
        : 'Models not downloaded. Please download from Onboarding or Home screen.';
    _isCheckingModels = false;
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

  void setOfflineMode(bool enabled) {
    _offlineModeEnabled = enabled;
    _settingsRepository.saveOfflineModeEnabled(enabled);
    notifyListeners();
  }

  Future<void> checkForModelUpdates() async {
    _isCheckingModels = true;
    _modelStatus = 'Checking for updates...';
    notifyListeners();
    final updated = await _modelManagementService.checkForUpdates();
    if (updated) {
      _modelStatus = 'Models updated successfully!';
      _areModelsDownloaded =
          true; // Assume successful update means they are downloaded
    } else {
      _modelStatus = _areModelsDownloaded
          ? 'Models are up to date.'
          : 'Models not found, please download.';
    }
    _isCheckingModels = false;
    notifyListeners();
  }

  Future<void> clearModels() async {
    _isCheckingModels = true;
    _modelStatus = 'Clearing models...';
    notifyListeners();
    await _modelManagementService.clearModels();
    _areModelsDownloaded = false;
    _modelStatus = 'Models cleared. Re-download required.';
    _isCheckingModels = false;
    notifyListeners();
  }
}
