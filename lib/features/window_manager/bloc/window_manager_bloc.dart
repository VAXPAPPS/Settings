import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:antidote/features/window_manager/services/window_manager_service.dart';
import 'window_manager_event.dart';
import 'window_manager_state.dart';

class WindowManagerBloc extends Bloc<WindowManagerEvent, WindowManagerState> {
  WindowManagerService? _windowManagerService;

  WindowManagerBloc() : super(const WindowManagerState()) {
    on<LoadWindowManager>(_onLoadWindowManager);
    on<RefreshWindowInfo>(_onRefreshWindowInfo);
    on<FocusWindow>(_onFocusWindow);
    on<SwapWindow>(_onSwapWindow);
    on<ChangeWindowState>(_onChangeWindowState);
    on<HideWindow>(_onHideWindow);
    on<ShowHiddenWindow>(_onShowHiddenWindow);
    on<CloseWindow>(_onCloseWindow);
    on<KillWindow>(_onKillWindow);
    on<ChangeLayout>(_onChangeLayout);
    on<SwitchDesktop>(_onSwitchDesktop);
    on<MoveWindowToDesktop>(_onMoveWindowToDesktop);
    on<CreateDesktop>(_onCreateDesktop);
    on<RemoveDesktop>(_onRemoveDesktop);
    on<RenameDesktop>(_onRenameDesktop);
    on<SwitchMonitor>(_onSwitchMonitor);
    on<MoveWindowToMonitor>(_onMoveWindowToMonitor);
    on<UpdateFloatingMode>(_onUpdateFloatingMode);
    on<UpdateSnapToEdge>(_onUpdateSnapToEdge);
    on<UpdateSnapThreshold>(_onUpdateSnapThreshold);
    on<UpdateBorderWidth>(_onUpdateBorderWidth);
    on<UpdateWindowGap>(_onUpdateWindowGap);
    on<UpdatePadding>(_onUpdatePadding);
    on<UpdateOpacity>(_onUpdateOpacity);
    on<UpdateBorderColor>(_onUpdateBorderColor);
    on<ResizeWindow>(_onResizeWindow);
    on<BalanceWindows>(_onBalanceWindows);
    on<SetPreselection>(_onSetPreselection);
    on<CancelPreselection>(_onCancelPreselection);
  }

  Future<void> _onLoadWindowManager(
    LoadWindowManager event,
    Emitter<WindowManagerState> emit,
  ) async {
    emit(state.copyWith(status: WindowManagerStatus.loading));

    _windowManagerService = WindowManagerService();
    try {
      await _windowManagerService!.connect();

      // Load actual data from window manager
      final desktops = await _windowManagerService!.getDesktops();
      final monitors = await _windowManagerService!.getMonitors();

      final activeDesktop = desktops.isNotEmpty
          ? desktops.firstWhere(
              (d) => d.active,
              orElse: () => desktops.first,
            ).name
          : null;

      final activeMonitor = monitors.isNotEmpty
          ? monitors
              .firstWhere(
                (m) => m.primary,
                orElse: () => monitors.first,
              )
              .name
          : null;

      emit(
        state.copyWith(
          status: WindowManagerStatus.loaded,
          desktops: desktops,
          activeDesktop: activeDesktop,
          monitors: monitors,
          activeMonitor: activeMonitor,
        ),
      );
    } catch (e) {
      debugPrint('Window manager init error: $e');
      emit(
        state.copyWith(
          status: WindowManagerStatus.error,
          errorMessage: 'Failed to initialize Window Manager: $e',
        ),
      );
    }
  }

  Future<void> _onRefreshWindowInfo(
    RefreshWindowInfo event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      // Query window data and refresh state
      // This would parse actual window manager responses
      emit(state.copyWith(status: WindowManagerStatus.loaded));
    } catch (e) {
      debugPrint('Window refresh error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Window Management Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onFocusWindow(
    FocusWindow event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.focusWindow(event.direction.toString().split('.').last);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Focus window error: $e');
    }
  }

