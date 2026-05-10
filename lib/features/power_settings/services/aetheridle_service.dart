import 'dart:io';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// خدمة Idle Config — تدعم ثلاثة daemons:
//   • aetheridle  → ~/.config/aetheridle/config
//   • swayidle    → ~/.config/swayidle/config      (نفس صيغة aetheridle)
//   • hypridle    → ~/.config/hypr/hypridle.conf   (صيغة listener{} خاصة)
//
// التطبيق يكتب الملف فقط. الـ daemon يعمل باستقلالية تامة عبر autostart.
// ─────────────────────────────────────────────────────────────────────────────

enum _IdleDaemon { aetheridle, swayidle, hypridle }

class AetheridleService {
  final String _home;

  AetheridleService() : _home = Platform.environment['HOME'] ?? '/root';

  // ─────────────────────────────────────────────────────────────────────────
  // مسارات الـ config
  // ─────────────────────────────────────────────────────────────────────────

  String get _aetheridleConfigPath => '$_home/.config/aetheridle/config';
  String get _swayidleConfigPath   => '$_home/.config/swayidle/config';
  String get _hypridleConfigPath   => '$_home/.config/hypr/hypridle.conf';

  // ─────────────────────────────────────────────────────────────────────────
  // اكتشاف الـ daemon المناسب
  // أولوية: إذا كان الـ config موجوداً → استخدمه
  //          ثم حسب المجمّع الحالي
  //          ثم aetheridle كـ default
  // ─────────────────────────────────────────────────────────────────────────

