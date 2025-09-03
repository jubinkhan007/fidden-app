import 'package:flutter/material.dart';

class ReviewsSearchBar extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const ReviewsSearchBar({
    super.key,
    required this.hint,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<ReviewsSearchBar> createState() => _ReviewsSearchBarState();
}

class _ReviewsSearchBarState extends State<ReviewsSearchBar> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: widget.hint,
                border: InputBorder.none,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.close, size: 18, color: Color(0xFF94A3B8)),
            onPressed: () {
              controller.clear();
              widget.onClear();
              widget.onChanged('');
            },
          ),
        ],
      ),
    );
  }
}
