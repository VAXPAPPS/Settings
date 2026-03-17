import 'package:settings/screens/power_settings/widgets/power_action_button.dart';
import 'package:flutter/material.dart';

class SystemActionsSection extends StatelessWidget {
  const SystemActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'System Actions',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PowerActionButton(
              icon: Icons.power_settings_new_rounded,
              color: Colors.redAccent,
              label: 'Shutdown',
              action: 'shutdown',
            ),
            PowerActionButton(
              icon: Icons.restart_alt_rounded,
              color: Colors.orangeAccent,
              label: 'Reboot',
              action: 'reboot',
            ),
            PowerActionButton(
              icon: Icons.bedtime_rounded,
              color: Colors.blueAccent,
              label: 'Suspend',
              action: 'suspend',
            ),
            PowerActionButton(
              icon: Icons.logout_rounded,
              color: Colors.grey,
              label: 'Logout',
              action: 'logout',
            ),
          ],
        ),
      ],
    );
  }
}
