import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/display_settings/display_settings.dart';
import 'package:settings/screens/display_settings/widgets/resolution_card.dart';
import 'package:settings/screens/display_settings/widgets/refresh_rate_card.dart';
import 'package:settings/screens/display_settings/widgets/brightness_card.dart';
import 'package:settings/screens/display_settings/widgets/orientation_card.dart';
import 'package:settings/screens/display_settings/widgets/scale_card.dart';

class SettingsGrid extends StatelessWidget {
  const SettingsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisplaySettingsBloc, DisplaySettingsState>(
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isTwoColumn = constraints.maxWidth > 1200;
            return Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                SizedBox(
                  width: isTwoColumn
                      ? (constraints.maxWidth - 24) / 2
                      : double.infinity,
                  child: const ResolutionCard(),
                ),
                SizedBox(
                  width: isTwoColumn
                      ? (constraints.maxWidth - 24) / 2
                      : double.infinity,
                  child: const RefreshRateCard(),
                ),
                if (state.brightnessSupported)
                  SizedBox(
                    width: isTwoColumn
                        ? (constraints.maxWidth - 24) / 2
                        : double.infinity,
                    child: const BrightnessCard(),
                  ),
                SizedBox(
                  width: isTwoColumn
                      ? (constraints.maxWidth - 24) / 2
                      : double.infinity,
                  child: const OrientationCard(),
                ),
                SizedBox(
                  width: isTwoColumn
                      ? (constraints.maxWidth - 24) / 2
                      : double.infinity,
                  child: const ScaleCard(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
