import 'package:settings/core/appbar.dart';
import 'package:settings/core/venom_layout.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';
import 'package:settings/core/config/settings_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await VenomConfig().init();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 700),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const VenomLabApp());
}

class VenomLabApp extends StatelessWidget {
  const VenomLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
      ),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.transparent,
        brightness: Brightness.dark,
        canvasColor: Colors.transparent,
        cardColor: Colors.transparent,
        // ignore: deprecated_member_use
        dialogBackgroundColor: Colors.transparent,
      ),
      home: const SettingsHomePage(),
    );
  }
}

class SettingsHomePage extends StatefulWidget {
  const SettingsHomePage({super.key});

  @override
  State<SettingsHomePage> createState() => _SettingsHomePageState();
}

class _SettingsHomePageState extends State<SettingsHomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return VenomScaffold(
      appBar: Appbar(),
      backgroundColor: const Color.fromARGB(0, 0, 0, 0),
      body: Container(
        decoration: const BoxDecoration(color: Color.fromARGB(100, 0, 0, 0)),
        child: Row(
          children: [
            Container(
              width: 240,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.builder(
                      itemCount: settingsPages.length,
                      itemBuilder: (context, index) {
                        final item = settingsPages[index];
                        final isSelected = _selectedIndex == index;
                        return _buildNavItem(item, index, isSelected);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: settingsPages.map((e) => e.page).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(SettingsPageItem item, int index, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _selectedIndex = index),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color.fromARGB(
                          255,
                          64,
                          200,
                          255,
                        ).withAlpha((255 * 0.35).round()),
                        const Color.fromARGB(
                          255,
                          100,
                          150,
                          255,
                        ).withAlpha((255 * 0.25).round()),
                        const Color.fromARGB(
                          255,
                          80,
                          120,
                          220,
                        ).withAlpha((255 * 0.15).round()),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    )
                  : null,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: const Color.fromARGB(
                        255,
                        64,
                        200,
                        255,
                      ).withAlpha((255 * 0.6).round()),
                      width: 1.5,
                    )
                  : Border.all(
                      color: Colors.white.withAlpha((255 * 0.1).round()),
                      width: 1,
                    ),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  color: isSelected
                      ? const Color.fromARGB(255, 120, 210, 255)
                      : Colors.white.withAlpha((255 * 0.7).round()),
                  size: 22,
                ),
                const SizedBox(width: 14),
                Text(
                  item.label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withAlpha((255 * 0.8).round()),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
