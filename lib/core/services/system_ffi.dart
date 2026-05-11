import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Native function signatures (C side)
// ─────────────────────────────────────────────────────────────────────────────

// System info
typedef _SysGetHostnameNative      = Pointer<Utf8> Function();
typedef _SysGetOsNameNative        = Pointer<Utf8> Function();
typedef _SysGetKernelVersionNative = Pointer<Utf8> Function();
typedef _SysGetCpuInfoNative       = Pointer<Utf8> Function();
typedef _SysGetTotalMemoryNative   = Pointer<Utf8> Function();
typedef _SysGetDiskInfoNative      = Pointer<Utf8> Function();

// Locale
typedef _SysGetLocaleNative        = Pointer<Utf8> Function();

// Date & Time
typedef _SysGetTimezoneNative      = Pointer<Utf8> Function();
typedef _SysGetNtpEnabledNative    = Int32 Function();
typedef _SysSetNtpNative           = Int32 Function(Int32 enabled);
typedef _SysSetTimezoneNative      = Int32 Function(Pointer<Utf8> tz);
typedef _SysListTimezonesNative    = Pointer<Utf8> Function();

// Users
typedef _SysGetUsersNative         = Pointer<Utf8> Function();

// SSH
typedef _SysIsSshEnabledNative     = Int32 Function();
typedef _SysSetSshEnabledNative    = Int32 Function(Int32 enabled);
typedef _SysGetSshInfoNative       = Pointer<Utf8> Function();

// Remote Desktop
typedef _SysIsRemoteDesktopEnabledNative  = Int32 Function();
typedef _SysSetRemoteDesktopEnabledNative = Int32 Function(Int32 enabled);

// Memory
typedef _SysFreeStringNative       = Void Function(Pointer<Utf8> str);

// Shell command
typedef _SysRunShellCommandNative  = Int32 Function(Pointer<Utf8> cmd);

// ─────────────────────────────────────────────────────────────────────────────
// Dart-side typedefs
// ─────────────────────────────────────────────────────────────────────────────

typedef _SysGetHostnameDart      = Pointer<Utf8> Function();
typedef _SysGetOsNameDart        = Pointer<Utf8> Function();
typedef _SysGetKernelVersionDart = Pointer<Utf8> Function();
typedef _SysGetCpuInfoDart       = Pointer<Utf8> Function();
typedef _SysGetTotalMemoryDart   = Pointer<Utf8> Function();
typedef _SysGetDiskInfoDart      = Pointer<Utf8> Function();

typedef _SysGetLocaleDart        = Pointer<Utf8> Function();

typedef _SysGetTimezoneDart      = Pointer<Utf8> Function();
typedef _SysGetNtpEnabledDart    = int Function();
typedef _SysSetNtpDart           = int Function(int enabled);
typedef _SysSetTimezoneDart      = int Function(Pointer<Utf8> tz);
typedef _SysListTimezonesDart    = Pointer<Utf8> Function();

typedef _SysGetUsersDart         = Pointer<Utf8> Function();

typedef _SysIsSshEnabledDart     = int Function();
typedef _SysSetSshEnabledDart    = int Function(int enabled);
typedef _SysGetSshInfoDart       = Pointer<Utf8> Function();

typedef _SysIsRemoteDesktopEnabledDart  = int Function();
typedef _SysSetRemoteDesktopEnabledDart = int Function(int enabled);

typedef _SysFreeStringDart       = void Function(Pointer<Utf8> str);

typedef _SysRunShellCommandDart  = int Function(Pointer<Utf8> cmd);

// ─────────────────────────────────────────────────────────────────────────────
// FFI Loader singleton
// ─────────────────────────────────────────────────────────────────────────────

class SystemFfi {
  static SystemFfi? _instance;
  static SystemFfi get instance => _instance ??= SystemFfi._load();

  late final DynamicLibrary _lib;

