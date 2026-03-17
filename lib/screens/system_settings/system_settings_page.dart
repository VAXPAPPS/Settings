import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/system_settings/system_settings.dart';
import 'package:settings/screens/system_settings/widgets/system_menu_item.dart';
import 'package:settings/screens/system_settings/widgets/region_language_dialog.dart';
import 'package:settings/screens/system_settings/widgets/date_time_dialog.dart';
import 'package:settings/screens/system_settings/widgets/users_dialog.dart';
import 'package:settings/screens/system_settings/widgets/remote_desktop_dialog.dart';
import 'package:settings/screens/system_settings/widgets/secure_shell_dialog.dart';
import 'package:settings/screens/system_settings/widgets/about_dialog.dart';


class SystemSettingsPage extends StatelessWidget {
  const SystemSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SystemSettingsBloc()..add(const LoadSystemSettings()),
      child: const SystemSettingsView(),
    );
  }
}


class SystemSettingsView extends StatelessWidget {
  const SystemSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Opacity(
              opacity: 0.6,
              child: const Text(
                'System information and settings',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.w300,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(height: 32),
            SystemMenuItem(
              icon: Icons.language_rounded,
              title: 'Region & Language',
              subtitle: 'System language and localization',
              onTap: () => _showRegionLanguageDialog(context),
            ),
            const SizedBox(height: 12),
            SystemMenuItem(
              icon: Icons.access_time_rounded,
              title: 'Date & Time',
              subtitle: 'Time zone and clock settings',
              onTap: () => _showDateTimeDialog(context),
            ),
            const SizedBox(height: 12),
            SystemMenuItem(
              icon: Icons.people_rounded,
              title: 'Users',
              subtitle: 'Add and remove accounts, change password',
              onTap: () => _showUsersDialog(context),
            ),
            const SizedBox(height: 12),
            SystemMenuItem(
              icon: Icons.desktop_windows_rounded,
              title: 'Remote Desktop',
              subtitle: 'Allow this device to be used remotely',
              onTap: () => _showRemoteDesktopDialog(context),
            ),
            const SizedBox(height: 12),
            SystemMenuItem(
              icon: Icons.terminal_rounded,
              title: 'Secure Shell',
              subtitle: 'SSH network access',
              onTap: () => _showSecureShellDialog(context),
            ),
            const SizedBox(height: 12),
            SystemMenuItem(
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'Hardware details and software versions',
              onTap: () => _showAboutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegionLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RegionLanguageDialog(),
    );
  }

  void _showDateTimeDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const DateTimeDialog());
  }

  void _showUsersDialog(BuildContext context) {
    showDialog(context: context, builder: (context) => const UsersDialog());
  }

  void _showRemoteDesktopDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const RemoteDesktopDialog(),
    );
  }

  void _showSecureShellDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SecureShellDialog(),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SystemAboutDialog(),
    );
  }
}
