import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:antidote/core/glassmorphic_container.dart';

class ToggleSetting extends StatelessWidget {
  final String label;
  final bool value;
  final String? description;
  final ValueChanged<bool> onChanged;

  const ToggleSetting({
    super.key,
    required this.label,
    required this.value,
    this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
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
              if (description != null) ...[
                const SizedBox(height: 4),
                Text(
                  description!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.blueAccent,
        ),
      ],
    );
  }
}

class SliderSetting extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final String? description;
  final ValueChanged<double> onChanged;

  const SliderSetting({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.description,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 120, 210, 255),
                ),
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 4),
          Text(
            description!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          activeColor: Colors.blueAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class ColorPickerSetting extends StatefulWidget {
  final String label;
  final String initialColor;
  final String? description;
  final ValueChanged<String>? onChanged;

  const ColorPickerSetting({
    super.key,
    required this.label,
    required this.initialColor,
    this.description,
    this.onChanged,
  });

  @override
  State<ColorPickerSetting> createState() => _ColorPickerSettingState();
}

class _ColorPickerSettingState extends State<ColorPickerSetting> {
  late Color _pickedColor;

  @override
  void initState() {
    super.initState();
    _pickedColor = _hexToColor(widget.initialColor);
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _openColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(200, 30, 30, 50),
          title: Text(
            widget.label,
            style: const TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _pickedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _pickedColor = color;
                });
              },
              labelTypes: const [],
              displayThumbColor: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                widget.onChanged?.call(_colorToHex(_pickedColor));
                Navigator.of(context).pop();
              },
              child: const Text(
                'Apply',
                style: TextStyle(color: Colors.blueAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.description!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.initialColor,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                      fontFamily: 'Courier',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openColorPicker,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _pickedColor,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class ConfigurationPanel extends StatelessWidget {
  final bool floatingMode;
  final bool snapToEdge;
  final int snapThreshold;
  final int borderWidth;
  final int windowGap;
  final int topPadding;
  final int bottomPadding;
  final bool focusOpacity;
  final double inactiveOpacity;
  final double activeOpacity;
  final String focusedBorderColor;
  final String normalBorderColor;
  final ValueChanged<bool>? onFloatingModeChanged;
  final ValueChanged<bool>? onSnapToEdgeChanged;
  final ValueChanged<double>? onSnapThresholdChanged;
  final ValueChanged<double>? onBorderWidthChanged;
  final ValueChanged<double>? onWindowGapChanged;
  final ValueChanged<double>? onTopPaddingChanged;
  final ValueChanged<double>? onBottomPaddingChanged;
  final ValueChanged<bool>? onFocusOpacityChanged;
  final ValueChanged<double>? onInactiveOpacityChanged;
  final ValueChanged<double>? onActiveOpacityChanged;
  final ValueChanged<String>? onFocusedBorderColorChanged;
  final ValueChanged<String>? onNormalBorderColorChanged;

  const ConfigurationPanel({
    super.key,
    required this.floatingMode,
    required this.snapToEdge,
    required this.snapThreshold,
    required this.borderWidth,
    required this.windowGap,
    required this.topPadding,
    required this.bottomPadding,
    required this.focusOpacity,
    required this.inactiveOpacity,
    required this.activeOpacity,
    required this.focusedBorderColor,
    required this.normalBorderColor,
    this.onFloatingModeChanged,
    this.onSnapToEdgeChanged,
    this.onSnapThresholdChanged,
    this.onBorderWidthChanged,
    this.onWindowGapChanged,
    this.onTopPaddingChanged,
    this.onBottomPaddingChanged,
    this.onFocusOpacityChanged,
    this.onInactiveOpacityChanged,
    this.onActiveOpacityChanged,
    this.onFocusedBorderColorChanged,
    this.onNormalBorderColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Configuration',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          ToggleSetting(
            label: 'Floating Mode',
            value: floatingMode,
            description: 'Enable floating window mode',
            onChanged: onFloatingModeChanged ?? (_) {},
          ),
          const SizedBox(height: 16),
          SliderSetting(
            label: 'Border Width',
            value: borderWidth.toDouble(),
            min: 1,
            max: 5,
            description: 'Window border thickness',
            onChanged: (v) => onBorderWidthChanged?.call(v),
          ),
          const SizedBox(height: 16),
          SliderSetting(
            label: 'Window Gap',
            value: windowGap.toDouble(),
            min: 0,
            max: 30,
            description: 'Space between windows',
            onChanged: (v) => onWindowGapChanged?.call(v),
          ),
          const SizedBox(height: 16),
          SliderSetting(
            label: 'Top Padding',
            value: topPadding.toDouble(),
            min: 0,
            max: 60,
            description: 'Space from top for panel',
            onChanged: (v) => onTopPaddingChanged?.call(v),
          ),
          const SizedBox(height: 16),
          SliderSetting(
            label: 'Bottom Padding',
            value: bottomPadding.toDouble(),
            min: 0,
            max: 60,
            description: 'Space from bottom for panel',
            onChanged: (v) => onBottomPaddingChanged?.call(v),
          ),
          const SizedBox(height: 16),
          ToggleSetting(
            label: 'Focus Opacity',
            value: focusOpacity,
            description: 'Adjust opacity based on focus',
            onChanged: onFocusOpacityChanged ?? (_) {},
          ),
          const SizedBox(height: 16),
          SliderSetting(
            label: 'Inactive Opacity',
            value: inactiveOpacity,
            min: 0.5,
            max: 1.0,
            description: 'Opacity for unfocused windows',
            onChanged: (v) => onInactiveOpacityChanged?.call(v),
          ),
          const SizedBox(height: 16),
          SliderSetting(
            label: 'Active Opacity',
            value: activeOpacity,
            min: 0.8,
            max: 1.0,
            description: 'Opacity for focused window',
            onChanged: (v) => onActiveOpacityChanged?.call(v),
          ),
          const SizedBox(height: 20),
          const Divider(
            color: Colors.white12,
            height: 1,
          ),
          const SizedBox(height: 20),
          const Text(
            'Border Colors',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          ColorPickerSetting(
            label: 'Focused Border',
            initialColor: focusedBorderColor,
            description: 'Color for focused window border',
            onChanged: (color) => onFocusedBorderColorChanged?.call(color),
          ),
          const SizedBox(height: 16),
          ColorPickerSetting(
            label: 'Normal Border',
            initialColor: normalBorderColor,
            description: 'Color for unfocused window border',
            onChanged: (color) => onNormalBorderColorChanged?.call(color),
          ),
        ],
      ),
    );
  }
}
