// flutter_app/lib/screens/translation/translation_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suno_app/screens/translation/translation_viewmodel.dart';
import 'package:suno_app/screens/translation/widgets/translation_display_card.dart';
import 'package:suno_app/screens/translation/widgets/audio_visualizer_widget.dart';
import 'package:suno_app/theme/app_colors.dart';
import 'package:suno_app/theme/app_text_styles.dart';

class TranslationScreen extends StatelessWidget {
  const TranslationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TranslationViewModel(
        translationService: Provider.of(context, listen: false),
      )..processAudio(), // Start processing immediately
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Translation', style: AppTextStyles.appBarTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Consumer<TranslationViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  AudioVisualizerWidget(
                    isProcessing: viewModel.isProcessing,
                    // You might pass audio levels here if available from AudioService
                  ),
                  const SizedBox(height: 24),
                  if (viewModel.isProcessing)
                    Column(
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.statusMessage,
                          style: AppTextStyles.subheading,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    )
                  else if (viewModel.translationResult != null)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TranslationDisplayCard(
                              title:
                                  'Original (${viewModel.sourceLanguage.displayName})',
                              content: viewModel.translationResult!.original,
                              backgroundColor: AppColors.lightGray,
                              textColor: AppColors.darkText,
                            ),
                            const SizedBox(height: 24),
                            TranslationDisplayCard(
                              title:
                                  'Translated (${viewModel.targetLanguage.displayName})',
                              content: viewModel.translationResult!.translated,
                              backgroundColor: AppColors.primary.withOpacity(
                                0.1,
                              ),
                              textColor: AppColors.primary,
                              confidence:
                                  viewModel.translationResult!.confidence,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (viewModel.errorMessage != null)
                    Text(
                      'Error: ${viewModel.errorMessage}',
                      style: AppTextStyles.bodyText.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  const Spacer(),
                  if (!viewModel.isProcessing &&
                      viewModel.translationResult != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton.extended(
                          heroTag: 'copy_original',
                          onPressed: () {
                            // Copy original text
                          },
                          label: const Text('Copy Original'),
                          icon: const Icon(Icons.copy),
                          backgroundColor: AppColors.primary.withOpacity(0.8),
                        ),
                        FloatingActionButton.extended(
                          heroTag: 'copy_translated',
                          onPressed: () {
                            // Copy translated text
                          },
                          label: const Text('Copy Translated'),
                          icon: const Icon(Icons.copy),
                          backgroundColor: AppColors.accent,
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
