// flutter_app/lib/screens/translation/widgets/audio_visualizer_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:suno_app/theme/app_colors.dart';
import 'package:suno_app/theme/app_text_styles.dart';

class AudioVisualizerWidget extends StatelessWidget {
  final bool isProcessing;
  // Potentially add List<double> audioLevels for a more dynamic visualizer

  const AudioVisualizerWidget({super.key, required this.isProcessing});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: isProcessing
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Simple pulsating dots for processing
                  _buildPulseDot(context, 0),
                  _buildPulseDot(context, 1),
                  _buildPulseDot(context, 2),
                ],
              )
            : Text(
                'Audio input processed.',
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.darkText.withOpacity(0.6),
                ),
              ),
      ),
    );
  }

  Widget _buildPulseDot(BuildContext context, int delayMultiplier) {
    return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.8, end: 1.2),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
          // This makes the animation repeat with a slight delay for each dot
          // For actual production, consider using `flutter_animate` for more control
          // or a dedicated package for audio visualization.
          child: Container(),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .slide(
          begin: const Offset(0, -0.1),
          end: const Offset(0, 0.1),
          duration: 1.seconds,
          curve: Curves.easeInOut,
        )
        .then(delay: (200 * delayMultiplier).ms); // Staggered animation
  }
}
