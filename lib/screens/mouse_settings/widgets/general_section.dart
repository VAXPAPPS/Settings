import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/mouse_settings/mouse_settings.dart';
import 'package:settings/screens/mouse_settings/widgets/section.dart';
import 'package:settings/screens/mouse_settings/widgets/segmented_button.dart';

class GeneralSection extends StatelessWidget {
  const GeneralSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MouseSettingsBloc, MouseSettingsState>(
      buildWhen: (previous, current) =>
          previous.primaryButton != current.primaryButton,
      builder: (context, state) {
        return Section(
          title: 'General',
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Primary Button',
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
                        label: 'Left',
                        isSelected: state.primaryButton == 'left',
                        onTap: () => context.read<MouseSettingsBloc>().add(
                          const SetPrimaryButton('left'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MouseSegmentedButton(
                        label: 'Right',
                        isSelected: state.primaryButton == 'right',
                        onTap: () => context.read<MouseSettingsBloc>().add(
                          const SetPrimaryButton('right'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Order of physical buttons on mice and touchpads',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
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
