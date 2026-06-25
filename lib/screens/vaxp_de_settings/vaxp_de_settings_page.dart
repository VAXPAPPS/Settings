import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/vaxp_de/vaxp_de.dart';
import 'package:settings/screens/vaxp_de_settings/views/dock_settings_view.dart';
import 'package:settings/screens/vaxp_de_settings/views/desktop_manager_settings_view.dart';
import 'package:settings/screens/vaxp_de_settings/views/osd_notify_settings_view.dart';
import 'package:settings/screens/vaxp_de_settings/views/aetherlock_settings_view.dart';
import 'package:settings/screens/vaxp_de_settings/views/vaxpother_settings_view.dart';
class VaxpDeSettingsPage extends StatelessWidget {
  const VaxpDeSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VaxpDeBloc()..add(LoadDockConfig()),
      child: const VaxpDeSettingsView(),
    );
  }
}

class VaxpDeSettingsView extends StatelessWidget {
  const VaxpDeSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VAXP DE',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your desktop environment settings',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildSectionCard(
                    context: context,
                    title: 'Dock',
                    description: 'Position, animations, and colors',
                    icon: Icons.dock_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<VaxpDeBloc>(),
                            child: const _DockSettingsScaffold(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSectionCard(
                    context: context,
                    title: 'Panel',
                    description: 'Top bar layout and widgets',
                    icon: Icons.space_dashboard_rounded,
                    onTap: () {
                      // Coming soon
                    },
                  ),
                  _buildSectionCard(
                    context: context,
                    title: 'Desktop Manager',
                    description: 'Wallpapers and icons behavior',
                    icon: Icons.wallpaper_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (context) => DesktopManagerBloc()..add(LoadDesktopManagerConfig()),
                            child: const _DesktopManagerSettingsScaffold(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSectionCard(
                    context: context,
                    title: 'osd-notify',
                    description: 'Notifications and OSD settings',
                    icon: Icons.notifications_active_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (context) => OsdNotifyBloc()..add(LoadOsdNotifyConfig()),
                            child: const _OsdNotifySettingsScaffold(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSectionCard(
                    context: context,
                    title: 'Aether Lock',
                    description: 'Lock screen customization',
                    icon: Icons.lock_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (context) => AetherLockBloc()..add(LoadAetherLockConfig()),
                            child: const _AetherLockSettingsScaffold(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildSectionCard(
                    context: context,
                    title: 'Vaxp Other',
                    description: 'Auth & Clipboard customizations',
                    icon: Icons.extension_rounded,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MultiBlocProvider(
                            providers: [
                              BlocProvider(create: (context) => AuthBloc()..add(LoadAuthConfig())),
                              BlocProvider(create: (context) => ClipboardBloc()..add(LoadClipboardConfig())),
                            ],
                            child: const _VaxpOtherSettingsScaffold(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 64, 200, 255).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color.fromARGB(255, 64, 200, 255),
                  size: 32,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockSettingsScaffold extends StatelessWidget {
  const _DockSettingsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(100, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Dock Settings',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<VaxpDeBloc>().add(RestoreDefaultDockConfig());
            },
            icon: const Icon(Icons.restore_rounded, color: Colors.white70),
            label: const Text(
              'Restore Settings',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: DockSettingsView(),
      ),
    );
  }
}

class _DesktopManagerSettingsScaffold extends StatelessWidget {
  const _DesktopManagerSettingsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(100, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Desktop Manager Settings',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<DesktopManagerBloc>().add(RestoreDefaultDesktopManagerConfig());
            },
            icon: const Icon(Icons.restore_rounded, color: Colors.white70),
            label: const Text(
              'Restore Settings',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: DesktopManagerSettingsView(),
      ),
    );
  }
}

class _OsdNotifySettingsScaffold extends StatelessWidget {
  const _OsdNotifySettingsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(100, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'OSD & Notify Settings',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<OsdNotifyBloc>().add(RestoreDefaultOsdNotifyConfig());
            },
            icon: const Icon(Icons.restore_rounded, color: Colors.white70),
            label: const Text(
              'Restore Settings',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: OsdNotifySettingsView(),
      ),
    );
  }
}

class _AetherLockSettingsScaffold extends StatelessWidget {
  const _AetherLockSettingsScaffold();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(100, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Aether Lock Settings',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.read<AetherLockBloc>().add(RestoreDefaultAetherLockConfig());
            },
            icon: const Icon(Icons.restore_rounded, color: Colors.white70),
            label: const Text(
              'Restore Settings',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0),
        child: AetherLockSettingsView(),
      ),
    );
  }
}

class _VaxpOtherSettingsScaffold extends StatelessWidget {
  const _VaxpOtherSettingsScaffold();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(100, 0, 0, 0),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Vaxp Other Settings',
            style: TextStyle(color: Colors.white),
          ),
          bottom: const TabBar(
            indicatorColor: Color(0xFF7EE0C9),
            labelColor: Color(0xFF7EE0C9),
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.security_rounded), text: 'Authentication'),
              Tab(icon: Icon(Icons.content_paste_rounded), text: 'Clipboard'),
            ],
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(RestoreDefaultAuthConfig());
                context.read<ClipboardBloc>().add(RestoreDefaultClipboardConfig());
              },
              icon: const Icon(Icons.restore_rounded, color: Colors.white70),
              label: const Text(
                'Restore Both',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.0),
          child: VaxpOtherSettingsView(),
        ),
      ),
    );
  }
}