  // Bound functions
  late final _SysGetHostnameDart      _getHostname;
  late final _SysGetOsNameDart        _getOsName;
  late final _SysGetKernelVersionDart _getKernelVersion;
  late final _SysGetCpuInfoDart       _getCpuInfo;
  late final _SysGetTotalMemoryDart   _getTotalMemory;
  late final _SysGetDiskInfoDart      _getDiskInfo;

  late final _SysGetLocaleDart        _getLocale;

  late final _SysGetTimezoneDart      _getTimezone;
  late final _SysGetNtpEnabledDart    _getNtpEnabled;
  late final _SysSetNtpDart           _setNtp;
  late final _SysSetTimezoneDart      _setTimezone;
  late final _SysListTimezonesDart    _listTimezones;

  late final _SysGetUsersDart         _getUsers;

  late final _SysIsSshEnabledDart     _isSshEnabled;
  late final _SysSetSshEnabledDart    _setSshEnabled;
  late final _SysGetSshInfoDart       _getSshInfo;

  late final _SysIsRemoteDesktopEnabledDart  _isRemoteDesktopEnabled;
  late final _SysSetRemoteDesktopEnabledDart _setRemoteDesktopEnabled;

  late final _SysFreeStringDart       _freeString;
  late final _SysRunShellCommandDart  _runShellCommand;

  SystemFfi._load() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final candidates = [
      '$exeDir/lib/libsystem_ffi.so',
      '$exeDir/libsystem_ffi.so',
      'libsystem_ffi.so',
    ];

    DynamicLibrary? lib;
    for (final path in candidates) {
      try {
        lib = DynamicLibrary.open(path);
        break;
      } catch (_) {}
    }
    if (lib == null) {
      throw UnsupportedError(
          '[SystemFfi] Cannot load libsystem_ffi.so. '
          'Ensure the library is built (flutter build linux).');
    }
    _lib = lib;

    _getHostname      = _lib.lookupFunction<_SysGetHostnameNative,      _SysGetHostnameDart>     ('sys_get_hostname');
    _getOsName        = _lib.lookupFunction<_SysGetOsNameNative,        _SysGetOsNameDart>       ('sys_get_os_name');
    _getKernelVersion = _lib.lookupFunction<_SysGetKernelVersionNative, _SysGetKernelVersionDart>('sys_get_kernel_version');
    _getCpuInfo       = _lib.lookupFunction<_SysGetCpuInfoNative,       _SysGetCpuInfoDart>      ('sys_get_cpu_info');
    _getTotalMemory   = _lib.lookupFunction<_SysGetTotalMemoryNative,   _SysGetTotalMemoryDart>  ('sys_get_total_memory');
    _getDiskInfo      = _lib.lookupFunction<_SysGetDiskInfoNative,      _SysGetDiskInfoDart>     ('sys_get_disk_info');

    _getLocale        = _lib.lookupFunction<_SysGetLocaleNative,        _SysGetLocaleDart>       ('sys_get_locale');

    _getTimezone      = _lib.lookupFunction<_SysGetTimezoneNative,      _SysGetTimezoneDart>     ('sys_get_timezone');
    _getNtpEnabled    = _lib.lookupFunction<_SysGetNtpEnabledNative,    _SysGetNtpEnabledDart>   ('sys_get_ntp_enabled');
    _setNtp           = _lib.lookupFunction<_SysSetNtpNative,           _SysSetNtpDart>          ('sys_set_ntp');
    _setTimezone      = _lib.lookupFunction<_SysSetTimezoneNative,      _SysSetTimezoneDart>     ('sys_set_timezone');
    _listTimezones    = _lib.lookupFunction<_SysListTimezonesNative,    _SysListTimezonesDart>   ('sys_list_timezones');

    _getUsers         = _lib.lookupFunction<_SysGetUsersNative,         _SysGetUsersDart>        ('sys_get_users');

