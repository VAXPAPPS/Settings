import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/keyboard_settings/keyboard_settings.dart';
import 'package:settings/screens/keyboard_settings/widgets/section_container.dart';
import 'package:settings/screens/keyboard_settings/widgets/radio_option.dart';

class InputSourceSwitchingSection extends StatelessWidget {
  const InputSourceSwitchingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeyboardSettingsBloc, KeyboardSettingsState>(
      buildWhen: (previous, current) =>
          previous.inputSourceSwitching != current.inputSourceSwitching,
      builder: (context, state) {
        return SectionContainer(
          title: 'Input Source Switching',
          subtitle:
              'Input sources can be switched using the Super+Space keyboard shortcut. This can be changed in the keyboard shortcut settings.',
          children: [
            RadioOption(
              label: 'Use the same source for all windows',
              isSelected: state.inputSourceSwitching == 'all-windows',
              onTap: () => context.read<KeyboardSettingsBloc>().add(
                const SetInputSourceSwitching('all-windows'),
              ),
            ),
            const SizedBox(height: 12),
            RadioOption(
              label: 'Switch input sources individually for each window',
              isSelected: state.inputSourceSwitching == 'per-window',
              onTap: () => context.read<KeyboardSettingsBloc>().add(
                const SetInputSourceSwitching('per-window'),
              ),
            ),
          ],
        );
      },
    );
  }
}
