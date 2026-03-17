import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/display_settings/display_settings.dart';
import 'package:settings/screens/display_settings/widgets/display_header.dart';
import 'package:settings/screens/display_settings/widgets/display_selector.dart';
import 'package:settings/screens/display_settings/widgets/settings_grid.dart';
import 'package:settings/screens/display_settings/widgets/display_profiles_section.dart';

class DisplaySettingsPage extends StatelessWidget {
  const DisplaySettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          DisplaySettingsBloc()..add(const InitializeDisplaySettings()),
      child: const DisplaySettingsView(),
    );
  }
}

class DisplaySettingsView extends StatelessWidget {
  const DisplaySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DisplayHeader(),
            const SizedBox(height: 32),
            const DisplaySelector(),
            const SizedBox(height: 24),
            const SettingsGrid(),
            const SizedBox(height: 24),
            const DisplayProfilesSection(),
          ],
        ),
      ),
    );
  }
}
