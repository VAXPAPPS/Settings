import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:settings/core/services/network_manager_service.dart';

class NetworkSettingsSheet extends StatefulWidget {
  final ConnectionDetails details;
  final NetworkManagerService service;
  final VoidCallback onSaved;
  final VoidCallback? onForget;

  const NetworkSettingsSheet({
    super.key,
    required this.details,
    required this.service,
    required this.onSaved,
    this.onForget,
  });

  @override
  State<NetworkSettingsSheet> createState() => _NetworkSettingsSheetState();
}

class _NetworkSettingsSheetState extends State<NetworkSettingsSheet> {
  late bool _isDhcp;
  late bool _autoConnect;
  final _ipCtrl = TextEditingController();
  final _gwCtrl = TextEditingController();
  final _subnetCtrl = TextEditingController();
  final _dns1Ctrl = TextEditingController();
  final _dns2Ctrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _isDhcp = widget.details.isDhcp;
    _autoConnect = widget.details.autoConnect;
    _ipCtrl.text = widget.details.ipAddress;
    _gwCtrl.text = widget.details.gateway;
    _subnetCtrl.text = widget.details.subnet.isEmpty
        ? '24'
        : widget.details.subnet;
    final dnsParts = widget.details.dns.split(', ');
    _dns1Ctrl.text = dnsParts.isNotEmpty ? dnsParts[0] : '';
    _dns2Ctrl.text = dnsParts.length > 1 ? dnsParts[1] : '';
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _gwCtrl.dispose();
    _subnetCtrl.dispose();
    _dns1Ctrl.dispose();
    _dns2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final ssid = widget.details.ssid;

    await widget.service.setAutoConnect(ssid, _autoConnect);

    if (_isDhcp) {
      await widget.service.setDHCP(ssid);
    } else {
      await widget.service.setStaticIP(
        ssid,
        _ipCtrl.text,
        _gwCtrl.text,
        _subnetCtrl.text,
        _dns1Ctrl.text,
      );
    }

    if (_dns1Ctrl.text.isNotEmpty || _dns2Ctrl.text.isNotEmpty) {
      await widget.service.setDNS(ssid, _dns1Ctrl.text, _dns2Ctrl.text);
    }

    setState(() => _saving = false);
    widget.onSaved();
  }

  Future<void> _forgetNetwork() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color.fromARGB(50, 0, 0, 0),
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
                    'Forget Network',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to forget "${widget.details.ssid}"?',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Forget', style: TextStyle(color: Colors.redAccent)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await widget.service.forgetNetwork(widget.details.ssid);
      if (mounted) {
        // Call onForget BEFORE pop to refresh data while context is valid
        widget.onForget?.call();
        // ignore: use_build_context_synchronously
      Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(50, 0, 0, 0),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.tealAccent),
                const SizedBox(width: 8),
                Text(
                  widget.details.ssid,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Auto-connect
            _buildSwitch(
              title: 'Auto-connect',
              subtitle: 'Connect automatically when in range',
              icon: Icons.autorenew,
              value: _autoConnect,
              onChanged: (v) => setState(() => _autoConnect = v),
            ),
            const Divider(color: Colors.white12, height: 32),

            // DHCP
            _buildSwitch(
              title: 'DHCP',
              subtitle: _isDhcp ? 'Obtain IP automatically' : 'Static IP',
              icon: Icons.public,
              value: _isDhcp,
              onChanged: (v) => setState(() => _isDhcp = v),
            ),

            // Static IP fields
            if (!_isDhcp) ...[
              const SizedBox(height: 20),
              _buildTextField(_ipCtrl, 'IP Address', '192.168.1.100'),
              const SizedBox(height: 12),
              _buildTextField(_gwCtrl, 'Gateway', '192.168.1.1'),
              const SizedBox(height: 12),
              _buildTextField(
                _subnetCtrl,
                'Subnet Prefix',
                '24',
                isNumber: true,
              ),
            ],

            const SizedBox(height: 20),
            const Text(
              'DNS Servers',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(_dns1Ctrl, 'Primary DNS', '8.8.8.8'),
            const SizedBox(height: 12),
            _buildTextField(_dns2Ctrl, 'Secondary DNS', '8.8.4.4'),

            const SizedBox(height: 32),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _forgetNetwork,
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Forget'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: Text(_saving ? 'Saving...' : 'Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
        ),
      ),
    );
  }

  Widget _buildSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.tealAccent, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: Colors.tealAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.tealAccent),
        ),
      ),
    );
  }
}
