import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/display_settings/display_settings.dart';
import 'package:settings/screens/display_settings/widgets/settings_card.dart';

class RefreshRateCard extends StatelessWidget {
  const RefreshRateCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisplaySettingsBloc, DisplaySettingsState>(
      buildWhen: (previous, current) =>
          previous.refreshRate != current.refreshRate ||
          previous.availableRefreshRates != current.availableRefreshRates,
      builder: (context, state) {
        return SettingsCard(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Refresh Rate',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              if (state.availableRefreshRates.isNotEmpty)
                Expanded(
                  child: DropdownButton<String>(
                    value:
                        state.availableRefreshRates.contains(state.refreshRate)
                        ? state.refreshRate
                        : null,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: const Color.fromARGB(255, 12, 12, 12),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    items: state.availableRefreshRates.map((rate) {
                      return DropdownMenuItem<String>(
                        value: rate,
                        child: Text(rate),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        context.read<DisplaySettingsBloc>().add(
                          SetRefreshRate(newValue),
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
