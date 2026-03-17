import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/bluetooth_settings/bluetooth_settings.dart';
import 'package:settings/screens/bluetooth_settings/widgets/device_tile.dart';

class DevicesList extends StatelessWidget {
  const DevicesList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothSettingsBloc, BluetoothSettingsState>(
      builder: (context, state) {
        if (state.status == BluetoothSettingsStatus.loading) {
          return const Center(
            child: CupertinoActivityIndicator(color: Colors.blueAccent),
          );
        }

        if (!state.bluetoothEnabled) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth_disabled_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Text(
                  'Bluetooth is turned off',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Turn on Bluetooth to see available devices',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (state.devices.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bluetooth_searching_rounded,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  'No devices found',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: state.devices.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final device = state.devices[index];
            return DeviceTile(device: device);
          },
        );
      },
    );
  }
}
