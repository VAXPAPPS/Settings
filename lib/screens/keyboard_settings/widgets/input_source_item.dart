import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/keyboard_settings/keyboard_settings.dart';

class InputSourceItem extends StatelessWidget {
  final InputSource source;

  const InputSourceItem({super.key, required this.source});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.keyboard_rounded, size: 20, color: Colors.white70),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              source.name,
              style: const TextStyle(fontSize: 14, color: Colors.white),
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20, color: Colors.white70),
            color: const Color.fromARGB(255, 45, 45, 45),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'remove',
                child: Text('Remove', style: TextStyle(color: Colors.white)),
              ),
            ],
            onSelected: (value) {
              if (value == 'remove') {
                context.read<KeyboardSettingsBloc>().add(
                  RemoveInputSource(source),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
