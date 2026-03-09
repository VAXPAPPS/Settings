import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:antidote/features/window_manager/models/window_node.dart';

class WindowManagerService {
  Process? _process;

  Future<void> connect() async {
    // Initialize connection to window manager (vaxp)
    // This would be implemented based on how vaxp communicates
    debugPrint('WindowManager service connected');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Window Management Commands
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> focusWindow(String direction) async {
    try {
      await _runCommand(['vaxp', 'node', '-f', direction]);
    } catch (e) {
      debugPrint('Focus window error: $e');
      rethrow;
    }
  }

  Future<void> swapWindow(String direction) async {
    try {
      await _runCommand(['vaxp', 'node', '-s', direction]);
    } catch (e) {
      debugPrint('Swap window error: $e');
      rethrow;
    }
  }

  Future<void> changeWindowState(String state) async {
    try {
      await _runCommand(['vaxp', 'node', '-t', state]);
    } catch (e) {
      debugPrint('Change window state error: $e');
      rethrow;
    }
  }

  Future<void> hideWindow() async {
    try {
      await _runCommand(['vaxp', 'node', '-g', 'hidden=on']);
    } catch (e) {
      debugPrint('Hide window error: $e');
      rethrow;
    }
  }

  Future<void> showHiddenWindow() async {
    try {
      await _runCommand(['vaxp', 'node', 'any.hidden', '-g', 'hidden=off']);
    } catch (e) {
      debugPrint('Show hidden window error: $e');
      rethrow;
    }
  }

  Future<void> closeWindow() async {
    try {
      await _runCommand(['vaxp', 'node', '-c']);
    } catch (e) {
      debugPrint('Close window error: $e');
      rethrow;
    }
  }

  Future<void> killWindow() async {
    try {
      await _runCommand(['vaxp', 'node', '-k']);
    } catch (e) {
      debugPrint('Kill window error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Desktop Management Commands
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> changeLayout(String layout) async {
    try {
      await _runCommand(['vaxp', 'desktop', '-l', layout]);
    } catch (e) {
      debugPrint('Change layout error: $e');
      rethrow;
    }
  }

  Future<void> switchDesktop(int desktopIndex) async {
    try {
      await _runCommand(['vaxp', 'desktop', '-f', '^$desktopIndex']);
    } catch (e) {
      debugPrint('Switch desktop error: $e');
      rethrow;
    }
  }

  Future<void> moveWindowToDesktop(String desktopName,
      {bool follow = false}) async {
    try {
      final args = ['vaxp', 'node', '-d', desktopName];
      if (follow) args.add('--follow');
      await _runCommand(args);
    } catch (e) {
      debugPrint('Move window to desktop error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Monitor Management Commands
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> switchMonitor(String direction) async {
    try {
      await _runCommand(['vaxp', 'monitor', '-f', direction]);
    } catch (e) {
      debugPrint('Switch monitor error: $e');
      rethrow;
    }
  }

  Future<void> moveWindowToMonitor(String direction) async {
    try {
      await _runCommand(['vaxp', 'node', '-m', direction]);
    } catch (e) {
      debugPrint('Move window to monitor error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Configuration Commands
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setFloatingMode(bool enabled) async {
    try {
      await _runCommand([
        'vaxp',
        'config',
        'floating_mode',
        enabled ? 'true' : 'false'
      ]);
    } catch (e) {
      debugPrint('Set floating mode error: $e');
      rethrow;
    }
  }

  Future<void> setSnapToEdge(bool enabled) async {
    try {
      await _runCommand(
        ['vaxp', 'config', 'snap_to_edge', enabled ? 'true' : 'false'],
      );
    } catch (e) {
      debugPrint('Set snap to edge error: $e');
      rethrow;
    }
  }

  Future<void> setSnapThreshold(int threshold) async {
    try {
      await _runCommand([
        'vaxp',
        'config',
        'snap_threshold',
        threshold.toString(),
      ]);
    } catch (e) {
      debugPrint('Set snap threshold error: $e');
      rethrow;
    }
  }

  Future<void> setBorderWidth(int width) async {
    try {
      await _runCommand(['vaxp', 'config', 'border_width', width.toString()]);
    } catch (e) {
      debugPrint('Set border width error: $e');
      rethrow;
    }
  }

  Future<void> setBorderColors(String focusedColor, String normalColor) async {
    try {
      await _runCommand([
        'vaxp',
        'config',
        'focused_border_color',
        focusedColor,
      ]);
      await _runCommand(
        ['vaxp', 'config', 'normal_border_color', normalColor],
      );
    } catch (e) {
      debugPrint('Set border colors error: $e');
      rethrow;
    }
  }

  Future<void> setWindowGap(int gap) async {
    try {
      await _runCommand(['vaxp', 'config', 'window_gap', gap.toString()]);
    } catch (e) {
      debugPrint('Set window gap error: $e');
      rethrow;
    }
  }

  Future<void> setPadding(int top, int bottom) async {
    try {
      await _runCommand(['vaxp', 'config', 'top_padding', top.toString()]);
      await _runCommand(['vaxp', 'config', 'bottom_padding', bottom.toString()]);
    } catch (e) {
      debugPrint('Set padding error: $e');
      rethrow;
    }
  }

  Future<void> setOpacity(
    bool focusOpacity,
    double inactiveOpacity,
    double activeOpacity,
  ) async {
    try {
      await _runCommand([
        'vaxp',
        'config',
        'focus_opacity',
        focusOpacity ? 'true' : 'false'
      ]);
      await _runCommand([
        'vaxp',
        'config',
        'inactive_opacity',
        inactiveOpacity.toString(),
      ]);
      await _runCommand([
        'vaxp',
        'config',
        'active_opacity',
        activeOpacity.toString(),
      ]);
    } catch (e) {
      debugPrint('Set opacity error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resize Commands
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> resizeWindow(String direction, int dx, int dy) async {
    try {
      await _runCommand([
        'vaxp',
        'node',
        '-z',
        direction,
        dx.toString(),
        dy.toString(),
      ]);
    } catch (e) {
      debugPrint('Resize window error: $e');
      rethrow;
    }
  }

  Future<void> balanceWindows() async {
    try {
      await _runCommand(['vaxp', 'node', '@/', '-B']);
    } catch (e) {
      debugPrint('Balance windows error: $e');
      rethrow;
    }
  }

  Future<List<Desktop>> getDesktops() async {
    try {
      final result = await queryDesktops();
      return _parseDesktops(result);
    } catch (e) {
      debugPrint('Get desktops error: $e');
      return [];
    }
  }

  Future<List<Monitor>> getMonitors() async {
    try {
      final result = await queryMonitors();
      return _parseMonitors(result);
    } catch (e) {
      debugPrint('Get monitors error: $e');
      return [];
    }
  }

  List<Desktop> _parseDesktops(String output) {
    final desktops = <Desktop>[];
    try {
      final lines = output.split('\n');
      int desktopIndex = 1;
      for (final line in lines) {
        if (line.isEmpty) continue;
        // vaxp query -D returns hex IDs only (e.g., 0x00200004)
        // Create numbered desktops with default layout
        final hexId = line.trim();
        if (hexId.startsWith('0x')) {
          desktops.add(
            Desktop(
              name: 'Desktop $desktopIndex',
              layout: 'tiled',
              active: desktopIndex == 1, // First desktop is active by default
              windowCount: 0,
            ),
          );
          desktopIndex++;
        }
      }
    } catch (e) {
      debugPrint('Parse desktops error: $e');
    }
    return desktops;
  }

  List<Monitor> _parseMonitors(String output) {
    final monitors = <Monitor>[];
    try {
      final lines = output.split('\n');
      int monitorIndex = 1;
      for (final line in lines) {
        if (line.isEmpty) continue;
        // vaxp query -M returns hex IDs only (e.g., 0x00200002)
        // Create monitors with generic names - first one is primary
        final hexId = line.trim();
        if (hexId.startsWith('0x')) {
          monitors.add(
            Monitor(
              name: 'Monitor $monitorIndex',
              width: 1920,
              height: 1080,
              x: monitorIndex == 1 ? 0 : 1920 * (monitorIndex - 1),
              y: 0,
              primary: monitorIndex == 1,
            ),
          );
          monitorIndex++;
        }
      }
    } catch (e) {
      debugPrint('Parse monitors error: $e');
    }
    return monitors;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Preselection
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> setPreselection(String direction, {double ratio = 0.5}) async {
    try {
      await _runCommand(['vaxp', 'node', '-p', direction]);
      if (ratio != 0.5) {
        await _runCommand(['vaxp', 'node', '-o', ratio.toString()]);
      }
    } catch (e) {
      debugPrint('Set preselection error: $e');
      rethrow;
    }
  }

  Future<void> cancelPreselection() async {
    try {
      await _runCommand(['vaxp', 'node', '-p', 'cancel']);
    } catch (e) {
      debugPrint('Cancel preselection error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Desktop Management - Create/Remove/Rename
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> createDesktop(String desktopName) async {
    try {
      await _runCommand(['vaxp', 'monitor', '-a', desktopName]);
    } catch (e) {
      debugPrint('Create desktop error: $e');
      rethrow;
    }
  }

  Future<void> removeDesktop(String desktopName) async {
    try {
      await _runCommand(['vaxp', 'desktop', '-f', desktopName]);
      await _runCommand(['vaxp', 'desktop', '-r']);
    } catch (e) {
      debugPrint('Remove desktop error: $e');
      rethrow;
    }
  }

  Future<void> renameDesktop(String oldName, String newName) async {
    try {
      await _runCommand(['vaxp', 'desktop', '-f', oldName]);
      await _runCommand(['vaxp', 'desktop', '-n', newName]);
    } catch (e) {
      debugPrint('Rename desktop error: $e');
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper Methods
  // ─────────────────────────────────────────────────────────────────────────

  Future<String> queryDesktops() async {
    try {
      return await _runCommand(['vaxp', 'query', '-D']);
    } catch (e) {
      debugPrint('Query desktops error: $e');
      return '';
    }
  }

  Future<String> queryMonitors() async {
    try {
      return await _runCommand(['vaxp', 'query', '-M']);
    } catch (e) {
      debugPrint('Query monitors error: $e');
      return '';
    }
  }

  Future<String> _runCommand(List<String> args) async {
    try {
      final result = await Process.run(args[0], args.sublist(1));
      if (result.exitCode != 0) {
        throw Exception('Command failed: ${result.stderr}');
      }
      return result.stdout.toString();
    } catch (e) {
      debugPrint('Command error: $e');
      rethrow;
    }
  }

  void dispose() {
    _process?.kill();
  }
}
