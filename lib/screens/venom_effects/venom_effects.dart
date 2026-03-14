import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:antidote/screens/venom_effects/widgets/shadows_section.dart';
import 'package:antidote/screens/venom_effects/widgets/blur_section.dart';
import 'package:antidote/screens/venom_effects/widgets/animations_section.dart';
import 'package:antidote/screens/venom_effects/widgets/geometry_section.dart';
import 'package:antidote/screens/venom_effects/widgets/effects_section.dart';

class CompositorSettingsPage extends StatefulWidget {
  const CompositorSettingsPage({Key? key}) : super(key: key);

  @override
  State<CompositorSettingsPage> createState() => _CompositorSettingsPageState();
}

class _CompositorSettingsPageState extends State<CompositorSettingsPage> {
  bool _isLoading = true;
  
  // ignore: unused_field
  String? _errorMessage;
  Timer? _debounce;
  final String _configPath =
      '${Platform.environment['HOME']}/.config/venom-miasma/venom.conf';

  
  bool _shadowEnabled = true;
  double _shadowRadius = 35.0;
  double _shadowOpacity = 0.5;
  double _shadowRed = 0.0;
  double _shadowGreen = 0.0;
  double _shadowBlue = 0.0;

  
  bool _blurEnabled = true;
  double _blurStrength = 5.0;

  
  bool _fadingEnabled = true;
  double _fadeSpeed = 50.0; 

  
  double _cornerRadius = 10.0;

  bool _audioVisualizerEnabled = true;
  bool _neonAutoColorEnabled = true;
  double _neonGlowIntensity = 21.8;
  bool _effectPulse = false;
  bool _effectFlash = false;
  bool _effectNeon = true;
  bool _effectChromatic = true;
  bool _effectShockwave = false;
  bool _effectPixelation = false;
  bool _effectRadialZoom = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _resetToDefaults() {
    setState(() {
      _shadowEnabled = true;
      _shadowRadius = 35.0;
      _shadowOpacity = 0.5;
      _shadowRed = 0.0;
      _shadowGreen = 0.0;
      _shadowBlue = 0.0;

      _blurEnabled = true;
      _blurStrength = 5.0;

      _fadingEnabled = true;
      _fadeSpeed = 70.0; 

      _cornerRadius = 10.0;
      
      _audioVisualizerEnabled = true;
      _neonAutoColorEnabled = true;
      _neonGlowIntensity = 21.8;
      _effectPulse = false;
      _effectFlash = false;
      _effectNeon = true;
      _effectChromatic = true;
      _effectShockwave = false;
      _effectPixelation = false;
      _effectRadialZoom = false;

      _updateConfig();
    });
  }

