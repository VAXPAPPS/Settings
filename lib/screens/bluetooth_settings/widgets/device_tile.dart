import 'package:settings/core/glassmorphic_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/bluetooth_settings/bluetooth_settings.dart';

class DeviceTile extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceTile({super.key, required this.device});

  IconData _getDeviceIcon() {
    switch (device.icon) {
      case 'audio-headset':
        return Icons.headset;
      case 'audio-headphones':
        return Icons.headphones;
      case 'phone':
        return Icons.phone_android;
      case 'computer':
        return Icons.computer;
      case 'input-keyboard':
        return Icons.keyboard;
      case 'input-mouse':
        return Icons.mouse;
      default:
        return device.connected ? Icons.bluetooth_connected : Icons.bluetooth;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 90,
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: device.connected
                  ? Colors.blue.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getDeviceIcon(),
              color: device.connected
                  ? Colors.blueAccent
                  : (device.paired ? Colors.white : Colors.white54),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  device.name.isEmpty ? device.address : device.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: device.connected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (device.paired)
                      _statusChip('Paired', Colors.greenAccent),
                    if (device.connected) ...[
                      const SizedBox(width: 6),
                      _statusChip('Connected', Colors.blueAccent),
                    ],
                    if (device.trusted) ...[
                      const SizedBox(width: 6),
                      _statusChip('Trusted', Colors.orangeAccent),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pair button (for unpaired devices)
              if (!device.paired)
                _actionButton(
                  context,
                  icon: Icons.link,
                  tooltip: 'Pair',
                  color: Colors.tealAccent,
                  onPressed: () => context.read<BluetoothSettingsBloc>().add(
                    PairDevice(device.address),
                  ),
                ),
              // Connect button (for paired but not connected)
              if (device.paired && !device.connected)
                _actionButton(
                  context,
                  icon: Icons.bluetooth_connected,
                  tooltip: 'Connect',
                  color: Colors.blueAccent,
                  onPressed: () => context.read<BluetoothSettingsBloc>().add(
                    ConnectDevice(device.address),
                  ),
                ),
              // Disconnect button (for connected devices)
              if (device.connected)
                _actionButton(
                  context,
                  icon: Icons.bluetooth_disabled,
                  tooltip: 'Disconnect',
                  color: Colors.orangeAccent,
                  onPressed: () => context.read<BluetoothSettingsBloc>().add(
                    DisconnectDevice(device.address),
                  ),
                ),
              // Remove button
              if (device.paired)
                _actionButton(
                  context,
                  icon: Icons.delete_outline,
                  tooltip: 'Remove',
                  color: Colors.redAccent,
                  onPressed: () => _confirmRemove(context),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      color: color,
      tooltip: tooltip,
      onPressed: onPressed,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
    );
  }

  void _confirmRemove(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text(
          'Remove Device',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove "${device.name.isEmpty ? device.address : device.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BluetoothSettingsBloc>().add(
                RemoveDevice(device.address),
              );
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
