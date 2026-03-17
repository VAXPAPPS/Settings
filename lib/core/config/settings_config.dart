import 'package:flutter/material.dart';
import 'package:settings/screens/wifi_settings/wifi_settings_page.dart';
import 'package:settings/screens/bluetooth_settings/bluetooth_settings_page.dart';
import 'package:settings/screens/ethernet_settings/ethernet_settings_page.dart';
import 'package:settings/screens/venom_effects/venom_effects.dart';
import 'package:settings/screens/apps_settings/apps_settings_page.dart';
import 'package:settings/screens/display_settings/display_settings_page.dart';
import 'package:settings/screens/audio_settings/audio_settings_page.dart';
import 'package:settings/screens/mouse_settings/mouse_settings_page.dart';
import 'package:settings/screens/keyboard_settings/keyboard_settings_page.dart';
import 'package:settings/screens/system_settings/system_settings_page.dart';
import 'package:settings/screens/power_settings/power_settings_page.dart';
import 'package:settings/screens/window_manager/window_manager_page.dart';

class SettingsPageItem {
  final String label;
  final IconData icon;
  final Widget page;

  const SettingsPageItem({
    required this.label,
    required this.icon,
    required this.page,
  });
}

const List<SettingsPageItem> settingsPages = [
  SettingsPageItem(
    label: 'Wi-Fi',
    icon: Icons.wifi_rounded,
    page: WiFiSettingsPage(),
  ),
  SettingsPageItem(
    label: 'Bluetooth',
    icon: Icons.bluetooth_rounded,
    page: BluetoothSettingsPage(),
  ),
  SettingsPageItem(
    label: 'Ethernet',
    icon: Icons.cable_rounded,
    page: EthernetSettingsPage(),
  ),
  SettingsPageItem(
    label: 'Window Manager',
    icon: Icons.window_rounded,
    page: WindowManagerPage(),
  ),
  SettingsPageItem(
    label: 'Venom Effects',
    icon: Icons.theater_comedy_sharp,
    page: CompositorSettingsPage(),
  ),
  SettingsPageItem(
    label: 'Venom Theme',
    icon: Icons.apps_rounded,
    page: AppsSettingsPage(),
  ),
  SettingsPageItem(
    label: 'Display',
    icon: Icons.monitor_rounded,
    page: DisplaySettingsPage(),
  ),
  SettingsPageItem(
    label: 'Sound',
    icon: Icons.volume_up_rounded,
    page: AudioSettingsPage(),
  ),
  SettingsPageItem(
    label: 'Mouse',
    icon: Icons.mouse_rounded,
    page: MouseSettingsPage(),
  ),
  SettingsPageItem(
    label: 'Keyboard',
    icon: Icons.keyboard_rounded,
    page: KeyboardSettingsPage(),
  ),
  SettingsPageItem(
    label: 'System',
    icon: Icons.settings_rounded,
    page: SystemSettingsPage(),
  ),
  SettingsPageItem(
    label: 'Power',
    icon: Icons.power_settings_new_rounded,
    page: PowerSettingsPage(),
  ),

];
