import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/mouse_settings/mouse_settings.dart';
import 'package:settings/screens/mouse_settings/widgets/tabs.dart';
import 'package:settings/screens/mouse_settings/widgets/tab_content.dart';
import 'package:settings/screens/mouse_settings/widgets/test_button.dart';


class MouseSettingsPage extends StatelessWidget {
  const MouseSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MouseSettingsBloc()..add(const LoadMouseSettings()),
      child: const MouseSettingsView(),
    );
  }
}


class MouseSettingsView extends StatelessWidget {
  const MouseSettingsView({super.key});

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
              'Mouse & Touchpad',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure input device settings',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 48),
            const Tabs(),
            const SizedBox(height: 24),
            const TabContent(),
            const SizedBox(height: 32),
            const TestButton(),
          ],
        ),
      ),
    );
  }
}
