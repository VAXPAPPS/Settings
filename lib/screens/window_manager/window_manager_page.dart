import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:antidote/features/window_manager/window_manager.dart';
import 'widgets/layout_selector.dart';
import 'widgets/window_commands.dart';
import 'widgets/configuration_panel.dart';
import 'widgets/desktop_monitor.dart';

class WindowManagerPage extends StatelessWidget {
  const WindowManagerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WindowManagerBloc()..add(const LoadWindowManager()),
      child: const WindowManagerView(),
    );
  }
}

class WindowManagerView extends StatelessWidget {
  const WindowManagerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<WindowManagerBloc, WindowManagerState>(
        builder: (context, state) {
          if (state.status == WindowManagerStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 120, 210, 255),
                ),
              ),
            );
          }

          if (state.status == WindowManagerStatus.error) {
            return Center(
              child: Text(
                state.errorMessage ?? 'Failed to load Window Manager',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Window Manager',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Control PoisonBlade window manager settings and layouts',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          LayoutSelector(
                            selectedLayout: state.desktops.isNotEmpty
                                ? state.desktops
                                    .firstWhere(
                                      (d) => d.active,
                                      orElse: () => state.desktops.first,
                                    )
                                    .layout
                                : 'tiled',
                            onLayoutChanged: (layout) {
                              context.read<WindowManagerBloc>().add(
                                    ChangeLayout(layout),
                                  );
                            },
                          ),
                          const SizedBox(height: 32),
                          WindowCommandsSection(
                            onFocusNext: () {
                              context.read<WindowManagerBloc>().add(
                                    const FocusWindow(WindowDirection.next),
                                  );
                            },
                            onFocusPrev: () {
                              context.read<WindowManagerBloc>().add(
                                    const FocusWindow(WindowDirection.prev),
                                  );
                            },
                            onSwapWindowNext: () {
                              context.read<WindowManagerBloc>().add(
                                    const SwapWindow(WindowDirection.next),
                                  );
                            },
                            onSwapWindowPrev: () {
                              context.read<WindowManagerBloc>().add(
                                    const SwapWindow(WindowDirection.prev),
                                  );
                            },
                            onToggleFloating: () {
                              context.read<WindowManagerBloc>().add(
                                    ChangeWindowState(
                                      'focus',
                                      WindowState.floating,
                                    ),
                                  );
                            },
                            onBalanceWindows: () {
                              context.read<WindowManagerBloc>().add(
                                    const BalanceWindows(),
                                  );
                            },
                          ),
                          const SizedBox(height: 32),
                          if (state.desktops.isNotEmpty)
                            DesktopManager(
                              desktops: state.desktops,
                              activeDesktop: state.activeDesktop,
                              onDesktopSelected: (desktopIndex) {
                                context.read<WindowManagerBloc>().add(
                                      SwitchDesktop(desktopIndex),
                                    );
                              },
                              onDesktopCreated: (desktopName) {
                                context.read<WindowManagerBloc>().add(
                                      CreateDesktop(desktopName),
                                    );
                              },
                            ),
                          if (state.desktops.isEmpty)
                            const Center(
                              child: Text(
                                'No desktops available',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    Expanded(
                      child: Column(
                        children: [
                          ConfigurationPanel(
                            floatingMode: state.config.floatingMode,
                            snapToEdge: state.config.snapToEdge,
                            snapThreshold: state.config.snapThreshold,
                            borderWidth: state.config.borderWidth,
                            windowGap: state.config.windowGap,
                            topPadding: state.config.topPadding,
                            bottomPadding: state.config.bottomPadding,
                            focusOpacity: state.config.focusOpacity,
                            inactiveOpacity: state.config.inactiveOpacity,
                            activeOpacity: state.config.activeOpacity,
                            focusedBorderColor: state.config.focusedBorderColor,
                            normalBorderColor: state.config.normalBorderColor,
                            onFloatingModeChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateFloatingMode(value),
                                  );
                            },
                            onSnapToEdgeChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateSnapToEdge(value),
                                  );
                            },
                            onSnapThresholdChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateSnapThreshold(value.toInt()),
                                  );
                            },
                            onBorderWidthChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateBorderWidth(value.toInt()),
                                  );
                            },
                            onWindowGapChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateWindowGap(value.toInt()),
                                  );
                            },
                            onTopPaddingChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdatePadding(value.toInt(), state.config.bottomPadding),
                                  );
                            },
                            onBottomPaddingChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdatePadding(state.config.topPadding, value.toInt()),
                                  );
                            },
                            onFocusOpacityChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateOpacity(
                                      value,
                                      state.config.inactiveOpacity,
                                      state.config.activeOpacity,
                                    ),
                                  );
                            },
                            onInactiveOpacityChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateOpacity(
                                      state.config.focusOpacity,
                                      value,
                                      state.config.activeOpacity,
                                    ),
                                  );
                            },
                            onActiveOpacityChanged: (value) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateOpacity(
                                      state.config.focusOpacity,
                                      state.config.inactiveOpacity,
                                      value,
                                    ),
                                  );
                            },
                            onFocusedBorderColorChanged: (color) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateBorderColor(color, state.config.normalBorderColor),
                                  );
                            },
                            onNormalBorderColorChanged: (color) {
                              context.read<WindowManagerBloc>().add(
                                    UpdateBorderColor(state.config.focusedBorderColor, color),
                                  );
                            },
                          ),
                          const SizedBox(height: 32),
                          MonitorInfo(
                            monitors: state.monitors,
                            activeMonitor: state.activeMonitor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
