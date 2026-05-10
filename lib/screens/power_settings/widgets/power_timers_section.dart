import 'package:settings/core/glassmorphic_container.dart';
import 'package:settings/features/power_settings/power_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// قسم مؤقتات حفظ الطاقة — تُكتب إلى ملف config الخاص بـ aetheridle
/// ويُعاد تشغيل aetheridle تلقائياً عند أي تغيير.
class PowerTimersSection extends StatelessWidget {
  const PowerTimersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerSettingsBloc, PowerSettingsState>(
      buildWhen: (prev, curr) =>
          prev.dimTimeout != curr.dimTimeout ||
          prev.blankTimeout != curr.blankTimeout ||
          prev.suspendTimeout != curr.suspendTimeout,
      builder: (context, state) {
        // تحويل الثواني إلى دقائق للـ sliders
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
              Row(
                children: [
                  const Text(
                    'Power Saving Timers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  Tooltip(
                    message: 'Managed by aetheridle',
                    child: Opacity(
                      opacity: 0.4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.timer_outlined,
                              size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'aetheridle',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Dim Screen
              _buildTimerSlider(
                context: context,
                title: 'Dim Screen',
                subtitle: 'Reduces brightness when idle',
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
                color: const Color(0xFF64B5F6),
              ),
              const SizedBox(height: 24),

              // ── Screen Off
              _buildTimerSlider(
                context: context,
                title: 'Screen Off',
                subtitle: 'Turns off display output',
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
                color: const Color(0xFF81C784),
              ),
              const SizedBox(height: 24),

              // ── System Sleep
              _buildTimerSlider(
                context: context,
                title: 'System Sleep',
                subtitle: 'Suspends the system (systemctl suspend)',
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
                color: const Color(0xFFCE93D8),
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
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
    required IconData icon,
    required Color color,
  }) {
    final sliderValue = value.clamp(0.0, 60.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: sliderValue <= 0
                    ? Colors.white.withValues(alpha: 0.05)
                    : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _formatDuration(sliderValue),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: sliderValue <= 0 ? Colors.white38 : color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            thumbColor: Colors.white,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
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
