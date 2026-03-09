import 'package:flutter/material.dart';
import 'package:antidote/screens/wifi_settings/wifi_settings_page.dart';
import 'package:antidote/screens/bluetooth_settings/bluetooth_settings_page.dart';
import 'package:antidote/screens/ethernet_settings/ethernet_settings_page.dart';
import 'package:antidote/screens/venom_effects/venom_effects.dart';
import 'package:antidote/screens/apps_settings/apps_settings_page.dart';
import 'package:antidote/screens/display_settings/display_settings_page.dart';
import 'package:antidote/screens/audio_settings/audio_settings_page.dart';
import 'package:antidote/screens/mouse_settings/mouse_settings_page.dart';
import 'package:antidote/screens/keyboard_settings/keyboard_settings_page.dart';
import 'package:antidote/screens/system_settings/system_settings_page.dart';
import 'package:antidote/screens/power_settings/power_settings_page.dart';
import 'package:antidote/screens/window_manager/window_manager_page.dart';

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
