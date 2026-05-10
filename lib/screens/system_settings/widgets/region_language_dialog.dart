import 'dart:io';
import 'package:flutter/material.dart';

class RegionLanguageDialog extends StatefulWidget {
  const RegionLanguageDialog({super.key});

  @override
  State<RegionLanguageDialog> createState() => _RegionLanguageDialogState();
}

class _RegionLanguageDialogState extends State<RegionLanguageDialog> {
  String _currentLanguage = 'English (US)';
  String _currentRegion = 'United States';

  @override
  void initState() {
    super.initState();
    _loadLanguageSettings();
  }

  Future<void> _loadLanguageSettings() async {
    try {
      
      final langResult = await Process.run('locale', []);
      if (langResult.exitCode == 0) {
        final locale = langResult.stdout.toString();
        
        if (locale.contains('LANG=')) {
          
        }
      }
    } catch (e) {
      debugPrint('Load language settings error: $e');
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
              'Region & Language',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            _buildDropdownSetting(
              'Language',
              _currentLanguage,
              ['English (US)', 'Arabic', 'French', 'German', 'Spanish'],
              (value) => setState(() => _currentLanguage = value),
            ),
            const SizedBox(height: 16),
            _buildDropdownSetting(
              'Region',
              _currentRegion,
              ['United States', 'United Kingdom', 'Canada', 'Australia'],
              (value) => setState(() => _currentRegion = value),
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

  Widget _buildDropdownSetting(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Column(
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
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color.fromARGB(255, 18, 22, 32),
            style: const TextStyle(color: Colors.white),
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
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
