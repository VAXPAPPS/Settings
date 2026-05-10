import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/power_settings/power_settings.dart';

class ProfileButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final String profileId;
  final Color color;

  const ProfileButton({
    super.key,
    required this.label,
    required this.icon,
    required this.profileId,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerSettingsBloc, PowerSettingsState>(
      buildWhen: (previous, current) =>
          previous.activePowerProfile != current.activePowerProfile,
      builder: (context, state) {
        final isActive = state.activePowerProfile == profileId;
        return Expanded(
          child: InkWell(
            onTap: () => context.read<PowerSettingsBloc>().add(
              SetPowerProfile(profileId),
            ),
            borderRadius: BorderRadius.circular(8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? color.withValues(alpha: 0.35)
                      : Colors.transparent,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isActive ? 0.18 : 0.06),
                    blurRadius: isActive ? 14 : 4,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(-0.04)
                      ..rotateY(0.03),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isActive
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  color.withValues(alpha: 0.28),
                                  color.withValues(alpha: 0.06),
                                ],
                              )
                            : const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.fromARGB(36, 255, 255, 255),
                                  Color.fromARGB(8, 255, 255, 255),
                                ],
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 
                              isActive ? 0.22 : 0.08,
                            ),
                            blurRadius: isActive ? 14 : 6,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: isActive ? Colors.white : Colors.white54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isActive ? Colors.white : Colors.white54,
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
