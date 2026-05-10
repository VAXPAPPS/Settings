import 'package:flutter/material.dart';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';

class ShortcutListTile extends StatelessWidget {
  final ShortcutItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ShortcutListTile({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: const Color.fromARGB(50, 0, 0, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.cyan.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
        ),
        child: Text(
          '${item.modifier == "None" ? "" : "${item.modifier} + "}${item.key}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.cyanAccent,
            fontFamily: 'Monospace',
          ),
        ),
      ),
      title: Text(
        item.command,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.grey),
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.redAccent),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
