import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../dashboard_controller.dart';

class ContextChips extends StatelessWidget {
  const ContextChips({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    return SizedBox(
      height: 50,
      child: Obx(() {
        final chips = controller.availableChips;
        final selectedChip = controller.selectedChip.value; // Access here to register dependency

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final chip = chips[index];
            // print('Building chip: $chip, selected: $selectedChip'); // DEBUG
            final isSelected = selectedChip == chip;
            
            return ChoiceChip(
              key: ValueKey(chip),
              label: Text(chip),
              selected: isSelected,
              onSelected: (bool selected) {
                // print('Chip tapped: $chip, selected: $selected'); // DEBUG
                if (selected) {
                  controller.selectChip(chip);
                }
              },
              selectedColor: Colors.black,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Colors.grey, width: 0.5),
              ),
              showCheckmark: false,
            );
          },
        );
      }),
    );
  }
}
