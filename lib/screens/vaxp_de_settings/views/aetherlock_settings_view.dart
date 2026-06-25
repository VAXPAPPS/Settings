import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:settings/features/vaxp_de/vaxp_de.dart';

class AetherLockSettingsView extends StatelessWidget {
  const AetherLockSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AetherLockBloc, AetherLockState>(
      builder: (context, state) {
        if (state is AetherLockLoading || state is AetherLockInitial) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF00FFFF)),
          );
        }

        if (state is AetherLockError) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Error loading Aether Lock settings:\n${state.message}',
                style: const TextStyle(color: Colors.redAccent, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (state is AetherLockLoaded) {
          final config = state.config;
          return Theme(
            data: ThemeData.dark().copyWith(
              sliderTheme: SliderThemeData(
                activeTrackColor: const Color(0xFF7EE0C9),
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                thumbColor: const Color(0xFF7EE0C9),
                overlayColor: const Color(0xFF7EE0C9).withValues(alpha: 0.2),
                valueIndicatorColor: const Color(0xFF1E1E1E),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF7EE0C9)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              physics: const BouncingScrollPhysics(),
              children: [
                _buildGlowHeader(
                  title: 'Aether Lock',
                  subtitle: 'Advanced Lock Screen Customization',
                  icon: Icons.lock_outline_rounded,
                  glowColor: config.accent,
                ),
                const SizedBox(height: 32),
                
                // Weather Section
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Weather', Icons.cloud_outlined),
                      const SizedBox(height: 24),
                      Autocomplete<String>(
                        initialValue: TextEditingValue(text: config.weatherLocation),
                        optionsBuilder: (TextEditingValue textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return const Iterable<String>.empty();
                          }
                          const commonCities = [
                            'Abu Dhabi', 'Amman', 'Ankara', 'Baghdad', 'Basra', 'Beijing', 'Beirut', 'Berlin',
                            'Cairo', 'Chicago', 'Damascus', 'Delhi', 'Doha', 'Dubai', 'Erbil', 'Istanbul',
                            'Jeddah', 'Karbala', 'Kirkuk', 'Kuwait City', 'London', 'Los Angeles', 'Mecca',
                            'Medina', 'Moscow', 'Mosul', 'Najaf', 'New York', 'Paris', 'Riyadh', 'Rome',
                            'Sanaa', 'São Paulo', 'Seoul', 'Sulaymaniyah', 'Sydney', 'Tehran', 'Tokyo',
                            'Toronto', 'Tunis'
                          ];
                          return commonCities.where((String option) {
                            return option.toLowerCase().startsWith(textEditingValue.text.toLowerCase());
                          });
                        },
                        onSelected: (String selection) {
                          context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(weatherLocation: selection)));
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Location',
                              labelStyle: TextStyle(color: Colors.white54),
                              prefixIcon: Icon(Icons.location_on_outlined, color: Colors.white54),
                            ),
                            onChanged: (val) => context.read<AetherLockBloc>().add(
                              UpdateAetherLockConfig(config.copyWith(weatherLocation: val)),
                            ),
                          );
                        },
                        optionsViewBuilder: (context, onSelected, options) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Material(
                              color: Colors.transparent,
                              child: Container(
                                width: 300,
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final option = options.elementAt(index);
                                    return InkWell(
                                      onTap: () => onSelected(option),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        child: Text(option, style: const TextStyle(color: Colors.white)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Notifications Section
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Notifications', Icons.notifications_none_outlined),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Hide Content', style: TextStyle(color: Colors.white, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Hide notification details on lock screen', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 13)),
                            ],
                          ),
                          Switch(
                            value: config.hideContent,
                            activeThumbColor: config.accent,
                            onChanged: (val) => context.read<AetherLockBloc>().add(
                              UpdateAetherLockConfig(config.copyWith(hideContent: val)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Borders and Geometry Section
                _buildGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Geometry & Borders', Icons.aspect_ratio_rounded),
                      const SizedBox(height: 16),
                      _buildSlider(context, 'Panel Border Width', config.panelBorderWidth, 0, 10, (v) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(panelBorderWidth: v)))),
                      const SizedBox(height: 16),
                      _buildSlider(context, 'Outer Border Width', config.outerBorderWidth, 0, 10, (v) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(outerBorderWidth: v)))),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Colors Section
                _buildSectionHeader('Color Palette', Icons.palette_outlined),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _buildColorBox(context, 'Accent', config.accent, true, (c) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(accent: c)))),
                    _buildColorBox(context, 'Accent Dim', config.accentDim, true, (c) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(accentDim: c)))),
                    _buildColorBox(context, 'Text Bright', config.textBright, true, (c) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(textBright: c)))),
                    _buildColorBox(context, 'Text Dim', config.textDim, true, (c) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(textDim: c)))),
                    _buildColorBox(context, 'Panel Background', config.panelBackground, true, (c) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(panelBackground: c)))),
                    _buildColorBox(context, 'Panel Border', config.panelBorder, true, (c) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(panelBorder: c)))),
                    _buildColorBox(context, 'Background', config.background, true, (c) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(background: c)))),
                    _buildColorBox(context, 'Outer Border', config.outerBorder, true, (c) => context.read<AetherLockBloc>().add(UpdateAetherLockConfig(config.copyWith(outerBorder: c)))),
                  ],
                ),
                const SizedBox(height: 64),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildGlowHeader({required String title, required String subtitle, required IconData icon, required Color glowColor}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.1),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: glowColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: glowColor, size: 36),
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF7EE0C9), size: 24),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(BuildContext context, String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
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
                  divisions: ((max - min) * 10).toInt(),
                  label: value.toStringAsFixed(1),
                  onChanged: onChanged,
                ),
              ),
              Container(
                width: 48,
                alignment: Alignment.centerRight,
                child: Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(color: Color(0xFF7EE0C9), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorBox(
    BuildContext context,
    String title,
    Color color,
    bool enableAlpha,
    ValueChanged<Color> onColorChanged,
  ) {
    return InkWell(
      onTap: () => _showColorPicker(context, title, color, enableAlpha, onColorChanged),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(200, 15, 15, 20),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    Flexible(
                      child: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: initialColor,
                          onColorChanged: (c) => currentColor = c,
                          enableAlpha: enableAlpha,
                          displayThumbColor: true,
                          paletteType: PaletteType.hsvWithHue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 16)),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7EE0C9),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            onColorChanged(currentColor);
                            Navigator.of(context).pop();
                          },
                          child: const Text('Apply', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
