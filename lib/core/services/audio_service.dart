import 'dart:ffi';

import 'package:ffi/ffi.dart';

class AudioDevice {
  final String name;
  final String description;
  final int volume;
  final bool isDefault;

  AudioDevice({
    required this.name,
    required this.description,
    required this.volume,
    required this.isDefault,
  });
}

class AppStream {
  final int index;
  final String name;
  final String icon;
  final int volume;
  final bool muted;

  AppStream({
    required this.index,
    required this.name,
    required this.icon,
    required this.volume,
    required this.muted,
  });
}

class AudioCard {
  final String name;
  final String description;

  AudioCard({required this.name, required this.description});
}

class AudioProfile {
  final String name;
  final String description;
  final bool available;

  AudioProfile({
    required this.name,
    required this.description,
    required this.available,
  });
}

class AudioService {
  static final _pulse = _PulseAudioClient();

  bool _overamplification = false;

  bool get isConnected => _pulse.isConnected;

  Future<void> connect() async {
    _pulse.connect();
  }

  Future<void> dispose() async {
    _pulse.disconnect();
  }

  Future<int> getVolume() async {
    final defaultSink = _pulse.getDefaultSinkName();
    if (defaultSink == null) return 0;
    final info = _pulse.getSinkInfoByName(defaultSink);
    return info?.volumePercent ?? 0;
  }

  Future<bool> setVolume(int volume) async {
    final defaultSink = _pulse.getDefaultSinkName();
    if (defaultSink == null) return false;
    final info = _pulse.getSinkInfoByName(defaultSink);
    if (info == null) return false;
    return _pulse.setSinkVolumeByName(
      defaultSink,
      info.channels,
      _clampVolume(volume),
    );
  }

  Future<bool> getMuted() async {
    final defaultSink = _pulse.getDefaultSinkName();
    if (defaultSink == null) return false;
    return _pulse.getSinkInfoByName(defaultSink)?.muted ?? false;
  }

  Future<bool> setMuted(bool muted) async {
    final defaultSink = _pulse.getDefaultSinkName();
    if (defaultSink == null) return false;
    return _pulse.setSinkMuteByName(defaultSink, muted);
  }

  Future<int> getMicVolume() async {
    final defaultSource = _pulse.getDefaultSourceName();
    if (defaultSource == null) return 0;
    final info = _pulse.getSourceInfoByName(defaultSource);
    return info?.volumePercent ?? 0;
  }

  Future<bool> setMicVolume(int volume) async {
    final defaultSource = _pulse.getDefaultSourceName();
    if (defaultSource == null) return false;
    final info = _pulse.getSourceInfoByName(defaultSource);
    if (info == null) return false;
    return _pulse.setSourceVolumeByName(
      defaultSource,
      info.channels,
      _clampVolume(volume),
    );
  }

  Future<bool> getMicMuted() async {
    final defaultSource = _pulse.getDefaultSourceName();
    if (defaultSource == null) return false;
    return _pulse.getSourceInfoByName(defaultSource)?.muted ?? false;
  }

  Future<bool> setMicMuted(bool muted) async {
    final defaultSource = _pulse.getDefaultSourceName();
    if (defaultSource == null) return false;
    return _pulse.setSourceMuteByName(defaultSource, muted);
  }

  Future<List<AudioDevice>> getSinks() async {
    final defaultSink = _pulse.getDefaultSinkName();
    return _pulse
        .getSinks()
        .map(
          (sink) => AudioDevice(
            name: sink.name,
            description: sink.description,
            volume: sink.volumePercent,
            isDefault: sink.name == defaultSink,
          ),
        )
        .toList();
  }

  Future<bool> setDefaultSink(String name) async {
    return _pulse.setDefaultSink(name);
  }

  Future<bool> setSinkVolume(String name, int volume) async {
    final info = _pulse.getSinkInfoByName(name);
    if (info == null) return false;
    return _pulse.setSinkVolumeByName(
      name,
      info.channels,
      _clampVolume(volume),
    );
  }

  Future<List<AudioDevice>> getSources() async {
    final defaultSource = _pulse.getDefaultSourceName();
    return _pulse
        .getSources()
        .where((source) => !source.isMonitor)
        .map(
          (source) => AudioDevice(
            name: source.name,
            description: source.description,
            volume: source.volumePercent,
            isDefault: source.name == defaultSource,
          ),
        )
        .toList();
  }

  Future<bool> setDefaultSource(String name) async {
    return _pulse.setDefaultSource(name);
  }

  Future<bool> setSourceVolume(String name, int volume) async {
    final info = _pulse.getSourceInfoByName(name);
    if (info == null) return false;
    return _pulse.setSourceVolumeByName(
      name,
      info.channels,
      _clampVolume(volume),
    );
  }