    _isSshEnabled     = _lib.lookupFunction<_SysIsSshEnabledNative,     _SysIsSshEnabledDart>    ('sys_is_ssh_enabled');
    _setSshEnabled    = _lib.lookupFunction<_SysSetSshEnabledNative,    _SysSetSshEnabledDart>   ('sys_set_ssh_enabled');
    _getSshInfo       = _lib.lookupFunction<_SysGetSshInfoNative,       _SysGetSshInfoDart>      ('sys_get_ssh_info');

    _isRemoteDesktopEnabled  = _lib.lookupFunction<_SysIsRemoteDesktopEnabledNative,  _SysIsRemoteDesktopEnabledDart> ('sys_is_remote_desktop_enabled');
    _setRemoteDesktopEnabled = _lib.lookupFunction<_SysSetRemoteDesktopEnabledNative, _SysSetRemoteDesktopEnabledDart>('sys_set_remote_desktop_enabled');

    _freeString      = _lib.lookupFunction<_SysFreeStringNative,      _SysFreeStringDart>     ('sys_free_string');
    _runShellCommand = _lib.lookupFunction<_SysRunShellCommandNative,  _SysRunShellCommandDart>('sys_run_shell_command');
  }

  // ── Internal helper ────────────────────────────────────────────────────────

  String _callString(Pointer<Utf8> Function() fn) {
    final ptr = fn();
    if (ptr == nullptr) return '';
    final s = ptr.toDartString();
    _freeString(ptr);
    return s;
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<String> getHostname()      async => _callString(_getHostname);
  Future<String> getOsName()        async => _callString(_getOsName);
  Future<String> getKernelVersion() async => _callString(_getKernelVersion);
  Future<String> getCpuInfo()       async => _callString(_getCpuInfo);
  Future<String> getTotalMemory()   async => _callString(_getTotalMemory);
  Future<String> getDiskInfo()      async => _callString(_getDiskInfo);

  Future<String> getLocale()        async => _callString(_getLocale);

  Future<String> getTimezone()      async => _callString(_getTimezone);

  Future<bool> getNtpEnabled() async {
    return _getNtpEnabled() != 0;
  }

  Future<bool> setNtp(bool enabled) async {
    return _setNtp(enabled ? 1 : 0) != 0;
  }

  Future<bool> setTimezone(String tz) async {
    final tzPtr = tz.toNativeUtf8();
    try {
      return _setTimezone(tzPtr) != 0;
    } finally {
      calloc.free(tzPtr);
    }
  }

  Future<List<String>> listTimezones() async {
    final raw = _callString(_listTimezones);
    if (raw.isEmpty) return [];
    return raw.split('\n').where((s) => s.isNotEmpty).toSet().toList()..sort();
  }

  /// Returns list of maps with keys: username, uid, home
  Future<List<Map<String, String>>> getUsers() async {
    final raw = _callString(_getUsers);

    if (raw.isEmpty) return [];
    final users = <Map<String, String>>[];
    for (final line in raw.split('\n')) {
      if (line.isEmpty) continue;
      final parts = line.split('\t');
      if (parts.length >= 3) {
        users.add({'username': parts[0], 'uid': parts[1], 'home': parts[2]});
      }
    }
    return users;
  }

  Future<bool> isSshEnabled() async {
    return _isSshEnabled() != 0;
  }

  Future<bool> setSshEnabled(bool enabled) async {
    return _setSshEnabled(enabled ? 1 : 0) != 0;
  }

  Future<String> getSshInfo() async => _callString(_getSshInfo);

  Future<bool> isRemoteDesktopEnabled() async {
    return _isRemoteDesktopEnabled() != 0;
  }

  Future<bool> setRemoteDesktopEnabled(bool enabled) async {
    return _setRemoteDesktopEnabled(enabled ? 1 : 0) != 0;
  }

  /// Runs an arbitrary shell command via the native system() call.
  /// Returns the exit code (0 = success).
  Future<int> runShellCommand(String cmd) async {
    final cmdPtr = cmd.toNativeUtf8();
    try {
      return _runShellCommand(cmdPtr);
    } finally {
      calloc.free(cmdPtr);
    }
  }
}
