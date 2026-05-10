import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/keyboard_settings/keyboard_settings.dart';
import 'package:settings/screens/keyboard_settings/widgets/section_container.dart';
import 'package:settings/screens/keyboard_settings/widgets/input_source_item.dart';
import 'package:settings/screens/keyboard_settings/widgets/add_input_source_dialog.dart';

class InputSourcesSection extends StatelessWidget {
  const InputSourcesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeyboardSettingsBloc, KeyboardSettingsState>(
      builder: (context, state) {
        return SectionContainer(
          title: 'Input Sources',
          subtitle: 'Includes keyboard layouts and input methods',
          children: [
            if (state.status == KeyboardSettingsStatus.loading)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CupertinoActivityIndicator()),
              )
            else if (state.currentSources.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'No input sources configured',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...state.currentSources.map(
                (source) => InputSourceItem(source: source),
              ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _showAddInputSourceDialog(context, state),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Input Source...'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddInputSourceDialog(
    BuildContext context,
    KeyboardSettingsState state,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AddInputSourceDialog(
        availableSources: state.availableSources,
        currentSources: state.currentSources,
        onAdd: (source) {
          context.read<KeyboardSettingsBloc>().add(AddInputSource(source));
          Navigator.pop(dialogContext);
        },
      ),
    );
  }
}
