import 'package:dbus/dbus.dart';
import 'package:antidote/core/services/dbus_service.dart';

class MouseService {
  late DBusRemoteObject _object;

  MouseService() {
    _object = DBusRemoteObject(
      DBusService().client,
      name: 'org.venom.Input',
      path: DBusObjectPath('/org/venom/Input'),
    );
  }

  Future<bool> setPrimaryButton(String button) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetMouseLeftHanded',
        [DBusBoolean(button == 'right')],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<String> getPrimaryButton() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetMouseSettings',
        [],
        replySignature: DBusSignature('ddbb'),
      );
      return result.values[3].asBoolean() ? 'right' : 'left';
    } catch (e) {
      return 'left';
    }
  }

  Future<bool> setPointerSpeed(double speed) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetMouseSpeed',
        [DBusDouble(speed)],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<double> getPointerSpeed() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetMouseSettings',
        [],
        replySignature: DBusSignature('ddbb'),
      );
      return result.values[1].asDouble();
    } catch (e) {
      return 1.0;
    }
  }

  Future<bool> setAccelerationEnabled(bool enabled) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetMouseAccel',
        [DBusDouble(enabled ? 0.0 : -1.0)],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<bool> getAccelerationEnabled() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetMouseSettings',
        [],
        replySignature: DBusSignature('ddbb'),
      );
      return result.values[0].asDouble() >= 0.0;
    } catch (e) {
      return true;
    }
  }

  Future<bool> setNaturalScroll(bool enabled) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetMouseNaturalScroll',
        [DBusBoolean(enabled)],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<bool> getNaturalScroll() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetMouseSettings',
        [],
        replySignature: DBusSignature('ddbb'),
      );
      return result.values[2].asBoolean();
    } catch (e) {
      return false;
    }
  }
}

class TouchpadService {
  late DBusRemoteObject _object;

  TouchpadService() {
    _object = DBusRemoteObject(
      DBusService().client,
      name: 'org.venom.Input',
      path: DBusObjectPath('/org/venom/Input'),
    );
  }

  Future<bool> setEnabled(bool enabled) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetTouchpadEnabled',
        [DBusBoolean(enabled)],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<bool> getEnabled() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetTouchpadSettings',
        [],
        replySignature: DBusSignature('bbbsdb'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return true;
    }
  }

  Future<bool> setDisableWhileTyping(bool enabled) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetTouchpadDisableWhileTyping',
        [DBusBoolean(enabled)],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<bool> getDisableWhileTyping() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetTouchpadSettings',
        [],
        replySignature: DBusSignature('bbbsdb'),
      );
      return result.values[5].asBoolean();
    } catch (e) {
      return true;
    }
  }

  Future<bool> setPointerSpeed(double speed) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetTouchpadSpeed',
        [DBusDouble(speed)],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<double> getPointerSpeed() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetTouchpadSettings',
        [],
        replySignature: DBusSignature('bbbsdb'),
      );
      return result.values[4].asDouble();
    } catch (e) {
      return 0.5;
    }
  }

  Future<bool> setSecondaryClick(String method) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetTouchpadScrollMethod',
        [DBusString(method)],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<String> getSecondaryClick() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetTouchpadSettings',
        [],
        replySignature: DBusSignature('bbbsdb'),
      );
      return result.values[3].asString();
    } catch (e) {
      return 'two-finger';
    }
  }

  Future<bool> setTapToClick(bool enabled) async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'SetTouchpadTapToClick',
        [DBusBoolean(enabled)],
        replySignature: DBusSignature('b'),
      );
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<bool> getTapToClick() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetTouchpadSettings',
        [],
        replySignature: DBusSignature('bbbsdb'),
      );
      return result.values[1].asBoolean();
    } catch (e) {
      return true;
    }
  }
}

class KeyboardService {
  late DBusRemoteObject _object;

  KeyboardService() {
    _object = DBusRemoteObject(
      DBusService().client,
      name: 'org.venom.Input',
      path: DBusObjectPath('/org/venom/Input'),
    );
  }

  Future<bool> setLayouts(String layouts) async {
    try {
      final result = await _object.callMethod('org.venom.Input', 'SetKeyboardLayouts', [
        DBusString(layouts),
      ], replySignature: DBusSignature('b'));
      return result.values[0].asBoolean();
    } catch (e) {
      return false;
    }
  }

  Future<String> getLayouts() async {
    try {
      final result = await _object.callMethod(
        'org.venom.Input',
        'GetKeyboardSettings',
        [],
        replySignature: DBusSignature('sss'),
      );
      return result.values[0].asString();
    } catch (e) {
      return 'us';
    }
  }
}
