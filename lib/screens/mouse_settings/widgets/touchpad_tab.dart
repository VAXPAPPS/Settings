import 'package:flutter/material.dart';
import 'package:settings/screens/mouse_settings/widgets/touchpad_section.dart';
import 'package:settings/screens/mouse_settings/widgets/clicking_section.dart';
import 'package:settings/screens/mouse_settings/widgets/tap_to_click_section.dart';

class TouchpadTab extends StatelessWidget {
  const TouchpadTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 120,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.touch_app_rounded,
              size: 64,
              color: Colors.blueAccent.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const TouchpadSection(),
        const SizedBox(height: 24),
        const ClickingSection(),
        const SizedBox(height: 24),
        const TapToClickSection(),
      ],
    );
  }
}
