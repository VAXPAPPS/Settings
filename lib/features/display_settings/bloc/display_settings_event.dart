import 'package:equatable/equatable.dart';
import 'package:settings/core/services/venom_display_service.dart';

abstract class DisplaySettingsEvent extends Equatable {
  const DisplaySettingsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeDisplaySettings extends DisplaySettingsEvent {
  const InitializeDisplaySettings();
}

class RefreshDisplays extends DisplaySettingsEvent {
  const RefreshDisplays();
}

class SelectDisplay extends DisplaySettingsEvent {
  final String displayName;
  const SelectDisplay(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

class SetOrientation extends DisplaySettingsEvent {
  final String orientation;
  const SetOrientation(this.orientation);

  @override
  List<Object?> get props => [orientation];
}

class SetResolution extends DisplaySettingsEvent {
  final DisplayMode mode;
  const SetResolution(this.mode);

  @override
  List<Object?> get props => [mode];
}

class SetRefreshRate extends DisplaySettingsEvent {
  final String refreshRate;
  const SetRefreshRate(this.refreshRate);

  @override
  List<Object?> get props => [refreshRate];
}

class SetBrightness extends DisplaySettingsEvent {
  final double brightness;
  const SetBrightness(this.brightness);

  @override
  List<Object?> get props => [brightness];
}

class SetScale extends DisplaySettingsEvent {
  final int scale;
  const SetScale(this.scale);

  @override
  List<Object?> get props => [scale];
}

class SetFractionalScaling extends DisplaySettingsEvent {
  final bool enabled;
  const SetFractionalScaling(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

class ToggleDisplayEnabled extends DisplaySettingsEvent {
  final String displayName;
  final bool enabled;
  const ToggleDisplayEnabled(this.displayName, this.enabled);

  @override
  List<Object?> get props => [displayName, enabled];
}

class SetPrimaryDisplay extends DisplaySettingsEvent {
  final String displayName;
  const SetPrimaryDisplay(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

class SetMirrorMode extends DisplaySettingsEvent {
  final String sourceDisplay;
  final String? targetDisplay;
  const SetMirrorMode(this.sourceDisplay, this.targetDisplay);

  @override
  List<Object?> get props => [sourceDisplay, targetDisplay];
}

class SaveDisplayProfile extends DisplaySettingsEvent {
  final String profileName;
  const SaveDisplayProfile(this.profileName);

  @override
  List<Object?> get props => [profileName];
}

class LoadDisplayProfile extends DisplaySettingsEvent {
  final String profileName;
  const LoadDisplayProfile(this.profileName);

  @override
  List<Object?> get props => [profileName];
}

class DeleteDisplayProfile extends DisplaySettingsEvent {
  final String profileName;
  const DeleteDisplayProfile(this.profileName);

  @override
  List<Object?> get props => [profileName];
}

class DisplayChangedExternally extends DisplaySettingsEvent {
  final String displayName;
  const DisplayChangedExternally(this.displayName);

  @override
  List<Object?> get props => [displayName];
}

// ── Wayland-specific events ───────────────────────────────────────────────────

/// Toggle Variable Refresh Rate (VRR / Adaptive Sync) — requires protocol v4
class SetAdaptiveSync extends DisplaySettingsEvent {
  final String displayName;
  final bool enabled;
  const SetAdaptiveSync(this.displayName, this.enabled);

  @override
  List<Object?> get props => [displayName, enabled];
}

/// Test configuration without applying (dry-run)
class TestConfiguration extends DisplaySettingsEvent {
  const TestConfiguration();
}

/// Set display position in compositor space
class SetDisplayPosition extends DisplaySettingsEvent {
  final String displayName;
  final int x;
  final int y;
  const SetDisplayPosition(this.displayName, this.x, this.y);

  @override
  List<Object?> get props => [displayName, x, y];
}

/// Wayland heads changed notification (from native callback)
class WlrHeadsChanged extends DisplaySettingsEvent {
  const WlrHeadsChanged();
}
