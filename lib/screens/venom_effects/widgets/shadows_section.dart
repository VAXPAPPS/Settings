import 'package:flutter/material.dart';
import 'package:settings/screens/venom_effects/widgets/section_container.dart';
import 'package:settings/screens/venom_effects/widgets/switch_setting.dart';
import 'package:settings/screens/venom_effects/widgets/slider_setting.dart';
import 'package:settings/screens/venom_effects/widgets/color_slider.dart';

class ShadowsSection extends StatelessWidget {
  final bool enabled;
  final double radius;
  final double opacity;
  final double red;
  final double green;
  final double blue;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onRadiusChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<double> onRedChanged;
  final ValueChanged<double> onGreenChanged;
  final ValueChanged<double> onBlueChanged;

  const ShadowsSection({
    super.key,
    required this.enabled,
    required this.radius,
    required this.opacity,
    required this.red,
    required this.green,
    required this.blue,
    required this.onEnabledChanged,
    required this.onRadiusChanged,
    required this.onOpacityChanged,
    required this.onRedChanged,
    required this.onGreenChanged,
    required this.onBlueChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: "Shadows",
      icon: Icons.layers_outlined,
      children: [
        SwitchSetting(
          title: "Enable Shadows",
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        SliderSetting(
          title: "Radius",
          value: radius,
          min: 0,
          max: 100,
          onChanged: onRadiusChanged,
          enabled: enabled,
        ),
        SliderSetting(
          title: "Opacity",
          value: opacity,
          min: 0.0,
          max: 1.0,
          onChanged: onOpacityChanged,
          enabled: enabled,
        ),
        const SizedBox(height: 10),
        
        Row(
          children: [
            Expanded(
              child: ColorSlider(
                value: red,
                color: Colors.redAccent,
                onChanged: onRedChanged,
                enabled: enabled,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ColorSlider(
                value: green,
                color: Colors.greenAccent,
                onChanged: onGreenChanged,
                enabled: enabled,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ColorSlider(
                value: blue,
                color: Colors.blueAccent,
                onChanged: onBlueChanged,
                enabled: enabled,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
