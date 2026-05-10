import 'dart:io';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// خدمة aetheridle — تُحدّث ملف config فقط.
// aetheridle يعمل بشكل مستقل (autostart) ويقرأ الملف بنفسه.
// التطبيق لا يُشغّل ولا يوقف ولا يُعيد تشغيل أي عملية.
// ─────────────────────────────────────────────────────────────────────────────

class AetheridleService {
  static const _configSubpath = '.config/aetheridle/config';

  String get _configPath {
    final home = Platform.environment['HOME'] ?? '/root';
    return '$home/$_configSubpath';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // كتابة ملف config
  // ─────────────────────────────────────────────────────────────────────────

  /// يكتب مهلات الخمول إلى ملف config.
  /// يحتفظ بالأسطر التي لا تبدأ بـ "timeout" (مثل before-sleep, lock, etc.)
  Future<void> setAllTimeouts({
    required int dimSeconds,
    required int blankSeconds,
    required int suspendSeconds,
  }) async {
    // احتفظ بالأسطر غير المتعلقة بـ timeout (before-sleep, lock, unlock, idlehint...)
    final preserved = await _readNonTimeoutLines();

    final buffer = StringBuffer();
    buffer.writeln('# aetheridle config — managed by Settings');
    buffer.writeln('# Do not add timeout lines manually; they are overwritten.');
    buffer.writeln();

    // أسطر محفوظة من الـ config الحالي (before-sleep, lock, ...)
    for (final line in preserved) {
      buffer.writeln(line);
    }

    if (preserved.isNotEmpty) buffer.writeln();

    // مهلة خفوت الشاشة
    if (dimSeconds > 0) {
      final dimCmd = _dimCmd();
      final undimCmd = _undimCmd();
      buffer.writeln('timeout $dimSeconds "$dimCmd" resume "$undimCmd"');
    }

    // مهلة إطفاء الشاشة
    if (blankSeconds > 0) {
      final offCmd = _screenOffCmd();
      final onCmd = _screenOnCmd();
      buffer.writeln('timeout $blankSeconds "$offCmd" resume "$onCmd"');
    }

    // مهلة السكون
    if (suspendSeconds > 0) {
      buffer.writeln('timeout $suspendSeconds "systemctl suspend"');
    }

    await _writeConfig(buffer.toString());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // قراءة الـ config الحالي
  // ─────────────────────────────────────────────────────────────────────────

  /// يُعيد المهلات الحالية بالثواني {dim, blank, suspend}.
  Future<Map<String, int>> getCurrentTimeoutsSeconds() async {
    final file = File(_configPath);
    if (!await file.exists()) return {'dim': 0, 'blank': 0, 'suspend': 0};

    int dim = 0, blank = 0, suspend = 0;
    final lines = await file.readAsLines();

    for (final raw in lines) {
      final line = raw.trim();
      if (!line.startsWith('timeout ')) continue;

      final parts = _splitConfigLine(line);
      if (parts == null) continue;

      final secs = parts['seconds'] ?? 0;
      final cmd  = parts['idle_cmd'] ?? '';

      if (cmd.contains('suspend')) {
        suspend = secs;
      } else if (cmd.contains('dpms off') ||
                 cmd.contains('power off') ||
                 cmd.contains('dpms force off')) {
        blank = secs;
      } else if (cmd.contains('brightnessctl') || cmd.contains('dim')) {
        dim = secs;
      }
    }

    return {'dim': dim, 'blank': blank, 'suspend': suspend};
  }

  /// يُعيد الأسطر التي لا تبدأ بـ "timeout" أو "#" أو فارغة.
  /// (before-sleep, lock, unlock, idlehint, after-resume, ...)
  Future<List<String>> _readNonTimeoutLines() async {
    final file = File(_configPath);
    if (!await file.exists()) return [];

    final result = <String>[];
    for (final line in await file.readAsLines()) {
      final t = line.trim();
      if (t.isEmpty || t.startsWith('#')) continue;
      if (t.startsWith('timeout ')) continue;
      result.add(line);
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // كتابة الملف
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _writeConfig(String content) async {
    final file = File(_configPath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    debugPrint('[AetheridleService] تم تحديث: $_configPath');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // أوامر الشاشة — حسب المجمّع
  // ─────────────────────────────────────────────────────────────────────────

  String _dimCmd() => 'brightnessctl set 30%';
  String _undimCmd() => 'brightnessctl set 100%';

  String _screenOffCmd() {
    if (_isHyprland()) return 'hyprctl dispatch dpms off';
    if (_isSway())     return "swaymsg 'output * power off'";
    return 'xset dpms force off';
  }

  String _screenOnCmd() {
    if (_isHyprland()) return 'hyprctl dispatch dpms on';
    if (_isSway())     return "swaymsg 'output * power on'";
    return 'xset dpms force on';
  }

  bool _isHyprland() {
    final v = Platform.environment['HYPRLAND_INSTANCE_SIGNATURE'];
    return v != null && v.isNotEmpty;
  }

  bool _isSway() {
    final v = Platform.environment['SWAYSOCK'];
    return v != null && v.isNotEmpty;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // تحليل سطر timeout
  // ─────────────────────────────────────────────────────────────────────────

  Map<String, dynamic>? _splitConfigLine(String line) {
    // صيغة: timeout <secs> "<idle_cmd>" [resume "<resume_cmd>"]
    final re = RegExp(
      r'^timeout\s+(\d+)\s+"([^"]+)"(?:\s+resume\s+"([^"]+)")?$',
    );
    var m = re.firstMatch(line);
    if (m != null) {
      return {
        'seconds':    int.tryParse(m.group(1)!) ?? 0,
        'idle_cmd':   m.group(2)!,
        'resume_cmd': m.group(3),
      };
    }

    // صيغة بدون علامات اقتباس: timeout <secs> <idle_cmd> [resume <resume_cmd>]
    final reSimple = RegExp(
      r'^timeout\s+(\d+)\s+(\S+)(?:\s+resume\s+(\S+))?$',
    );
    m = reSimple.firstMatch(line);
    if (m != null) {
      return {
        'seconds':    int.tryParse(m.group(1)!) ?? 0,
        'idle_cmd':   m.group(2)!,
        'resume_cmd': m.group(3),
      };
    }

    return null;
  }
}
