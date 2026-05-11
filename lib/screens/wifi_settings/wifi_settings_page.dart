import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/wifi_settings/wifi_settings.dart';
import 'package:settings/screens/wifi_settings/widgets/wifi_header.dart';
import 'package:settings/screens/wifi_settings/widgets/wifi_status_section.dart';
import 'package:settings/screens/wifi_settings/widgets/networks_header.dart';
import 'package:settings/screens/wifi_settings/widgets/networks_list.dart';

class WiFiSettingsPage extends StatelessWidget {
  const WiFiSettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WiFiSettingsBloc()..add(const InitializeWiFi()),
      child: const WiFiSettingsView(),
    );
  }
}

class WiFiSettingsView extends StatelessWidget {
  const WiFiSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<WiFiSettingsBloc, WiFiSettingsState>(
      listenWhen: (previous, current) =>
          previous.passwordRequiredFor != current.passwordRequiredFor &&
          current.passwordRequiredFor != null,
      listener: (context, state) async {
        if (state.passwordRequiredFor != null) {
          final password = await _showPasswordDialog(context);
          if (password != null && password.isNotEmpty && context.mounted) {
            context.read<WiFiSettingsBloc>().add(
              ConnectToNetwork(state.passwordRequiredFor!, password),
            );
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const WifiHeader(),
              const SizedBox(height: 32),
              const WifiStatusSection(),
              const SizedBox(height: 24),
              const NetworksHeader(),
              const SizedBox(height: 16),
              const Expanded(child: NetworksList()),
            ],
          ),
        ),
      ),
    );
  }

  Future<String?> _showPasswordDialog(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) {
        String? password;
        bool obscureText = true;

        return AlertDialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(50, 0, 0, 0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Enter Password', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (context, setState) => TextField(
                        onChanged: (value) => password = value,
                        obscureText: obscureText,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Network Password',
                          hintStyle: const TextStyle(color: Colors.white54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureText ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () => setState(() => obscureText = !obscureText),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white24),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.tealAccent),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, password),
                          child: const Text('Connect', style: TextStyle(color: Colors.tealAccent)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
