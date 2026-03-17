import 'package:flutter/material.dart';
import 'package:settings/features/keyboard_settings/keyboard_settings.dart';

class AddInputSourceDialog extends StatefulWidget {
  final List<InputSource> availableSources;
  final List<InputSource> currentSources;
  final Function(InputSource) onAdd;

  const AddInputSourceDialog({
    super.key,
    required this.availableSources,
    required this.currentSources,
    required this.onAdd,
  });

  @override
  State<AddInputSourceDialog> createState() => _AddInputSourceDialogState();
}

class _AddInputSourceDialogState extends State<AddInputSourceDialog> {
  String _searchQuery = '';
  InputSource? _selectedSource;

  List<InputSource> get _filteredSources {
    if (_searchQuery.isEmpty) {
      return widget.availableSources;
    }
    return widget.availableSources
        .where(
          (source) =>
              source.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              source.id.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color.fromARGB(255, 18, 22, 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 500,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Add Input Source',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _selectedSource != null
                      ? () => widget.onAdd(_selectedSource!)
                      : null,
                  child: Text(
                    'Add',
                    style: TextStyle(
                      color: _selectedSource != null
                          ? Colors.blueAccent
                          : Colors.white38,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Language or country',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                itemCount: _filteredSources.length,
                itemBuilder: (context, index) {
                  final source = _filteredSources[index];
                  final isSelected =
                      _selectedSource?.id == source.id &&
                      _selectedSource?.type == source.type;
                  final isAlreadyAdded = widget.currentSources.any(
                    (s) => s.id == source.id && s.type == source.type,
                  );

                  return InkWell(
                    onTap: isAlreadyAdded
                        ? null
                        : () => setState(() => _selectedSource = source),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.blueAccent.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              source.name,
                              style: TextStyle(
                                color: isAlreadyAdded
                                    ? Colors.white38
                                    : Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          if (isAlreadyAdded)
                            const Text(
                              '(Already added)',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
