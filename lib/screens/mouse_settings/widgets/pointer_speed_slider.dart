import 'package:flutter/material.dart';

class PointerSpeedSlider extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final ValueChanged<double> onChanged;

  const PointerSpeedSlider({
    super.key,
    required this.label,
    required this.value,
    this.max = 1.0,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Text(
              'Slow',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderThemeData(
                  trackHeight: 4,
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                  thumbColor: Colors.white,
                  overlayShape: SliderComponentShape.noOverlay,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 8,
                  ),
                ),
                child: Slider(
                  value: value.clamp(0.0, max),
                  min: 0,
                  max: max,
                  onChanged: onChanged,
                ),
              ),
            ),
            const Text(
              'Fast',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}
