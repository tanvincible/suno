class TranslationResult {
  final String original;
  final String translated;
  final double confidence; // 0.0 to 1.0

  TranslationResult({
    required this.original,
    required this.translated,
    required this.confidence,
  });
}
