import 'package:flutter/material.dart';

class DisplayHeader extends StatelessWidget {
  const DisplayHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Display',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Manage your display settings',
          style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.6)),
        ),
      ],
    );
  }
}
