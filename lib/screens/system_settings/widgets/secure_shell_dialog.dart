import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:settings/features/system_settings/services/system_service.dart';

class SecureShellDialog extends StatefulWidget {
  const SecureShellDialog({super.key});

  @override
  State<SecureShellDialog> createState() => _SecureShellDialogState();
}

class _SecureShellDialogState extends State<SecureShellDialog> {
  final _service = SystemService();

  bool _sshEnabled = false;
  bool _loading    = true;
  String? _sshInfo;

  @override
  void initState() {
    super.initState();
    _loadSSHSettings();
  }

  Future<void> _loadSSHSettings() async {
    try {
      final enabled = await _service.isSSHEnabled();
      String? info;
      if (enabled) info = await _service.getSSHInfo();
      if (!mounted) return;
      setState(() {
        _sshEnabled = enabled;
        _sshInfo    = info;
        _loading    = false;
      });
    } catch (e) {
      debugPrint('Load SSH settings error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setSSH(bool enabled) async {
    setState(() => _sshEnabled = enabled);
    final ok = await _service.setSSHEnabled(enabled);
    if (!mounted) return;
    if (ok) {
      // Refresh SSH info after enabling
      if (enabled) {
        final info = await _service.getSSHInfo();
        if (mounted) setState(() => _sshInfo = info);
      } else {
        setState(() => _sshInfo = null);
      }
    } else {
      setState(() => _sshEnabled = !enabled);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Requires administrator privileges'),
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
                  if (_sshEnabled && _sshInfo != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _sshInfo!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
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
