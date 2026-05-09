import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:settings/core/services/compositor_config_interface.dart';
import 'package:settings/core/services/compositor_service_locator.dart';

class VenomShortcutManager {
  final CompositorConfigService _config = CompositorServiceLocator.getService();

  Future<List<ShortcutItem>> loadShortcuts() async {
    return await _config.loadShortcuts();
  }

  Future<void> saveShortcuts(List<ShortcutItem> items) async {
    await _config.saveShortcuts(items);
  }

  Future<void> restartDaemon() async {
    // Compositors usually handle reloading automatically via inotify.
  }
}
