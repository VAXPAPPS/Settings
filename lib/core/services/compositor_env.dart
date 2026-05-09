import 'dart:io';

enum CompositorType { wayfire, hyprland, sway, unknown }

class CompositorEnv {
  static CompositorType detectCompositor() {
    final xdgDesktop = Platform.environment['XDG_CURRENT_DESKTOP']?.toLowerCase() ?? '';
    final hyprlandSig = Platform.environment['HYPRLAND_INSTANCE_SIGNATURE'];
    final swaySock = Platform.environment['SWAYSOCK'];

    if (hyprlandSig != null || xdgDesktop.contains('hyprland')) {
      return CompositorType.hyprland;
    }
    if (swaySock != null || xdgDesktop.contains('sway')) {
      return CompositorType.sway;
    }
    if (xdgDesktop.contains('wayfire')) {
      return CompositorType.wayfire;
    }

    // Fallback
    return CompositorType.wayfire;
  }
}
