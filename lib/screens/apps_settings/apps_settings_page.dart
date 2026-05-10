import 'package:flutter/material.dart';
import 'package:venom_config/venom_config.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:settings/screens/apps_settings/widgets/apps_settings_header.dart';
import 'package:settings/screens/apps_settings/widgets/system_theme_color_section.dart';
import 'package:settings/screens/apps_settings/widgets/system_text_color_section.dart';

class AppsSettingsPage extends StatefulWidget {
  const AppsSettingsPage({super.key});

  @override
  State<AppsSettingsPage> createState() => _AppsSettingsPageState();
}

class _AppsSettingsPageState extends State<AppsSettingsPage> {
  
  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
  ];

  Color _currentColor = Colors.blue;
  Color _currentTextColor = Colors.white;
  double _opacity = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppsSettingsHeader(onReset: _resetToDefaults),
            const SizedBox(height: 32),

            
            SystemThemeColorSection(
              currentColor: _currentColor,
              opacity: _opacity,
              presetColors: _presetColors,
              onColorChanged: (color) {
                setState(() {
                  _currentColor = color;
                  _updateConfig(color.withValues(alpha: _opacity));
                });
              },
              onOpacityChanged: (value) {
                setState(() {
                  _opacity = value;
                  _updateConfig(_currentColor.withValues(alpha: _opacity));
                });
              },
              onPickCustomColor: () => _showColorPicker(context),
            ),

            const SizedBox(height: 32),

            
            SystemTextColorSection(
              currentTextColor: _currentTextColor,
              presetColors: _presetColors,
              onColorChanged: (color) {
                setState(() {
                  _currentTextColor = color;
                  _updateTextConfig(color);
                });
              },
              onPickCustomColor: () => _showTextColorPicker(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick Background Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentColor,
              onColorChanged: (color) {
                setState(() {
                  _currentColor = color;
                });
              },
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                _updateConfig(_currentColor.withValues(alpha: _opacity));
                // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showTextColorPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick Text Color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _currentTextColor,
              onColorChanged: (color) {
                setState(() {
                  _currentTextColor = color;
                });
              },
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Got it'),
              onPressed: () {
                _updateTextConfig(_currentTextColor);
                // ignore: use_build_context_synchronously
      Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateConfig(Color color) async {
    String hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    await VenomConfig().set('system.background_color', hex);
  }

  Future<void> _updateTextConfig(Color color) async {
    String hex =
        '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    await VenomConfig().set('system.text_color', hex);
  }

  void _resetToDefaults() {
    setState(() {
      
      _currentColor = const Color.fromARGB(100, 0, 0, 0);
      _opacity = 1.0; 

      
      _currentTextColor = Colors.white;

      
      _updateConfig(_currentColor);
      _updateTextConfig(_currentTextColor);
    });
  }
}
