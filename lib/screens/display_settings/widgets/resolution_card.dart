import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/display_settings/display_settings.dart';
import 'package:settings/screens/display_settings/widgets/settings_card.dart';

class ResolutionCard extends StatelessWidget {
  const ResolutionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisplaySettingsBloc, DisplaySettingsState>(
      buildWhen: (previous, current) =>
          previous.currentMode != current.currentMode ||
          previous.availableModes != current.availableModes ||
          previous.displayServer != current.displayServer,
      builder: (context, state) {
        // Get unique resolutions
        final uniqueResolutions = <String, DisplayMode>{};
        for (final mode in state.availableModes) {
          final key = mode.resolution;
          if (!uniqueResolutions.containsKey(key)) {
            uniqueResolutions[key] = mode;
          }
        }
        final resolutions = uniqueResolutions.values.toList();

        return SettingsCard(
          height: 180,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resolution',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (state.displayServer != 'Unknown')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: state.displayServer == 'Wayland'
                                ? Colors.blue.withValues(alpha: 0.2)
                                : Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: state.displayServer == 'Wayland'
                                  ? Colors.blue.withValues(alpha: 0.5)
                                  : Colors.green.withValues(alpha: 0.5),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            state.displayServer,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: state.displayServer == 'Wayland'
                                  ? Colors.blueAccent
                                  : Colors.greenAccent,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (state.currentMode != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Current',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          state.currentMode!.resolution,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              if (resolutions.isNotEmpty)
                Expanded(
                  child: DropdownButton<DisplayMode>(
                    value: state.currentMode,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color.fromARGB(87, 12, 12, 12),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    hint: const Text(
                      'Select Resolution',
                      style: TextStyle(color: Colors.white54),
                    ),
                    items: resolutions.map((mode) {
                      return DropdownMenuItem<DisplayMode>(
                        value: mode,
                        child: Text(mode.resolution),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        context.read<DisplaySettingsBloc>().add(
                          SetResolution(newValue),
                        );
                      }
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
