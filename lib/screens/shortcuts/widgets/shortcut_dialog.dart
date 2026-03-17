import 'package:flutter/material.dart';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';

class ShortcutDialog extends StatefulWidget {
  final ShortcutItem? existingItem;
  final Function(ShortcutItem) onSave;

  const ShortcutDialog({super.key, this.existingItem, required this.onSave});

  @override
  State<ShortcutDialog> createState() => _ShortcutDialogState();
}

class _ShortcutDialogState extends State<ShortcutDialog> {
  late TextEditingController _keyController;
  late TextEditingController _cmdController;
  late String _selectedMod;

  final List<String> _modifiers = [
    'None',
    'Ctrl',
    'Alt',
    'Shift',
    'Super',
    'Ctrl+Alt',
    'Ctrl+Shift',
    'Super+Shift',
  ];

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(
      text: widget.existingItem?.key ?? '',
    );
    _cmdController = TextEditingController(
      text: widget.existingItem?.command ?? '',
    );
    _selectedMod = widget.existingItem?.modifier ?? 'None';
  }

  @override
  void dispose() {
    _keyController.dispose();
    _cmdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(
        255,
        30,
        30,
        30,
      ), 
      title: Text(
        widget.existingItem == null ? 'New Keybind' : 'Edit Keybind',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            value: _modifiers.contains(_selectedMod) ? _selectedMod : 'None',
            dropdownColor: const Color.fromARGB(255, 40, 40, 40),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Modifier',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            items: _modifiers
                .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                .toList(),
            onChanged: (val) => setState(() => _selectedMod = val!),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _keyController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Key (e.g. z, F1, VolUp)',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
            ),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _cmdController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Command',
              labelStyle: TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyanAccent),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan[700]),
          onPressed: () {
            if (_keyController.text.isEmpty || _cmdController.text.isEmpty)
              return;

            final newItem = ShortcutItem(
              _selectedMod,
              _keyController.text,
              _cmdController.text,
            );
            widget.onSave(newItem);
            Navigator.pop(context);
          },
          child: const Text(
            'Save & Apply',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
