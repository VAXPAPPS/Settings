import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/power_settings/power_settings.dart';
import 'package:settings/screens/power_settings/widgets/battery_tile.dart';
import 'package:settings/screens/power_settings/widgets/power_profiles_section.dart';
import 'package:settings/screens/power_settings/widgets/power_timers_section.dart';
import 'package:settings/screens/power_settings/widgets/system_actions_section.dart';

class PowerSettingsPage extends StatelessWidget {
  const PowerSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PowerSettingsBloc()..add(const LoadPowerSettings()),
      child: const PowerSettingsView(),
    );
  }
}

class PowerSettingsView extends StatelessWidget {
  const PowerSettingsView({super.key});

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
              'Power',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            const Opacity(
              opacity: 0.6,
              child: Text(
                'Manage battery and power settings',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w300,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const BatteryTile(),
            const SizedBox(height: 32),
            const PowerProfilesSection(),
            const SizedBox(height: 32),
            const PowerTimersSection(),
            const SizedBox(height: 32),
            const Divider(color: Colors.white10, height: 1),
            const SizedBox(height: 24),
            const SystemActionsSection(),
          ],
        ),
      ),
    );
  }
}
