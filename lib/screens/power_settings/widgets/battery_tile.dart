import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/power_settings/power_settings.dart';

class BatteryTile extends StatelessWidget {
  const BatteryTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PowerSettingsBloc, PowerSettingsState>(
      buildWhen: (previous, current) =>
          previous.batteryLevel != current.batteryLevel ||
          previous.isCharging != current.isCharging,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.02)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                state.isCharging
                    ? Icons.battery_charging_full_rounded
                    : Icons.battery_std_rounded,
                color: state.isCharging ? Colors.greenAccent : Colors.white70,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Battery',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: state.batteryLevel / 100,
                        minHeight: 6,
                        backgroundColor: Colors.white10,
                        color: state.isCharging
                            ? Colors.greenAccent
                            : (state.batteryLevel <= 20
                                  ? Colors.redAccent
                                  : Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${state.batteryLevel.toInt()}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
