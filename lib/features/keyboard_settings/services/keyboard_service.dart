import 'package:flutter/foundation.dart';
import '../models/input_source.dart';
import 'package:settings/core/services/wayfire_config_service.dart';
import 'layout_repository.dart';

class KeyboardService {
  final LayoutRepository _layoutRepository = LayoutRepository();
  final WayfireConfigService _wayfire = WayfireConfigService();

  KeyboardService();

  Future<List<InputSource>> getCurrentSources() async {
    try {
      final activeStr = await _wayfire.getValue('input', 'xkb_layout') ?? 'us';
      if (activeStr.isEmpty) return [];

      final layoutIds = activeStr.split(',');
      final List<InputSource> sources = [];

      final allLayouts = await _layoutRepository.getSystemLayouts();
      final layoutMap = {for (var l in allLayouts) l.id: l.name};

      for (final id in layoutIds) {
        final cleanId = id.trim();
        if (cleanId.isEmpty) continue;
        final name = layoutMap[cleanId] ?? cleanId;
        sources.add(InputSource(id: cleanId, name: name, type: 'xkb'));
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

      await _wayfire.setValue('input', 'xkb_layout', layoutsString);
      return true;
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

      await _wayfire.setValue('input', 'xkb_layout', layoutsString);
      return true;
    } catch (e) {
      debugPrint('Remove input source error: $e');
      return false;
    }
  }
}
