import 'package:settings/core/glassmorphic_container.dart';
import 'package:settings/features/power_settings/power_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PowerTimersSection extends StatelessWidget {
  const PowerTimersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerSettingsBloc, PowerSettingsState>(
      builder: (context, state) {
        // Convert seconds to minutes for sliders
        final dimMinutes = state.dimTimeout / 60.0;
        final blankMinutes = state.blankTimeout / 60.0;
        final suspendMinutes = state.suspendTimeout / 60.0;

        return GlassmorphicContainer(
          width: double.infinity,
          height: null,
          borderRadius: 8,
          padding: const EdgeInsets.all(24),
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Power Saving Timers',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildTimerSlider(
                context: context,
                title: 'Dim Screen',
                value: dimMinutes,
                onChanged: (value) {
                  context.read<PowerSettingsBloc>().add(
                    SetIdleTimeouts(
                      dim: (value * 60).round(),
                      blank: state.blankTimeout,
                      suspend: state.suspendTimeout,
                    ),
                  );
                },
                icon: Icons.brightness_medium_rounded,
              ),
              const SizedBox(height: 24),
              _buildTimerSlider(
                context: context,
                title: 'Screen Off',
                value: blankMinutes,
                onChanged: (value) {
                  context.read<PowerSettingsBloc>().add(
                    SetIdleTimeouts(
                      dim: state.dimTimeout,
                      blank: (value * 60).round(),
                      suspend: state.suspendTimeout,
                    ),
                  );
                },
                icon: Icons.screen_lock_portrait_rounded,
              ),
              const SizedBox(height: 24),
              _buildTimerSlider(
                context: context,
                title: 'System Sleep',
                value: suspendMinutes,
                onChanged: (value) {
                  context.read<PowerSettingsBloc>().add(
                    SetIdleTimeouts(
                      dim: state.dimTimeout,
                      blank: state.blankTimeout,
                      suspend: (value * 60).round(),
                    ),
                  );
                },
                icon: Icons.bedtime_rounded,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerSlider({
    required BuildContext context,
    required String title,
    required double value,
    required ValueChanged<double> onChanged,
    required IconData icon,
  }) {
    // Clamp value to safe range for slider
    final sliderValue = value.clamp(0.0, 60.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
            const Spacer(),
            Text(
              _formatDuration(sliderValue),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color.fromARGB(255, 0, 253, 232),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: Colors.white,
            overlayColor: const Color.fromARGB(255, 0, 253, 232).withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: sliderValue,
            min: 0,
            max: 60,
            divisions: 60,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  String _formatDuration(double minutes) {
    if (minutes <= 0) return 'Never';
    if (minutes < 1) return '${(minutes * 60).round()} sec';
    return '${minutes.round()} min';
  }
}
