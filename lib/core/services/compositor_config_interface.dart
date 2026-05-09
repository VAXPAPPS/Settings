import 'package:settings/screens/shortcuts/models/shortcut_item.dart';
import 'package:settings/core/models/mouse_config.dart';

abstract class CompositorConfigService {
  /// Get the current active keyboard layouts (comma separated, e.g. "us,ara")
  Future<String> getKeyboardLayouts();

  /// Set the keyboard layouts
  Future<void> setKeyboardLayouts(String layouts);

  /// Load all shortcuts configured in the compositor
  Future<List<ShortcutItem>> loadShortcuts();

  /// Save all shortcuts to the compositor configuration
  Future<void> saveShortcuts(List<ShortcutItem> items);

  /// Get the current mouse configuration
  Future<MouseConfig> getMouseConfig();

  /// Save the mouse configuration
  Future<void> saveMouseConfig(MouseConfig config);
}
