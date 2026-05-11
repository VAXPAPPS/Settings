import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:settings/features/system_settings/services/system_service.dart';

class SystemAboutDialog extends StatefulWidget {
  const SystemAboutDialog({super.key});

  @override
  State<SystemAboutDialog> createState() => _SystemAboutDialogState();
}

class _SystemAboutDialogState extends State<SystemAboutDialog> {
  final _service = SystemService();

  String _hostname = 'Loading…';
  String _osVersion = 'Loading…';
  String _kernel = 'Loading…';
  String _cpu = 'Loading…';
  String _memory = 'Loading…';
  String _disk = 'Loading…';

  @override
  void initState() {
    super.initState();
    _loadSystemInfo();
  }

  Future<void> _loadSystemInfo() async {
    final results = await Future.wait([
      _service.getHostname(),
      _service.getOSName(),
      _service.getKernelVersion(),
      _service.getCPUInfo(),
      _service.getTotalMemory(),
      _service.getDiskInfo(),
    ]);
    if (!mounted) return;
    setState(() {
      _hostname = results[0].isEmpty ? 'Unknown' : results[0];
      _osVersion = results[1].isEmpty ? 'Unknown' : results[1];
      _kernel = results[2].isEmpty ? 'Unknown' : results[2];
      _cpu = results[3].isEmpty ? 'Unknown' : results[3];
      _memory = results[4].isEmpty ? 'Unknown' : results[4];
      _disk = results[5].isEmpty ? 'Unknown' : results[5];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color.fromARGB(100, 0, 0, 0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoRow('Hostname', _hostname),
                const SizedBox(height: 12),
                _buildInfoRow('OS Version', _osVersion),
                const SizedBox(height: 12),
                _buildInfoRow('Kernel', _kernel),
                const SizedBox(height: 12),
                _buildInfoRow('CPU', _cpu),
                const SizedBox(height: 12),
                _buildInfoRow('Memory', _memory),
                const SizedBox(height: 12),
                _buildInfoRow('Disk', _disk),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
