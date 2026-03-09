import 'package:flutter/material.dart';
import 'package:antidote/core/glassmorphic_container.dart';
import 'package:antidote/features/window_manager/models/window_node.dart';
import 'desktop_creator.dart';

class DesktopManager extends StatelessWidget {
  final List<Desktop> desktops;
  final String? activeDesktop;
  final ValueChanged<int>? onDesktopSelected;
  final ValueChanged<String>? onDesktopCreated;

  const DesktopManager({
    super.key,
    required this.desktops,
    this.activeDesktop,
    this.onDesktopSelected,
    this.onDesktopCreated,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Desktops',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              DesktopCreator(
                onDesktopCreated: (desktopName) {
                  onDesktopCreated?.call(desktopName);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: desktops.length,
            itemBuilder: (context, index) {
              final desktop = desktops[index];
              final isActive = desktop.name == activeDesktop;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onDesktopSelected?.call(index + 1),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isActive
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color.fromARGB(255, 64, 200, 255)
                                    .withAlpha((255 * 0.35).round()),
                                const Color.fromARGB(255, 100, 150, 255)
                                    .withAlpha((255 * 0.25).round()),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive
                            ? const Color.fromARGB(255, 64, 200, 255)
                                .withAlpha((255 * 0.6).round())
                            : Colors.white.withAlpha((255 * 0.1).round()),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              desktop.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                                color: isActive
                                    ? const Color.fromARGB(255, 120, 210, 255)
                                    : Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${desktop.windowCount} windows • ${desktop.layout}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 64, 200, 255)
                                  .withAlpha((255 * 0.3).round()),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Color.fromARGB(255, 120, 210, 255),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class MonitorInfo extends StatelessWidget {
  final List<Monitor> monitors;
  final String? activeMonitor;

  const MonitorInfo({
    super.key,
    required this.monitors,
    this.activeMonitor,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Monitors',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: monitors.length,
            itemBuilder: (context, index) {
              final monitor = monitors[index];
              final isActive = monitor.name == activeMonitor;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? const Color.fromARGB(255, 64, 200, 255)
                            .withAlpha((255 * 0.6).round())
                        : Colors.white.withAlpha((255 * 0.1).round()),
                    width: isActive ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          monitor.name,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? const Color.fromARGB(255, 120, 210, 255)
                                : Colors.white,
                          ),
                        ),
                        if (monitor.primary)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Primary',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.purple,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _MonitorDetail(
                          label: 'Resolution',
                          value: '${monitor.width}x${monitor.height}',
                        ),
                        _MonitorDetail(
                          label: 'Position',
                          value: '${monitor.x},${monitor.y}',
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MonitorDetail extends StatelessWidget {
  final String label;
  final String value;

  const _MonitorDetail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
