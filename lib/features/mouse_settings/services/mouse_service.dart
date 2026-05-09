import 'package:settings/core/models/mouse_config.dart';
import 'package:settings/core/services/compositor_config_interface.dart';
import 'package:settings/core/services/compositor_service_locator.dart';

class MouseService {
  final CompositorConfigService _configService = CompositorServiceLocator.getService();
  MouseConfig? _cachedConfig;

  MouseService();

  Future<void> dispose() async {}

  Future<MouseConfig> _getConfig() async {
    _cachedConfig ??= await _configService.getMouseConfig();
    return _cachedConfig!;
  }

  Future<void> _saveConfig() async {
    if (_cachedConfig != null) {
      await _configService.saveMouseConfig(_cachedConfig!);
    }
  }

  Future<String> getPrimaryButton() async => (await _getConfig()).primaryButton;

  Future<void> setPrimaryButton(String button) async {
    (await _getConfig()).primaryButton = button;
    await _saveConfig();
  }

  Future<double> getMousePointerSpeed() async => (await _getConfig()).mousePointerSpeed;

  Future<void> setMousePointerSpeed(double speed) async {
    (await _getConfig()).mousePointerSpeed = speed;
    await _saveConfig();
  }

  Future<bool> getMouseAcceleration() async => (await _getConfig()).mouseAcceleration;

  Future<void> setMouseAcceleration(bool enabled) async {
    (await _getConfig()).mouseAcceleration = enabled;
    await _saveConfig();
  }

  Future<String> getScrollDirection() async => (await _getConfig()).scrollDirection;

  Future<void> setScrollDirection(String direction) async {
    (await _getConfig()).scrollDirection = direction;
    await _saveConfig();
  }

  Future<bool> getTouchpadEnabled() async => (await _getConfig()).touchpadEnabled;

  Future<void> setTouchpadEnabled(bool enabled) async {
    (await _getConfig()).touchpadEnabled = enabled;
    await _saveConfig();
  }

  Future<bool> getDisableWhileTyping() async => (await _getConfig()).disableWhileTyping;

  Future<void> setDisableWhileTyping(bool enabled) async {
    (await _getConfig()).disableWhileTyping = enabled;
    await _saveConfig();
  }

  Future<double> getTouchpadPointerSpeed() async => (await _getConfig()).touchpadPointerSpeed;

  Future<void> setTouchpadPointerSpeed(double speed) async {
    (await _getConfig()).touchpadPointerSpeed = speed;
    await _saveConfig();
  }

  Future<String> getSecondaryClick() async => (await _getConfig()).secondaryClick;

  Future<void> setSecondaryClick(String method) async {
    (await _getConfig()).secondaryClick = method;
    await _saveConfig();
  }

  Future<bool> getTapToClick() async => (await _getConfig()).tapToClick;

  Future<void> setTapToClick(bool enabled) async {
    (await _getConfig()).tapToClick = enabled;
    await _saveConfig();
  }
}
