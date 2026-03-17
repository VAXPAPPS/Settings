import 'package:flutter/material.dart';
import 'package:settings/screens/venom_effects/widgets/section_container.dart';
import 'package:settings/screens/venom_effects/widgets/slider_setting.dart';

class GeometrySection extends StatelessWidget {
  final double cornerRadius;
  final ValueChanged<double> onCornerRadiusChanged;

  const GeometrySection({
    super.key,
    required this.cornerRadius,
    required this.onCornerRadiusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SectionContainer(
      title: "Geometry",
      icon: Icons.rounded_corner,
      children: [
        SliderSetting(
          title: "Corner Radius",
          value: cornerRadius,
          min: 0,
          max: 30,
          onChanged: onCornerRadiusChanged,
        ),
      ],
    );
  }
}
