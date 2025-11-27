import 'package:flutter/material.dart';

class NicheDropdown extends StatelessWidget {
  final List<String> availableNiches;
  final String selectedNiche;
  final Function(String) onNicheChanged;

  const NicheDropdown({
    super.key,
    required this.availableNiches,
    required this.selectedNiche,
    required this.onNicheChanged,
  });

  @override
  Widget build(BuildContext context) {
    // If only one niche or none, don't show dropdown
    if (availableNiches.length <= 1) {
      if (availableNiches.isNotEmpty) {
        return Chip(
          label: Text(
            _getNicheLabel(availableNiches.first),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          avatar: Text(_getNicheIcon(availableNiches.first)),
        );
      }
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: availableNiches.contains(selectedNiche) ? selectedNiche : null,
          hint: const Text("Select View"),
          isDense: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black87),
          items: availableNiches.map((String niche) {
            return DropdownMenuItem<String>(
              value: niche,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getNicheIcon(niche), style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    _getNicheLabel(niche),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              onNicheChanged(newValue);
            }
          },
        ),
      ),
    );
  }

  String _getNicheLabel(String niche) {
    switch (niche) {
      case 'tattoo_artist':
        return 'Tattoo Artist';
      case 'barber':
        return 'Barber';
      case 'fitness_trainer':
        return 'Fitness Trainer';
      case 'hairstylist':
        return 'Hairstylist';
      case 'nail_tech':
        return 'Nail Tech';
      case 'makeup_artist':
        return 'Makeup Artist';
      case 'esthetician':
        return 'Esthetician';
      case 'massage_therapist':
        return 'Massage Therapist';
      default:
        return 'Other';
    }
  }

  String _getNicheIcon(String niche) {
    switch (niche) {
      case 'tattoo_artist':
        return '🖋️';
      case 'barber':
        return '✂️';
      case 'fitness_trainer':
        return '🏋️';
      case 'hairstylist':
        return '💇';
      case 'nail_tech':
        return '💅';
      case 'makeup_artist':
        return '💄';
      case 'esthetician':
        return '🧖';
      case 'massage_therapist':
        return '🌿';
      default:
        return '🏪';
    }
  }
}
