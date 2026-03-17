import 'package:flutter/foundation.dart';
import '../models/input_source.dart';
import 'package:settings/core/services/venom_input_service.dart' as venom;
import 'layout_repository.dart';

class KeyboardService {
  final LayoutRepository _layoutRepository = LayoutRepository();
  late venom.KeyboardService _keyboard;

  KeyboardService() {
    _keyboard = venom.KeyboardService();
  }

  Future<List<InputSource>> getCurrentSources() async {
    try {
      final activeStr = await _keyboard.getLayouts();
      if (activeStr.isEmpty) return [];

      final layoutIds = activeStr.split(',');
      final List<InputSource> sources = [];

      final allLayouts = await _layoutRepository.getSystemLayouts();
      final layoutMap = {for (var l in allLayouts) l.id: l.name};

      for (final id in layoutIds) {
        final name = layoutMap[id] ?? id;
        sources.add(InputSource(id: id, name: name, type: 'xkb'));
      }
      return sources;
    } catch (e) {
      debugPrint('Get current sources error: $e');
      return [];
    }
  }

  Future<List<InputSource>> getAvailableSources() async {
    try {
      final layouts = await _layoutRepository.getSystemLayouts();
      return layouts
          .map((l) => InputSource(id: l.id, name: l.name, type: 'xkb'))
          .toList();
    } catch (e) {
      debugPrint('Get available sources error: $e');
      return [];
    }
  }

  Future<bool> addInputSource(
    InputSource source,
    List<InputSource> currentSources,
  ) async {
    try {
      if (currentSources.any((s) => s.id == source.id)) {
        return false;
      }

      final newSources = [...currentSources, source];
      final layoutsString = newSources.map((s) => s.id).join(',');

      return await _keyboard.setLayouts(layoutsString);
    } catch (e) {
      debugPrint('Add input source error: $e');
      return false;
    }
  }

  Future<bool> removeInputSource(
    InputSource source,
    List<InputSource> currentSources,
  ) async {
    try {
      final newSources = currentSources
          .where((s) => s.id != source.id)
          .toList();
      final layoutsString = newSources.map((s) => s.id).join(',');

      return await _keyboard.setLayouts(layoutsString);
    } catch (e) {
      debugPrint('Remove input source error: $e');
      return false;
    }
  }
}
