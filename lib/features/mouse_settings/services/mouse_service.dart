import 'package:dbus/dbus.dart';
import 'package:settings/core/services/venom_input_service.dart' as venom;

class MouseService {
  final DBusClient _bus = DBusClient.session();
  late venom.MouseService _mouse;
  late venom.TouchpadService _touchpad;

  MouseService() {
    _mouse = venom.MouseService();
    _touchpad = venom.TouchpadService();
  }

  Future<void> dispose() async {
    await _bus.close();
  }

  Future<String> getPrimaryButton() => _mouse.getPrimaryButton();

  Future<void> setPrimaryButton(String button) async {
    await _mouse.setPrimaryButton(button);
  }

  Future<double> getMousePointerSpeed() => _mouse.getPointerSpeed();

  Future<void> setMousePointerSpeed(double speed) async {
    await _mouse.setPointerSpeed(speed);
  }

  Future<bool> getMouseAcceleration() => _mouse.getAccelerationEnabled();

  Future<void> setMouseAcceleration(bool enabled) async {
    await _mouse.setAccelerationEnabled(enabled);
  }

  Future<String> getScrollDirection() async {
    final natural = await _mouse.getNaturalScroll();
    return natural ? 'natural' : 'traditional';
  }

  Future<void> setScrollDirection(String direction) async {
    await _mouse.setNaturalScroll(direction == 'natural');
  }

  Future<bool> getTouchpadEnabled() => _touchpad.getEnabled();

  Future<void> setTouchpadEnabled(bool enabled) async {
    await _touchpad.setEnabled(enabled);
  }

  Future<bool> getDisableWhileTyping() => _touchpad.getDisableWhileTyping();

  Future<void> setDisableWhileTyping(bool enabled) async {
    await _touchpad.setDisableWhileTyping(enabled);
  }

  Future<double> getTouchpadPointerSpeed() => _touchpad.getPointerSpeed();

  Future<void> setTouchpadPointerSpeed(double speed) async {
    await _touchpad.setPointerSpeed(speed);
  }

  Future<String> getSecondaryClick() => _touchpad.getSecondaryClick();

  Future<void> setSecondaryClick(String method) async {
    await _touchpad.setSecondaryClick(method);
  }

  Future<bool> getTapToClick() => _touchpad.getTapToClick();

  Future<void> setTapToClick(bool enabled) async {
    await _touchpad.setTapToClick(enabled);
  }
}
