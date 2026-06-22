import 'dart:io';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:settings/features/vaxp_de/vaxp_de.dart';

class DesktopManagerSettingsView extends StatelessWidget {
  const DesktopManagerSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DesktopManagerBloc, DesktopManagerState>(
      builder: (context, state) {
        if (state is DesktopManagerLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DesktopManagerError) {
          return Center(
            child: Text(
              'Error loading desktop manager settings:\n${state.message}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (state is DesktopManagerLoaded) {
          final config = state.config;

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              _buildSectionTitle('Desktop Mode'),
              _buildDesktopModeSelector(context, config),
              const SizedBox(height: 32),

              _buildSectionTitle('Wallpaper Settings'),
              _buildPathSelector(
                context: context,
                title: 'Wallpaper File',
                subtitle: 'Path to the active wallpaper',
                currentPath: config.wallpaperPath,
                isDir: false,
                onChanged: (path) {
                  context.read<DesktopManagerBloc>().add(
                    UpdateDesktopManagerConfig(config.copyWith(wallpaperPath: path)),
                  );
                },
              ),
              const SizedBox(height: 8),
              _SystemWallpapersCard(config: config),
              const SizedBox(height: 8),
              _buildPathSelector(
                context: context,
                title: 'Wallpaper Directory',
                subtitle: 'Path containing your wallpapers',
                currentPath: config.wallpaperDirs,
                isDir: true,
                onChanged: (path) {
                  context.read<DesktopManagerBloc>().add(
                    UpdateDesktopManagerConfig(config.copyWith(wallpaperDirs: path)),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildAnimationSelector(context, config),
              const SizedBox(height: 32),

              _buildSectionTitle('Widgets Theme'),
              _buildColorTile(
                context: context,
                title: 'Widgets Background Color',
                subtitle: 'Color and opacity for desktop widgets',
                color: config.themeColor.withValues(alpha: config.themeOpacity),
                enableAlpha: true,
                onColorChanged: (c) {
                  context.read<DesktopManagerBloc>().add(
                    UpdateDesktopManagerConfig(
                      config.copyWith(
                        themeColor: c.withValues(alpha: 1.0),
                        themeOpacity: c.a,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Manage Widgets'),
              ..._buildWidgetsList(context, config),
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

  Widget _buildDesktopModeSelector(BuildContext context, DesktopManagerConfig config) {
    return _buildSettingCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mode',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildModeOption(context, config, 'normal', Icons.monitor),
              const SizedBox(width: 8),
              _buildModeOption(context, config, 'work', Icons.work_rounded),
              const SizedBox(width: 8),
              _buildModeOption(context, config, 'widgets', Icons.widgets_rounded),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeOption(BuildContext context, DesktopManagerConfig config, String mode, IconData icon) {
    final isSelected = config.desktopMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<DesktopManagerBloc>().add(
            UpdateDesktopManagerConfig(config.copyWith(desktopMode: mode)),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color.fromARGB(255, 64, 200, 255).withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color.fromARGB(255, 64, 200, 255) : Colors.transparent,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? const Color.fromARGB(255, 64, 200, 255) : Colors.white54),
              const SizedBox(height: 8),
              Text(
                mode[0].toUpperCase() + mode.substring(1),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPathSelector({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String currentPath,
    required bool isDir,
    required ValueChanged<String> onChanged,
  }) {
    return _buildSettingCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  currentPath.isEmpty ? subtitle : currentPath,
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () async {
              String? result;
              if (isDir) {
                result = await FilePicker.platform.getDirectoryPath();
              } else {
                final resultObj = await FilePicker.platform.pickFiles(type: FileType.media);
                result = resultObj?.files.single.path;
              }
              if (result != null) {
                onChanged(result);
              }
            },
            icon: Icon(isDir ? Icons.folder_rounded : Icons.image_rounded, size: 18),
            label: const Text('Browse'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationSelector(BuildContext context, DesktopManagerConfig config) {
    return _buildSettingCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Wallpaper Animation',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              Text(
                'Animation when switching wallpapers',
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
              child: DropdownButton<int>(
                value: config.wallpaperAnim >= 0 && config.wallpaperAnim <= 10 ? config.wallpaperAnim : 0,
                dropdownColor: const Color.fromARGB(91, 0, 0, 0),
                style: const TextStyle(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    context.read<DesktopManagerBloc>().add(
                      UpdateDesktopManagerConfig(config.copyWith(wallpaperAnim: newValue))
                    );
                  }
                },
                items: DesktopManagerConfig.animationNames.asMap().entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text('${entry.key == 0 ? "" : "${entry.key}. "}${entry.value}'),
                  );
                }).toList(),
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
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(102, 0, 0, 0),
                    blurRadius: 4,
                    offset: Offset(0, 2),
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

  List<Widget> _buildWidgetsList(BuildContext context, DesktopManagerConfig config) {
    if (config.availableWidgets.isEmpty) {
      return [
        _buildSettingCard(
          child: const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No widgets found in ~/.config/vaxp/desktop/widgets', style: TextStyle(color: Colors.white54)),
            ),
          ),
        )
      ];
    }

    return config.availableWidgets.map((widgetName) {
      final isEnabled = config.isWidgetEnabled(widgetName);
      return Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: _buildSettingCard(
          child: SwitchListTile(
            title: Text(widgetName, style: const TextStyle(color: Colors.white)),
            value: isEnabled,
            activeThumbColor: const Color.fromARGB(255, 64, 200, 255),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            onChanged: (bool value) {
              final newDisabled = List<String>.from(config.disabledWidgets);
              if (value) {
                newDisabled.remove(widgetName);
              } else {
                if (!newDisabled.contains(widgetName)) {
                  newDisabled.add(widgetName);
                }
              }
              context.read<DesktopManagerBloc>().add(
                UpdateDesktopManagerConfig(config.copyWith(disabledWidgets: newDisabled)),
              );
            },
          ),
        ),
      );
    }).toList();
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

class _SystemWallpapersCard extends StatefulWidget {
  final DesktopManagerConfig config;

  const _SystemWallpapersCard({required this.config});

  @override
  State<_SystemWallpapersCard> createState() => _SystemWallpapersCardState();
}

class _SystemWallpapersCardState extends State<_SystemWallpapersCard> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  late Future<List<String>> _wallpapersFuture;

  @override
  void initState() {
    super.initState();
    _wallpapersFuture = _getSystemWallpapers(widget.config.wallpaperDirs);
  }

  @override
  void didUpdateWidget(_SystemWallpapersCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.wallpaperDirs != widget.config.wallpaperDirs) {
      _wallpapersFuture = _getSystemWallpapers(widget.config.wallpaperDirs);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<List<String>> _getSystemWallpapers(String userDir) async {
    final List<String> paths = [];
    final dirsToSearch = ['/usr/share/backgrounds'];
    if (userDir.isNotEmpty) {
      dirsToSearch.add(userDir);
    }

    for (final dirPath in dirsToSearch) {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        try {
          final entities = await dir.list().toList();
          for (var e in entities) {
            if (e is File) {
              final p = e.path.toLowerCase();
              if (p.endsWith('.png') || p.endsWith('.jpg') || p.endsWith('.jpeg') || p.endsWith('.webp') ||
                  p.endsWith('.gif') || p.endsWith('.mp4') || p.endsWith('.mkv') || p.endsWith('.webm')) {
                paths.add(e.path);
              }
            }
          }
        } catch (_) {}
      }
    }
    
    final uniquePaths = paths.toSet().toList();
    uniquePaths.sort();
    return uniquePaths;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _wallpapersFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

        final paths = snapshot.data!;
        
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'System Wallpapers',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final imageWidth = (availableWidth - (8 * 4)) / 5;
                  const gridHeight = 180.0;
                  final imageHeight = (gridHeight - 8) / 2;
                  final ratio = imageHeight / imageWidth;

                  return Focus(
                    focusNode: _focusNode,
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                          _scrollController.animateTo(
                            (_scrollController.offset - imageWidth - 8).clamp(0.0, _scrollController.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                          return KeyEventResult.handled;
                        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                          _scrollController.animateTo(
                            (_scrollController.offset + imageWidth + 8).clamp(0.0, _scrollController.position.maxScrollExtent),
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                          return KeyEventResult.handled;
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: MouseRegion(
                      onEnter: (_) => _focusNode.requestFocus(),
                      onExit: (_) => _focusNode.unfocus(),
                      child: Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            final offset = pointerSignal.scrollDelta.dy;
                            if (offset != 0) {
                              _scrollController.jumpTo(
                                (_scrollController.offset + offset).clamp(0.0, _scrollController.position.maxScrollExtent),
                              );
                            }
                          }
                        },
                        child: SizedBox(
                          height: gridHeight,
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: true,
                            child: GridView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.horizontal,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: ratio,
                              ),
                              itemCount: paths.length,
                              itemBuilder: (context, index) {
                                final path = paths[index];
                                final isSelected = widget.config.wallpaperPath == path;
                                final isVideo = path.toLowerCase().endsWith('.mp4') || 
                                                path.toLowerCase().endsWith('.mkv') || 
                                                path.toLowerCase().endsWith('.webm');
                                                
                                return GestureDetector(
                                  onTap: () {
                                    context.read<DesktopManagerBloc>().add(
                                      UpdateDesktopManagerConfig(widget.config.copyWith(wallpaperPath: path)),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isVideo ? Colors.black45 : null,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? const Color.fromARGB(255, 64, 200, 255) : Colors.transparent,
                                        width: 2,
                                      ),
                                      image: isVideo ? null : DecorationImage(
                                        image: ResizeImage(
                                          FileImage(File(path)),
                                          width: 300, // Resize to act as a thumbnail
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: isVideo ? Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.movie_rounded, color: Colors.white70, size: 32),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                            child: Text(
                                              path.split('/').last,
                                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ) : null,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
