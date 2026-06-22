import 'dart:io';

enum CompositorType { wayfire, hyprland, sway, aether, unknown }

class CompositorEnv {
  static CompositorType detectCompositor() {
    final xdgDesktop = Platform.environment['XDG_CURRENT_DESKTOP']?.toLowerCase() ?? '';
    final xdgSession = Platform.environment['XDG_SESSION_DESKTOP']?.toLowerCase() ?? '';
    final desktopSession = Platform.environment['DESKTOP_SESSION']?.toLowerCase() ?? '';
    final waylandDisplay = Platform.environment['WAYLAND_DISPLAY']?.toLowerCase() ?? '';
    
    final hyprlandSig = Platform.environment['HYPRLAND_INSTANCE_SIGNATURE'];
    final swaySock = Platform.environment['SWAYSOCK'];

    if (xdgDesktop.contains('aether') || xdgSession.contains('aether') || desktopSession.contains('aether') || waylandDisplay.contains('aether')) {
      return CompositorType.aether;
    }
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
