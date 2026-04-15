import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/wifi_settings/wifi_settings.dart';
import 'package:settings/core/glassmorphic_container.dart';

class NetworkTile extends StatelessWidget {
  final WiFiNetwork network;
  final bool isConnecting;
  final VoidCallback? onSettingsTap;

  const NetworkTile({
    super.key,
    required this.network,
    required this.isConnecting,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 72,
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            network.strength > 80
                ? Icons.wifi_rounded
                : network.strength > 60
                ? Icons.network_wifi_3_bar_rounded
                : network.strength > 40
                ? Icons.network_wifi_2_bar_rounded
                : Icons.network_wifi_1_bar_rounded,
            color: network.connected ? Colors.tealAccent : Colors.white54,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        network.ssid.isEmpty ? network.bssid : network.ssid,
                        style: TextStyle(
                          color: network.connected
                              ? Colors.white
                              : Colors.white70,
                          fontWeight: network.connected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (network.secured)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          Icons.lock_rounded,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  network.connected
                      ? 'Connected'
                      : '${network.band} • ${network.strength}%',
                  style: TextStyle(
                    color: network.connected
                        ? Colors.tealAccent
                        : Colors.white38,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isConnecting)
            const SizedBox(
              width: 24,
              height: 24,
              child: CupertinoActivityIndicator(color: Colors.tealAccent),
            )
          else if (network.connected)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Settings icon for connected network
                IconButton(
                  icon: const Icon(Icons.settings_rounded, size: 20),
                  color: Colors.white54,
                  onPressed: onSettingsTap,
                  tooltip: 'Network Settings',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36,
                    minHeight: 36,
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.tealAccent,
                  size: 22,
                ),
              ],
            )
          else
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.read<WiFiSettingsBloc>().add(
                  ConnectToNetwork(network, ''),
                ),
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'Connect',
                    style: TextStyle(
                      color: Color.fromARGB(255, 100, 200, 255),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