  Future<List<AppStream>> getAppStreams() async {
    return _pulse
        .getSinkInputs()
        .map(
          (stream) => AppStream(
            index: stream.index,
            name: stream.name,
            icon: stream.icon,
            volume: stream.volumePercent,
            muted: stream.muted,
          ),
        )
        .toList();
  }

  Future<bool> setAppVolume(int index, int volume) async {
    final info = _pulse.getSinkInputInfo(index);
    if (info == null) return false;
    return _pulse.setSinkInputVolume(
      index,
      info.channels,
      _clampVolume(volume),
    );
  }

  Future<bool> setAppMuted(int index, bool muted) async {
    return _pulse.setSinkInputMute(index, muted);
  }

  Future<bool> moveAppToSink(int index, String sinkName) async {
    return _pulse.moveSinkInputByName(index, sinkName);
  }

  Future<List<AudioCard>> getCards() async {
    return _pulse
        .getCards()
        .map(
          (card) => AudioCard(name: card.name, description: card.description),
        )
        .toList();
  }

  Future<List<AudioProfile>> getProfiles(String cardName) async {
    final card = _pulse.getCardByName(cardName);
    if (card == null) return [];
    return card.profiles
        .map(
          (profile) => AudioProfile(
            name: profile.name,
            description: profile.description,
            available: profile.available,
          ),
        )
        .toList();
  }

  Future<bool> setProfile(String cardName, String profile) async {
    return _pulse.setCardProfile(cardName, profile);
  }

  Future<bool> getOveramplification() async {
    return _overamplification;
  }

  Future<bool> setOveramplification(bool enabled) async {
    _overamplification = enabled;
    return true;
  }

  Future<int> getMaxVolume() async {
    return _overamplification ? 150 : 100;
  }

  int _clampVolume(int volume) {
    final max = _overamplification ? 150 : 100;
    return volume.clamp(0, max);
  }
}

class _PulseAudioClient {
  _PulseAudioClient();

  static final DynamicLibrary _lib = DynamicLibrary.open('libpulse.so.0');

