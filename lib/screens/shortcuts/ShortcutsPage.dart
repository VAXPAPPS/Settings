import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:settings/screens/shortcuts/services/shortcut_manager.dart';
import 'package:settings/screens/shortcuts/widgets/shortcut_list_tile.dart';
import 'package:settings/screens/shortcuts/widgets/shortcut_dialog.dart';


class ShortcutsPage extends StatefulWidget {
  const ShortcutsPage({super.key});

  @override
  State<ShortcutsPage> createState() => _ShortcutsPageState();
}

class _ShortcutsPageState extends State<ShortcutsPage> {
  final VenomShortcutManager _manager = VenomShortcutManager();
  List<ShortcutItem> _shortcuts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _manager.loadShortcuts();
    setState(() {
      _shortcuts = data;
      _isLoading = false;
    });
  }

  void _addOrEditShortcut({ShortcutItem? existingItem, int? index}) {
    showDialog(
      context: context,
      builder: (ctx) => ShortcutDialog(
        existingItem: existingItem,
        onSave: (newItem) async {
          setState(() {
            if (existingItem == null) {
              _shortcuts.add(newItem);
            } else {
              _shortcuts[index!] = newItem;
            }
          });

          
          await _manager.saveShortcuts(_shortcuts);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved & Daemon Restarted'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 1),
              ),
            );
          }
        },
      ),
    );
  }

  void _deleteShortcut(int index) async {
    setState(() {
      _shortcuts.removeAt(index);
    });
    await _manager.saveShortcuts(_shortcuts);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shortcut Deleted'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venom Shortcuts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.cyanAccent),
            onPressed: () async {
              
              await _manager.restartDaemon();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Manual Restart Sent!')),
                );
              }
            },
            tooltip: 'Force Restart Daemon',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : _shortcuts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.keyboard, size: 64, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    "No shortcuts configured.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _shortcuts.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final item = _shortcuts[i];
                return ShortcutListTile(
                  item: item,
                  onEdit: () =>
                      _addOrEditShortcut(existingItem: item, index: i),
                  onDelete: () => _deleteShortcut(i),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditShortcut(),
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }
}
