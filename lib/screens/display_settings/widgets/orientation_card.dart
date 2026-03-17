import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/display_settings/display_settings.dart';
import 'package:settings/screens/display_settings/widgets/settings_card.dart';

class OrientationCard extends StatelessWidget {
  const OrientationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisplaySettingsBloc, DisplaySettingsState>(
      buildWhen: (previous, current) =>
          previous.orientation != current.orientation,
      builder: (context, state) {
        return SettingsCard(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Orientation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OrientationButton(
                    label: 'Landscape',
                    icon: Icons.crop_landscape_rounded,
                    isSelected: state.orientation == 'Landscape',
                    onTap: () => context.read<DisplaySettingsBloc>().add(
                      const SetOrientation('Landscape'),
                    ),
                  ),
                  OrientationButton(
                    label: 'Portrait',
                    icon: Icons.crop_portrait_rounded,
                    isSelected: state.orientation.contains('Portrait'),
                    onTap: () => context.read<DisplaySettingsBloc>().add(
                      const SetOrientation('Portrait Left'),
                    ),
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

class OrientationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const OrientationButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blueAccent.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Colors.blueAccent
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.blueAccent : Colors.white70,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