  static final _paMainloopNew = _lib
      .lookupFunction<
        Pointer<_PaMainloop> Function(),
        Pointer<_PaMainloop> Function()
      >('pa_mainloop_new');
  static final _paMainloopFree = _lib
      .lookupFunction<
        Void Function(Pointer<_PaMainloop>),
        void Function(Pointer<_PaMainloop>)
      >('pa_mainloop_free');
  static final _paMainloopIterate = _lib
      .lookupFunction<
        Int32 Function(Pointer<_PaMainloop>, Int32, Pointer<Int32>),
        int Function(Pointer<_PaMainloop>, int, Pointer<Int32>)
      >('pa_mainloop_iterate');
  static final _paMainloopGetApi = _lib
      .lookupFunction<
        Pointer<_PaMainloopApi> Function(Pointer<_PaMainloop>),
        Pointer<_PaMainloopApi> Function(Pointer<_PaMainloop>)
      >('pa_mainloop_get_api');
  static final _paContextNew = _lib
      .lookupFunction<
        Pointer<_PaContext> Function(Pointer<_PaMainloopApi>, Pointer<Utf8>),
        Pointer<_PaContext> Function(Pointer<_PaMainloopApi>, Pointer<Utf8>)
      >('pa_context_new');
  static final _paContextConnect = _lib
      .lookupFunction<
        Int32 Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Uint32,
          Pointer<Void>,
        ),
        int Function(Pointer<_PaContext>, Pointer<Utf8>, int, Pointer<Void>)
      >('pa_context_connect');
  static final _paContextDisconnect = _lib
      .lookupFunction<
        Void Function(Pointer<_PaContext>),
        void Function(Pointer<_PaContext>)
      >('pa_context_disconnect');
  static final _paContextUnref = _lib
      .lookupFunction<
        Void Function(Pointer<_PaContext>),
        void Function(Pointer<_PaContext>)
      >('pa_context_unref');
  static final _paContextGetState = _lib
      .lookupFunction<
        Int32 Function(Pointer<_PaContext>),
        int Function(Pointer<_PaContext>)
      >('pa_context_get_state');
  static final _paContextErrno = _lib
      .lookupFunction<
        Int32 Function(Pointer<_PaContext>),
        int Function(Pointer<_PaContext>)
      >('pa_context_errno');
  static final _paStrerror = _lib
      .lookupFunction<
        Pointer<Utf8> Function(Int32),
        Pointer<Utf8> Function(int)
      >('pa_strerror');
  static final _paOperationGetState = _lib
      .lookupFunction<
        Int32 Function(Pointer<_PaOperation>),
        int Function(Pointer<_PaOperation>)
      >('pa_operation_get_state');
  static final _paOperationUnref = _lib
      .lookupFunction<
        Void Function(Pointer<_PaOperation>),
        void Function(Pointer<_PaOperation>)
      >('pa_operation_unref');
  static final _paContextGetServerInfo = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaServerInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaServerInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_server_info');
  static final _paContextGetSinkInfoList = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaSinkInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaSinkInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_sink_info_list');
  static final _paContextGetSinkInfoByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSinkInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSinkInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_sink_info_by_name');
  static final _paContextGetSourceInfoList = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaSourceInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaSourceInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_source_info_list');
  static final _paContextGetSourceInfoByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSourceInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSourceInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_source_info_by_name');
  static final _paContextGetSinkInputInfoList = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaSinkInputInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaSinkInputInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_sink_input_info_list');
  static final _paContextGetSinkInputInfo = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Uint32,
          Pointer<NativeFunction<_PaSinkInputInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          int,
          Pointer<NativeFunction<_PaSinkInputInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_sink_input_info');
  static final _paContextGetCardInfoList = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaCardInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<NativeFunction<_PaCardInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_card_info_list');
  static final _paContextGetCardInfoByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaCardInfoCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaCardInfoCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_get_card_info_by_name');
  static final _paContextSetDefaultSink = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_default_sink');
  static final _paContextSetDefaultSource = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_default_source');
  static final _paContextSetSinkVolumeByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<_PaCVolume>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<_PaCVolume>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_sink_volume_by_name');
  static final _paContextSetSourceVolumeByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<_PaCVolume>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<_PaCVolume>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_source_volume_by_name');
  static final _paContextSetSinkMuteByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Int32,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          int,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_sink_mute_by_name');
  static final _paContextSetSourceMuteByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Int32,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          int,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_source_mute_by_name');
  static final _paContextSetSinkInputVolume = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Uint32,
          Pointer<_PaCVolume>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          int,
          Pointer<_PaCVolume>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_sink_input_volume');
  static final _paContextSetSinkInputMute = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Uint32,
          Int32,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          int,
          int,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_sink_input_mute');
  static final _paContextMoveSinkInputByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Uint32,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          int,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_move_sink_input_by_name');
  static final _paContextSetCardProfileByName = _lib
      .lookupFunction<
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        ),
        Pointer<_PaOperation> Function(
          Pointer<_PaContext>,
          Pointer<Utf8>,
          Pointer<Utf8>,
          Pointer<NativeFunction<_PaSuccessCbNative>>,
          Pointer<Void>,
        )
      >('pa_context_set_card_profile_by_name');
  static final _paCvolumeSet = _lib
      .lookupFunction<
        Pointer<_PaCVolume> Function(Pointer<_PaCVolume>, Uint32, Uint32),
        Pointer<_PaCVolume> Function(Pointer<_PaCVolume>, int, int)
      >('pa_cvolume_set');
  static final _paSwVolumeFromLinear = _lib
      .lookupFunction<Uint32 Function(Double), int Function(double)>(
        'pa_sw_volume_from_linear',
      );
  static final _paSwVolumeToLinear = _lib
      .lookupFunction<Double Function(Uint32), double Function(int)>(
        'pa_sw_volume_to_linear',
      );
  static final _paProplistGets = _lib
      .lookupFunction<
        Pointer<Utf8> Function(Pointer<_PaProplist>, Pointer<Utf8>),
        Pointer<Utf8> Function(Pointer<_PaProplist>, Pointer<Utf8>)
      >('pa_proplist_gets');

  static final Pointer<NativeFunction<_PaServerInfoCbNative>>
  _serverInfoCallbackPtr = Pointer.fromFunction<_PaServerInfoCbNative>(
    _serverInfoCallback,
  );
  static final Pointer<NativeFunction<_PaSinkInfoCbNative>>
  _sinkInfoCallbackPtr = Pointer.fromFunction<_PaSinkInfoCbNative>(
    _sinkInfoCallback,
  );
  static final Pointer<NativeFunction<_PaSourceInfoCbNative>>
  _sourceInfoCallbackPtr = Pointer.fromFunction<_PaSourceInfoCbNative>(
    _sourceInfoCallback,
  );
  static final Pointer<NativeFunction<_PaSinkInputInfoCbNative>>
  _sinkInputInfoCallbackPtr = Pointer.fromFunction<_PaSinkInputInfoCbNative>(
    _sinkInputInfoCallback,
  );
  static final Pointer<NativeFunction<_PaCardInfoCbNative>>
  _cardInfoCallbackPtr = Pointer.fromFunction<_PaCardInfoCbNative>(
    _cardInfoCallback,
  );
  static final Pointer<NativeFunction<_PaSuccessCbNative>> _successCallbackPtr =
      Pointer.fromFunction<_PaSuccessCbNative>(_successCallback);

  Pointer<_PaMainloop>? _mainloop;
  Pointer<_PaContext>? _context;
  bool _connected = false;

  bool get isConnected => _connected;

  void connect() {
    if (_connected) return;

    _mainloop = _paMainloopNew();
    if (_mainloop == null || _mainloop == nullptr) {
      throw Exception('Failed to create PulseAudio mainloop');
    }

    final appName = 'Settings'.toNativeUtf8();
    try {
      _context = _paContextNew(_paMainloopGetApi(_mainloop!), appName);
    } finally {
      malloc.free(appName);
    }

    if (_context == null || _context == nullptr) {
      _disposeNative();
      throw Exception('Failed to create PulseAudio context');
    }

    final result = _paContextConnect(_context!, nullptr.cast(), 0, nullptr);
    if (result < 0) {
      final error = _contextError();
      _disposeNative();
      throw Exception(error);
    }

    final retval = calloc<Int32>();
    try {
      while (true) {
        final state = _paContextGetState(_context!);
        if (state == _paContextReady) {
          _connected = true;
          return;
        }
        if (state == _paContextFailed || state == _paContextTerminated) {
          final error = _contextError();
          _disposeNative();
          throw Exception(error);
        }

        if (_paMainloopIterate(_mainloop!, 1, retval) < 0) {
          final error = _contextError();
          _disposeNative();
          throw Exception(error);
        }
      }
    } finally {
      calloc.free(retval);
    }
  }

  void disconnect() {
    if (!_connected && _mainloop == null && _context == null) {
      return;
    }

    _disposeNative();
    _connected = false;
  }

  String? getDefaultSinkName() {
    _ensureConnected();
    final serverInfo = _getServerInfo();
    return serverInfo?.defaultSinkName;
  }

  String? getDefaultSourceName() {
    _ensureConnected();
    final serverInfo = _getServerInfo();
    return serverInfo?.defaultSourceName;
  }

  List<_NodeInfo> getSinks() {
    _ensureConnected();
    final store = _SinkInfoStore();
    final op = _paContextGetSinkInfoList(
      _context!,
      _sinkInfoCallbackPtr,
      store.userdata,
    );
    _waitForListOperation(op, store);
    return store.items;
  }

  _NodeInfo? getSinkInfoByName(String name) {
    _ensureConnected();
    final nativeName = name.toNativeUtf8();
    final store = _SinkInfoStore();
    try {
      final op = _paContextGetSinkInfoByName(
        _context!,
        nativeName,
        _sinkInfoCallbackPtr,
        store.userdata,
      );
      _waitForListOperation(op, store);
      return store.items.isEmpty ? null : store.items.first;
    } finally {
      malloc.free(nativeName);
    }
  }

  List<_NodeInfo> getSources() {
    _ensureConnected();
    final store = _SourceInfoStore();
    final op = _paContextGetSourceInfoList(
      _context!,
      _sourceInfoCallbackPtr,
      store.userdata,
    );
    _waitForListOperation(op, store);
    return store.items;
  }

  _NodeInfo? getSourceInfoByName(String name) {
    _ensureConnected();
    final nativeName = name.toNativeUtf8();
    final store = _SourceInfoStore();
    try {
      final op = _paContextGetSourceInfoByName(
        _context!,
        nativeName,
        _sourceInfoCallbackPtr,
        store.userdata,
      );
      _waitForListOperation(op, store);
      return store.items.isEmpty ? null : store.items.first;
    } finally {
      malloc.free(nativeName);
    }
  }

  List<_SinkInputDetails> getSinkInputs() {
    _ensureConnected();
    final store = _SinkInputInfoStore();
    final op = _paContextGetSinkInputInfoList(
      _context!,
      _sinkInputInfoCallbackPtr,
      store.userdata,
    );
    _waitForListOperation(op, store);
    return store.items;
  }

  _SinkInputDetails? getSinkInputInfo(int index) {
    _ensureConnected();
    final store = _SinkInputInfoStore();
    final op = _paContextGetSinkInputInfo(
      _context!,
      index,
      _sinkInputInfoCallbackPtr,
      store.userdata,
    );
    _waitForListOperation(op, store);
    return store.items.isEmpty ? null : store.items.first;
  }

  List<_CardDetails> getCards() {
    _ensureConnected();
    final store = _CardInfoStore();
    final op = _paContextGetCardInfoList(
      _context!,
      _cardInfoCallbackPtr,
      store.userdata,
    );
    _waitForListOperation(op, store);
    return store.items;
  }

  _CardDetails? getCardByName(String name) {
    _ensureConnected();
    final nativeName = name.toNativeUtf8();
    final store = _CardInfoStore();
    try {
      final op = _paContextGetCardInfoByName(
        _context!,
        nativeName,
        _cardInfoCallbackPtr,
        store.userdata,
      );
      _waitForListOperation(op, store);
      return store.items.isEmpty ? null : store.items.first;
    } finally {
      malloc.free(nativeName);
    }
  }

  bool setDefaultSink(String name) {
    _ensureConnected();
    final nativeName = name.toNativeUtf8();
    try {
      return _runSuccessOperation(
        (userdata) => _paContextSetDefaultSink(
          _context!,
          nativeName,
          _successCallbackPtr,
          userdata,
        ),
      );
    } finally {
      malloc.free(nativeName);
    }
  }

  bool setDefaultSource(String name) {
    _ensureConnected();
    final nativeName = name.toNativeUtf8();
    try {
      return _runSuccessOperation(
        (userdata) => _paContextSetDefaultSource(
          _context!,
          nativeName,
          _successCallbackPtr,
          userdata,
        ),
      );
    } finally {
      malloc.free(nativeName);
    }
  }

  bool setSinkVolumeByName(String name, int channels, int percent) {
    _ensureConnected();
    return _withVolume(channels, percent, (volume, userdata) {
      final nativeName = name.toNativeUtf8();
      try {
        return _paContextSetSinkVolumeByName(
          _context!,
          nativeName,
          volume,
          _successCallbackPtr,
          userdata,
        );
      } finally {
        malloc.free(nativeName);
      }
    });
  }

  bool setSourceVolumeByName(String name, int channels, int percent) {
    _ensureConnected();
    return _withVolume(channels, percent, (volume, userdata) {
      final nativeName = name.toNativeUtf8();
      try {
        return _paContextSetSourceVolumeByName(
          _context!,
          nativeName,
          volume,
          _successCallbackPtr,
          userdata,
        );
      } finally {
        malloc.free(nativeName);
      }
    });
  }

  bool setSinkMuteByName(String name, bool muted) {
    _ensureConnected();
    final nativeName = name.toNativeUtf8();
    try {
      return _runSuccessOperation(
        (userdata) => _paContextSetSinkMuteByName(
          _context!,
          nativeName,
          muted ? 1 : 0,
          _successCallbackPtr,
          userdata,
        ),
      );
    } finally {
      malloc.free(nativeName);
    }
  }

  bool setSourceMuteByName(String name, bool muted) {
    _ensureConnected();
    final nativeName = name.toNativeUtf8();
    try {
      return _runSuccessOperation(
        (userdata) => _paContextSetSourceMuteByName(
          _context!,
          nativeName,
          muted ? 1 : 0,
          _successCallbackPtr,
          userdata,
        ),
      );
    } finally {
      malloc.free(nativeName);
    }
  }

  bool setSinkInputVolume(int index, int channels, int percent) {
    _ensureConnected();
    return _withVolume(
      channels,
      percent,
      (volume, userdata) => _paContextSetSinkInputVolume(
        _context!,
        index,
        volume,
        _successCallbackPtr,
        userdata,
      ),
    );
  }

  bool setSinkInputMute(int index, bool muted) {
    _ensureConnected();
    return _runSuccessOperation(
      (userdata) => _paContextSetSinkInputMute(
        _context!,
        index,
        muted ? 1 : 0,
        _successCallbackPtr,
        userdata,
      ),
    );
  }

  bool moveSinkInputByName(int index, String sinkName) {
    _ensureConnected();
    final nativeSinkName = sinkName.toNativeUtf8();
    try {
      return _runSuccessOperation(
        (userdata) => _paContextMoveSinkInputByName(
          _context!,
          index,
          nativeSinkName,
          _successCallbackPtr,
          userdata,
        ),
      );
    } finally {
      malloc.free(nativeSinkName);
    }
  }

  bool setCardProfile(String cardName, String profileName) {
    _ensureConnected();
    final nativeCard = cardName.toNativeUtf8();
    final nativeProfile = profileName.toNativeUtf8();
    try {
      return _runSuccessOperation(
        (userdata) => _paContextSetCardProfileByName(
          _context!,
          nativeCard,
          nativeProfile,
          _successCallbackPtr,
          userdata,
        ),
      );
    } finally {
      malloc.free(nativeCard);
      malloc.free(nativeProfile);
    }
  }

  _ServerInfo? _getServerInfo() {
    final store = _ServerInfoStore();
    final op = _paContextGetServerInfo(
      _context!,
      _serverInfoCallbackPtr,
      store.userdata,
    );
    _waitForSingleOperation(op, store);
    return store.info;
  }

  bool _withVolume(
    int channels,
    int percent,
    Pointer<_PaOperation> Function(
      Pointer<_PaCVolume> volume,
      Pointer<Void> userdata,
    )
    start,
  ) {
    final volume = calloc<_PaCVolume>();
    try {
      final paVolume = _paSwVolumeFromLinear(percent.clamp(0, 150) / 100.0);
      _paCvolumeSet(volume, channels <= 0 ? 1 : channels, paVolume);
      return _runSuccessOperation((userdata) => start(volume, userdata));
    } finally {
      calloc.free(volume);
    }
  }

  bool _runSuccessOperation(
    Pointer<_PaOperation> Function(Pointer<Void> userdata) start,
  ) {
    final store = _SuccessStore();
    final op = start(store.userdata);
    _waitForSingleOperation(op, store);
    return store.success ?? false;
  }

  void _waitForListOperation(Pointer<_PaOperation> op, _BaseStore store) {
    try {
      _waitForOperation(op, () => store.completed);
    } finally {
      store.dispose();
    }
  }

  void _waitForSingleOperation(Pointer<_PaOperation> op, _BaseStore store) {
    try {
      _waitForOperation(op, () => store.completed);
    } finally {
      store.dispose();
    }
  }

  void _waitForOperation(Pointer<_PaOperation> op, bool Function() done) {
    if (op == nullptr) {
      throw Exception(_contextError());
    }

    final retval = calloc<Int32>();
    try {
      while (true) {
        if (done()) break;

        final opState = _paOperationGetState(op);
        if (opState != _paOperationRunning && done()) {
          break;
        }

        final state = _paContextGetState(_context!);
        if (state == _paContextFailed || state == _paContextTerminated) {
          throw Exception(_contextError());
        }

        if (_paMainloopIterate(_mainloop!, 1, retval) < 0) {
          throw Exception(_contextError());
        }
      }
    } finally {
      calloc.free(retval);
      _paOperationUnref(op);
    }
  }

  String _contextError() {
    if (_context == null || _context == nullptr) {
      return 'PulseAudio context is unavailable';
    }
    final code = _paContextErrno(_context!);
    return _paStrerror(code).toDartString();
  }

  void _ensureConnected() {
    if (!_connected || _context == null || _context == nullptr) {
      throw Exception('Audio service is not connected');
    }
  }

  void _disposeNative() {
    if (_context != null && _context != nullptr) {
      _paContextDisconnect(_context!);
      _paContextUnref(_context!);
      _context = null;
    }
    if (_mainloop != null && _mainloop != nullptr) {
      _paMainloopFree(_mainloop!);
      _mainloop = null;
    }
  }
}

