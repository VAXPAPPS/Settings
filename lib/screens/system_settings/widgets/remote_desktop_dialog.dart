import 'dart:io';
import 'package:flutter/material.dart';

class RemoteDesktopDialog extends StatefulWidget {
  const RemoteDesktopDialog({super.key});

  @override
  State<RemoteDesktopDialog> createState() => _RemoteDesktopDialogState();
}

class _RemoteDesktopDialogState extends State<RemoteDesktopDialog> {
  bool _remoteDesktopEnabled = false;
  bool _screenSharingEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadRemoteDesktopSettings();
  }

  Future<void> _loadRemoteDesktopSettings() async {
    try {
      
      final vncResult = await Process.run('systemctl', [
        'is-active',
        'vino-server',
      ]);
      setState(() => _remoteDesktopEnabled = vncResult.exitCode == 0);

      
      final sharingResult = await Process.run('gsettings', [
        'get',
        'org.gnome.desktop.remote-desktop.rdp',
        'enable',
      ]);
      if (sharingResult.exitCode == 0) {
        setState(
          () => _screenSharingEnabled =
              sharingResult.stdout.toString().trim() == 'true',
        );
      }
    } catch (e) {
      debugPrint('Load remote desktop settings error: $e');
    }
  }

  Future<void> _setRemoteDesktop(bool enabled) async {
    try {
      if (enabled) {
        await Process.run('systemctl', ['--user', 'enable', 'vino-server']);
        await Process.run('systemctl', ['--user', 'start', 'vino-server']);
      } else {
        await Process.run('systemctl', ['--user', 'stop', 'vino-server']);
        await Process.run('systemctl', ['--user', 'disable', 'vino-server']);
      }
      setState(() => _remoteDesktopEnabled = enabled);
    } catch (e) {
      debugPrint('Set remote desktop error: $e');
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
              'Remote Desktop',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildToggleSetting(
              'Remote Desktop',
              _remoteDesktopEnabled,
              'Allow remote connections to this device',
              _setRemoteDesktop,
            ),
            const SizedBox(height: 16),
            _buildToggleSetting(
              'Screen Sharing',
              _screenSharingEnabled,
              'Allow others to view your screen',
              (value) => setState(() => _screenSharingEnabled = value),
            ),
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