  Future<_IdleDaemon> _detectDaemon() async {
    // هل يوجد hypridle config؟
    if (await File(_hypridleConfigPath).exists()) return _IdleDaemon.hypridle;
    // هل يوجد swayidle config؟
    if (await File(_swayidleConfigPath).exists()) return _IdleDaemon.swayidle;
    // هل يوجد aetheridle config؟
    if (await File(_aetheridleConfigPath).exists()) return _IdleDaemon.aetheridle;

    // لا يوجد أي config — اختر حسب المجمّع
    if (_isHyprland()) return _IdleDaemon.hypridle;
    if (_isSway())     return _IdleDaemon.swayidle;
    return _IdleDaemon.aetheridle;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // الواجهة الرئيسية
  // ─────────────────────────────────────────────────────────────────────────

  /// يضبط المهلات الثلاث ويكتبها في الـ config المناسب.
  Future<void> setAllTimeouts({
    required int dimSeconds,
    required int blankSeconds,
    required int suspendSeconds,
  }) async {
    final daemon = await _detectDaemon();
    debugPrint('[IdleService] daemon=$daemon');

    switch (daemon) {
      case _IdleDaemon.aetheridle:
        await _writeAetheridleConfig(
          path: _aetheridleConfigPath,
          dimSeconds: dimSeconds,
          blankSeconds: blankSeconds,
          suspendSeconds: suspendSeconds,
        );
      case _IdleDaemon.swayidle:
        await _writeAetheridleConfig(
          path: _swayidleConfigPath,
          dimSeconds: dimSeconds,
          blankSeconds: blankSeconds,
          suspendSeconds: suspendSeconds,
        );
      case _IdleDaemon.hypridle:
        await _writeHypridleConfig(
          dimSeconds: dimSeconds,
          blankSeconds: blankSeconds,
          suspendSeconds: suspendSeconds,
        );
    }
  }

  /// يُعيد المهلات الحالية {dim, blank, suspend} بالثواني.
  Future<Map<String, int>> getCurrentTimeoutsSeconds() async {
    final daemon = await _detectDaemon();
    switch (daemon) {
      case _IdleDaemon.aetheridle:
        return _readAetheridleTimeouts(_aetheridleConfigPath);
      case _IdleDaemon.swayidle:
        return _readAetheridleTimeouts(_swayidleConfigPath); // نفس الصيغة
      case _IdleDaemon.hypridle:
        return _readHypridleTimeouts();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // aetheridle / swayidle — نفس الصيغة
  //
  // timeout <secs> "<idle_cmd>" [resume "<resume_cmd>"]
  // before-sleep "<cmd>"
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _writeAetheridleConfig({
    required String path,
    required int dimSeconds,
    required int blankSeconds,
    required int suspendSeconds,
  }) async {
    final preserved = await _readNonTimeoutLines(path);
    final buf = StringBuffer();

    buf.writeln('# managed by Settings — do not edit timeout lines manually');
    buf.writeln();

    // أسطر محفوظة (before-sleep, lock, ...)
    for (final line in preserved) {
      buf.writeln(line);
    }
    if (preserved.isNotEmpty) buf.writeln();

    if (dimSeconds > 0) {
      buf.writeln(
        'timeout $dimSeconds "${_dimCmd()}" resume "${_undimCmd()}"',
      );
    }
    if (blankSeconds > 0) {
      buf.writeln(
        'timeout $blankSeconds "${_screenOffCmd()}" resume "${_screenOnCmd()}"',
      );
    }
    if (suspendSeconds > 0) {
      buf.writeln('timeout $suspendSeconds "systemctl suspend"');
    }

    await _writeFile(path, buf.toString());
  }

  Future<Map<String, int>> _readAetheridleTimeouts(String path) async {
    final file = File(path);
    if (!await file.exists()) return {'dim': 0, 'blank': 0, 'suspend': 0};

    int dim = 0, blank = 0, suspend = 0;

    for (final raw in await file.readAsLines()) {
      final line = raw.trim();
      if (!line.startsWith('timeout ')) continue;
      final p = _parseTimeoutLine(line);
      if (p == null) continue;

      final secs = (p['seconds'] as num).toInt();
      final cmd  = p['idle_cmd'] as String;

      if (cmd.contains('suspend')) {
        suspend = secs;
      } else if (_isScreenOffCmd(cmd)) {
        blank = secs;
      } else if (cmd.contains('brightnessctl') || cmd.contains('dim')) {
        dim = secs;
      }
    }

    return {'dim': dim, 'blank': blank, 'suspend': suspend};
  }

  // ─────────────────────────────────────────────────────────────────────────
  // hypridle — صيغة listener {} خاصة
  //
  // general {
  //   before_sleep_cmd = ...
  //   after_sleep_cmd  = ...
  // }
  // listener {
  //   timeout    = <secs>
  //   on-timeout = <cmd>
  //   on-resume  = <cmd>
  // }
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _writeHypridleConfig({
    required int dimSeconds,
    required int blankSeconds,
    required int suspendSeconds,
  }) async {
    // احتفظ بـ general block من الـ config الحالي إن وُجد
    final generalBlock = await _readHypridleGeneralBlock();
    final buf = StringBuffer();

    buf.writeln('# managed by Settings — listener blocks are overwritten');
    buf.writeln();

    // general block
    if (generalBlock.isNotEmpty) {
      for (final line in generalBlock) { buf.writeln(line); }
    } else {
      // default general block
      buf.writeln('general {');
      if (_isHyprland()) {
        buf.writeln('    after_sleep_cmd = hyprctl dispatch dpms on');
      }
      buf.writeln('    ignore_dbus_inhibit = false');
      buf.writeln('}');
    }
    buf.writeln();

    if (dimSeconds > 0) {
      buf.writeln('listener {');
      buf.writeln('    timeout    = $dimSeconds');
      buf.writeln('    on-timeout = ${_dimCmd()}');
      buf.writeln('    on-resume  = ${_undimCmd()}');
      buf.writeln('}');
      buf.writeln();
    }

    if (blankSeconds > 0) {
      buf.writeln('listener {');
      buf.writeln('    timeout    = $blankSeconds');
      buf.writeln('    on-timeout = ${_screenOffCmd()}');
      buf.writeln('    on-resume  = ${_screenOnCmd()}');
      buf.writeln('}');
      buf.writeln();
    }

    if (suspendSeconds > 0) {
      buf.writeln('listener {');
      buf.writeln('    timeout    = $suspendSeconds');
      buf.writeln('    on-timeout = systemctl suspend');
      buf.writeln('}');
    }

    await _writeFile(_hypridleConfigPath, buf.toString());
  }

  Future<Map<String, int>> _readHypridleTimeouts() async {
    final file = File(_hypridleConfigPath);
    if (!await file.exists()) return {'dim': 0, 'blank': 0, 'suspend': 0};

    int dim = 0, blank = 0, suspend = 0;
    int? currentTimeout;
    String? currentOnTimeout;

    for (final raw in await file.readAsLines()) {
      final line = raw.trim();

      if (line.startsWith('timeout')) {
        // timeout = <secs>
        final m = RegExp(r'timeout\s*=\s*(\d+)').firstMatch(line);
        if (m != null) currentTimeout = int.tryParse(m.group(1)!);
      } else if (line.startsWith('on-timeout')) {
        final m = RegExp(r'on-timeout\s*=\s*(.+)').firstMatch(line);
        if (m != null) currentOnTimeout = m.group(1)!.trim();
      } else if (line == '}') {
        // نهاية listener block
        if (currentTimeout != null && currentOnTimeout != null) {
          if (currentOnTimeout.contains('suspend')) {
            suspend = currentTimeout;
          } else if (_isScreenOffCmd(currentOnTimeout)) {
            blank = currentTimeout;
          } else if (currentOnTimeout.contains('brightnessctl') ||
                     currentOnTimeout.contains('dim')) {
            dim = currentTimeout;
          }
        }
        currentTimeout  = null;
        currentOnTimeout = null;
      }
    }

    return {'dim': dim, 'blank': blank, 'suspend': suspend};
  }

  // ─────────────────────────────────────────────────────────────────────────
  // مساعدات القراءة
  // ─────────────────────────────────────────────────────────────────────────

  /// يُعيد الأسطر التي ليست timeout أو تعليق أو فارغة (before-sleep, lock...)
  Future<List<String>> _readNonTimeoutLines(String path) async {
    final file = File(path);
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

  /// يُعيد أسطر كتلة general { } من hypridle.conf
  Future<List<String>> _readHypridleGeneralBlock() async {
    final file = File(_hypridleConfigPath);
    if (!await file.exists()) return [];

    final result = <String>[];
    bool inGeneral = false;

    for (final line in await file.readAsLines()) {
      final t = line.trim();
      if (t.startsWith('general') && t.contains('{')) {
        inGeneral = true;
        result.add(line);
        continue;
      }
      if (inGeneral) {
        result.add(line);
        if (t == '}') break;
      }
    }
    return result;
  }

  Map<String, Object?>? _parseTimeoutLine(String line) {
    // صيغة بعلامات اقتباس مزدوجة: timeout 300 "cmd" resume "cmd"
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
    // صيغة بعلامات اقتباس مفردة: timeout 300 'cmd' resume 'cmd'
    final reSimple = RegExp(
      r"^timeout\s+(\d+)\s+'([^']+)'(?:\s+resume\s+'([^']+)')?$",
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

  bool _isScreenOffCmd(String cmd) =>
      cmd.contains('dpms off') ||
      cmd.contains('power off') ||
      cmd.contains('dpms force off');

  // ─────────────────────────────────────────────────────────────────────────
  // أوامر الشاشة — حسب المجمّع
  // ─────────────────────────────────────────────────────────────────────────

  String _dimCmd()     => 'brightnessctl set 30%';
  String _undimCmd()   => 'brightnessctl set 100%';

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
  // كتابة الملف
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _writeFile(String path, String content) async {
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
    debugPrint('[IdleService] تم تحديث: $path');
  }
}
