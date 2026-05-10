import 'dart:io';
import 'package:flutter/material.dart';

class SecureShellDialog extends StatefulWidget {
  const SecureShellDialog({super.key});

  @override
  State<SecureShellDialog> createState() => _SecureShellDialogState();
}

class _SecureShellDialogState extends State<SecureShellDialog> {
  bool _sshEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSSHSettings();
  }

  Future<void> _loadSSHSettings() async {
    try {
      final result = await Process.run('systemctl', ['is-active', 'ssh']);
      setState(() => _sshEnabled = result.exitCode == 0);
    } catch (e) {
      
      try {
        final result2 = await Process.run('systemctl', ['is-active', 'sshd']);
        setState(() => _sshEnabled = result2.exitCode == 0);
      } catch (_) {}
    }
  }

  Future<void> _setSSH(bool enabled) async {
    try {
      final serviceName = _sshEnabled ? 'ssh' : 'sshd';
      if (enabled) {
        await Process.run('sudo', ['systemctl', 'enable', serviceName]);
        await Process.run('sudo', ['systemctl', 'start', serviceName]);
      } else {
        await Process.run('sudo', ['systemctl', 'stop', serviceName]);
        await Process.run('sudo', ['systemctl', 'disable', serviceName]);
      }
      setState(() => _sshEnabled = enabled);
    } catch (e) {
      debugPrint('Set SSH error: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requires administrator privileges')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 18, 22, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Secure Shell',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildToggleSetting(
              'SSH',
              _sshEnabled,
              'Enable SSH network access to this device',
              _setSSH,
            ),
            const SizedBox(height: 16),
            if (_sshEnabled) ...[
              FutureBuilder<String>(
                future: _getSSHInfo(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        snapshot.data!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ],
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => // ignore: use_build_context_synchronously
      Navigator.pop(context),
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
    );
  }

  Future<String> _getSSHInfo() async {
    try {
      final hostname = await Process.run('hostname', []);
      final ipResult = await Process.run('hostname', ['-I']);
      final hostnameStr = hostname.stdout.toString().trim();
      final ipStr = ipResult.stdout.toString().trim().split(' ').first;
      return 'SSH is enabled\nConnect using: ssh $hostnameStr@$ipStr';
    } catch (e) {
      return 'SSH is enabled';
    }
  }

  Widget _buildToggleSetting(
    String label,
    bool value,
    String? description,
    ValueChanged<bool> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.blueAccent,
            ),
          ],
        ),
      ],
    );
  }
}
