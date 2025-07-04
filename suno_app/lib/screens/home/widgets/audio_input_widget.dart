// flutter_app/lib/screens/home/widgets/audio_input_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:suno_app/theme/app_colors.dart';

class AudioInputWidget extends StatelessWidget {
  final bool isRecording;
  final VoidCallback onToggleRecord;

  const AudioInputWidget({
    super.key,
    required this.isRecording,
    required this.onToggleRecord,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggleRecord,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: isRecording ? 120 : 100,
        height: isRecording ? 120 : 100,
        decoration: BoxDecoration(
          color: isRecording ? AppColors.accent : AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: isRecording
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 10,
                  ),
                ]
              : [],
        ),
        child: isRecording
            ? Center(
                    child: Icon(
                      Icons.stop_rounded,
                      color: Colors.white,
                      size: 50,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .scaleXY(
                    duration: 1.seconds,
                    begin: 0.9,
                    end: 1.0,
                    curve: Curves.easeInOutBack,
                  )
                  .then(delay: 0.5.seconds)
                  .scaleXY(
                    duration: 1.seconds,
                    begin: 1.0,
                    end: 0.9,
                    curve: Curves.easeInOutBack,
                  )
            : const Center(
                child: Icon(Icons.mic_rounded, color: Colors.white, size: 50),
              ),
      ),
    );
  }
}