class _NodeInfo {
  final String name;
  final String description;
  final int volumePercent;
  final bool muted;
  final int channels;
  final bool isMonitor;

  const _NodeInfo({
    required this.name,
    required this.description,
    required this.volumePercent,
    required this.muted,
    required this.channels,
    this.isMonitor = false,
  });
}

class _SinkInputDetails {
  final int index;
  final String name;
  final String icon;
  final int volumePercent;
  final bool muted;
  final int channels;

  const _SinkInputDetails({
    required this.index,
    required this.name,
    required this.icon,
    required this.volumePercent,
    required this.muted,
    required this.channels,
  });
}

class _CardDetails {
  final String name;
  final String description;
  final List<_CardProfileDetails> profiles;

  const _CardDetails({
    required this.name,
    required this.description,
    required this.profiles,
  });
}

class _CardProfileDetails {
  final String name;
  final String description;
  final bool available;

  const _CardProfileDetails({
    required this.name,
    required this.description,
    required this.available,
  });
}

class _ServerInfo {
  final String? defaultSinkName;
  final String? defaultSourceName;

  const _ServerInfo({
    required this.defaultSinkName,
    required this.defaultSourceName,
  });
}

abstract class _BaseStore {
  _BaseStore() : _token = calloc<Uint8>(1) {
    _stores[_token.address] = this;
  }

