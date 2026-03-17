import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/wifi_settings/wifi_settings.dart';

class NetworksHeader extends StatelessWidget {
  const NetworksHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WiFiSettingsBloc, WiFiSettingsState>(
      buildWhen: (previous, current) =>
          previous.isScanning != current.isScanning ||
          previous.wifiEnabled != current.wifiEnabled,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Available Networks',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (state.isScanning)
              const SizedBox(
                width: 20,
                height: 20,
                child: CupertinoActivityIndicator(
                  color: Color.fromARGB(255, 100, 200, 255),
                ),
              )
            else
              IconButton(
                onPressed: state.wifiEnabled
                    ? () => context.read<WiFiSettingsBloc>().add(
                        const RefreshNetworks(),
                      )
                    : null,
                icon: const Icon(Icons.refresh_rounded),
                color: state.wifiEnabled
                    ? Colors.white54
                    : Colors.white.withValues(alpha: 0.3),
              ),
          ],
        );
      },
    );
  }
}
