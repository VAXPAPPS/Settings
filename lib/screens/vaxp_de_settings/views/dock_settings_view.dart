import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:settings/features/vaxp_de/vaxp_de.dart';

class DockSettingsView extends StatelessWidget {
  const DockSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VaxpDeBloc, VaxpDeState>(
      builder: (context, state) {
        if (state is VaxpDeLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is VaxpDeError) {
          return Center(
            child: Text(
              'Error loading dock settings:\n${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is VaxpDeLoaded) {
          final config = state.dockConfig;
          
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildSectionTitle('Position & Behavior'),
              _buildPositionSelector(context, config),
              const SizedBox(height: 16),
              _buildLaunchAnimationSelector(context, config),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Colors & Theming'),
              _buildColorTile(
                context: context,
                title: 'Background Color',
                subtitle: 'Main dock background color',
                color: config.backgroundColor,
                enableAlpha: true,
                onColorChanged: (c) {
                  context.read<VaxpDeBloc>().add(
                    UpdateDockConfig(config.copyWith(backgroundColor: c))
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildColorTile(
                context: context,
                title: 'Context Menu Color',
                subtitle: 'Color of right-click menus on the dock',
                color: config.contextMenuColor,
                enableAlpha: true,
                onColorChanged: (c) {
                  context.read<VaxpDeBloc>().add(
                    UpdateDockConfig(config.copyWith(contextMenuColor: c))
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildColorTile(
                context: context,
                title: 'Indicator Color',
                subtitle: 'Running app indicator color',
                color: config.indicatorColor,
                enableAlpha: false,
                onColorChanged: (c) {
                  context.read<VaxpDeBloc>().add(
                    UpdateDockConfig(config.copyWith(indicatorColor: c))
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildColorTile(
                context: context,
                title: 'Launch Ring Color',
                subtitle: 'Color of ring during app launch',
                color: config.launchRingColor,
                enableAlpha: false,
                onColorChanged: (c) {
                  context.read<VaxpDeBloc>().add(
                    UpdateDockConfig(config.copyWith(launchRingColor: c))
                  );
                },
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPositionSelector(BuildContext context, DockConfig config) {
    return _buildSettingCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dock Position',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                'Screen edge to place the dock',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(154, 0, 0, 0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: config.position,
                dropdownColor: const Color.fromARGB(74, 0, 0, 0),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    context.read<VaxpDeBloc>().add(
                      UpdateDockConfig(config.copyWith(position: newValue))
                    );
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'bottom', child: Text('Bottom')),
                  DropdownMenuItem(value: 'top', child: Text('Top')),
                  DropdownMenuItem(value: 'left', child: Text('Left')),
                  DropdownMenuItem(value: 'right', child: Text('Right')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaunchAnimationSelector(BuildContext context, DockConfig config) {
    return _buildSettingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Launch Animation',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Animation style when launching apps',
                    style: TextStyle(color: Colors.white54, fontSize: 13),
                  ),
                ],
              ),
              Text(
                config.launchAnimation.toString(),
                style: const TextStyle(
                  color: Color.fromARGB(255, 64, 200, 255),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(154, 0, 0, 0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            width: double.infinity,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: config.launchAnimation >= 1 && config.launchAnimation <= 7 ? config.launchAnimation : 1,
                dropdownColor: const Color.fromARGB(91, 0, 0, 0),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                isExpanded: true,
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    context.read<VaxpDeBloc>().add(
                      UpdateDockConfig(config.copyWith(launchAnimation: newValue))
                    );
                  }
                },
                items: const [
                  DropdownMenuItem(value: 1, child: Text('Spinner (Default)')),
                  DropdownMenuItem(value: 2, child: Text('Pulse Ripple')),
                  DropdownMenuItem(value: 3, child: Text('Orbiting Dots')),
                  DropdownMenuItem(value: 4, child: Text('Radar Sweep')),
                  DropdownMenuItem(value: 5, child: Text('Dashed Chase')),
                  DropdownMenuItem(value: 6, child: Text('Pendulum Bounce')),
                  DropdownMenuItem(value: 7, child: Text('Breathing Halo')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required Color color,
    required bool enableAlpha,
    required ValueChanged<Color> onColorChanged,
  }) {
    return _buildSettingCard(
      child: InkWell(
        onTap: () {
          _showColorPicker(context, title, color, enableAlpha, onColorChanged);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(102, 0, 0, 0),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
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
        return AlertDialog(
          backgroundColor: const Color.fromARGB(154, 0, 0, 0),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: initialColor,
              onColorChanged: (c) => currentColor = c,
              enableAlpha: enableAlpha,
              displayThumbColor: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                onColorChanged(currentColor);
                Navigator.of(context).pop();
              },
              child: const Text('Save', style: TextStyle(color: Color.fromARGB(255, 64, 200, 255))),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }
}
