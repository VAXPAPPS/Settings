import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/mouse_settings/mouse_settings.dart';
import 'package:settings/screens/mouse_settings/widgets/section.dart';
import 'package:settings/screens/mouse_settings/widgets/toggle_setting.dart';
import 'package:settings/screens/mouse_settings/widgets/pointer_speed_slider.dart';

class TouchpadSection extends StatelessWidget {
  const TouchpadSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MouseSettingsBloc, MouseSettingsState>(
      buildWhen: (previous, current) =>
          previous.touchpadEnabled != current.touchpadEnabled ||
          previous.disableWhileTyping != current.disableWhileTyping ||
          previous.touchpadPointerSpeed != current.touchpadPointerSpeed,
      builder: (context, state) {
        return Section(
          title: 'Touchpad',
          children: [
            ToggleSetting(
              label: 'Touchpad',
              value: state.touchpadEnabled,
              onChanged: (value) => context.read<MouseSettingsBloc>().add(
                SetTouchpadEnabled(value),
              ),
            ),
            const SizedBox(height: 16),
            ToggleSetting(
              label: 'Disable Touchpad While Typing',
              value: state.disableWhileTyping,
              onChanged: (value) => context.read<MouseSettingsBloc>().add(
                SetDisableWhileTyping(value),
              ),
            ),
            const SizedBox(height: 24),
            PointerSpeedSlider(
              label: 'Pointer Speed',
              value: state.touchpadPointerSpeed,
              onChanged: (value) => context.read<MouseSettingsBloc>().add(
                SetTouchpadPointerSpeed(value),
              ),
            ),
          ],
        );
      },
    );
  }
}
