import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/ethernet_settings/ethernet_settings.dart';
import 'package:settings/core/glassmorphic_container.dart';

class EthernetSettingsPage extends StatelessWidget {
  const EthernetSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          EthernetSettingsBloc()..add(const InitializeEthernet()),
      child: const EthernetSettingsView(),
    );
  }
}

class EthernetSettingsView extends StatelessWidget {
  const EthernetSettingsView({super.key});

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
              'Ethernet',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage wired network connections',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Network Interfaces',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                BlocBuilder<EthernetSettingsBloc, EthernetSettingsState>(
                  buildWhen: (p, c) => p.status != c.status,
                  builder: (context, state) {
                    if (state.status == EthernetSettingsStatus.loading) {
                      return const SizedBox(
                        width: 20,
                        height: 20,
                        child: CupertinoActivityIndicator(
                          color: Colors.blueAccent,
                        ),
                      );
                    }
                    return IconButton(
                      onPressed: () => context.read<EthernetSettingsBloc>().add(
                        const RefreshInterfaces(),
                      ),
                      icon: const Icon(Icons.refresh_rounded),
                      color: Colors.white54,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Expanded(child: _InterfacesList()),
          ],
        ),
      ),
    );
  }
}

class _InterfacesList extends StatelessWidget {
  const _InterfacesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EthernetSettingsBloc, EthernetSettingsState>(
      builder: (context, state) {
        if (state.status == EthernetSettingsStatus.loading) {
          return const Center(
            child: CupertinoActivityIndicator(color: Colors.blueAccent),
          );
        }

        if (state.status == EthernetSettingsStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'An error occurred',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        if (state.interfaces.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cable_outlined,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
                const SizedBox(height: 16),
                Text(
                  'No ethernet interfaces found',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemCount: state.interfaces.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final iface = state.interfaces[index];
            return _InterfaceTile(iface: iface);
          },
        );
      },
    );
  }
}

class _InterfaceTile extends StatelessWidget {
  final EthernetInterface iface;

  const _InterfaceTile({required this.iface});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
      borderRadius: 8,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.lan_rounded,
            color: iface.connected
                ? Colors.greenAccent
                : (iface.enabled ? Colors.white : Colors.white38),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  iface.name,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: iface.connected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  iface.macAddress,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
                if (iface.connected && iface.ipAddress.isNotEmpty)
                  Text(
                    '${iface.ipAddress} • ${iface.speed} Mb/s',
                    style: TextStyle(
                      color: Colors.greenAccent.withValues(alpha: 0.7),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                iface.connected ? 'Connected' : 'Disconnected',
                style: TextStyle(
                  color: iface.connected ? Colors.greenAccent : Colors.white38,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Switch(
                value: iface.connected,
                onChanged: (enabled) {
                  if (enabled) {
                    context.read<EthernetSettingsBloc>().add(
                      EnableInterface(iface.name),
                    );
                  } else {
                    context.read<EthernetSettingsBloc>().add(
                      DisableInterface(iface.name),
                    );
                  }
                },
                activeTrackColor: Colors.greenAccent.withValues(alpha: 0.5),
                // ignore: deprecated_member_use
                activeThumbColor: Colors.greenAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
