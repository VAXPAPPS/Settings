import 'package:equatable/equatable.dart';
import 'package:antidote/features/window_manager/models/window_node.dart';

abstract class WindowManagerEvent extends Equatable {
  const WindowManagerEvent();

  @override
  List<Object?> get props => [];
}

// Loading
class LoadWindowManager extends WindowManagerEvent {
  const LoadWindowManager();
}

class RefreshWindowInfo extends WindowManagerEvent {
  const RefreshWindowInfo();
}

// Window Management
class FocusWindow extends WindowManagerEvent {
  final WindowDirection direction;
  const FocusWindow(this.direction);

  @override
  List<Object?> get props => [direction];
}

class SwapWindow extends WindowManagerEvent {
  final WindowDirection direction;
  const SwapWindow(this.direction);

  @override
  List<Object?> get props => [direction];
}

class ChangeWindowState extends WindowManagerEvent {
  final String windowId;
  final WindowState state;
  const ChangeWindowState(this.windowId, this.state);

  @override
  List<Object?> get props => [windowId, state];
}

class HideWindow extends WindowManagerEvent {
  const HideWindow();
}

class ShowHiddenWindow extends WindowManagerEvent {
  const ShowHiddenWindow();
}

class CloseWindow extends WindowManagerEvent {
  const CloseWindow();
}

class KillWindow extends WindowManagerEvent {
  const KillWindow();
}

// Desktop Management
class ChangeLayout extends WindowManagerEvent {
  final String layout;
  const ChangeLayout(this.layout);

  @override
  List<Object?> get props => [layout];
}

class SwitchDesktop extends WindowManagerEvent {
  final int desktopIndex;
  const SwitchDesktop(this.desktopIndex);

  @override
  List<Object?> get props => [desktopIndex];
}

class MoveWindowToDesktop extends WindowManagerEvent {
  final String desktopName;
  final bool follow;
  const MoveWindowToDesktop(this.desktopName, {this.follow = false});

  @override
  List<Object?> get props => [desktopName, follow];
}

class CreateDesktop extends WindowManagerEvent {
  final String desktopName;
  const CreateDesktop(this.desktopName);

  @override
  List<Object?> get props => [desktopName];
}

class RemoveDesktop extends WindowManagerEvent {
  final String desktopName;
  const RemoveDesktop(this.desktopName);

  @override
  List<Object?> get props => [desktopName];
}

class RenameDesktop extends WindowManagerEvent {
  final String oldName;
  final String newName;
  const RenameDesktop(this.oldName, this.newName);

  @override
  List<Object?> get props => [oldName, newName];
}

// Monitor Management
class SwitchMonitor extends WindowManagerEvent {
  final WindowDirection direction;
  const SwitchMonitor(this.direction);

  @override
  List<Object?> get props => [direction];
}

class MoveWindowToMonitor extends WindowManagerEvent {
  final WindowDirection direction;
  const MoveWindowToMonitor(this.direction);

  @override
  List<Object?> get props => [direction];
}

// Configuration
class UpdateFloatingMode extends WindowManagerEvent {
  final bool enabled;
  const UpdateFloatingMode(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateSnapToEdge extends WindowManagerEvent {
  final bool enabled;
  const UpdateSnapToEdge(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class UpdateSnapThreshold extends WindowManagerEvent {
  final int threshold;
  const UpdateSnapThreshold(this.threshold);

  @override
  List<Object?> get props => [threshold];
}

class UpdateBorderWidth extends WindowManagerEvent {
  final int width;
  const UpdateBorderWidth(this.width);

  @override
  List<Object?> get props => [width];
}

class UpdateWindowGap extends WindowManagerEvent {
  final int gap;
  const UpdateWindowGap(this.gap);

  @override
  List<Object?> get props => [gap];
}

class UpdatePadding extends WindowManagerEvent {
  final int top;
  final int bottom;
  const UpdatePadding(this.top, this.bottom);

  @override
  List<Object?> get props => [top, bottom];
}

class UpdateOpacity extends WindowManagerEvent {
  final bool focusOpacity;
  final double inactiveOpacity;
  final double activeOpacity;
  const UpdateOpacity(
    this.focusOpacity,
    this.inactiveOpacity,
    this.activeOpacity,
  );

  @override
  List<Object?> get props => [focusOpacity, inactiveOpacity, activeOpacity];
}

class UpdateBorderColor extends WindowManagerEvent {
  final String focusedColor;
  final String normalColor;
  const UpdateBorderColor(this.focusedColor, this.normalColor);

  @override
  List<Object?> get props => [focusedColor, normalColor];
}

// Resize
class ResizeWindow extends WindowManagerEvent {
  final String direction;
  final int dx;
  final int dy;
  const ResizeWindow(this.direction, this.dx, this.dy);

  @override
  List<Object?> get props => [direction, dx, dy];
}

class BalanceWindows extends WindowManagerEvent {
  const BalanceWindows();
}

// Preselection
class SetPreselection extends WindowManagerEvent {
  final WindowDirection direction;
  const SetPreselection(this.direction);

  @override
  List<Object?> get props => [direction];
}

class CancelPreselection extends WindowManagerEvent {
  const CancelPreselection();
}
