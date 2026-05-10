import 'dart:io';
import 'package:flutter/foundation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// خدمة Idle Config — تدعم ثلاثة daemons:
//   • aetheridle  → ~/.config/aetheridle/config
//   • swayidle    → ~/.config/swayidle/config   (نفس صيغة aetheridle)
//   • hypridle    → ~/.config/hypr/hypridle.conf (صيغة listener {} خاصة)
//
// الكشف بالأولوية:
//   1) أي daemon يعمل الآن عبر pgrep
//   2) أي config موجود على الديسك
//   3) أي binary مثبت على النظام
//   4) aetheridle كـ default
//
// التطبيق يكتب الملف فقط — الـ daemon يعمل باستقلالية تامة.
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
  // كشف الـ daemon
  // ─────────────────────────────────────────────────────────────────────────

  Future<_IdleDaemon> _detectDaemon() async {
    // ① أي daemon يعمل الآن؟ (الأكثر موثوقية)
    if (await _isProcessRunning('hypridle'))   { return _IdleDaemon.hypridle; }
    if (await _isProcessRunning('swayidle'))   { return _IdleDaemon.swayidle; }
    if (await _isProcessRunning('aetheridle')) { return _IdleDaemon.aetheridle; }

    // ② أي config موجود؟
    if (await File(_aetheridleConfigPath).exists()) { return _IdleDaemon.aetheridle; }
    if (await File(_swayidleConfigPath).exists())   { return _IdleDaemon.swayidle; }
    if (await File(_hypridleConfigPath).exists())   { return _IdleDaemon.hypridle; }

    // ③ أي binary مثبت؟
    if (await _binaryExists('aetheridle')) { return _IdleDaemon.aetheridle; }
    if (await _binaryExists('swayidle'))   { return _IdleDaemon.swayidle; }
    if (await _binaryExists('hypridle'))   { return _IdleDaemon.hypridle; }

    // ④ default
    return _IdleDaemon.aetheridle;
  }

  Future<bool> _isProcessRunning(String name) async {
    try {
      final r = await Process.run('pgrep', ['-x', name]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _binaryExists(String name) async {
    try {
      final r = await Process.run('which', [name]);
      return r.exitCode == 0;
    } catch (_) {
      return false;
    }
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
    debugPrint('[IdleService] write → daemon=$daemon');

    switch (daemon) {
      case _IdleDaemon.aetheridle:
        await _writeLineConfig(
          path: _aetheridleConfigPath,
          dimSeconds: dimSeconds,
          blankSeconds: blankSeconds,
          suspendSeconds: suspendSeconds,
        );
      case _IdleDaemon.swayidle:
        await _writeLineConfig(
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
    debugPrint('[IdleService] read  → daemon=$daemon');

    switch (daemon) {
      case _IdleDaemon.aetheridle:
        return _readLineConfig(_aetheridleConfigPath);
      case _IdleDaemon.swayidle:
        return _readLineConfig(_swayidleConfigPath);
      case _IdleDaemon.hypridle:
        return _readHypridleTimeouts();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // aetheridle / swayidle — صيغة الأسطر
  //
  // كتابة:  timeout <secs> <cmd> [resume <resume_cmd>]
  // قراءة:  تدعم مقتبسة مزدوجة، مفردة، أو بدون اقتباس
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _writeLineConfig({
    required String path,
    required int dimSeconds,
    required int blankSeconds,
    required int suspendSeconds,
  }) async {
    // احتفظ بالأسطر غير المتعلقة بـ timeout (before-sleep، lock، إلخ)
    final preserved = await _readNonTimeoutLines(path);
    final buf = StringBuffer();

    buf.writeln('# managed by Settings — timeout lines are auto-generated');
    buf.writeln();

    for (final line in preserved) {
      buf.writeln(line);
    }
    if (preserved.isNotEmpty) { buf.writeln(); }

    if (dimSeconds > 0) {
      buf.writeln(
        "timeout $dimSeconds '${_dimCmd()}' resume '${_undimCmd()}'",
      );
    }
    if (blankSeconds > 0) {
      buf.writeln(
        "timeout $blankSeconds '${_screenOffCmd()}' resume '${_screenOnCmd()}'",
      );
    }
    if (suspendSeconds > 0) {
      buf.writeln("timeout $suspendSeconds 'systemctl suspend'");
    }

    await _writeFile(path, buf.toString());
  }

  Future<Map<String, int>> _readLineConfig(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      debugPrint('[IdleService] config not found: $path');
      return {'dim': 0, 'blank': 0, 'suspend': 0};
    }

    int dim = 0, blank = 0, suspend = 0;
    final lines = await file.readAsLines();
    debugPrint('[IdleService] reading ${lines.length} lines from $path');

    for (final raw in lines) {
      final line = raw.trim();
      if (line.isEmpty || line.startsWith('#')) { continue; }
      if (!line.startsWith('timeout')) { continue; }

      final p = _parseTimeoutLine(line);
      if (p == null) {
        debugPrint('[IdleService] could not parse: $line');
        continue;
      }

      final secs = p.seconds;
      final cmd  = p.idleCmd;
      debugPrint('[IdleService] parsed: secs=$secs cmd=$cmd');

      if (cmd.contains('suspend')) {
        suspend = secs;
      } else if (_isScreenOffCmd(cmd)) {
        blank = secs;
      } else if (cmd.contains('brightnessctl') || cmd.contains('dim')) {
        dim = secs;
      }
    }

    debugPrint('[IdleService] result: dim=$dim blank=$blank suspend=$suspend');
    return {'dim': dim, 'blank': blank, 'suspend': suspend};
  }

  // ─────────────────────────────────────────────────────────────────────────
  // hypridle — صيغة listener {}
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _writeHypridleConfig({
    required int dimSeconds,
    required int blankSeconds,
    required int suspendSeconds,
  }) async {
    final generalBlock = await _readHypridleGeneralBlock();
    final buf = StringBuffer();

    buf.writeln('# managed by Settings — listener blocks are auto-generated');
    buf.writeln();

    if (generalBlock.isNotEmpty) {
      for (final line in generalBlock) { buf.writeln(line); }
    } else {
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
    if (!await file.exists()) {
      debugPrint('[IdleService] hypridle config not found');
      return {'dim': 0, 'blank': 0, 'suspend': 0};
    }

    int dim = 0, blank = 0, suspend = 0;
    int? currentTimeout;
    String? currentOnTimeout;

    for (final raw in await file.readAsLines()) {
      final line = raw.trim();

      // timeout = <secs>
      final mTimeout = RegExp(r'^\s*timeout\s*=\s*(\d+)').firstMatch(line);
      if (mTimeout != null) {
        currentTimeout = int.tryParse(mTimeout.group(1)!);
        continue;
      }

      // on-timeout = <cmd>
      final mOnTimeout = RegExp(r'^\s*on-timeout\s*=\s*(.+)').firstMatch(line);
      if (mOnTimeout != null) {
        currentOnTimeout = mOnTimeout.group(1)!.trim();
        continue;
      }

      // نهاية الـ block
      if (line == '}' && currentTimeout != null && currentOnTimeout != null) {
        if (currentOnTimeout.contains('suspend')) {
          suspend = currentTimeout;
        } else if (_isScreenOffCmd(currentOnTimeout)) {
          blank = currentTimeout;
        } else if (currentOnTimeout.contains('brightnessctl') ||
                   currentOnTimeout.contains('dim')) {
          dim = currentTimeout;
        }
        currentTimeout   = null;
        currentOnTimeout = null;
      }
    }

    debugPrint('[IdleService] hypridle: dim=$dim blank=$blank suspend=$suspend');
    return {'dim': dim, 'blank': blank, 'suspend': suspend};
  }

  // ─────────────────────────────────────────────────────────────────────────
  // parser — يدعم الصيغ الثلاث
  //   "cmd" resume "cmd"     ← مقتبس مزدوج
  //   'cmd' resume 'cmd'     ← مقتبس مفرد
  //   cmd args resume cmd    ← بدون اقتباس (يُقسّم على كلمة resume)
  // ─────────────────────────────────────────────────────────────────────────

  _ParsedTimeout? _parseTimeoutLine(String line) {
    // استخرج العدد والباقي: timeout <secs> <rest>
    final base = RegExp(r'^timeout\s+(\d+)\s+(.+)$').firstMatch(line);
    if (base == null) { return null; }

    final secs = int.tryParse(base.group(1)!) ?? 0;
    final rest = base.group(2)!.trim();

    // ① مقتبس مزدوج: "idle" resume "resume"
    final dq = RegExp(
      r'^"([^"]+)"(?:\s+resume\s+"([^"]+)")?$',
    ).firstMatch(rest);
    if (dq != null) {
      return _ParsedTimeout(secs, dq.group(1)!, dq.group(2));
    }

    // ② مقتبس مفرد: 'idle' resume 'resume'
    final sq = RegExp(
      r"^'([^']+)'(?:\s+resume\s+'([^']+)')?$",
    ).firstMatch(rest);
    if (sq != null) {
      return _ParsedTimeout(secs, sq.group(1)!, sq.group(2));
    }

    // ③ بدون اقتباس — نُقسّم على كلمة resume
    const kw = ' resume ';
    final idx = rest.indexOf(kw);
    if (idx >= 0) {
      return _ParsedTimeout(
        secs,
        rest.substring(0, idx).trim(),
        rest.substring(idx + kw.length).trim(),
      );
    }

    // ④ أمر واحد بدون resume
    return _ParsedTimeout(secs, rest, null);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // مساعدات القراءة
  // ─────────────────────────────────────────────────────────────────────────

  /// يُعيد الأسطر التي ليست timeout أو تعليق أو فارغة.
  Future<List<String>> _readNonTimeoutLines(String path) async {
    final file = File(path);
    if (!await file.exists()) { return []; }
    final result = <String>[];
    for (final line in await file.readAsLines()) {
      final t = line.trim();
      if (t.isEmpty || t.startsWith('#')) { continue; }
      if (t.startsWith('timeout')) { continue; }
      result.add(line);
    }
    return result;
  }

  /// يُعيد كتلة general { } من hypridle.conf.
  Future<List<String>> _readHypridleGeneralBlock() async {
    final file = File(_hypridleConfigPath);
    if (!await file.exists()) { return []; }

    final result = <String>[];
    bool inGeneral = false;

    for (final line in await file.readAsLines()) {
      final t = line.trim();
      if (!inGeneral && t.startsWith('general') && t.contains('{')) {
        inGeneral = true;
        result.add(line);
        continue;
      }
      if (inGeneral) {
        result.add(line);
        if (t == '}') { break; }
      }
    }
    return result;
  }

  bool _isScreenOffCmd(String cmd) =>
      cmd.contains('dpms off') ||
      cmd.contains('power off') ||
      cmd.contains('dpms force off');

  // ─────────────────────────────────────────────────────────────────────────
  // أوامر الشاشة
  // ─────────────────────────────────────────────────────────────────────────

  String _dimCmd()   => 'brightnessctl set 30%';
  String _undimCmd() => 'brightnessctl set 100%';

  String _screenOffCmd() {
    if (_isHyprland()) { return 'hyprctl dispatch dpms off'; }
    if (_isSway())     { return "swaymsg 'output * power off'"; }
    return 'xset dpms force off';
  }

  String _screenOnCmd() {
    if (_isHyprland()) { return 'hyprctl dispatch dpms on'; }
    if (_isSway())     { return "swaymsg 'output * power on'"; }
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
    debugPrint('[IdleService] wrote: $path');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// نموذج بسيط لنتيجة الـ parse
// ─────────────────────────────────────────────────────────────────────────────

class _ParsedTimeout {
  final int seconds;
  final String idleCmd;
  final String? resumeCmd;

  const _ParsedTimeout(this.seconds, this.idleCmd, this.resumeCmd);
}
