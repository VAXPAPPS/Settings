import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/mouse_settings/mouse_settings.dart';
import 'package:settings/screens/mouse_settings/widgets/section.dart';
import 'package:settings/screens/mouse_settings/widgets/radio_option.dart';

class ScrollDirectionSection extends StatelessWidget {
  const ScrollDirectionSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MouseSettingsBloc, MouseSettingsState>(
      buildWhen: (previous, current) =>
          previous.scrollDirection != current.scrollDirection,
      builder: (context, state) {
        return Section(
          title: 'Scroll Direction',
          children: [
            RadioOption(
              title: 'Traditional',
              description: 'Scrolling moves the view',
              isSelected: state.scrollDirection == 'traditional',
              icon: Icons.arrow_upward_rounded,
              onTap: () => context.read<MouseSettingsBloc>().add(
                const SetScrollDirection('traditional'),
              ),
            ),
            const SizedBox(height: 16),
            RadioOption(
              title: 'Natural',
              description: 'Scrolling moves the content',
              isSelected: state.scrollDirection == 'natural',
              icon: Icons.arrow_downward_rounded,
              onTap: () => context.read<MouseSettingsBloc>().add(
                const SetScrollDirection('natural'),
              ),
            ),
          ],
        );
      },
    );
  }
}
