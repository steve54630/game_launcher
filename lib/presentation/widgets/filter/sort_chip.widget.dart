import 'package:flutter/material.dart';
import 'package:game_launcher/core/extensions.dart';

class SortChoiceChip extends StatelessWidget {
  final String label;
  final LibrarySortType value;
  final LibrarySortType currentValue;
  final Function(LibrarySortType) onSelected;

  const SortChoiceChip({
    super.key,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: value == currentValue,
      onSelected: (selected) {
        if (selected) onSelected(value);
      },
    );
  }
}
