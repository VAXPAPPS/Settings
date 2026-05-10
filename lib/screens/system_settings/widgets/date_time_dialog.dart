import 'dart:io';
import 'package:flutter/material.dart';

class DateTimeDialog extends StatefulWidget {
  const DateTimeDialog({super.key});

  @override
  State<DateTimeDialog> createState() => _DateTimeDialogState();
}

class _DateTimeDialogState extends State<DateTimeDialog> {
  bool _automaticTime = true;
  bool _automaticTimezone = true;
  String _timezone = 'UTC';
  List<String> _timezones = [];

  @override
  void initState() {
    super.initState();
    _loadDateTimeSettings();
  }

  Future<void> _loadDateTimeSettings() async {
    try {
      
      final tzResult = await Process.run('timedatectl', [
        'show',
        '--property=Timezone',
        '--value',
      ]);
      if (tzResult.exitCode == 0) {
        setState(() => _timezone = tzResult.stdout.toString().trim());
      }

      
      final listResult = await Process.run('timedatectl', ['list-timezones']);
      if (listResult.exitCode == 0) {
        final allTimezones =
            listResult.stdout
                .toString()
                .split('\n')
                .where((tz) => tz.isNotEmpty)
                .toSet() 
                .toList()
              ..sort();

        setState(() {
          _timezones = allTimezones;
          
          if (!_timezones.contains(_timezone) && _timezone.isNotEmpty) {
            _timezones.insert(0, _timezone);
          }
        });
      }

      
      final autoResult = await Process.run('timedatectl', [
        'show',
        '--property=NTP',
        '--value',
      ]);
      if (autoResult.exitCode == 0) {
        setState(
          () => _automaticTime = autoResult.stdout.toString().trim() == 'yes',
        );
      }
    } catch (e) {
      debugPrint('Load date time settings error: $e');
    }
  }

  Future<void> _setAutomaticTime(bool enabled) async {
    try {
      await Process.run('timedatectl', ['set-ntp', enabled.toString()]);
      setState(() => _automaticTime = enabled);
    } catch (e) {
      debugPrint('Set automatic time error: $e');
    }
  }

  Future<void> _setTimezone(String tz) async {
    try {
      await Process.run('sudo', ['timedatectl', 'set-timezone', tz]);
      setState(() => _timezone = tz);
    } catch (e) {
      debugPrint('Set timezone error: $e');
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
    
    final timezoneList = List<String>.from(_timezones);
    if (_timezone.isNotEmpty && !timezoneList.contains(_timezone)) {
      timezoneList.insert(0, _timezone);
    }

    
    final uniqueTimezones = timezoneList.toSet().toList()..sort();
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
