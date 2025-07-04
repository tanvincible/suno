// flutter_app/lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suno_app/screens/home/home_viewmodel.dart';
import 'package:suno_app/screens/home/widgets/audio_input_widget.dart';
import 'package:suno_app/screens/home/widgets/language_selector_widget.dart';
import 'package:suno_app/theme/app_colors.dart';
import 'package:suno_app/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Suno', style: AppTextStyles.appBarTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
          ],
        ),
        body: Consumer<HomeViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text('Tap to translate', style: AppTextStyles.subheading),
                  const SizedBox(height: 32),
                  AudioInputWidget(
                    isRecording: viewModel.isRecording,
                    onToggleRecord: () {
                      if (viewModel.isRecording) {
                        viewModel.stopRecording();
                        Navigator.pushNamed(
                          context,
                          '/translation',
                        ); // Navigate to translation screen
                      } else {
                        viewModel.startRecording();
                      }
                    },
                  ),
                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      LanguageSelectorWidget(
                        label: 'From',
                        selectedLanguage: viewModel.sourceLanguage,
                        onChanged: (lang) => viewModel.setSourceLanguage(lang!),
                      ),
                      Icon(
                        Icons.compare_arrows,
                        color: AppColors.primary,
                        size: 30,
                      ),
                      LanguageSelectorWidget(
                        label: 'To',
                        selectedLanguage: viewModel.targetLanguage,
                        onChanged: (lang) => viewModel.setTargetLanguage(lang!),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
