import 'package:flutter/material.dart';
import 'package:settings/screens/mouse_settings/widgets/general_section.dart';
import 'package:settings/screens/mouse_settings/widgets/mouse_section.dart';
import 'package:settings/screens/mouse_settings/widgets/scroll_direction_section.dart';

class MouseTab extends StatelessWidget {
  const MouseTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        GeneralSection(),
        SizedBox(height: 24),
        MouseSection(),
        SizedBox(height: 24),
        ScrollDirectionSection(),
      ],
    );
  }
}
