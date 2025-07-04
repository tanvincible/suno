// flutter_app/lib/screens/translation/widgets/translation_display_card.dart
import 'package:flutter/material.dart';
import 'package:suno_app/theme/app_text_styles.dart';

class TranslationDisplayCard extends StatelessWidget {
  final String title;
  final String content;
  final Color backgroundColor;
  final Color textColor;
  final double? confidence;

  const TranslationDisplayCard({
    super.key,
    required this.title,
    required this.content,
    required this.backgroundColor,
    required this.textColor,
    this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: backgroundColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.caption.copyWith(
                color: textColor.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: AppTextStyles.bodyText.copyWith(color: textColor),
            ),
            if (confidence != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Confidence: ${(confidence! * 100).toStringAsFixed(0)}%',
                  style: AppTextStyles.caption.copyWith(
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
