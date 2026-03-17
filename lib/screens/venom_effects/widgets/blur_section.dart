import 'package:flutter/material.dart';
import 'package:settings/screens/venom_effects/widgets/section_container.dart';
import 'package:settings/screens/venom_effects/widgets/switch_setting.dart';
import 'package:settings/screens/venom_effects/widgets/slider_setting.dart';

class BlurSection extends StatelessWidget {
  final bool enabled;
  final double strength;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onStrengthChanged;

  const BlurSection({
    super.key,
    required this.enabled,
    required this.strength,
    required this.onEnabledChanged,
    required this.onStrengthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: "Blur (Glass)",
      icon: Icons.blur_on,
      children: [
        SwitchSetting(
          title: "Enable Blur",
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        SliderSetting(
          title: "Blur Strength",
          value: strength,
          min: 0,
          max: 20,
          onChanged: onStrengthChanged,
          enabled: enabled,
        ),
      ],
    );
  }
}
