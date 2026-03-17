import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/audio_settings/audio_settings.dart';
import 'section_container.dart';
import 'device_dropdown.dart';
import 'sliders.dart';
import 'common_widgets.dart';

class OutputSection extends StatelessWidget {
  const OutputSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioSettingsBloc, AudioSettingsState>(
      builder: (context, state) {
        return SectionContainer(
          title: 'Output',
          children: [
            DeviceDropdown(
              label: 'Output Device',
              selectedDevice: state.selectedOutputDevice,
              devices: state.outputDevices,
              icon: Icons.headphones_rounded,
              onChanged: (device) => context.read<AudioSettingsBloc>().add(
                SetOutputDevice(device),
              ),
            ),
            const SizedBox(height: 24),
            VolumeSlider(
              label: 'Output Volume',
              value: state.outputVolume,
              icon: state.outputMuted
                  ? Icons.volume_off
                  : Icons.volume_up_rounded,
              max: state.maxVolume,
              muted: state.outputMuted,
              onChanged: (value) =>
                  context.read<AudioSettingsBloc>().add(SetOutputVolume(value)),
              onMuteToggle: () => context.read<AudioSettingsBloc>().add(
                const ToggleOutputMute(),
              ),
            ),
            const SizedBox(height: 24),
            ToggleSetting(
              label: 'Overamplification',
              value: state.overamplification,
              description: 'Allow volume to exceed 100% (up to 150%)',
              onChanged: (value) => context.read<AudioSettingsBloc>().add(
                SetOveramplification(value),
              ),
            ),
          ],
        );
      },
    );
  }
}