  static final Map<int, _BaseStore> _stores = {};

  final Pointer<Uint8> _token;
  bool completed = false;

  Pointer<Void> get userdata => _token.cast<Void>();

  static T? get<T extends _BaseStore>(Pointer<Void> userdata) {
    return _stores[userdata.address] as T?;
  }

  void dispose() {
    _stores.remove(_token.address);
    calloc.free(_token);
  }
}

class _ServerInfoStore extends _BaseStore {
  _ServerInfo? info;
}

class _SuccessStore extends _BaseStore {
  bool? success;
}

class _SinkInfoStore extends _BaseStore {
  final List<_NodeInfo> items = [];
}

class _SourceInfoStore extends _BaseStore {
  final List<_NodeInfo> items = [];
}

class _SinkInputInfoStore extends _BaseStore {
  final List<_SinkInputDetails> items = [];
}

class _CardInfoStore extends _BaseStore {
  final List<_CardDetails> items = [];
}

void _serverInfoCallback(
  Pointer<_PaContext> context,
  Pointer<_PaServerInfo> info,
  Pointer<Void> userdata,
) {
  final store = _BaseStore.get<_ServerInfoStore>(userdata);
  if (store == null) return;

  store.info = _ServerInfo(
    defaultSinkName: info.ref.defaultSinkName
        .cast<Utf8>()
        .toNullableDartString(),
    defaultSourceName: info.ref.defaultSourceName
        .cast<Utf8>()
        .toNullableDartString(),
  );
  store.completed = true;
}

