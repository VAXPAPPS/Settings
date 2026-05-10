import 'package:settings/screens/power_settings/widgets/profile_button.dart';
import 'package:flutter/material.dart';

class PowerProfilesSection extends StatelessWidget {
  const PowerProfilesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white54,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.fromARGB(12, 255, 255, 255),
                Color.fromARGB(10, 255, 255, 255),
              ],
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              ProfileButton(
                label: 'Saver',
                icon: Icons.eco_rounded,
                profileId: 'power-saver',
                color: Colors.greenAccent,
              ),
              ProfileButton(
                label: 'Balanced',
                icon: Icons.balance_rounded,
                profileId: 'balanced',
                color: Colors.blueAccent,
              ),
              ProfileButton(
                label: 'Boost',
                icon: Icons.speed_rounded,
                profileId: 'performance',
                color: Colors.redAccent,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
