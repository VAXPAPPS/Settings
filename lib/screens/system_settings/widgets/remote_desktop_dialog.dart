import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:settings/features/system_settings/services/system_service.dart';

class RemoteDesktopDialog extends StatefulWidget {
  const RemoteDesktopDialog({super.key});

  @override
  State<RemoteDesktopDialog> createState() => _RemoteDesktopDialogState();
}

class _RemoteDesktopDialogState extends State<RemoteDesktopDialog> {
  final _service = SystemService();

  bool _remoteDesktopEnabled  = false;
  bool _screenSharingEnabled  = false;
  bool _loading               = true;

  @override
  void initState() {
    super.initState();
    _loadRemoteDesktopSettings();
  }

  Future<void> _loadRemoteDesktopSettings() async {
    try {
      final enabled = await _service.isRemoteDesktopEnabled();
      if (!mounted) return;
      setState(() {
        _remoteDesktopEnabled = enabled;
        // Screen sharing uses the same backend for now
        _screenSharingEnabled = enabled;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Load remote desktop settings error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setRemoteDesktop(bool enabled) async {
    setState(() => _remoteDesktopEnabled = enabled);
    final ok = await _service.setRemoteDesktopEnabled(enabled);
    if (!mounted) return;
    if (!ok) {
      setState(() => _remoteDesktopEnabled = !enabled);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to change remote desktop state'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
              color: const Color.fromARGB(150, 10, 10, 15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: _loading
            ? const SizedBox(
                height: 160,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
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
