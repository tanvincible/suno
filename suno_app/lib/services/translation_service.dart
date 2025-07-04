import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:suno_app/models/translation_result.dart';
import 'package:suno_app/models/language.dart';

// FFI bindings (auto-generated) - unchanged from your example, assuming ffigen works
typedef SunoInitC =
    Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);
typedef SunoInit =
    int Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>);

typedef SunoProcessAudioC =
    Int32 Function(Pointer<FFIAudioChunk>, Pointer<FFITranslation>);
typedef SunoProcessAudio =
    int Function(Pointer<FFIAudioChunk>, Pointer<FFITranslation>);

typedef SunoFreeStringC = Void Function(Pointer<Utf8>);
typedef SunoFreeString = void Function(Pointer<Utf8>);

typedef SunoCleanupC = Void Function();
typedef SunoCleanup = void Function();

// FFI structs - unchanged
final class FFIAudioChunk extends Struct {
  external Pointer<Float> data;
  @Size()
  external int length;
  @Uint32()
  external int sampleRate;
  @Uint16()
  external int channels;
}

final class FFITranslation extends Struct {
  external Pointer<Utf8> original;
  external Pointer<Utf8> translated;
  @Float()
  external double confidence;
}

class TranslationService {
  late DynamicLibrary _dylib;
  late SunoInit _sunoInit;
  late SunoProcessAudio _sunoProcessAudio;
  late SunoFreeString _sunoFreeString;
  late SunoCleanup _sunoCleanup;

  bool _isInitialized = false;
  Float32List? _queuedAudioData;
  int? _queuedSampleRate;
  Language _currentSourceLanguage = Language.english; // Default
  Language _currentTargetLanguage = Language.spanish; // Default

  bool get isInitialized => _isInitialized;
  Language get currentSourceLanguage => _currentSourceLanguage;
  Language get currentTargetLanguage => _currentTargetLanguage;

  // Method to set audio data for processing later
  void setAudioDataForProcessing(Float32List audioData, int sampleRate) {
    _queuedAudioData = audioData;
    _queuedSampleRate = sampleRate;
  }

  void setLanguages(Language source, Language target) {
    _currentSourceLanguage = source;
    _currentTargetLanguage = target;
  }

  Future<void> initialize({
    required String sourceLang,
    required String targetLang,
  }) async {
    if (_isInitialized) return; // Prevent re-initialization

    // Load the dynamic library
    if (Platform.isAndroid) {
      _dylib = DynamicLibrary.open('libsuno_core.so');
    } else if (Platform.isIOS) {
      _dylib = DynamicLibrary.process(); // iOS bundles static libs
    } else {
      throw UnsupportedError('Platform not supported');
    }

    // Bind functions
    _sunoInit = _dylib
        .lookup<NativeFunction<SunoInitC>>('suno_init')
        .asFunction();
    _sunoProcessAudio = _dylib
        .lookup<NativeFunction<SunoProcessAudioC>>('suno_process_audio')
        .asFunction();
    _sunoFreeString = _dylib
        .lookup<NativeFunction<SunoFreeStringC>>('suno_free_string')
        .asFunction();
    _sunoCleanup = _dylib
        .lookup<NativeFunction<SunoCleanupC>>('suno_cleanup')
        .asFunction();

    // Get model paths
    final appDir = await getApplicationDocumentsDirectory();
    // Assuming Gemma 3N will be downloaded as a .bin file
    final whisperPath = '${appDir.path}/models/whisper-small-q4.bin';
    final gemmaPath =
        '${appDir.path}/models/gemma-2b-it-q4.bin'; // Or gemma-4b-it-q4.bin if selected

    // Initialize Rust core
    final whisperPathPtr = whisperPath.toNativeUtf8();
    final gemmaPathPtr = gemmaPath.toNativeUtf8();
    final sourceLangPtr = sourceLang.toNativeUtf8();
    final targetLangPtr = targetLang.toNativeUtf8();

    final result = _sunoInit(
      whisperPathPtr,
      gemmaPathPtr,
      sourceLangPtr,
      targetLangPtr,
    );

    malloc.free(whisperPathPtr);
    malloc.free(gemmaPathPtr);
    malloc.free(sourceLangPtr);
    malloc.free(targetLangPtr);

    if (result == 0) {
      _isInitialized = true;
    } else {
      throw Exception('Failed to initialize Suno core. Error code: $result');
    }
  }

  Future<TranslationResult?> processQueuedAudio() async {
    if (!_isInitialized) {
      throw Exception(
        'TranslationService not initialized. Call initialize() first.',
      );
    }
    if (_queuedAudioData == null || _queuedSampleRate == null) {
      throw Exception('No audio data queued for processing.');
    }

    final audioData = _queuedAudioData!;
    final sampleRate = _queuedSampleRate!;

    // Allocate memory for audio data
    final audioPtr = malloc.allocate<Float>(audioData.length * sizeOf<Float>());
    final audioList = audioPtr.asTypedList(audioData.length);
    audioList.setAll(0, audioData);

    // Create FFI audio chunk
    final audioChunk = malloc.allocate<FFIAudioChunk>(sizeOf<FFIAudioChunk>());
    audioChunk.ref.data = audioPtr;
    audioChunk.ref.length = audioData.length;
    audioChunk.ref.sampleRate = sampleRate;
    audioChunk.ref.channels = 1; // Assuming mono audio

    // Allocate result structure
    final result = malloc.allocate<FFITranslation>(sizeOf<FFITranslation>());

    // Call Rust function
    final status = _sunoProcessAudio(audioChunk, result);

    TranslationResult? translationResult;
    if (status == 0) {
      final original = result.ref.original.toDartString();
      final translated = result.ref.translated.toDartString();
      final confidence = result.ref.confidence;

      translationResult = TranslationResult(
        original: original,
        translated: translated,
        confidence: confidence,
      );

      // Free Rust-allocated strings
      _sunoFreeString(result.ref.original);
      _sunoFreeString(result.ref.translated);
    } else {
      // Handle Rust errors more gracefully, e.g., mapping error codes
      throw Exception('Rust core processing failed with status: $status');
    }

    // Free allocated memory
    malloc.free(audioPtr);
    malloc.free(audioChunk);
    malloc.free(result);

    // Clear queued audio after processing
    _queuedAudioData = null;
    _queuedSampleRate = null;

    return translationResult;
  }

  void dispose() {
    if (_isInitialized) {
      _sunoCleanup();
      _isInitialized = false;
    }
  }
}
