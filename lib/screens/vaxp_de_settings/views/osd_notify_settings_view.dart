import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:settings/features/vaxp_de/vaxp_de.dart';

class OsdNotifySettingsView extends StatelessWidget {
  const OsdNotifySettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OsdNotifyBloc, OsdNotifyState>(
      builder: (context, state) {
        if (state is OsdNotifyLoading || state is OsdNotifyInitial) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF00FFFF),
            ),
          );
        }

        if (state is OsdNotifyError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Text(
                'Error loading settings:\n${state.message}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state is OsdNotifyLoaded) {
          final config = state.config;

          return Theme(
            data: ThemeData.dark().copyWith(
              sliderTheme: SliderThemeData(
                activeTrackColor: const Color(0xFF00FFFF),
                inactiveTrackColor: Colors.white.withOpacity(0.1),
                thumbColor: const Color(0xFF00FFFF),
                overlayColor: const Color(0xFF00FFFF).withOpacity(0.2),
                valueIndicatorColor: const Color(0xFF222222),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildSectionHeader(Icons.notifications_active_rounded, 'Notifications', 'Customize your desktop notification popups'),
                _buildCardGroup([
                  _buildColorTile(context, config, 'Background Color', 'Notifications background color', config.notifyBgColor, true, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyBgColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Border Color', 'Notifications border color', config.notifyBorderColor, true, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyBorderColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Title Text Color', 'Notifications title text color', config.notifyTitleTextColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyTitleTextColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Body Text Color', 'Notifications body text color', config.notifyBodyTextColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyBodyTextColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Button Background Color', 'Action button background', config.notifyBtnBgColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyBtnBgColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Button Text Color', 'Action button text', config.notifyBtnTextColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyBtnTextColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Button Hover Background', 'Action button hover background', config.notifyBtnHoverBgColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyBtnHoverBgColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Button Hover Text', 'Action button hover text', config.notifyBtnHoverTextColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyBtnHoverTextColor: c)))),
                ]),

                const SizedBox(height: 24),
                _buildCardGroup([
                  _buildPositionSelector(context, config),
                  _buildDivider(),
                  _buildSlider(context, 'Margin X', 'Horizontal margin from screen edge', config.notifyMarginX.toDouble(), 0, 100, (v) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyMarginX: v.toInt())))),
                  _buildDivider(),
                  _buildSlider(context, 'Margin Y', 'Vertical margin from screen edge', config.notifyMarginY.toDouble(), 0, 100, (v) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifyMarginY: v.toInt())))),
                  _buildDivider(),
                  _buildSlider(context, 'Spacing', 'Spacing between multiple notifications', config.notifySpacing.toDouble(), 0, 50, (v) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(notifySpacing: v.toInt())))),
                ]),

                const SizedBox(height: 48),
                _buildSectionHeader(Icons.volume_up_rounded, 'On-Screen Display (OSD)', 'Volume and brightness popup styling'),
                _buildCardGroup([
                  _buildColorTile(context, config, 'Background Color', 'OSD popup background', config.osdBgColor, true, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(osdBgColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Text Color', 'OSD percentage text', config.osdTextColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(osdTextColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Bar Background Color', 'Volume/Brightness track background', config.osdBarBgColor, true, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(osdBarBgColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Bar Foreground Color', 'Volume/Brightness filled bar', config.osdBarFgColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(osdBarFgColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Icon Normal Color', 'Primary icon color', config.osdIconNormalColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(osdIconNormalColor: c)))),
                  _buildDivider(),
                  _buildColorTile(context, config, 'Icon Muted Color', 'Muted/Zero icon color', config.osdIconMutedColor, false, (c) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(osdIconMutedColor: c)))),
                ]),

                const SizedBox(height: 48),
                _buildSectionHeader(Icons.audiotrack_rounded, 'System Sounds', 'Assign audio files to system events'),
                _buildCardGroup([
                  _buildPathSelector(context: context, title: 'Notification', subtitle: 'Standard notification chime', currentPath: config.soundNotification, onChanged: (p) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(soundNotification: p)))),
                  _buildDivider(),
                  _buildPathSelector(context: context, title: 'Charger Connect', subtitle: 'When power is connected', currentPath: config.soundChargerConnect, onChanged: (p) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(soundChargerConnect: p)))),
                  _buildDivider(),
                  _buildPathSelector(context: context, title: 'Charger Disconnect', subtitle: 'When power is disconnected', currentPath: config.soundChargerDisconnect, onChanged: (p) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(soundChargerDisconnect: p)))),
                  _buildDivider(),
                  _buildPathSelector(context: context, title: 'USB Connect', subtitle: 'When a USB device is plugged in', currentPath: config.soundUsbConnect, onChanged: (p) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(soundUsbConnect: p)))),
                  _buildDivider(),
                  _buildPathSelector(context: context, title: 'USB Disconnect', subtitle: 'When a USB device is removed', currentPath: config.soundUsbDisconnect, onChanged: (p) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(soundUsbDisconnect: p)))),
                  _buildDivider(),
                  _buildPathSelector(context: context, title: 'Battery Full', subtitle: 'When battery reaches high limit', currentPath: config.soundLimitHigh, onChanged: (p) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(soundLimitHigh: p)))),
                  _buildDivider(),
                  _buildPathSelector(context: context, title: 'Battery Low', subtitle: 'When battery reaches low limit', currentPath: config.soundLimitLow, onChanged: (p) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(soundLimitLow: p)))),
                  _buildDivider(),
                  _buildPathSelector(context: context, title: 'Error', subtitle: 'System error sound', currentPath: config.soundError, onChanged: (p) => context.read<OsdNotifyBloc>().add(UpdateOsdNotifyConfig(config.copyWith(soundError: p)))),
                ]),
                const SizedBox(height: 64),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFFF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF00FFFF), size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            children: children,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.white.withOpacity(0.05),
      indent: 16,
      endIndent: 16,
    );
  }

  Widget _buildPositionSelector(BuildContext context, OsdNotifyConfig config) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Position',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Notification popup screen location',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: OsdNotifyConfig.positions.contains(config.notifyPosition) ? config.notifyPosition : 'top-right',
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                icon: const Icon(Icons.expand_more_rounded, color: Colors.white70),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<OsdNotifyBloc>().add(
                      UpdateOsdNotifyConfig(config.copyWith(notifyPosition: newValue))
                    );
                  }
                },
                items: OsdNotifyConfig.positions.map((pos) {
                  return DropdownMenuItem(
                    value: pos,
                    child: Text(pos),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context, String title, String subtitle, double value, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: value,
                    min: min,
                    max: max,
                    divisions: (max - min).toInt(),
                    label: value.toInt().toString(),
                    onChanged: onChanged,
                  ),
                ),
                Container(
                  width: 48,
                  alignment: Alignment.centerRight,
                  child: Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Color(0xFF00FFFF),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTile(
    BuildContext context,
    OsdNotifyConfig config,
    String title,
    String subtitle,
    Color color,
    bool enableAlpha,
    ValueChanged<Color> onColorChanged,
  ) {
    return InkWell(
      onTap: () {
        _showColorPicker(context, title, color, enableAlpha, onColorChanged);
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context, 
    String title, 
    Color initialColor, 
    bool enableAlpha,
    ValueChanged<Color> onColorChanged,
  ) {
    Color currentColor = initialColor;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ColorPicker(
                  pickerColor: initialColor,
                  onColorChanged: (c) => currentColor = c,
                  enableAlpha: enableAlpha,
                  displayThumbColor: true,
                  portraitOnly: true,
                  pickerAreaBorderRadius: BorderRadius.circular(12),
                  pickerAreaHeightPercent: 0.7,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white54,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        onColorChanged(currentColor);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFFF),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Save Color', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPathSelector({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String currentPath,
    required ValueChanged<String> onChanged,
  }) {
    final hasPath = currentPath.isNotEmpty;
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  hasPath ? currentPath : subtitle,
                  style: TextStyle(
                    color: hasPath ? const Color(0xFF00FFFF) : Colors.white.withOpacity(0.5), 
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Row(
            children: [
              if (hasPath) ...[
                IconButton(
                  icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 20),
                  onPressed: () => onChanged(''),
                  tooltip: 'Clear',
                  splashRadius: 20,
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                onPressed: () async {
                  final resultObj = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['mp3', 'wav', 'ogg'],
                  );
                  final result = resultObj?.files.single.path;
                  if (result != null) {
                    onChanged(result);
                  }
                },
                icon: const Icon(Icons.folder_open_rounded, size: 18),
                label: const Text('Browse'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