void _sinkInfoCallback(
  Pointer<_PaContext> context,
  Pointer<_PaSinkInfo> info,
  int eol,
  Pointer<Void> userdata,
) {
  final store = _BaseStore.get<_SinkInfoStore>(userdata);
  if (store == null) return;

  if (eol != 0) {
    store.completed = true;
    return;
  }

  store.items.add(
    _NodeInfo(
      name: info.ref.name.cast<Utf8>().toDartString(),
      description:
          info.ref.description.cast<Utf8>().toNullableDartString() ??
          info.ref.name.cast<Utf8>().toDartString(),
      volumePercent: _volumeToPercent(info.ref.volume),
      muted: info.ref.mute != 0,
      channels: info.ref.volume.channels,
    ),
  );
}

void _sourceInfoCallback(
  Pointer<_PaContext> context,
  Pointer<_PaSourceInfo> info,
  int eol,
  Pointer<Void> userdata,
) {
  final store = _BaseStore.get<_SourceInfoStore>(userdata);
  if (store == null) return;

  if (eol != 0) {
    store.completed = true;
    return;
  }

  final monitorName = info.ref.monitorOfSinkName
      .cast<Utf8>()
      .toNullableDartString();
  store.items.add(
    _NodeInfo(
      name: info.ref.name.cast<Utf8>().toDartString(),
      description:
          info.ref.description.cast<Utf8>().toNullableDartString() ??
          info.ref.name.cast<Utf8>().toDartString(),
      volumePercent: _volumeToPercent(info.ref.volume),
      muted: info.ref.mute != 0,
      channels: info.ref.volume.channels,
      isMonitor: monitorName != null && monitorName.isNotEmpty,
    ),
  );
}

