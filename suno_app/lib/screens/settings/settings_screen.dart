// flutter_app/lib/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:suno_app/models/language.dart';
import 'package:suno_app/screens/settings/settings_viewmodel.dart';
import 'package:suno_app/theme/app_text_styles.dart';
import 'package:suno_app/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(
        settingsRepository: Provider.of(context, listen: false),
        modelManagementService: Provider.of(context, listen: false),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Settings', style: AppTextStyles.appBarTitle),
        ),
        body: Consumer<SettingsViewModel>(
          builder: (context, viewModel, child) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSectionHeader('General'),
                ListTile(
                  title: const Text('Default Source Language'),
                  trailing: DropdownButton<Language>(
                    value: viewModel.sourceLanguage,
                    onChanged: (lang) => viewModel.setSourceLanguage(lang!),
                    items: Language.values.map((lang) {
                      return DropdownMenuItem<Language>(
                        value: lang,
                        child: Text(lang.displayName),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  title: const Text('Default Target Language'),
                  trailing: DropdownButton<Language>(
                    value: viewModel.targetLanguage,
                    onChanged: (lang) => viewModel.setTargetLanguage(lang!),
                    items: Language.values.map((lang) {
                      return DropdownMenuItem<Language>(
                        value: lang,
                        child: Text(lang.displayName),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  title: const Text('Offline Mode (Auto)'),
                  trailing: Switch(
                    value: viewModel.offlineModeEnabled,
                    onChanged: viewModel.setOfflineMode,
                    activeColor: AppColors.primary,
                  ),
                ),
                const Divider(),
                _buildSectionHeader('AI Models'),
                ListTile(
                  title: const Text('Gemma 3N Model Status'),
                  subtitle: Text(viewModel.modelStatus),
                  trailing: viewModel.isCheckingModels
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : (viewModel.areModelsDownloaded
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : Icon(Icons.warning, color: Colors.amber)),
                ),
                ListTile(
                  title: const Text('Check for Model Updates'),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checking for updates...')),
                    );
                    await viewModel.checkForModelUpdates();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(viewModel.modelStatus)),
                    );
                  },
                ),
                ListTile(
                  title: const Text('Clear Downloaded Models'),
                  subtitle: const Text(
                    'Frees up device storage (requires re-download)',
                  ),
                  onTap: () async {
                    final confirm = await _showConfirmDialog(
                      context,
                      'Clear Models?',
                      'Are you sure you want to delete all downloaded AI models?',
                    );
                    if (confirm ?? false) {
                      await viewModel.clearModels();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Models cleared.')),
                      );
                    }
                  },
                ),
                const Divider(),
                _buildSectionHeader('About'),
                ListTile(
                  title: const Text('Version'),
                  trailing: Text(viewModel.appVersion),
                ),
                ListTile(
                  title: const Text('Privacy Policy'),
                  onTap: () {
                    // Navigate to privacy policy
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: AppTextStyles.subheading.copyWith(color: AppColors.primary),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(
    BuildContext context,
    String title,
    String content,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
