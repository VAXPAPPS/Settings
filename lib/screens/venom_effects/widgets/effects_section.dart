import 'package:flutter/material.dart';
import 'package:antidote/core/glassmorphic_container.dart';

class EffectsSection extends StatelessWidget {
  final bool pulseEnabled;
  final bool flashEnabled;
  final bool neonEnabled;
  final bool chromaticEnabled;
  final bool shockwaveEnabled;
  final bool pixelationEnabled;
  final bool radialZoomEnabled;
  final ValueChanged<bool>? onPulseChanged;
  final ValueChanged<bool>? onFlashChanged;
  final ValueChanged<bool>? onNeonChanged;
  final ValueChanged<bool>? onChromaticChanged;
  final ValueChanged<bool>? onShockwaveChanged;
  final ValueChanged<bool>? onPixelationChanged;
  final ValueChanged<bool>? onRadialZoomChanged;

  const EffectsSection({
    super.key,
    this.pulseEnabled = false,
    this.flashEnabled = false,
    this.neonEnabled = false,
    this.chromaticEnabled = false,
    this.shockwaveEnabled = false,
    this.pixelationEnabled = false,
    this.radialZoomEnabled = false,
    this.onPulseChanged,
    this.onFlashChanged,
    this.onNeonChanged,
    this.onChromaticChanged,
    this.onShockwaveChanged,
    this.onPixelationChanged,
    this.onRadialZoomChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Audio Visualizer Effects',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _EffectTile(
            title: '💓 Beat Pulse',
            description: 'Shadow breathing with music beats',
            enabled: pulseEnabled,
            onChanged: onPulseChanged,
          ),
          _EffectTile(
            title: '🌈 Vibrant Flashes',
            description: 'Random color flashes on peaks',
            enabled: flashEnabled,
            onChanged: onFlashChanged,
          ),
          _EffectTile(
            title: '🎨 Neon Aura',
            description: 'Rotating spectrum glow',
            enabled: neonEnabled,
            onChanged: onNeonChanged,
          ),
          _EffectTile(
            title: '⚡ Chromatic Glitch',
            description: 'RGB split on high frequencies',
            enabled: chromaticEnabled,
            onChanged: onChromaticChanged,
          ),
          _EffectTile(
            title: '🌊 Bass Shockwaves',
            description: 'Ripple distortion on bass drops',
            enabled: shockwaveEnabled,
            onChanged: onShockwaveChanged,
          ),
          _EffectTile(
            title: '👾 Pixelation',
            description: '8-bit mosaic on intense moments',
            enabled: pixelationEnabled,
            onChanged: onPixelationChanged,
          ),
          _EffectTile(
            title: '🚀 Radial Zoom',
            description: 'Warp speed blur on snare hits',
            enabled: radialZoomEnabled,
            onChanged: onRadialZoomChanged,
          ),
        ],
      ),
    );
  }
}

class _EffectTile extends StatelessWidget {
  final String title;
  final String description;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  const _EffectTile({
    required this.title,
    required this.description,
    required this.enabled,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white.withAlpha((255 * 0.1).round()),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: enabled
            ? Colors.white.withAlpha((255 * 0.08).round())
            : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onChanged,
            activeColor: const Color.fromARGB(255, 64, 200, 255),
          ),
        ],
      ),
    );
  }
}
