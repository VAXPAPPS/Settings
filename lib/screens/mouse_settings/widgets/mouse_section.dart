import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:antidote/features/mouse_settings/mouse_settings.dart';
import 'package:antidote/screens/mouse_settings/widgets/section.dart';
import 'package:antidote/screens/mouse_settings/widgets/pointer_speed_slider.dart';

class MouseSection extends StatelessWidget {
  const MouseSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MouseSettingsBloc, MouseSettingsState>(
      buildWhen: (previous, current) =>
          previous.mousePointerSpeed != current.mousePointerSpeed ||
          previous.mouseAcceleration != current.mouseAcceleration,
      builder: (context, state) {
        return Section(
          title: 'Mouse',
          children: [
            PointerSpeedSlider(
              label: 'Pointer Speed',
              value: state.mousePointerSpeed,
              max: 2.0,
              onChanged: (value) => context.read<MouseSettingsBloc>().add(
                SetMousePointerSpeed(value),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Mouse Acceleration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.mouseAcceleration,
                  onChanged: (value) => context.read<MouseSettingsBloc>().add(
                    SetMouseAcceleration(value),
                  ),
                  activeColor: Colors.blueAccent,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
