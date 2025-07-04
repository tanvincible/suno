// flutter_app/lib/screens/onboarding/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suno_app/services/permissions_service.dart';
import 'package:suno_app/services/model_management_service.dart';
import 'package:suno_app/shared/widgets/primary_button.dart';
import 'package:suno_app/theme/app_colors.dart';
import 'package:suno_app/theme/app_text_styles.dart';
import 'dart:io' show Platform; // Import for platform checks

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  bool _microphonePermissionGranted = false;
  bool _storagePermissionGranted = false;
  double _modelDownloadProgress = 0.0;
  String _downloadStatus = 'Initializing...';
  bool _isDownloading = false;

  // Added for temporary bypass
  bool _bypassPermissions = false;

  @override
  void initState() {
    super.initState();
    // Determine if we are on a desktop platform (Linux, Windows, macOS)
    // where permissions might be handled differently or we want to bypass for dev
    _bypassPermissions =
        (Platform.isLinux || Platform.isWindows || Platform.isMacOS);

    _checkPermissionsAndModels();
  }

  Future<void> _checkPermissionsAndModels() async {
    final permissionService = Provider.of<PermissionsService>(
      context,
      listen: false,
    );
    final modelService = Provider.of<ModelManagementService>(
      context,
      listen: false,
    );

    if (_bypassPermissions) {
      // If bypassing, assume permissions are granted for dev purposes
      _microphonePermissionGranted = true;
      _storagePermissionGranted = true;
    } else {
      _microphonePermissionGranted = await permissionService
          .checkMicrophonePermission();
      _storagePermissionGranted = await permissionService
          .checkStoragePermission();
    }

    // Check if models are already downloaded
    if (await modelService.areModelsDownloaded()) {
      _modelDownloadProgress = 1.0;
      _downloadStatus = 'Models ready!';
    }

    setState(() {});
  }

  Future<void> _requestPermissions() async {
    final permissionService = Provider.of<PermissionsService>(
      context,
      listen: false,
    );

    if (_bypassPermissions) {
      // For bypass mode, just set to true
      _microphonePermissionGranted = true;
      _storagePermissionGranted = true;
    } else {
      _microphonePermissionGranted = await permissionService
          .requestMicrophonePermission();
      _storagePermissionGranted = await permissionService
          .requestStoragePermission();
    }
    setState(() {});
  }

  Future<void> _downloadModels() async {
    setState(() {
      _isDownloading = true;
      _downloadStatus = 'Downloading Gemma 3N and Whisper models...';
    });
    final modelService = Provider.of<ModelManagementService>(
      context,
      listen: false,
    );
    await modelService.downloadModels(
      onProgress: (progress, message) {
        setState(() {
          _modelDownloadProgress = progress;
          _downloadStatus = message;
        });
      },
    );
    setState(() {
      _isDownloading = false;
      _downloadStatus = 'Models downloaded successfully!';
    });
  }

  // _canProceed logic now incorporates the bypass for permissions
  bool get _canProceed {
    if (_bypassPermissions) {
      // If bypassing permissions, only model download is the gate
      return _modelDownloadProgress == 1.0;
    } else {
      // Original logic for mobile
      return _microphonePermissionGranted &&
          _storagePermissionGranted &&
          _modelDownloadProgress == 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // Suno Logo/Icon
            Icon(Icons.mic_rounded, size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Welcome to Suno',
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your real-time audio translation companion. Experience seamless communication.',
              style: AppTextStyles.bodyText,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            _buildPermissionStatus(
              'Microphone Access',
              _microphonePermissionGranted,
              'Allows Suno to listen to your voice for translation.',
            ),
            const SizedBox(height: 16),
            _buildPermissionStatus(
              'Storage Access',
              _storagePermissionGranted,
              'Required to store AI models (Gemma 3n, Whisper) on your device for offline use.',
            ),
            const SizedBox(height: 24),
            // Conditionally show Grant Permissions button or bypass message
            if (!(_microphonePermissionGranted && _storagePermissionGranted) &&
                !_bypassPermissions)
              PrimaryButton(
                text: 'Grant Permissions',
                onPressed: _requestPermissions,
              )
            else if (_bypassPermissions &&
                !(_microphonePermissionGranted && _storagePermissionGranted))
              // This case handles the UI when we are bypassing but still need to show the state
              Column(
                children: [
                  Text(
                    'Permissions bypassed for development on desktop.',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Optionally, a button to explicitly "simulate" granting
                  PrimaryButton(
                    text: 'Simulate Permissions Granted (Dev)',
                    onPressed: () {
                      setState(() {
                        _microphonePermissionGranted = true;
                        _storagePermissionGranted = true;
                      });
                    },
                  ),
                ],
              )
            else if (_modelDownloadProgress < 1.0)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _modelDownloadProgress,
                    backgroundColor: AppColors.lightGray,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _downloadStatus,
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  if (!_isDownloading)
                    PrimaryButton(
                      text: 'Download Models',
                      onPressed: _downloadModels,
                    ),
                ],
              )
            else
              PrimaryButton(
                text: 'Get Started',
                onPressed: _canProceed
                    ? () => Navigator.pushReplacementNamed(context, '/home')
                    : null,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatus(
    String title,
    bool granted,
    String description,
  ) {
    return Row(
      children: [
        Icon(
          granted ? Icons.check_circle : Icons.info_outline,
          color: granted ? Colors.green : AppColors.secondary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.subheading.copyWith(
                  color: granted ? AppColors.darkText : AppColors.secondary,
                ),
              ),
              Text(description, style: AppTextStyles.caption),
            ],
          ),
        ),
      ],
    );
  }
}
