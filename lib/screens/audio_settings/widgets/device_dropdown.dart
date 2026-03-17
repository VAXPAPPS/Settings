import 'package:flutter/material.dart';
import 'package:settings/core/services/audio_service.dart';

class DeviceDropdown extends StatelessWidget {
  final String label;
  final AudioDevice? selectedDevice;
  final List<AudioDevice> devices;
  final IconData icon;
  final ValueChanged<AudioDevice> onChanged;

  const DeviceDropdown({
    super.key,
    required this.label,
    required this.selectedDevice,
    required this.devices,
    required this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.white70),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButton<AudioDevice>(
            value: devices.contains(selectedDevice) ? selectedDevice : null,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color.fromARGB(255, 18, 22, 32),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            hint: const Text(
              'Select device',
              style: TextStyle(color: Colors.white54),
            ),
            items: devices.map((device) {
              return DropdownMenuItem<AudioDevice>(
                value: device,
                child: Text(
                  device.description,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) onChanged(newValue);
            },
          ),
        ),
      ],
    );
  }
}
