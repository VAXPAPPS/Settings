import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/bluetooth_settings/bluetooth_settings.dart';
import 'package:settings/screens/bluetooth_settings/widgets/bluetooth_header.dart';
import 'package:settings/screens/bluetooth_settings/widgets/bluetooth_status_section.dart';
import 'package:settings/screens/bluetooth_settings/widgets/devices_header.dart';
import 'package:settings/screens/bluetooth_settings/widgets/devices_list.dart';

class BluetoothSettingsPage extends StatelessWidget {
  const BluetoothSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BluetoothSettingsBloc()..add(const InitializeBluetooth()),
      child: const BluetoothSettingsView(),
    );
  }
}

class BluetoothSettingsView extends StatelessWidget {
  const BluetoothSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<BluetoothSettingsBloc, BluetoothSettingsState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage &&
          current.errorMessage != null,
      listener: (context, state) {
        if (state.errorMessage != null) {
          // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BluetoothHeader(),
              const SizedBox(height: 32),
              const BluetoothStatusSection(),
              const SizedBox(height: 24),
              const DevicesHeader(),
              const SizedBox(height: 16),
              const Expanded(child: DevicesList()),
            ],
          ),
        ),
      ),
    );
  }
}
