import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:settings/features/keyboard_settings/keyboard_settings.dart';
import 'package:settings/screens/keyboard_settings/widgets/section_container.dart';
import 'package:settings/screens/keyboard_settings/widgets/clickable_item.dart';

class SpecialCharacterEntrySection extends StatelessWidget {
  const SpecialCharacterEntrySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KeyboardSettingsBloc, KeyboardSettingsState>(
      builder: (context, state) {
        return SectionContainer(
          title: 'Special Character Entry',
          subtitle:
              'Methods for entering symbols and letter variants using the keyboard',
          children: [
            ClickableItem(
              label: 'Alternate Characters Key',
              value: state.alternateCharactersKey,
              onTap: () {
                // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Alternate Characters Key settings - Coming soon',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            ClickableItem(
              label: 'Compose Key',
              value: state.composeKey,
              onTap: () {
                // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Compose Key settings - Coming soon'),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
