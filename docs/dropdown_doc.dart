import 'package:animated_custom_dropdown/custom_dropdown.dart' as dropdown;
import 'package:flutter/material.dart';

class UserModel with dropdown.CustomDropdownListFilter {
  const UserModel({required this.name, required this.email});

  final String name;
  final String email;

  @override
  String toString() => name;

  @override
  bool filter(String query) => name.toLowerCase().contains(query.toLowerCase());
}

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({
    super.key,
    this.options = const [
      UserModel(name: 'Ava Johnson', email: 'ava@example.com'),
      UserModel(name: 'Noah Williams', email: 'noah@example.com'),
      UserModel(name: 'Mia Chen', email: 'mia@example.com'),
      UserModel(name: 'Liam Patel', email: 'liam@example.com'),
      UserModel(name: 'Sophia Garcia', email: 'sophia@example.com'),
      UserModel(name: 'Oliver Smith', email: 'oliver@example.com'),
    ],
    this.initialSelection = const [],
    this.onChanged,
  });

  final List<UserModel> options;
  final List<UserModel> initialSelection;
  final ValueChanged<List<UserModel>>? onChanged;

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  late List<UserModel> _selectedItems;

  @override
  void initState() {
    super.initState();
    _selectedItems = widget.initialSelection
        .where(widget.options.contains)
        .toSet()
        .toList();
  }

  void _updateSelection(List<UserModel> items) {
    setState(() {
      _selectedItems = items;
    });
    widget.onChanged?.call(List.unmodifiable(_selectedItems));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Searchable multi-select')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              elevation: 0,
              color: colors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: colors.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Choose users',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Search names and select one or more users.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    dropdown.CustomDropdown<UserModel>.multiSelectSearch(
                      key: const ValueKey('user-dropdown'),
                      items: widget.options,
                      initialItems: _selectedItems,
                      onListChanged: _updateSelection,
                      hintText: 'Select one or more users',
                      labelText: 'Users',
                      searchHintText: 'Search user names...',
                      overlayHeight: 360,
                      decoration: dropdown.CustomDropdownDecoration(
                        closedFillColor: colors.surface,
                        expandedFillColor: colors.surface,
                        closedBorderRadius: BorderRadius.circular(14),
                        expandedBorderRadius: BorderRadius.circular(14),
                        closedBorder: Border.all(color: colors.outlineVariant),
                        expandedBorder: Border.all(color: colors.primary),
                        searchFieldDecoration: dropdown.SearchFieldDecoration(
                          prefixIcon: Icon(
                            Icons.search,
                            color: colors.onSurfaceVariant,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: colors.outlineVariant,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(color: colors.primary),
                          ),
                        ),
                      ),
                    ),
                    if (_selectedItems.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_selectedItems.length} '
                                  '${_selectedItems.length == 1 ? 'user' : 'users'} selected',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _updateSelection([]),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
