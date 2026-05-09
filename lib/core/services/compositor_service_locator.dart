import 'compositor_config_interface.dart';
import 'compositor_env.dart';
import 'wayfire_config_service.dart';
import 'hyprland_config_service.dart';
import 'sway_config_service.dart';

class CompositorServiceLocator {
  static CompositorConfigService? _instance;

  static CompositorConfigService getService() {
    if (_instance != null) {
      return _instance!;
    }

    final type = CompositorEnv.detectCompositor();
    
    switch (type) {
      case CompositorType.hyprland:
        _instance = HyprlandConfigService();
        break;
      case CompositorType.sway:
        _instance = SwayConfigService();
        break;
      case CompositorType.wayfire:
      case CompositorType.unknown:
        _instance = WayfireConfigService();
        break;
    }

    return _instance!;
  }
}
