import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/wifi_settings/wifi_settings.dart';
import 'package:settings/core/glassmorphic_container.dart';

class WifiStatusSection extends StatelessWidget {
  const WifiStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WiFiSettingsBloc, WiFiSettingsState>(
      buildWhen: (previous, current) =>
          previous.connectionStatus != current.connectionStatus ||
          previous.wifiEnabled != current.wifiEnabled,
      builder: (context, state) {
        final status = state.connectionStatus;
        if (status == null || !status.connected) {
          return const SizedBox.shrink();
        }

        return GlassmorphicContainer(
          width: double.infinity,
          borderRadius: 12,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.wifi_rounded,
                      color: Colors.tealAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.ssid,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Connected • ${status.strength}% signal',
                          style: TextStyle(
                            color: Colors.tealAccent.withValues(alpha: 0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12),
              const SizedBox(height: 12),

              // Connection details
              _infoRow('IP Address', status.ipAddress),
              _infoRow('Gateway', status.gateway),
              _infoRow('Subnet', status.subnet),
              _infoRow('DNS', status.dns),
              _infoRow('Speed', '${status.speed} Mb/s'),

              const SizedBox(height: 16),

              // Disconnect button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<WiFiSettingsBloc>().add(
                      const DisconnectNetwork(),
                    );
                  },
                  icon: const Icon(Icons.link_off_rounded, size: 18),
                  label: const Text('Disconnect'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: BorderSide(
                      color: Colors.redAccent.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
