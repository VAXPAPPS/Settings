import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/mouse_settings/mouse_settings.dart';
import 'package:settings/screens/mouse_settings/widgets/tab_button.dart';

class Tabs extends StatelessWidget {
  const Tabs({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MouseSettingsBloc, MouseSettingsState>(
      buildWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab,
      builder: (context, state) {
        return Row(
          children: [
            TabButton(
              label: 'Mouse',
              isSelected: state.selectedTab == 0,
              onTap: () =>
                  context.read<MouseSettingsBloc>().add(const ChangeTab(0)),
            ),
            const SizedBox(width: 8),
            TabButton(
              label: 'Touchpad',
              isSelected: state.selectedTab == 1,
              onTap: () =>
                  context.read<MouseSettingsBloc>().add(const ChangeTab(1)),
            ),
          ],
        );
      },
    );
  }
}
