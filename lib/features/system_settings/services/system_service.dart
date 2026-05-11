import 'package:flutter/foundation.dart';
import 'package:settings/core/services/system_ffi.dart';

/// High-level system-settings service backed entirely by native FFI.
/// No dart:io / Process.run() calls remain here.
class SystemService {
  final SystemFfi _ffi;

  SystemService({SystemFfi? ffi}) : _ffi = ffi ?? SystemFfi.instance;

  // ── Language / Locale ──────────────────────────────────────────────────────

  Future<String> getCurrentLanguage() async {
    try {
      return await _ffi.getLocale();
    } catch (e) {
      debugPrint('Get language error: $e');
      return 'en_US.UTF-8';
    }
  }

  // ── Date & Time ────────────────────────────────────────────────────────────

  Future<String> getCurrentTimezone() async {
    try {
      return await _ffi.getTimezone();
    } catch (e) {
      debugPrint('Get timezone error: $e');
      return 'UTC';
    }
  }

  Future<List<String>> getAvailableTimezones() async {
    try {
      return await _ffi.listTimezones();
    } catch (e) {
      debugPrint('Get timezones error: $e');
      return [];
    }
  }

  Future<bool> isAutomaticTimeEnabled() async {
    try {
      return await _ffi.getNtpEnabled();
    } catch (e) {
      debugPrint('Check NTP error: $e');
      return true;
    }
  }

  Future<bool> setAutomaticTime(bool enabled) async {
    try {
      return await _ffi.setNtp(enabled);
    } catch (e) {
      debugPrint('Set NTP error: $e');
      return false;
    }
  }

  Future<bool> setTimezone(String timezone) async {
    try {
      return await _ffi.setTimezone(timezone);
    } catch (e) {
      debugPrint('Set timezone error: $e');
      return false;
    }
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  Future<List<Map<String, String>>> getUsers() async {
    try {
      return await _ffi.getUsers();
    } catch (e) {
      debugPrint('Get users error: $e');
      return [];
    }
  }

  // ── Remote Desktop ─────────────────────────────────────────────────────────

  Future<bool> isRemoteDesktopEnabled() async {
    try {
      return await _ffi.isRemoteDesktopEnabled();
    } catch (e) {
      debugPrint('Check remote desktop error: $e');
      return false;
    }
  }

  Future<bool> setRemoteDesktopEnabled(bool enabled) async {
    try {
      return await _ffi.setRemoteDesktopEnabled(enabled);
    } catch (e) {
      debugPrint('Set remote desktop error: $e');
      return false;
    }
  }

  // ── SSH ────────────────────────────────────────────────────────────────────

  Future<bool> isSSHEnabled() async {
    try {
      return await _ffi.isSshEnabled();
    } catch (e) {
      debugPrint('Check SSH error: $e');
      return false;
    }
  }

  Future<bool> setSSHEnabled(bool enabled) async {
    try {
      return await _ffi.setSshEnabled(enabled);
    } catch (e) {
      debugPrint('Set SSH error: $e');
      return false;
    }
  }

  // ── About / Hardware Info ──────────────────────────────────────────────────

  Future<String> getHostname() async {
    try {
      return await _ffi.getHostname();
    } catch (e) {
      debugPrint('Get hostname error: $e');
      return 'Unknown';
    }
  }

  Future<String> getOSName() async {
    try {
      return await _ffi.getOsName();
    } catch (e) {
      debugPrint('Get OS name error: $e');
      return 'Linux';
    }
  }

  Future<String> getKernelVersion() async {
    try {
      return await _ffi.getKernelVersion();
    } catch (e) {
      debugPrint('Get kernel error: $e');
      return 'Unknown';
    }
  }

  Future<String> getTotalMemory() async {
    try {
      return await _ffi.getTotalMemory();
    } catch (e) {
      debugPrint('Get memory error: $e');
      return 'Unknown';
    }
  }

  Future<String> getCPUInfo() async {
    try {
      return await _ffi.getCpuInfo();
    } catch (e) {
      debugPrint('Get CPU info error: $e');
      return 'Unknown';
    }
  }

  Future<String> getDiskInfo() async {
    try {
      return await _ffi.getDiskInfo();
    } catch (e) {
      debugPrint('Get disk info error: $e');
      return 'Unknown';
    }
  }

  Future<String> getSSHInfo() async {
    try {
      return await _ffi.getSshInfo();
    } catch (e) {
      debugPrint('Get SSH info error: $e');
      return 'SSH is enabled';
    }
  }

  // ── Generic privileged shell command ───────────────────────────────────────

  /// Runs a shell command via native system() and returns the exit code.
  Future<int> runShellCommand(String cmd) async {
    try {
      return await _ffi.runShellCommand(cmd);
    } catch (e) {
      debugPrint('runShellCommand error: $e');
      return -1;
    }
  }
}
