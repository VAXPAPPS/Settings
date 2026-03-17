import 'package:flutter/material.dart';
import 'package:settings/screens/venom_effects/widgets/section_container.dart';
import 'package:settings/screens/venom_effects/widgets/switch_setting.dart';
import 'package:settings/screens/venom_effects/widgets/slider_setting.dart';

class AnimationsSection extends StatelessWidget {
  final bool enabled;
  final double speed;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<double> onSpeedChanged;

  const AnimationsSection({
    super.key,
    required this.enabled,
    required this.speed,
    required this.onEnabledChanged,
    required this.onSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: "Animations",
      icon: Icons.animation,
      children: [
        SwitchSetting(
          title: "Enable Fading",
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        
        SliderSetting(
          title: "Animation Speed",
          value: speed,
          min: 10,
          max: 100,
          onChanged: onSpeedChanged,
          enabled: enabled,
        ),
      ],
    );
  }
}