void _sinkInputInfoCallback(
  Pointer<_PaContext> context,
  Pointer<_PaSinkInputInfo> info,
  int eol,
  Pointer<Void> userdata,
) {
  final store = _BaseStore.get<_SinkInputInfoStore>(userdata);
  if (store == null) return;

  if (eol != 0) {
    store.completed = true;
    return;
  }

  final proplist = info.ref.proplist;
  final appName = _getProp(proplist, 'application.name');
  final mediaName = _getProp(proplist, 'media.name');
  final icon = _getProp(proplist, 'application.icon_name');

  store.items.add(
    _SinkInputDetails(
      index: info.ref.index,
      name:
          appName ??
          mediaName ??
          info.ref.name.cast<Utf8>().toNullableDartString() ??
          'Unknown App',
      icon: icon ?? 'audio-x-generic',
      volumePercent: _volumeToPercent(info.ref.volume),
      muted: info.ref.mute != 0,
      channels: info.ref.volume.channels,
    ),
  );
}

void _cardInfoCallback(
  Pointer<_PaContext> context,
  Pointer<_PaCardInfo> info,
  int eol,
  Pointer<Void> userdata,
) {
  final store = _BaseStore.get<_CardInfoStore>(userdata);
  if (store == null) return;

  if (eol != 0) {
    store.completed = true;
    return;
  }

  final profiles = <_CardProfileDetails>[];
  final profilesPtr = info.ref.profiles2;
  if (profilesPtr != nullptr) {
    for (var i = 0; i < info.ref.nProfiles; i++) {
      final profilePtr = (profilesPtr + i).value;
      if (profilePtr == nullptr) continue;
      profiles.add(
        _CardProfileDetails(
          name: profilePtr.ref.name.cast<Utf8>().toDartString(),
          description:
              profilePtr.ref.description.cast<Utf8>().toNullableDartString() ??
              profilePtr.ref.name.cast<Utf8>().toDartString(),
          available: profilePtr.ref.available != 0,
        ),
      );
    }
  }

  store.items.add(
    _CardDetails(
      name: info.ref.name.cast<Utf8>().toDartString(),
      description:
          _getProp(info.ref.proplist, 'device.description') ??
          _getProp(info.ref.proplist, 'alsa.card_name') ??
          info.ref.name.cast<Utf8>().toDartString(),
      profiles: profiles,
    ),
  );
}

void _successCallback(
  Pointer<_PaContext> context,
  int success,
  Pointer<Void> userdata,
) {
  final store = _BaseStore.get<_SuccessStore>(userdata);
  if (store == null) return;
  store.success = success != 0;
  store.completed = true;
}

int _volumeToPercent(_PaCVolume volume) {
  final channels = volume.channels <= 0 ? 1 : volume.channels;
  var total = 0;
  for (var i = 0; i < channels; i++) {
    total += volume.values[i];
  }
  final avg = (total / channels).round();
  return (_PulseAudioClient._paSwVolumeToLinear(avg) * 100).round();
}

String? _getProp(Pointer<_PaProplist> proplist, String key) {
  if (proplist == nullptr) return null;
  final nativeKey = key.toNativeUtf8();
  try {
    final value = _PulseAudioClient._paProplistGets(proplist, nativeKey);
    if (value == nullptr) return null;
    return value.toDartString();
  } finally {
    malloc.free(nativeKey);
  }
}

