import 'package:settings/core/glassmorphic_container.dart';
import 'package:settings/screens/apps_settings/widgets/color_option.dart';
import 'package:flutter/material.dart';

class SystemTextColorSection extends StatelessWidget {
  final Color currentTextColor;
  final List<Color> presetColors;
  final ValueChanged<Color> onColorChanged;
  final VoidCallback onPickCustomColor;

  const SystemTextColorSection({
    super.key,
    required this.currentTextColor,
    required this.presetColors,
    required this.onColorChanged,
    required this.onPickCustomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Text Color',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphicContainer(
          width: double.infinity,
          height: 300,
          borderRadius: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Text Color Presets',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: presetColors
                      .map(
                        (color) => ColorOption(
                          color: color,
                          selectedColor: currentTextColor,
                          onTap: () => onColorChanged(color),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 24),
                const Divider(color: Colors.white24),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      'Custom Text Color:',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.color_lens),
                      label: const Text("Pick Custom Color"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTextColor,
                        foregroundColor:
                            currentTextColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: onPickCustomColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
