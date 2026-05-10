import 'package:flutter/material.dart';

class AppsSettingsHeader extends StatelessWidget {
  final VoidCallback onReset;

  const AppsSettingsHeader({super.key, required this.onReset});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Applications Control',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Spacer(),
        ElevatedButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.restore, color: Colors.white),
          label: const Text("Reset to Default"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
