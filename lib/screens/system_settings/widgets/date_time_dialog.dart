import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:settings/features/system_settings/services/system_service.dart';

class DateTimeDialog extends StatefulWidget {
  const DateTimeDialog({super.key});

  @override
  State<DateTimeDialog> createState() => _DateTimeDialogState();
}

class _DateTimeDialogState extends State<DateTimeDialog> {
  final _service = SystemService();

  bool _automaticTime = true;
  bool _automaticTimezone = true;
  String _timezone = 'UTC';
  List<String> _timezones = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDateTimeSettings();
  }

  Future<void> _loadDateTimeSettings() async {
    try {
      final results = await Future.wait([
        _service.getCurrentTimezone(),
        _service.getAvailableTimezones(),
        _service.isAutomaticTimeEnabled(),
      ]);

      if (!mounted) return;
      setState(() {
        _timezone = results[0] as String;
        _timezones = results[1] as List<String>;
        _automaticTime = results[2] as bool;
        _loading = false;

        // Ensure current TZ is in the list
        if (_timezone.isNotEmpty && !_timezones.contains(_timezone)) {
          _timezones = [_timezone, ..._timezones];
        }
      });
    } catch (e) {
      debugPrint('Load date time settings error: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _setAutomaticTime(bool enabled) async {
    setState(() => _automaticTime = enabled);
    await _service.setAutomaticTime(enabled);
  }

  Future<void> _setTimezone(String tz) async {
    final ok = await _service.setTimezone(tz);
    if (!mounted) return;
    if (ok) {
      setState(() => _timezone = tz);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requires administrator privileges')),
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
              color: const Color.fromARGB(100, 0, 0, 0),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            child: _loading
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date & Time',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildToggleSetting(
                        'Automatic Time',
                        _automaticTime,
                        _setAutomaticTime,
                      ),
                      const SizedBox(height: 16),
                      _buildToggleSetting(
                        'Automatic Timezone',
                        _automaticTimezone,
                        (value) => setState(() => _automaticTimezone = value),
                      ),
                      const SizedBox(height: 16),
                      _buildTimezoneDropdown(),
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
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _buildTimezoneDropdown() {
    final uniqueTimezones = _timezones.toSet().toList()..sort();
    final displayValue = uniqueTimezones.contains(_timezone) ? _timezone : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timezone',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: displayValue,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color.fromARGB(255, 18, 22, 32),
            style: const TextStyle(color: Colors.white),
            hint: Text(
              _timezone.isNotEmpty ? _timezone : 'Select timezone',
              style: const TextStyle(color: Colors.white70),
            ),
            items: uniqueTimezones.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: (newValue) {
              if (newValue != null) _setTimezone(newValue);
            },
          ),
        ),
      ],
    );
  }
}
