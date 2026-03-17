import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/audio_settings/audio_settings.dart';
import 'widgets/output_section.dart';
import 'widgets/input_section.dart';
import 'widgets/sounds_section.dart';


class AudioSettingsPage extends StatelessWidget {
  const AudioSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioSettingsBloc()..add(const LoadAudioSettings()),
      child: const AudioSettingsView(),
    );
  }
}


class AudioSettingsView extends StatelessWidget {
  const AudioSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sound',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure audio devices and settings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 48),
            const OutputSection(),
            const SizedBox(height: 32),
            const InputSection(),
            const SizedBox(height: 32),
            const SoundsSection(),
          ],
        ),
      ),
    );
  }
}
