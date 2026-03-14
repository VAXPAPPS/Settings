import 'package:flutter/material.dart';

class VolumeSlider extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final int max;
  final bool muted;
  final ValueChanged<int> onChanged;
  final VoidCallback? onMuteToggle;

  const VolumeSlider({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.max = 100,
    this.muted = false,
    required this.onChanged,
    this.onMuteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: muted ? Colors.red : Colors.white70),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$value%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: muted
                    ? Colors.grey
                    : (value > 100 ? Colors.orange : Colors.white),
              ),
            ),
            if (onMuteToggle != null) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  muted ? Icons.volume_off : Icons.volume_up,
                  color: muted ? Colors.red : Colors.white54,
                  size: 20,
                ),
                onPressed: onMuteToggle,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 4,
            activeTrackColor: muted
                ? Colors.grey
                : (value > 100 ? Colors.orange : Colors.blueAccent),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            thumbColor: Colors.white,
            overlayShape: SliderComponentShape.noOverlay,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.toDouble().clamp(0, max.toDouble()),
            min: 0,
            max: max.toDouble(),
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
      ],
    );
  }
}
