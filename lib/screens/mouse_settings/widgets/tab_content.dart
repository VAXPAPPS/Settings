import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/mouse_settings/mouse_settings.dart';
import 'package:settings/screens/mouse_settings/widgets/mouse_tab.dart';
import 'package:settings/screens/mouse_settings/widgets/touchpad_tab.dart';

class TabContent extends StatelessWidget {
  const TabContent({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MouseSettingsBloc, MouseSettingsState>(
      buildWhen: (previous, current) =>
          previous.selectedTab != current.selectedTab,
      builder: (context, state) {
        return state.selectedTab == 0 ? const MouseTab() : const TouchpadTab();
      },
    );
  }
}
