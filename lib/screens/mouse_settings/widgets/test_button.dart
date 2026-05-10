import 'package:flutter/material.dart';

class TestButton extends StatelessWidget {
  const TestButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Test your mouse settings here')),
          );
        },
        icon: const Icon(Icons.mouse_rounded),
        label: const Text('Test Mouse'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
