import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:settings/features/vaxp_de/vaxp_de.dart';

class VaxpOtherSettingsView extends StatelessWidget {
  const VaxpOtherSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        const _AuthSettingsTab(),
        const _ClipboardSettingsTab(),
      ],
    );
  }
}

class _AuthSettingsTab extends StatelessWidget {
  const _AuthSettingsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF7EE0C9)));
        }

        if (state is AuthError) {
          return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.redAccent)));
        }

        if (state is AuthLoaded) {
          final config = state.config;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionHeader('General', Icons.settings_rounded),
              const SizedBox(height: 16),
              _buildDropdown(
                context: context,
                title: 'Theme',
                value: config.theme,
                options: ['Minimal', 'Polkit', 'Terminal'],
                onChanged: (val) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(theme: val))),
              ),
              const SizedBox(height: 32),
              
              _buildSectionHeader('Theme.Minimal', Icons.palette_outlined),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Background', config.minimalBackgroundColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalBackgroundColor: c)))),
                _buildColorBox(context, 'Text Color', config.minimalTextColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalTextColor: c)))),
                _buildColorBox(context, 'Input Bg', config.minimalInputBackground, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalInputBackground: c)))),
                _buildColorBox(context, 'Input Text', config.minimalInputTextColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalInputTextColor: c)))),
                _buildColorBox(context, 'Input Focus', config.minimalInputFocusBorder, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalInputFocusBorder: c)))),
                _buildColorBox(context, 'Primary Btn', config.minimalPrimaryButton, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalPrimaryButton: c)))),
                _buildColorBox(context, 'Pri Btn Hover', config.minimalPrimaryButtonHover, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalPrimaryButtonHover: c)))),
                _buildColorBox(context, 'Secondary Btn', config.minimalSecondaryButton, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalSecondaryButton: c)))),
                _buildColorBox(context, 'Sec Btn Hover', config.minimalSecondaryButtonHover, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalSecondaryButtonHover: c)))),
                _buildColorBox(context, 'Avatar Ring', config.minimalAvatarRing, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(minimalAvatarRing: c)))),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader('Theme.Polkit', Icons.security_rounded),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Background', config.polkitBackgroundColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitBackgroundColor: c)))),
                _buildColorBox(context, 'Border', config.polkitBorderColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitBorderColor: c)))),
                _buildColorBox(context, 'Text Color', config.polkitTextColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitTextColor: c)))),
                _buildColorBox(context, 'Accent', config.polkitAccentColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitAccentColor: c)))),
                _buildColorBox(context, 'Accent Hover', config.polkitAccentColorHover, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitAccentColorHover: c)))),
                _buildColorBox(context, 'User Row Bg', config.polkitUserRowBackground, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitUserRowBackground: c)))),
                _buildColorBox(context, 'Input Bg', config.polkitInputBackground, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitInputBackground: c)))),
                _buildColorBox(context, 'Input Text', config.polkitInputTextColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitInputTextColor: c)))),
                _buildColorBox(context, 'Button Bg', config.polkitButtonBackground, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitButtonBackground: c)))),
                _buildColorBox(context, 'Button Hover', config.polkitButtonHover, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(polkitButtonHover: c)))),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader('Theme.Terminal', Icons.terminal_rounded),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Background', config.terminalBackgroundColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalBackgroundColor: c)))),
                _buildColorBox(context, 'Border', config.terminalBorderColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalBorderColor: c)))),
                _buildColorBox(context, 'Title Bar', config.terminalTitleBarColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalTitleBarColor: c)))),
                _buildColorBox(context, 'Text Color', config.terminalTextColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalTextColor: c)))),
                _buildColorBox(context, 'Prompt Color', config.terminalPromptColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalPromptColor: c)))),
                _buildColorBox(context, 'Input Bg', config.terminalInputBackground, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalInputBackground: c)))),
                _buildColorBox(context, 'Input Text', config.terminalInputTextColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalInputTextColor: c)))),
                _buildColorBox(context, 'Hint Color', config.terminalHintColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalHintColor: c)))),
                _buildColorBox(context, 'Warning Color', config.terminalWarningColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalWarningColor: c)))),
                _buildColorBox(context, 'Command Color', config.terminalCommandColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalCommandColor: c)))),
                _buildColorBox(context, 'Path Color', config.terminalPathColor, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalPathColor: c)))),
                _buildColorBox(context, 'Dot Red', config.terminalDotRed, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalDotRed: c)))),
                _buildColorBox(context, 'Dot Yellow', config.terminalDotYellow, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalDotYellow: c)))),
                _buildColorBox(context, 'Dot Green', config.terminalDotGreen, true, (c) => context.read<AuthBloc>().add(UpdateAuthConfig(config.copyWith(terminalDotGreen: c)))),
              ]),
              const SizedBox(height: 64),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDropdown({required BuildContext context, required String title, required String value, required List<String> options, required ValueChanged<String> onChanged}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF1E1E1E),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClipboardSettingsTab extends StatelessWidget {
  const _ClipboardSettingsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClipboardBloc, ClipboardState>(
      builder: (context, state) {
        if (state is ClipboardLoading || state is ClipboardInitial) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFC084FC)));
        }

        if (state is ClipboardError) {
          return Center(child: Text('Error: ${state.message}', style: const TextStyle(color: Colors.redAccent)));
        }

        if (state is ClipboardLoaded) {
          final config = state.config;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            physics: const BouncingScrollPhysics(),
            children: [
              _buildSectionHeader('Settings', Icons.settings_rounded),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ghost Mode', style: TextStyle(color: Colors.white, fontSize: 16)),
                  Switch(
                    value: config.ghostMode,
                    activeThumbColor: const Color(0xFFC084FC),
                    onChanged: (val) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(ghostMode: val))),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              _buildSectionHeader('Window & General Colors', Icons.window_rounded),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Window Box Bg', config.windowBoxBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(windowBoxBg: c)))),
                _buildColorBox(context, 'Window Box Border', config.windowBoxBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(windowBoxBorder: c)))),
                _buildColorBox(context, 'Glass Panel Bg', config.glassPanelBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(glassPanelBg: c)))),
                _buildColorBox(context, 'Header Title', config.headerTitle, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(headerTitle: c)))),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader('Ghost Pill Colors', Icons.visibility_off_rounded),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Ghost Pill Bg', config.ghostPillBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(ghostPillBg: c)))),
                _buildColorBox(context, 'Ghost Pill Text', config.ghostPillText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(ghostPillText: c)))),
                _buildColorBox(context, 'Ghost Pill Border', config.ghostPillBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(ghostPillBorder: c)))),
                _buildColorBox(context, 'Ghost Active Text', config.ghostActiveText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(ghostActiveText: c)))),
                _buildColorBox(context, 'Ghost Active Bg', config.ghostActiveBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(ghostActiveBg: c)))),
                _buildColorBox(context, 'Ghost Active Border', config.ghostActiveBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(ghostActiveBorder: c)))),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader('Search Box Colors', Icons.search_rounded),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Search Box Bg', config.searchBoxBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(searchBoxBg: c)))),
                _buildColorBox(context, 'Search Box Border', config.searchBoxBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(searchBoxBorder: c)))),
                _buildColorBox(context, 'Search Box Text', config.searchBoxText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(searchBoxText: c)))),
                _buildColorBox(context, 'Search Box Focus Border', config.searchBoxFocusBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(searchBoxFocusBorder: c)))),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader('Tab Button Colors', Icons.tab_rounded),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Tab Btn Bg', config.tabBtnBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(tabBtnBg: c)))),
                _buildColorBox(context, 'Tab Btn Text', config.tabBtnText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(tabBtnText: c)))),
                _buildColorBox(context, 'Tab Btn Checked Bg', config.tabBtnCheckedBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(tabBtnCheckedBg: c)))),
                _buildColorBox(context, 'Tab Btn Checked Text', config.tabBtnCheckedText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(tabBtnCheckedText: c)))),
                _buildColorBox(context, 'Tab Btn Checked Border', config.tabBtnCheckedBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(tabBtnCheckedBorder: c)))),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader('Card Colors', Icons.content_copy_rounded),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Card Bg', config.cardBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(cardBg: c)))),
                _buildColorBox(context, 'Card Border', config.cardBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(cardBorder: c)))),
                _buildColorBox(context, 'Card Hover Border', config.cardHoverBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(cardHoverBorder: c)))),
                _buildColorBox(context, 'Card Text', config.cardText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(cardText: c)))),
                _buildColorBox(context, 'Card Code Text', config.cardCodeText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(cardCodeText: c)))),
                _buildColorBox(context, 'Meta Text', config.metaText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(metaText: c)))),
                _buildColorBox(context, 'Pin Flag Bg', config.pinFlagBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(pinFlagBg: c)))),
                _buildColorBox(context, 'Pin Flag Text', config.pinFlagText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(pinFlagText: c)))),
              ]),
              const SizedBox(height: 32),

              _buildSectionHeader('Menu Colors', Icons.menu_rounded),
              const SizedBox(height: 16),
              Wrap(spacing: 16, runSpacing: 16, children: [
                _buildColorBox(context, 'Menu Bg', config.menuBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(menuBg: c)))),
                _buildColorBox(context, 'Menu Border', config.menuBorder, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(menuBorder: c)))),
                _buildColorBox(context, 'Menu Item Text', config.menuItemText, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(menuItemText: c)))),
                _buildColorBox(context, 'Menu Item Hover Bg', config.menuItemHoverBg, true, (c) => context.read<ClipboardBloc>().add(UpdateClipboardConfig(config.copyWith(menuItemHoverBg: c)))),
              ]),
              const SizedBox(height: 64),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

Widget _buildSectionHeader(String title, IconData icon) {
  return Row(
    children: [
      Icon(icon, color: Colors.white70, size: 24),
      const SizedBox(width: 12),
      Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
      width: 150,
      padding: const EdgeInsets.all(12),
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
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
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
                        child: const Text('Cancel', style: TextStyle(color: Colors.white54, fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7EE0C9),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {
                          onColorChanged(currentColor);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Apply', style: TextStyle(fontWeight: FontWeight.bold)),
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
