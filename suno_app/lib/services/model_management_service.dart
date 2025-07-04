import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ModelManagementService {
  final List<String> _modelFileNames = [
    'whisper-small-q4.bin',
    'gemma-2b-it-q4.bin',
    // 'gemma-4b-it-q4.bin', // If you decide to offer different Gemma variants
  ];

  Future<String> _getModelPath(String fileName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return '${modelsDir.path}/$fileName';
  }

  Future<bool> areModelsDownloaded() async {
    for (String fileName in _modelFileNames) {
      final path = await _getModelPath(fileName);
      if (!await File(path).exists()) {
        return false;
      }
      // Optionally, add a checksum verification here for production
    }
    return true;
  }

  Future<void> downloadModels({
    Function(double progress, String message)? onProgress,
  }) async {
    final totalModels = _modelFileNames.length;
    for (int i = 0; i < totalModels; i++) {
      final fileName = _modelFileNames[i];
      final modelPath = await _getModelPath(fileName);
      final modelFile = File(modelPath);

      if (await modelFile.exists()) {
        onProgress?.call(
          (i + 1) / totalModels,
          'Model $fileName already exists.',
        );
        continue; // Skip if already downloaded
      }

      onProgress?.call(i / totalModels, 'Downloading $fileName...');

      // Replace with actual download URL for your models (e.g., from Hugging Face, your CDN)
      // This is a placeholder URL
      final String downloadUrl = 'https://your-cdn.com/models/$fileName';

      try {
        final request = http.Request('GET', Uri.parse(downloadUrl));
        final response = await request.send();

        if (response.statusCode == 200) {
          final contentLength = response.contentLength;
          int receivedBytes = 0;
          final List<int> bytes = [];

          await for (var chunk in response.stream) {
            bytes.addAll(chunk);
            receivedBytes += chunk.length;
            if (contentLength != null) {
              onProgress?.call(
                (i + (receivedBytes / contentLength)) / totalModels,
                'Downloading $fileName... (${(receivedBytes / (1024 * 1024)).toStringAsFixed(2)}MB / ${(contentLength / (1024 * 1024)).toStringAsFixed(2)}MB)',
              );
            }
          }
          await modelFile.writeAsBytes(bytes);
          onProgress?.call((i + 1) / totalModels, '$fileName downloaded!');
        } else {
          throw Exception(
            'Failed to download $fileName: ${response.statusCode}',
          );
        }
      } catch (e) {
        throw Exception('Error downloading $fileName: $e');
      }
    }
    onProgress?.call(1.0, 'All models downloaded successfully!');
  }

  Future<bool> checkForUpdates() async {
    // In a production app, this would involve checking a remote manifest/version file
    // e.g., fetch a JSON from your server that lists latest model versions and their checksums.
    // For this MVP, we'll just re-verify if files exist.
    return !await areModelsDownloaded(); // Simple check: if not all exist, consider an "update" needed.
  }

  Future<void> clearModels() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${appDir.path}/models');
    if (await modelsDir.exists()) {
      await modelsDir.delete(recursive: true);
    }
  }
}
