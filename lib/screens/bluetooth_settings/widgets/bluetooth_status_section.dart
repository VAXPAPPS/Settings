import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/bluetooth_settings/bluetooth_settings.dart';
import 'package:settings/core/glassmorphic_container.dart';

class BluetoothStatusSection extends StatelessWidget {
  const BluetoothStatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothSettingsBloc, BluetoothSettingsState>(
      buildWhen: (previous, current) =>
          previous.adapterStatus != current.adapterStatus ||
          previous.bluetoothEnabled != current.bluetoothEnabled,
      builder: (context, state) {
        final adapter = state.adapterStatus;
        if (adapter == null || !state.bluetoothEnabled) {
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
                      color: Colors.blue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bluetooth,
                      color: Colors.blueAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          adapter.name.isNotEmpty
                              ? adapter.name
                              : 'Bluetooth Adapter',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: adapter.powered
                                    ? Colors.greenAccent
                                    : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              adapter.powered ? 'Active' : 'Inactive',
                              style: TextStyle(
                                color: adapter.powered
                                    ? Colors.greenAccent.withValues(alpha: 0.8)
                                    : Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                            if (adapter.discovering) ...[
                              const SizedBox(width: 12),
                              Icon(
                                Icons.search,
                                size: 14,
                                color: Colors.blueAccent.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Scanning...',
                                style: TextStyle(
                                  color: Colors.blueAccent.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (adapter.address.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white12),
                const SizedBox(height: 8),
                _infoRow('Address', adapter.address),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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