extension on Pointer<Utf8> {
  String? toNullableDartString() {
    if (this == nullptr) return null;
    return toDartString();
  }
}

const int _paContextReady = 4;
const int _paContextFailed = 5;
const int _paContextTerminated = 6;
const int _paOperationRunning = 0;

typedef _PaServerInfoCbNative =
    Void Function(Pointer<_PaContext>, Pointer<_PaServerInfo>, Pointer<Void>);
typedef _PaSinkInfoCbNative =
    Void Function(
      Pointer<_PaContext>,
      Pointer<_PaSinkInfo>,
      Int32,
      Pointer<Void>,
    );
typedef _PaSourceInfoCbNative =
    Void Function(
      Pointer<_PaContext>,
      Pointer<_PaSourceInfo>,
      Int32,
      Pointer<Void>,
    );
typedef _PaSinkInputInfoCbNative =
    Void Function(
      Pointer<_PaContext>,
      Pointer<_PaSinkInputInfo>,
      Int32,
      Pointer<Void>,
    );
typedef _PaCardInfoCbNative =
    Void Function(
      Pointer<_PaContext>,
      Pointer<_PaCardInfo>,
      Int32,
      Pointer<Void>,
    );
typedef _PaSuccessCbNative =
    Void Function(Pointer<_PaContext>, Int32, Pointer<Void>);

final class _PaMainloop extends Opaque {}

final class _PaMainloopApi extends Opaque {}

final class _PaContext extends Opaque {}

final class _PaOperation extends Opaque {}

final class _PaProplist extends Opaque {}

final class _PaSampleSpec extends Struct {
  @Int32()
  external int format;

  @Uint32()
  external int rate;

  @Uint8()
  external int channels;
}

final class _PaChannelMap extends Struct {
  @Uint8()
  external int channels;

  @Array(32)
  external Array<Int32> map;
}

final class _PaCVolume extends Struct {
  @Uint8()
  external int channels;

  @Array(32)
  external Array<Uint32> values;
}

final class _PaServerInfo extends Struct {
  external Pointer<Utf8> userName;
  external Pointer<Utf8> hostName;
  external Pointer<Utf8> serverVersion;
  external Pointer<Utf8> serverName;
  external _PaSampleSpec sampleSpec;
  external Pointer<Utf8> defaultSinkName;
  external Pointer<Utf8> defaultSourceName;

  @Uint32()
  external int cookie;

  external _PaChannelMap channelMap;
}

final class _PaSinkInfo extends Struct {
  external Pointer<Utf8> name;

  @Uint32()
  external int index;

  external Pointer<Utf8> description;
  external _PaSampleSpec sampleSpec;
  external _PaChannelMap channelMap;

  @Uint32()
  external int ownerModule;

  external _PaCVolume volume;

  @Int32()
  external int mute;
}

final class _PaSourceInfo extends Struct {
  external Pointer<Utf8> name;

  @Uint32()
  external int index;

  external Pointer<Utf8> description;
  external _PaSampleSpec sampleSpec;
  external _PaChannelMap channelMap;

  @Uint32()
  external int ownerModule;

  external _PaCVolume volume;

  @Int32()
  external int mute;

  @Uint32()
  external int monitorOfSink;

  external Pointer<Utf8> monitorOfSinkName;
}

final class _PaSinkInputInfo extends Struct {
  @Uint32()
  external int index;

  external Pointer<Utf8> name;

  @Uint32()
  external int ownerModule;

  @Uint32()
  external int client;

  @Uint32()
  external int sink;

  external _PaSampleSpec sampleSpec;
  external _PaChannelMap channelMap;
  external _PaCVolume volume;

  @Uint64()
  external int bufferUsec;

  @Uint64()
  external int sinkUsec;

  external Pointer<Utf8> resampleMethod;
  external Pointer<Utf8> driver;

  @Int32()
  external int mute;

  external Pointer<_PaProplist> proplist;
}

final class _PaCardProfileInfo2 extends Struct {
  external Pointer<Utf8> name;
  external Pointer<Utf8> description;

  @Uint32()
  external int nSinks;

  @Uint32()
  external int nSources;

  @Uint32()
  external int priority;

  @Int32()
  external int available;
}

final class _PaCardInfo extends Struct {
  @Uint32()
  external int index;

  external Pointer<Utf8> name;

  @Uint32()
  external int ownerModule;

  external Pointer<Utf8> driver;

  @Uint32()
  external int nProfiles;

  external Pointer<Void> profiles;
  external Pointer<Void> activeProfile;
  external Pointer<_PaProplist> proplist;

  @Uint32()
  external int nPorts;

  external Pointer<Void> ports;
  external Pointer<Pointer<_PaCardProfileInfo2>> profiles2;
  external Pointer<_PaCardProfileInfo2> activeProfile2;
}
