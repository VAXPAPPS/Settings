import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/mouse_settings/mouse_settings.dart';
import 'package:settings/screens/mouse_settings/widgets/section.dart';
import 'package:settings/screens/mouse_settings/widgets/segmented_button.dart';

class ClickingSection extends StatelessWidget {
  const ClickingSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MouseSettingsBloc, MouseSettingsState>(
      buildWhen: (previous, current) =>
          previous.secondaryClick != current.secondaryClick,
      builder: (context, state) {
        return Section(
          title: 'Clicking',
          children: [
            const Text(
              'Secondary Click',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MouseSegmentedButton(
                    label: 'Two-finger',
                    isSelected: state.secondaryClick == 'two-finger',
                    onTap: () => context.read<MouseSettingsBloc>().add(
                      const SetSecondaryClick('two-finger'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MouseSegmentedButton(
                    label: 'Corner',
                    isSelected: state.secondaryClick == 'corner',
                    onTap: () => context.read<MouseSettingsBloc>().add(
                      const SetSecondaryClick('corner'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
