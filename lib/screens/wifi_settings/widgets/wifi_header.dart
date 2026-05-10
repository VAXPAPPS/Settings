import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/wifi_settings/wifi_settings.dart';

class WifiHeader extends StatelessWidget {
  const WifiHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WiFiSettingsBloc, WiFiSettingsState>(
      buildWhen: (previous, current) =>
          previous.wifiEnabled != current.wifiEnabled,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wi-Fi',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Manage wireless networks',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      state.wifiEnabled ? 'On' : 'Off',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: state.wifiEnabled,
                      onChanged: (value) => context
                          .read<WiFiSettingsBloc>()
                          .add(ToggleWiFi(value)),
                      activeThumbColor: const Color.fromARGB(255, 100, 200, 255),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
