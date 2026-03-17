import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/display_settings/display_settings.dart';
import 'package:settings/screens/display_settings/widgets/settings_card.dart';

class BrightnessCard extends StatelessWidget {
  const BrightnessCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisplaySettingsBloc, DisplaySettingsState>(
      buildWhen: (previous, current) =>
          previous.brightness != current.brightness,
      builder: (context, state) {
        return SettingsCard(
          height: 140,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Brightness',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${state.brightness.round()}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    Icons.brightness_low_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        activeTrackColor: Colors.blueAccent,
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: Colors.white,
                        overlayShape: SliderComponentShape.noOverlay,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                        ),
                      ),
                      child: Slider(
                        value: state.brightness.clamp(0.0, 100.0),
                        min: 0,
                        max: 100,
                        onChanged: (value) => context
                            .read<DisplaySettingsBloc>()
                            .add(SetBrightness(value)),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.brightness_high_rounded,
                    color: Colors.white.withOpacity(0.5),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
