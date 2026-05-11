import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:settings/features/system_settings/services/system_service.dart';

class RegionLanguageDialog extends StatefulWidget {
  const RegionLanguageDialog({super.key});

  @override
  State<RegionLanguageDialog> createState() => _RegionLanguageDialogState();
}

class _RegionLanguageDialogState extends State<RegionLanguageDialog> {
  final _service = SystemService();

  String _currentLocale = '';
  String _currentLanguage = 'English (US)';
  String _currentRegion   = 'United States';

  // Mapping from locale prefix → display name
  static const _languageMap = {
    'en': 'English (US)',
    'ar': 'Arabic',
    'fr': 'French',
    'de': 'German',
    'es': 'Spanish',
  };

  @override
  void initState() {
    super.initState();
    _loadLanguageSettings();
  }

  Future<void> _loadLanguageSettings() async {
    try {
      final locale = await _service.getCurrentLanguage();
      if (!mounted) return;
      setState(() {
        _currentLocale = locale;
        // Map locale prefix to display name
        final prefix = locale.split('_').first.toLowerCase();
        _currentLanguage = _languageMap[prefix] ?? 'English (US)';
        // Map locale country code to region display name
        if (locale.contains('_')) {
          final country = locale.split('_')[1].split('.').first.toUpperCase();
          switch (country) {
            case 'US': _currentRegion = 'United States'; break;
            case 'GB': _currentRegion = 'United Kingdom'; break;
            case 'CA': _currentRegion = 'Canada'; break;
            case 'AU': _currentRegion = 'Australia'; break;
            case 'SA':
            case 'AE': _currentRegion = 'United States'; break;
            default:   _currentRegion = 'United States';
          }
        }
      });
    } catch (e) {
      debugPrint('Load language settings error: $e');
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
            const SizedBox(height: 8),
            if (_currentLocale.isNotEmpty)
              Text(
                'Current locale: $_currentLocale',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            const SizedBox(height: 16),
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
