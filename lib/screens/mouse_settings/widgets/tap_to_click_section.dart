import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/mouse_settings/mouse_settings.dart';
import 'package:settings/screens/mouse_settings/widgets/section.dart';
import 'package:settings/screens/mouse_settings/widgets/toggle_setting.dart';

class TapToClickSection extends StatelessWidget {
  const TapToClickSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MouseSettingsBloc, MouseSettingsState>(
      buildWhen: (previous, current) =>
          previous.tapToClick != current.tapToClick,
      builder: (context, state) {
        return Section(
          title: 'Tap to Click',
          children: [
            ToggleSetting(
              label: 'Tap to Click',
              description: 'Single finger tap to click buttons',
              value: state.tapToClick,
              onChanged: (value) =>
                  context.read<MouseSettingsBloc>().add(SetTapToClick(value)),
            ),
          ],
        );
      },
    );
  }
}