  Future<void> _onSwapWindow(
    SwapWindow event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.swapWindow(event.direction.toString().split('.').last);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Swap window error: $e');
    }
  }

  Future<void> _onChangeWindowState(
    ChangeWindowState event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      final stateString = event.state.toString().split('.').last;
      await _windowManagerService!.changeWindowState(stateString);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Change window state error: $e');
    }
  }

  Future<void> _onHideWindow(
    HideWindow event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.hideWindow();
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Hide window error: $e');
    }
  }

  Future<void> _onShowHiddenWindow(
    ShowHiddenWindow event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.showHiddenWindow();
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Show hidden window error: $e');
    }
  }

  Future<void> _onCloseWindow(
    CloseWindow event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.closeWindow();
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Close window error: $e');
    }
  }

  Future<void> _onKillWindow(
    KillWindow event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.killWindow();
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Kill window error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Desktop Management Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onChangeLayout(
    ChangeLayout event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.changeLayout(event.layout);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Change layout error: $e');
    }
  }

  Future<void> _onSwitchDesktop(
    SwitchDesktop event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.switchDesktop(event.desktopIndex);
      // Update active desktop to the selected one
      if (event.desktopIndex > 0 && event.desktopIndex <= state.desktops.length) {
        final selectedDesktop = state.desktops[event.desktopIndex - 1];
        emit(state.copyWith(activeDesktop: selectedDesktop.name));
      }
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Switch desktop error: $e');
    }
  }

  Future<void> _onMoveWindowToDesktop(
    MoveWindowToDesktop event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.moveWindowToDesktop(
        event.desktopName,
        follow: event.follow,
      );
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Move window to desktop error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Monitor Management Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSwitchMonitor(
    SwitchMonitor event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.switchMonitor(event.direction.toString().split('.').last);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Switch monitor error: $e');
    }
  }

  Future<void> _onMoveWindowToMonitor(
    MoveWindowToMonitor event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.moveWindowToMonitor(event.direction.toString().split('.').last);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Move window to monitor error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Configuration Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onUpdateFloatingMode(
    UpdateFloatingMode event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setFloatingMode(event.enabled);
      emit(
        state.copyWith(
          config: state.config.copyWith(floatingMode: event.enabled),
        ),
      );
    } catch (e) {
      debugPrint('Update floating mode error: $e');
    }
  }

  Future<void> _onUpdateSnapToEdge(
    UpdateSnapToEdge event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setSnapToEdge(event.enabled);
      emit(
        state.copyWith(
          config: state.config.copyWith(snapToEdge: event.enabled),
        ),
      );
    } catch (e) {
      debugPrint('Update snap to edge error: $e');
    }
  }

  Future<void> _onUpdateSnapThreshold(
    UpdateSnapThreshold event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setSnapThreshold(event.threshold);
      emit(
        state.copyWith(
          config: state.config.copyWith(snapThreshold: event.threshold),
        ),
      );
    } catch (e) {
      debugPrint('Update snap threshold error: $e');
    }
  }

  Future<void> _onUpdateBorderWidth(
    UpdateBorderWidth event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setBorderWidth(event.width);
      emit(
        state.copyWith(
          config: state.config.copyWith(borderWidth: event.width),
        ),
      );
    } catch (e) {
      debugPrint('Update border width error: $e');
    }
  }

  Future<void> _onUpdateWindowGap(
    UpdateWindowGap event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setWindowGap(event.gap);
      emit(
        state.copyWith(
          config: state.config.copyWith(windowGap: event.gap),
        ),
      );
    } catch (e) {
      debugPrint('Update window gap error: $e');
    }
  }

  Future<void> _onUpdatePadding(
    UpdatePadding event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setPadding(event.top, event.bottom);
      emit(
        state.copyWith(
          config:
              state.config.copyWith(topPadding: event.top, bottomPadding: event.bottom),
        ),
      );
    } catch (e) {
      debugPrint('Update padding error: $e');
    }
  }

  Future<void> _onUpdateOpacity(
    UpdateOpacity event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setOpacity(
        event.focusOpacity,
        event.inactiveOpacity,
        event.activeOpacity,
      );
      emit(
        state.copyWith(
          config: state.config.copyWith(
            focusOpacity: event.focusOpacity,
            inactiveOpacity: event.inactiveOpacity,
            activeOpacity: event.activeOpacity,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Update opacity error: $e');
    }
  }

  Future<void> _onUpdateBorderColor(
    UpdateBorderColor event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setBorderColors(
        event.focusedColor,
        event.normalColor,
      );
      emit(
        state.copyWith(
          config: state.config.copyWith(
            focusedBorderColor: event.focusedColor,
            normalBorderColor: event.normalColor,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Update border color error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Resize Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onResizeWindow(
    ResizeWindow event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.resizeWindow(event.direction, event.dx, event.dy);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Resize window error: $e');
    }
  }

  Future<void> _onBalanceWindows(
    BalanceWindows event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.balanceWindows();
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Balance windows error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Preselection Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onSetPreselection(
    SetPreselection event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.setPreselection(
        event.direction.toString().split('.').last,
      );
      emit(
        state.copyWith(
          preselectionDirection: event.direction.toString().split('.').last,
        ),
      );
    } catch (e) {
      debugPrint('Set preselection error: $e');
    }
  }

  Future<void> _onCancelPreselection(
    CancelPreselection event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.cancelPreselection();
      emit(state.copyWith(preselectionDirection: null));
    } catch (e) {
      debugPrint('Cancel preselection error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Desktop Management - Create/Remove/Rename Handlers
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _onCreateDesktop(
    CreateDesktop event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.createDesktop(event.desktopName);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Create desktop error: $e');
    }
  }

  Future<void> _onRemoveDesktop(
    RemoveDesktop event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.removeDesktop(event.desktopName);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Remove desktop error: $e');
    }
  }

  Future<void> _onRenameDesktop(
    RenameDesktop event,
    Emitter<WindowManagerState> emit,
  ) async {
    if (_windowManagerService == null) return;

    try {
      await _windowManagerService!.renameDesktop(event.oldName, event.newName);
      add(const RefreshWindowInfo());
    } catch (e) {
      debugPrint('Rename desktop error: $e');
    }
  }

  @override
  Future<void> close() {
    _windowManagerService?.dispose();
    return super.close();
  }
}
