import 'package:flutter/material.dart';
import 'package:antidote/core/glassmorphic_container.dart';

class WindowCommandButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const WindowCommandButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: Colors.white.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WindowCommandsSection extends StatelessWidget {
  final VoidCallback onFocusNext;
  final VoidCallback onFocusPrev;
  final VoidCallback onSwapWindowNext;
  final VoidCallback onSwapWindowPrev;
  final VoidCallback onToggleFloating;
  final VoidCallback onBalanceWindows;

  const WindowCommandsSection({
    super.key,
    required this.onFocusNext,
    required this.onFocusPrev,
    required this.onSwapWindowNext,
    required this.onSwapWindowPrev,
    required this.onToggleFloating,
    required this.onBalanceWindows,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Window Commands',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _CommandGroup(
            title: 'Focus Navigation',
            children: [
              WindowCommandButton(
                label: 'Next Window',
                icon: Icons.arrow_forward_rounded,
                onPressed: onFocusNext,
              ),
              const SizedBox(width: 8),
              WindowCommandButton(
                label: 'Prev Window',
                icon: Icons.arrow_back_rounded,
                onPressed: onFocusPrev,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CommandGroup(
            title: 'Window Management',
            children: [
              WindowCommandButton(
                label: 'Swap Next',
                icon: Icons.swap_horiz_rounded,
                onPressed: onSwapWindowNext,
              ),
              const SizedBox(width: 8),
              WindowCommandButton(
                label: 'Swap Prev',
                icon: Icons.swap_horiz_rounded,
                onPressed: onSwapWindowPrev,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CommandGroup(
            title: 'Layout Control',
            children: [
              WindowCommandButton(
                label: 'Toggle Floating',
                icon: Icons.layers_rounded,
                onPressed: onToggleFloating,
              ),
              const SizedBox(width: 8),
              WindowCommandButton(
                label: 'Balance Windows',
                icon: Icons.space_dashboard_rounded,
                onPressed: onBalanceWindows,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CommandGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _CommandGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: children,
        ),
      ],
    );
  }
}
