// flutter_app/lib/theme/app_text_styles.dart
import 'package:flutter/material.dart';
import 'package:suno_app/theme/app_colors.dart';

class AppTextStyles {
  static const String _fontFamily = 'Roboto'; // Or choose your desired font

  static const TextStyle appBarTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.onPrimary,
  );

  static const TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.darkText,
  );

  static const TextStyle subheading = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.darkText,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.darkText,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.onPrimary,
  );
}
