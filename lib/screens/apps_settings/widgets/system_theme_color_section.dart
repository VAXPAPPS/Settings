import 'package:settings/core/glassmorphic_container.dart';
import 'package:settings/screens/apps_settings/widgets/color_option.dart';
import 'package:flutter/material.dart';

class SystemThemeColorSection extends StatelessWidget {
  final Color currentColor;
  final double opacity;
  final List<Color> presetColors;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<double> onOpacityChanged;
  final VoidCallback onPickCustomColor;

  const SystemThemeColorSection({
    super.key,
    required this.currentColor,
    required this.opacity,
    required this.presetColors,
    required this.onColorChanged,
    required this.onOpacityChanged,
    required this.onPickCustomColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Theme Color',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        GlassmorphicContainer(
          width: double.infinity,
          height: 400,
          borderRadius: 8,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Preset Colors',
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
                          selectedColor: currentColor,
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
                      'Custom Color:',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.color_lens),
                      label: const Text("Pick Custom Color"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentColor,
                        foregroundColor: currentColor.computeLuminance() > 0.5
                            ? Colors.black
                            : Colors.white,
                      ),
                      onPressed: onPickCustomColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Opacity / Transparency',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: opacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        label: '${(opacity * 100).round()}%',
                        onChanged: onOpacityChanged,
                      ),
                    ),
                    Text(
                      '${(opacity * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
