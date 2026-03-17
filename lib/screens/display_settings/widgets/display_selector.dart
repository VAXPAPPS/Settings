import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/display_settings/display_settings.dart';

class DisplaySelector extends StatelessWidget {
  const DisplaySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DisplaySettingsBloc, DisplaySettingsState>(
      buildWhen: (previous, current) =>
          previous.displays != current.displays ||
          previous.selectedDisplayName != current.selectedDisplayName,
      builder: (context, state) {
        if (state.displays.isEmpty) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.monitor,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Displays',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: state.displays.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final display = state.displays[index];
                    final isSelected =
                        display.name == state.selectedDisplayName;
                    return _DisplayCard(
                      display: display,
                      isSelected: isSelected,
                      onTap: () => context.read<DisplaySettingsBloc>().add(
                        SelectDisplay(display.name),
                      ),
                      onSetPrimary: () => context
                          .read<DisplaySettingsBloc>()
                          .add(SetPrimaryDisplay(display.name)),
                      onToggle: (enabled) => context
                          .read<DisplaySettingsBloc>()
                          .add(ToggleDisplayEnabled(display.name, enabled)),
                    );
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

class _DisplayCard extends StatelessWidget {
  final DisplayInfo display;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onSetPrimary;
  final Function(bool) onToggle;

  const _DisplayCard({
    required this.display,
    required this.isSelected,
    required this.onTap,
    required this.onSetPrimary,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7AA2F7).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7AA2F7).withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.desktop_windows_rounded,
                  size: 16,
                  color: isSelected
                      ? const Color.fromARGB(255, 0, 255, 242)
                      : Colors.white.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    display.name,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (display.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9ECE6A).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'P',
                      style: TextStyle(
                        color: Color(0xFF9ECE6A),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            Text(
              display.resolution,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  display.rateString,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 10,
                  ),
                ),
                if (!display.isPrimary && display.isConnected)
                  GestureDetector(
                    onTap: onSetPrimary,
                    child: Icon(
                      Icons.star_border_rounded,
                      size: 16,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
