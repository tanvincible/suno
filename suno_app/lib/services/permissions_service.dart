// package:suno_app/services/permissions_service.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform; // Import for platform checks

/// A service class to handle requesting and checking application permissions.
class PermissionsService {
  /// Determines if the current platform is a desktop environment.
  /// Permissions often behave differently or are not strictly required on desktop.
  bool get _isDesktopPlatform {
    return Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  }

  /// Requests microphone permission if not already granted.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestMicrophonePermission() async {
    if (_isDesktopPlatform) {
      // On desktop, we bypass explicit permission requests for development ease.
      // Assume permission is "granted" for development purposes.
      debugPrint('Microphone permission bypassed for desktop platform.');
      return true;
    }

    // For mobile platforms, proceed with actual permission request
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Checks the current status of microphone permission.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> checkMicrophonePermission() async {
    if (_isDesktopPlatform) {
      // On desktop, we bypass explicit permission checks for development ease.
      debugPrint('Microphone permission check bypassed for desktop platform.');
      return true;
    }

    // For mobile platforms, proceed with actual permission check
    final status = await Permission.microphone.status;
    return status.isGranted;
  }

  /// Requests storage permission if not already granted.
  /// This is typically needed for saving and loading AI models locally.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> requestStoragePermission() async {
    if (_isDesktopPlatform) {
      // On desktop, we bypass explicit permission requests for development ease.
      debugPrint('Storage permission bypassed for desktop platform.');
      return true;
    }

    // On Android 10 (API 29) and above, apps use scoped storage,
    // which often doesn't require explicit storage permission for app-specific directories.
    // However, for broader compatibility and if models might be accessed by other parts
    // of the system or if you intend to save outside app-specific storage (less likely for models),
    // requesting it explicitly is safer.
    // For iOS, storage permission is generally not explicitly requested by apps
    // for their sandboxed directories.
    // This permission primarily targets Android < 11.

    if (await Permission.storage.isDenied) {
      final status = await Permission.storage.request();
      return status.isGranted;
    }
    return await Permission.storage.isGranted;
  }

  /// Checks the current status of storage permission.
  /// Returns `true` if permission is granted, `false` otherwise.
  Future<bool> checkStoragePermission() async {
    if (_isDesktopPlatform) {
      // On desktop, we bypass explicit permission checks for development ease.
      debugPrint('Storage permission check bypassed for desktop platform.');
      return true;
    }

    final status = await Permission.storage.status;
    return status.isGranted;
  }

  /// Opens the app settings to allow the user to manually grant permissions.
  /// Returns `true` if settings were opened, `false` otherwise.
  Future<bool> openAppSettings() async {
    // This method is also platform-specific and might not work on desktop.
    if (_isDesktopPlatform) {
      debugPrint('Cannot open app settings on desktop platform.');
      return false;
    }
    // Call the actual permission_handler method for mobile platforms
    return await openAppSettings();
  }
}
