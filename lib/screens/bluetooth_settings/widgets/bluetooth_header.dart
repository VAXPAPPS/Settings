import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/bluetooth_settings/bluetooth_settings.dart';

class BluetoothHeader extends StatelessWidget {
  const BluetoothHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothSettingsBloc, BluetoothSettingsState>(
      buildWhen: (previous, current) =>
          previous.bluetoothEnabled != current.bluetoothEnabled ||
          previous.adapterStatus != current.adapterStatus ||
          previous.status != current.status,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bluetooth',
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Manage paired and nearby devices',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    if (state.adapterStatus != null &&
                        state.adapterStatus!.name.isNotEmpty)
                      Text(
                        state.adapterStatus!.name,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      state.bluetoothEnabled ? 'On' : 'Off',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Switch(
                      value: state.bluetoothEnabled,
                      onChanged: state.status == BluetoothSettingsStatus.loading
                          ? null
                          : (value) => context
                                .read<BluetoothSettingsBloc>()
                                .add(ToggleBluetooth(value)),
                      activeTrackColor: Colors.blueAccent.withValues(
                        alpha: 0.5,
                      ),
                      activeThumbColor: Colors.blueAccent,
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
