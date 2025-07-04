// flutter_app/lib/screens/home/widgets/language_selector_widget.dart
import 'package:flutter/material.dart';
import 'package:suno_app/models/language.dart';
import 'package:suno_app/theme/app_text_styles.dart';

class LanguageSelectorWidget extends StatelessWidget {
  final String label;
  final Language selectedLanguage;
  final ValueChanged<Language?> onChanged;

  const LanguageSelectorWidget({
    super.key,
    required this.label,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.bodyText),
        const SizedBox(height: 8),
        DropdownButton<Language>(
          value: selectedLanguage,
          onChanged: onChanged,
          items: Language.values.map((lang) {
            return DropdownMenuItem<Language>(
              value: lang,
              child: Text(lang.displayName, style: AppTextStyles.subheading),
            );
          }).toList(),
          underline: Container(), // Remove default underline
          icon: Icon(
            Icons.arrow_drop_down,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }
}
