import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/keyboard_settings/keyboard_settings.dart';
import 'package:settings/screens/keyboard_settings/widgets/input_sources_section.dart';
import 'package:settings/screens/keyboard_settings/widgets/input_source_switching_section.dart';
import 'package:settings/screens/keyboard_settings/widgets/special_character_entry_section.dart';
import 'package:settings/screens/keyboard_settings/widgets/section_container.dart';
import 'package:settings/screens/keyboard_settings/widgets/clickable_item.dart';
import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:settings/screens/shortcuts/services/shortcut_manager.dart';
import 'package:settings/screens/shortcuts/widgets/shortcut_list_tile.dart';
import 'package:settings/screens/shortcuts/widgets/shortcut_dialog.dart';

class KeyboardSettingsPage extends StatelessWidget {
  const KeyboardSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          KeyboardSettingsBloc()..add(const LoadKeyboardSettings()),
      child: const KeyboardSettingsView(),
    );
  }
}

enum KeyboardView { main, shortcuts }

class KeyboardSettingsView extends StatefulWidget {
  const KeyboardSettingsView({super.key});

  @override
  State<KeyboardSettingsView> createState() => _KeyboardSettingsViewState();
}

class _KeyboardSettingsViewState extends State<KeyboardSettingsView> {
  KeyboardView _currentView = KeyboardView.main;

  final VenomShortcutManager _shortcutManager = VenomShortcutManager();
  List<ShortcutItem> _shortcuts = [];
  bool _shortcutsLoading = false;

  void _switchToShortcuts() async {
    setState(() {
      _currentView = KeyboardView.shortcuts;
      _shortcutsLoading = true;
    });

    final data = await _shortcutManager.loadShortcuts();
    if (mounted) {
      setState(() {
        _shortcuts = data;
        _shortcutsLoading = false;
      });
    }
  }

  void _switchToMain() {
    setState(() => _currentView = KeyboardView.main);
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

          await _shortcutManager.saveShortcuts(_shortcuts);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Saved to wayfire.ini'),
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
    await _shortcutManager.saveShortcuts(_shortcuts);
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
    return BlocListener<KeyboardSettingsBloc, KeyboardSettingsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _currentView == KeyboardView.main
              ? _buildMainView()
              : _buildShortcutsView(),
        ),
        floatingActionButton: _currentView == KeyboardView.shortcuts
            ? FloatingActionButton(
                onPressed: () => _addOrEditShortcut(),
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildMainView() {
    return SingleChildScrollView(
      key: const ValueKey('main'),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keyboard',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Configure keyboard and input settings',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 48),
          const InputSourcesSection(),
          const SizedBox(height: 24),
          const InputSourceSwitchingSection(),
          const SizedBox(height: 24),
          const SpecialCharacterEntrySection(),
          const SizedBox(height: 24),
          SectionContainer(
            title: 'Keyboard Shortcuts',
            children: [
              ClickableItem(
                label: 'View and Customize Shortcuts',
                onTap: _switchToShortcuts,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutsView() {
    return SingleChildScrollView(
      key: const ValueKey('shortcuts'),
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: _switchToMain,
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                tooltip: 'Back',
              ),
              const SizedBox(width: 8),
              const Text(
                'Keyboard Shortcuts',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              // Removed manual restart daemon button since wayfire auto-reloads
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your custom keyboard shortcuts',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 32),
          if (_shortcutsLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: CupertinoActivityIndicator(),
              ),
            )
          else if (_shortcuts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(48),
                child: Column(
                  children: [
                    Icon(
                      Icons.keyboard,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No shortcuts configured.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => _addOrEditShortcut(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Shortcut'),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
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
        ],
      ),
    );
  }
}
