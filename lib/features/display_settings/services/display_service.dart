import 'dart:io';
import 'package:dbus/dbus.dart';
import 'package:flutter/foundation.dart';
import '../models/display_resolution.dart';
import '../../power_settings/services/power_service.dart';


class DisplayService {
  DBusClient? _sysbus;
  String? _cachedDisplayName;

  DBusClient get sysbus {
    _sysbus ??= DBusClient.system();
    return _sysbus!;
  }

  

  
  Future<String> detectDisplayServer() async {
    try {
      final waylandDisplay = Platform.environment['WAYLAND_DISPLAY'];
      if (waylandDisplay != null && waylandDisplay.isNotEmpty) {
        return 'Wayland';
      }

      final sessionType = Platform.environment['XDG_SESSION_TYPE'];
      if (sessionType != null) {
        return sessionType.toLowerCase() == 'wayland' ? 'Wayland' : 'X11';
      }

      try {
        final result = await Process.run('xrandr', ['--version']);
        if (result.exitCode == 0) {
          return 'X11';
        }
      } catch (_) {}

      return 'Wayland';
    } catch (e) {
      debugPrint('Detect display server error: $e');
      return 'Unknown';
    }
  }

  

  
  Future<String?> getDisplayName() async {
    if (_cachedDisplayName != null) return _cachedDisplayName;

    try {
      final result = await Process.run('xrandr', []);
      if (result.exitCode == 0) {
        final lines = result.stdout.toString().split('\n');
        for (final line in lines) {
          if (line.contains(' connected')) {
            final match = RegExp(r'^(\S+)\s+connected').firstMatch(line);
            if (match != null) {
              _cachedDisplayName = match.group(1);
              return _cachedDisplayName;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Get display name error: $e');
    }
    return null;
  }

  

  
  Future<List<DisplayResolution>> getX11AvailableResolutions() async {
    final List<DisplayResolution> resolutions = [];
    try {
      final result = await Process.run('xrandr', []);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');
        bool inConnectedOutput = false;

        for (final line in lines) {
          if (line.contains(' connected')) {
            inConnectedOutput = true;
            continue;
          }
          if (line.contains(' disconnected')) {
            inConnectedOutput = false;
            continue;
          }

          if (inConnectedOutput) {
            final match = RegExp(r'\s+(\d+)x(\d+)\s+').firstMatch(line);
            if (match != null) {
              final width = int.tryParse(match.group(1) ?? '') ?? 0;
              final height = int.tryParse(match.group(2) ?? '') ?? 0;
              if (width > 0 && height > 0) {
                final gcd = _gcd(width, height);
                final aspectW = width ~/ gcd;
                final aspectH = height ~/ gcd;
                final aspectRatio = '$aspectW:$aspectH';

                if (!resolutions.any(
                  (r) => r.width == width && r.height == height,
                )) {
                  resolutions.add(
                    DisplayResolution(
                      width: width,
                      height: height,
                      aspectRatio: aspectRatio,
                      isNative: line.contains('+'),
                    ),
                  );
                }
              }
            }
          }
        }

        resolutions.sort(
          (a, b) => (b.width * b.height).compareTo(a.width * a.height),
        );
      }
    } catch (e) {
      debugPrint('Get X11 resolutions error: $e');
    }
    return resolutions;
  }

  
  Future<Map<String, dynamic>> getX11DisplayInfo() async {
    try {
      final result = await Process.run('xrandr', ['--current']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');

        for (final line in lines) {
          if (line.contains(' connected') && line.contains('+')) {
            final modeMatch = RegExp(
              r'(\d+)x(\d+)\+.*?(\d+\.\d+)\s*Hz',
            ).firstMatch(line);
            if (modeMatch != null) {
              final width = int.tryParse(modeMatch.group(1) ?? '') ?? 1680;
              final height = int.tryParse(modeMatch.group(2) ?? '') ?? 1050;
              final refresh = modeMatch.group(3) ?? '60.00';

              final gcd = _gcd(width, height);
              final aspectW = width ~/ gcd;
              final aspectH = height ~/ gcd;

              return {
                'width': width,
                'height': height,
                'aspectRatio': '$aspectW:$aspectH',
                'refreshRate': '$refresh Hz',
                'orientation':
                    (line.contains('left') || line.contains('inverted'))
                    ? 'Portrait'
                    : 'Landscape',
              };
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Get X11 display info error: $e');
    }
    return {};
  }

  
  Future<List<String>> getX11AvailableRefreshRates(
    int width,
    int height,
  ) async {
    final List<String> rates = [];
    try {
      final result = await Process.run('xrandr', []);
      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final lines = output.split('\n');

        for (final line in lines) {
          if (line.contains('${width}x$height')) {
            final rateMatches = RegExp(r'(\d+\.\d+)\s*\+?\*?').allMatches(line);
            for (final match in rateMatches) {
              final rate = match.group(1);
              if (rate != null && !rates.contains('$rate Hz')) {
                rates.add('$rate Hz');
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Get X11 refresh rates error: $e');
    }
    return rates;
  }

  
  Future<bool> setResolution(DisplayResolution resolution) async {
    try {
      final displayName = await getDisplayName();
      if (displayName == null) return false;

      final result = await Process.run('xrandr', [
        '--output',
        displayName,
        '--mode',
        '${resolution.width}x${resolution.height}',
      ]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set resolution error: $e');
      return false;
    }
  }

  
  Future<bool> setRefreshRate(String refreshRate) async {
    try {
      final displayName = await getDisplayName();
      if (displayName == null) return false;

      final rate = refreshRate.replaceAll(' Hz', '');
      final result = await Process.run('xrandr', [
        '--output',
        displayName,
        '--rate',
        rate,
      ]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set refresh rate error: $e');
      return false;
    }
  }

  

  
  Future<bool> setOrientation(String orientation, String displayServer) async {
    try {
      final displayName = await getDisplayName();
      if (displayName == null) return false;

      String xrandrOrientation;
      switch (orientation) {
        case 'Portrait Left':
          xrandrOrientation = 'left';
          break;
        case 'Portrait Right':
          xrandrOrientation = 'right';
          break;
        case 'Landscape Inverted':
          xrandrOrientation = 'inverted';
          break;
        default:
          xrandrOrientation = 'normal';
      }

      final result = await Process.run('xrandr', [
        '--output',
        displayName,
        '--rotate',
        xrandrOrientation,
      ]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set orientation error: $e');
      return false;
    }
  }

  

  
  Future<bool> setScale(int scale) async {
    try {
      final scaleFactor = scale / 100.0;
      final result = await Process.run('gsettings', [
        'set',
        'org.gnome.desktop.interface',
        'text-scaling-factor',
        scaleFactor.toString(),
      ]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set scale error: $e');
      return false;
    }
  }

  
  Future<int> getScale() async {
    try {
      final result = await Process.run('gsettings', [
        'get',
        'org.gnome.desktop.interface',
        'text-scaling-factor',
      ]);
      if (result.exitCode == 0) {
        final scaleValue =
            double.tryParse(result.stdout.toString().trim()) ?? 1.0;
        return (scaleValue * 100).round();
      }
    } catch (e) {
      debugPrint('Get scale error: $e');
    }
    return 100;
  }

  
  Future<bool> setFractionalScaling(bool enabled) async {
    try {
      final result = await Process.run('gsettings', [
        'set',
        'org.gnome.mutter',
        'experimental-features',
        enabled ? "['scale-monitor-framebuffer']" : '[]',
      ]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set fractional scaling error: $e');
      return false;
    }
  }

  

  
  Future<Map<String, dynamic>> initBrightness() async {
    // السطوع عبر brightnessctl — لا يحتاج D-Bus
    final powerService = PowerService();
    try {
      final current = await powerService.getBrightness();
      final max     = await powerService.getMaxBrightness();

      if (max > 0) {
        return {
          'brightness':         (current / max * 100).clamp(0.0, 100.0),
          'maxBrightness':      max.toDouble(),
          'brightnessSupported': true,
          'brightnessMethod':   'brightnessctl',
        };
      }
    } catch (e) {
      debugPrint('brightnessctl failed: $e');
    }

    return {
      'brightness':         100.0,
      'maxBrightness':      100.0,
      'brightnessSupported': false,
      'brightnessMethod':   'none',
    };
  }

  
  Future<bool> setBrightness(
    double value,
    String method,
    double maxBrightness,
  ) async {
    if (method == 'brightnessctl') {
      final powerService = PowerService();
      try {
        final absoluteValue = (value / 100.0 * maxBrightness).round();
        return await powerService.setBrightness(absoluteValue);
      } catch (e) {
        debugPrint('Set brightness error: $e');
      }
    }
    return false;
  }

  

  
  Future<bool> getNightLightStatus() async {
    try {
      final result = await Process.run('gsettings', [
        'get',
        'org.gnome.settings-daemon.plugins.color',
        'night-light-enabled',
      ]);
      if (result.exitCode == 0) {
        return result.stdout.toString().trim() == 'true';
      }
    } catch (e) {
      debugPrint('Get night light status error: $e');
    }
    return false;
  }

  
  Future<bool> setNightLight(bool enabled) async {
    try {
      final result = await Process.run('gsettings', [
        'set',
        'org.gnome.settings-daemon.plugins.color',
        'night-light-enabled',
        enabled.toString(),
      ]);
      return result.exitCode == 0;
    } catch (e) {
      debugPrint('Set night light error: $e');
      return false;
    }
  }

  

  int _gcd(int a, int b) {
    while (b != 0) {
      final t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  void dispose() {
    _sysbus?.close();
    _sysbus = null;
  }
}