  Future<void> _loadConfig() async {
    try {
      final file = File(_configPath);
      if (!await file.exists()) throw Exception("Config file not found");
      final content = await file.readAsString();

      setState(() {
        
        final shadowMatch = RegExp(
          r'^\s*shadow\s*=\s*(true|false)',
          multiLine: true,
        ).firstMatch(content);
        if (shadowMatch != null)
          _shadowEnabled = shadowMatch.group(1) == 'true';

        final sRadiusMatch = RegExp(
          r'^\s*shadow-radius\s*=\s*(\d+)',
          multiLine: true,
        ).firstMatch(content);
        if (sRadiusMatch != null)
          _shadowRadius = double.tryParse(sRadiusMatch.group(1)!) ?? 35.0;

        final sOpacityMatch = RegExp(
          r'^\s*shadow-opacity\s*=\s*([\d\.]+)',
          multiLine: true,
        ).firstMatch(content);
        if (sOpacityMatch != null)
          _shadowOpacity = double.tryParse(sOpacityMatch.group(1)!) ?? 0.5;

        
        final sRedMatch = RegExp(
          r'^\s*shadow-red\s*=\s*([\d\.]+)',
          multiLine: true,
        ).firstMatch(content);
        if (sRedMatch != null)
          _shadowRed = double.tryParse(sRedMatch.group(1)!) ?? 0.0;
        final sGreenMatch = RegExp(
          r'^\s*shadow-green\s*=\s*([\d\.]+)',
          multiLine: true,
        ).firstMatch(content);
        if (sGreenMatch != null)
          _shadowGreen = double.tryParse(sGreenMatch.group(1)!) ?? 0.0;
        final sBlueMatch = RegExp(
          r'^\s*shadow-blue\s*=\s*([\d\.]+)',
          multiLine: true,
        ).firstMatch(content);
        if (sBlueMatch != null)
          _shadowBlue = double.tryParse(sBlueMatch.group(1)!) ?? 0.0;

        
        final bStrengthMatch = RegExp(
          r'strength\s*=\s*(\d+)',
        ).firstMatch(content);
        if (bStrengthMatch != null)
          _blurStrength = double.tryParse(bStrengthMatch.group(1)!) ?? 5.0;

        final bMethodMatch = RegExp(
          r'method\s*=\s*"(\w+)"',
        ).firstMatch(content);
        if (bMethodMatch != null)
          _blurEnabled = (bMethodMatch.group(1) != "none");

        
        final fadeMatch = RegExp(
          r'^\s*fading\s*=\s*(true|false)',
          multiLine: true,
        ).firstMatch(content);
        if (fadeMatch != null) _fadingEnabled = fadeMatch.group(1) == 'true';

        
        final fadeStepMatch = RegExp(
          r'^\s*fade-in-step\s*=\s*([\d\.]+)',
          multiLine: true,
        ).firstMatch(content);
        if (fadeStepMatch != null) {
          double rawStep = double.tryParse(fadeStepMatch.group(1)!) ?? 0.07;
          
          _fadeSpeed = ((rawStep - 0.01) * 1000).clamp(0.0, 100.0);
        }

        
        final cRadiusMatch = RegExp(
          r'^\s*corner-radius\s*=\s*(\d+)',
          multiLine: true,
        ).firstMatch(content);
        if (cRadiusMatch != null)
          _cornerRadius = double.tryParse(cRadiusMatch.group(1)!) ?? 10.0;

        final avMatch = RegExp(r'^\s*audio-visualizer\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (avMatch != null) _audioVisualizerEnabled = avMatch.group(1) == 'true';

        final nacMatch = RegExp(r'^\s*neon-auto-color\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (nacMatch != null) _neonAutoColorEnabled = nacMatch.group(1) == 'true';

        final ngiMatch = RegExp(r'^\s*neon-glow-intensity\s*=\s*([\d\.]+)', multiLine: true).firstMatch(content);
        if (ngiMatch != null) _neonGlowIntensity = double.tryParse(ngiMatch.group(1)!) ?? 21.8;

        final epMatch = RegExp(r'^\s*effect-pulse\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (epMatch != null) _effectPulse = epMatch.group(1) == 'true';

        final efMatch = RegExp(r'^\s*effect-flash\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (efMatch != null) _effectFlash = efMatch.group(1) == 'true';

        final enMatch = RegExp(r'^\s*effect-neon\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (enMatch != null) _effectNeon = enMatch.group(1) == 'true';

        final ecMatch = RegExp(r'^\s*effect-chromatic\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (ecMatch != null) _effectChromatic = ecMatch.group(1) == 'true';

        final esMatch = RegExp(r'^\s*effect-shockwave\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (esMatch != null) _effectShockwave = esMatch.group(1) == 'true';

        final epixMatch = RegExp(r'^\s*effect-pixelation\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (epixMatch != null) _effectPixelation = epixMatch.group(1) == 'true';

        final erzMatch = RegExp(r'^\s*effect-radial-zoom\s*=\s*(true|false)', multiLine: true).firstMatch(content);
        if (erzMatch != null) _effectRadialZoom = erzMatch.group(1) == 'true';

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _updateConfig() async {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      try {
        final file = File(_configPath);
        String content = await file.readAsString();

        String replaceValue(String key, String newValue) {
          return content.replaceAllMapped(
            RegExp(
              r'(^\s*' + RegExp.escape(key) + r'\s*=\s*)([^;]+)',
              multiLine: true,
            ),
            (match) => '${match.group(1)}$newValue',
          );
        }

        String replaceBlockValue(String key, String newValue) {
          return content.replaceAllMapped(
            RegExp(r'(\s*' + RegExp.escape(key) + r'\s*=\s*)([^;]+)'),
            (match) => '${match.group(1)}$newValue',
          );
        }

        
        content = replaceValue('shadow', _shadowEnabled.toString());
        content = replaceValue(
          'shadow-radius',
          _shadowRadius.toInt().toString(),
        );
        content = replaceValue(
          'shadow-opacity',
          _shadowOpacity.toStringAsFixed(2),
        );
        content = replaceValue('shadow-red', _shadowRed.toStringAsFixed(2));
        content = replaceValue('shadow-green', _shadowGreen.toStringAsFixed(2));
        content = replaceValue('shadow-blue', _shadowBlue.toStringAsFixed(2));

        
        content = replaceBlockValue(
          'strength',
          _blurStrength.toInt().toString(),
        );
        content = replaceBlockValue(
          'method',
          _blurEnabled ? '"dual_kawase"' : '"none"',
        );

        
        content = replaceValue('fading', _fadingEnabled.toString());
        
        
        double stepValue = 0.01 + (_fadeSpeed / 1000);
        content = replaceValue('fade-in-step', stepValue.toStringAsFixed(3));
        content = replaceValue('fade-out-step', stepValue.toStringAsFixed(3));

        
        content = replaceValue(
          'corner-radius',
          _cornerRadius.toInt().toString(),
        );

        content = replaceValue('audio-visualizer', _audioVisualizerEnabled.toString());
        content = replaceValue('neon-auto-color', _neonAutoColorEnabled.toString());
        content = replaceValue('neon-glow-intensity', _neonGlowIntensity.toStringAsFixed(1));
        content = replaceValue('effect-pulse', _effectPulse.toString());
        content = replaceValue('effect-flash', _effectFlash.toString());
        content = replaceValue('effect-neon', _effectNeon.toString());
        content = replaceValue('effect-chromatic', _effectChromatic.toString());
        content = replaceValue('effect-shockwave', _effectShockwave.toString());
        content = replaceValue('effect-pixelation', _effectPixelation.toString());
        content = replaceValue('effect-radial-zoom', _effectRadialZoom.toString());

        await file.writeAsString(content);
        debugPrint("Config updated successfully!");
      } catch (e) {
        debugPrint("Error saving config: $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CupertinoActivityIndicator());

    return Stack(
      children: [
        Container(color: const Color.fromARGB(0, 0, 0, 0)),
        Center(
          child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(0, 0, 0, 0),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(28, 0, 0, 0),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 25, 30, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Venom Effects",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.restart_alt_rounded,
                          color: Color(0xFFBB9AF7),
                          size: 28,
                        ),
                        onPressed: _resetToDefaults,
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white10, indent: 30, endIndent: 30),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 10,
                    ),
                    children: [
                      
                      ShadowsSection(
                        enabled: _shadowEnabled,
                        radius: _shadowRadius,
                        opacity: _shadowOpacity,
                        red: _shadowRed,
                        green: _shadowGreen,
                        blue: _shadowBlue,
                        onEnabledChanged: (v) {
                          setState(() => _shadowEnabled = v);
                          _updateConfig();
                        },
                        onRadiusChanged: (v) {
                          setState(() => _shadowRadius = v);
                          _updateConfig();
                        },
                        onOpacityChanged: (v) {
                          setState(() => _shadowOpacity = v);
                          _updateConfig();
                        },
                        onRedChanged: (v) {
                          setState(() => _shadowRed = v);
                          _updateConfig();
                        },
                        onGreenChanged: (v) {
                          setState(() => _shadowGreen = v);
                          _updateConfig();
                        },
                        onBlueChanged: (v) {
                          setState(() => _shadowBlue = v);
                          _updateConfig();
                        },
                      ),

                      const SizedBox(height: 20),

                      
                      BlurSection(
                        enabled: _blurEnabled,
                        strength: _blurStrength,
                        onEnabledChanged: (v) {
                          setState(() => _blurEnabled = v);
                          _updateConfig();
                        },
                        onStrengthChanged: (v) {
                          setState(() => _blurStrength = v);
                          _updateConfig();
                        },
                      ),

                      const SizedBox(height: 20),

                      
                      AnimationsSection(
                        enabled: _fadingEnabled,
                        speed: _fadeSpeed,
                        onEnabledChanged: (v) {
                          setState(() => _fadingEnabled = v);
                          _updateConfig();
                        },
                        onSpeedChanged: (v) {
                          setState(() => _fadeSpeed = v);
                          _updateConfig();
                        },
                      ),

                      const SizedBox(height: 20),

                      
                      GeometrySection(
                        cornerRadius: _cornerRadius,
                        onCornerRadiusChanged: (v) {
                          setState(() => _cornerRadius = v);
                          _updateConfig();
                        },
                      ),
                      const SizedBox(height: 20),

                      EffectsSection(
                        audioVisualizerEnabled: _audioVisualizerEnabled,
                        neonAutoColorEnabled: _neonAutoColorEnabled,
                        neonGlowIntensity: _neonGlowIntensity,
                        pulseEnabled: _effectPulse,
                        flashEnabled: _effectFlash,
                        neonEnabled: _effectNeon,
                        chromaticEnabled: _effectChromatic,
                        shockwaveEnabled: _effectShockwave,
                        pixelationEnabled: _effectPixelation,
                        radialZoomEnabled: _effectRadialZoom,
                        onAudioVisualizerChanged: (v) { setState(() => _audioVisualizerEnabled = v); _updateConfig(); },
                        onNeonAutoColorChanged: (v) { setState(() => _neonAutoColorEnabled = v); _updateConfig(); },
                        onNeonGlowIntensityChanged: (v) { setState(() => _neonGlowIntensity = v); _updateConfig(); },
                        onPulseChanged: (v) { setState(() => _effectPulse = v); _updateConfig(); },
                        onFlashChanged: (v) { setState(() => _effectFlash = v); _updateConfig(); },
                        onNeonChanged: (v) { setState(() => _effectNeon = v); _updateConfig(); },
                        onChromaticChanged: (v) { setState(() => _effectChromatic = v); _updateConfig(); },
                        onShockwaveChanged: (v) { setState(() => _effectShockwave = v); _updateConfig(); },
                        onPixelationChanged: (v) { setState(() => _effectPixelation = v); _updateConfig(); },
                        onRadialZoomChanged: (v) { setState(() => _effectRadialZoom = v); _updateConfig(); },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
