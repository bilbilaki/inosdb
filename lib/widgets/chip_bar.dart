// lib/widgets/chip_bar.dart
import 'package:flutter/material.dart';
import 'package:miko/utils/colors.dart';
//import 'package:myapp/utils/dummy_data.dart';

class ChipBar extends StatefulWidget {
  const ChipBar({super.key});

  @override
  State<ChipBar> createState() => _ChipBarState();
}

class _ChipBarState extends State<ChipBar> {
  String _selectedChip = 'All';
  final List<String> _chipLabels = getChipLabels();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      color: AppColors.primaryBackground,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        itemCount: _chipLabels.length,
        itemBuilder: (context, index) {
          final label = _chipLabels[index];
          final isSelected = label == _selectedChip;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedChip = label;
                  });
                  // TODO: Add filtering logic based on chip selection
                }
              },
              backgroundColor: AppColors.chipBackground,
              selectedColor: AppColors.chipBackgroundSelected,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.chipTextSelected : AppColors.chipText,
                fontWeight: FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.transparent) // No border
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
            ),
          );
        },
      ),
    );
  }
}

List<String> getChipLabels() {
  return ['All', 'Anime', 'TV Series', 'Movies'];
  
}