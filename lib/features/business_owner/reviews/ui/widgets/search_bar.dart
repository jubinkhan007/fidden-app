import 'package:flutter/material.dart';

// ReviewsSearchBar.dart
class ReviewsSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final TextEditingController controller; // ⬅️ add

  const ReviewsSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.onClear,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // ... your decoration
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller, // ⬅️ use injected controller
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
              onChanged: onChanged,
            ),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
            onPressed: () {
              controller.clear();
              onClear();
              onChanged('');
            },
          ),
        ],
      ),
    );
  }
}
