// package:suno_app/services/audio_service.dart
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:record/record.dart'; // From pubspec.yaml: record: ^5.0.0
import 'package:path_provider/path_provider.dart'; // From pubspec.yaml: path_provider: ^2.0.0

/// A service class responsible for handling audio recording.
class AudioService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _currentRecordingPath;
  int _sampleRate = 16000; // Default sample rate, common for speech processing

  // Constants for audio processing
  static const int _wavHeaderSize = 44;
  static const int _bytesPerSample = 2; // 16-bit audio
  static const int _maxInt16 = 32767;

  /// Gets the sample rate currently used for recording.
  int get sampleRate => _sampleRate;

  /// Sets the sample rate for recording.
  /// Must be called before starting recording.
  void setSampleRate(int sampleRate) {
    if (sampleRate <= 0) {
      throw ArgumentError('Sample rate must be positive');
    }
    _sampleRate = sampleRate;
  }

  /// Starts recording audio.
  ///
  /// Throws an exception if microphone permission is not granted or recording fails.
  Future<void> startRecording() async {
    try {
      // Check if already recording
      if (await _audioRecorder.isRecording()) {
        throw Exception('Already recording. Stop current recording first.');
      }

      // Check permissions
      if (!await _audioRecorder.hasPermission()) {
        throw Exception('Microphone permission not granted.');
      }

      // Create recording path
      final directory = await getTemporaryDirectory();
      _currentRecordingPath =
          '${directory.path}/suno_audio_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Start recording with validated parameters
      await _audioRecorder.start(
        RecordConfig(
          encoder: AudioEncoder.wav, // Using WAV for raw PCM data
          bitRate: 128000, // Example bit rate
          sampleRate: _sampleRate, // Use the configured sample rate
          numChannels:
              1, // Mono audio is generally sufficient for ASR/translation
        ),
        path: _currentRecordingPath!,
      );

      debugPrint('Recording started to: $_currentRecordingPath');
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _currentRecordingPath = null; // Reset path on error
      rethrow; // Re-throw to be handled by the calling ViewModel/UI
    }
  }

  /// Stops the current audio recording and returns the recorded audio data as Float32List.
  ///
  /// Returns `null` if no recording was in progress or if an error occurred.
  Future<Float32List?> stopRecording() async {
    if (!await _audioRecorder.isRecording()) {
      debugPrint('No recording in progress to stop.');
      return null;
    }

    try {
      final path = await _audioRecorder.stop();
      debugPrint('Recording stopped. File saved to: $path');

      if (path == null) {
        debugPrint('Recording path is null');
        return null;
      }

      final audioFile = File(path);
      if (!await audioFile.exists()) {
        debugPrint('Audio file does not exist: $path');
        return null;
      }

      // Read and process the audio file
      final Float32List? audioData = await _processAudioFile(audioFile);

      // Clean up the temporary recording file
      await _cleanupFile(audioFile);
      _currentRecordingPath = null;

      return audioData;
    } catch (e) {
      debugPrint('Error stopping recording or processing audio: $e');
      await _cleanupCurrentRecording();
      return null;
    }
  }

  /// Processes the WAV audio file and converts it to Float32List.
  Future<Float32List?> _processAudioFile(File audioFile) async {
    try {
      final bytes = await audioFile.readAsBytes();

      // Validate WAV file size
      if (bytes.length < _wavHeaderSize) {
        debugPrint(
          'WAV file too small (${bytes.length} bytes), likely corrupted or not a valid WAV.',
        );
        return null;
      }

      // Validate WAV header (basic check)
      if (!_isValidWavFile(bytes)) {
        debugPrint('Invalid WAV file format');
        return null;
      }

      // Extract audio data
      final ByteData byteData = ByteData.view(bytes.buffer, _wavHeaderSize);
      final int numSamples = byteData.lengthInBytes ~/ _bytesPerSample;

      if (numSamples == 0) {
        debugPrint('No audio samples found in file');
        return null;
      }

      // Convert to Float32List with proper normalization
      final Float32List floatData = Float32List(numSamples);

      for (int i = 0; i < numSamples; i++) {
        final int sample = byteData.getInt16(
          i * _bytesPerSample,
          Endian.little,
        );
        // Normalize Int16 sample to Float32 (-1.0 to 1.0)
        // Using proper normalization to avoid clipping
        floatData[i] = sample / _maxInt16;
      }

      debugPrint('Processed ${floatData.length} audio samples');
      return floatData;
    } catch (e) {
      debugPrint('Error processing audio file: $e');
      return null;
    }
  }

  /// Basic WAV file validation by checking the header.
  bool _isValidWavFile(Uint8List bytes) {
    if (bytes.length < 12) return false;

    // Check for "RIFF" at the beginning
    final riffCheck =
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46;

    // Check for "WAVE" at offset 8
    final waveCheck =
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45;

    return riffCheck && waveCheck;
  }

  /// Safely deletes a file with error handling.
  Future<void> _cleanupFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        debugPrint('Cleaned up audio file: ${file.path}');
      }
    } catch (e) {
      debugPrint('Error cleaning up file ${file.path}: $e');
    }
  }

  /// Cleans up the current recording file.
  Future<void> _cleanupCurrentRecording() async {
    if (_currentRecordingPath != null) {
      await _cleanupFile(File(_currentRecordingPath!));
      _currentRecordingPath = null;
    }
  }

  /// Checks if the audio recorder is currently recording.
  Future<bool> isRecording() async {
    return _audioRecorder.isRecording();
  }

  /// Cancels the current recording without returning audio data.
  Future<void> cancelRecording() async {
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.cancel();
      debugPrint('Recording cancelled');
    }
    await _cleanupCurrentRecording();
  }

  /// Gets the current recording path if recording is in progress.
  String? get currentRecordingPath => _currentRecordingPath;

  /// Disposes of the audio recorder resources.
  Future<void> dispose() async {
    if (await _audioRecorder.isRecording()) {
      await _audioRecorder.cancel();
    }

    await _cleanupCurrentRecording();
    _audioRecorder.dispose();
    debugPrint('AudioService disposed.');
  }
}
