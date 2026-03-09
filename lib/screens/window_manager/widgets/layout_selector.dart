import 'package:flutter/material.dart';
import 'package:antidote/core/glassmorphic_container.dart';

class LayoutSelector extends StatelessWidget {
  final String selectedLayout;
  final ValueChanged<String> onLayoutChanged;

  const LayoutSelector({
    super.key,
    required this.selectedLayout,
    required this.onLayoutChanged,
  });

  @override
  Widget build(BuildContext context) {
    final layouts = [
      ('Tiled', 'tiled'),
      ('Monocle', 'monocle'),
      ('Tall', 'tall'),
      ('RTall', 'rtall'),
      ('Wide', 'wide'),
      ('RWide', 'rwide'),
      ('Grid', 'grid'),
      ('RGrid', 'rgrid'),
      ('Even', 'even'),
    ];

    return GlassmorphicContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Layout Mode',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.5,
            ),
            itemCount: layouts.length,
            itemBuilder: (context, index) {
              final (label, value) = layouts[index];
              final isSelected = selectedLayout == value;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onLayoutChanged(value),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color.fromARGB(255, 64, 200, 255)
                                    .withAlpha((255 * 0.35).round()),
                                const Color.fromARGB(255, 100, 150, 255)
                                    .withAlpha((255 * 0.25).round()),
                              ],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? const Color.fromARGB(255, 64, 200, 255)
                                .withAlpha((255 * 0.6).round())
                            : Colors.white.withAlpha((255 * 0.1).round()),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? const Color.fromARGB(255, 120, 210, 255)
                              : Colors.white.withAlpha((255 * 0.7).round()),
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
  }
}
