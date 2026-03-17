import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/audio_settings/audio_settings.dart';
import 'section_container.dart';
import 'device_dropdown.dart';
import 'sliders.dart';

class InputSection extends StatelessWidget {
  const InputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioSettingsBloc, AudioSettingsState>(
      builder: (context, state) {
        return SectionContainer(
          title: 'Input',
          children: [
            DeviceDropdown(
              label: 'Input Device',
              selectedDevice: state.selectedInputDevice,
              devices: state.inputDevices,
              icon: Icons.mic_rounded,
              onChanged: (device) =>
                  context.read<AudioSettingsBloc>().add(SetInputDevice(device)),
            ),
            const SizedBox(height: 24),
            VolumeSlider(
              label: 'Input Volume',
              value: state.inputVolume,
              icon: state.inputMuted ? Icons.mic_off : Icons.mic_rounded,
              muted: state.inputMuted,
              onChanged: (value) =>
                  context.read<AudioSettingsBloc>().add(SetInputVolume(value)),
              onMuteToggle: () => context.read<AudioSettingsBloc>().add(
                const ToggleInputMute(),
              ),
            ),
          ],
        );
      },
    );
  }
}
