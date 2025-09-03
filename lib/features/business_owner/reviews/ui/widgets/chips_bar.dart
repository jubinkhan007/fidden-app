import 'package:fidden/features/business_owner/reviews/state/reviews_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ReviewsChipsBar extends StatelessWidget {
  const ReviewsChipsBar({
    super.key,
    required this.filters,
    required this.onTapFilterSheet,
    required this.onClearDates,
  });

  final ReviewsFilterController filters;
  final VoidCallback onTapFilterSheet;
  final VoidCallback onClearDates;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MMM d');
    return Obx(() {
      final svc = filters.selectedServiceName.value;
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _chip(
              icon: Icons.design_services,
              label: svc.isEmpty ? 'Any service' : svc,
            ),
            _chip(
              icon: Icons.star_rounded,
              label: filters.minRating.value == 0
                  ? 'Any rating'
                  : '≥ ${filters.minRating.value}.0',
            ),
            _chip(
              icon: filters.hasReplyOnly.value
                  ? Icons.mark_chat_read
                  : Icons.mark_chat_unread_outlined,
              label: filters.hasReplyOnly.value ? 'Has reply' : 'All replies',
            ),
            _chip(icon: Icons.sort, label: _sortLabel(filters.sort.value)),

            GestureDetector(
              onTap: onTapFilterSheet,
              child: Chip(
                avatar: const Icon(Icons.tune, size: 18),
                label: Text(
                  (filters.dateFrom.value == null &&
                          filters.dateTo.value == null)
                      ? 'More filters'
                      : '${filters.dateFrom.value != null ? fmt.format(filters.dateFrom.value!) : 'Any'} – ${filters.dateTo.value != null ? fmt.format(filters.dateTo.value!) : 'Any'}',
                ),
                shape: const StadiumBorder(
                  side: BorderSide(color: Color(0xFFE2E8F0)),
                ),
                backgroundColor: Colors.white,
              ),
            ),
            if (filters.dateFrom.value != null || filters.dateTo.value != null)
              ActionChip(
                avatar: const Icon(Icons.clear, size: 18),
                label: const Text('Clear dates'),
                onPressed: onClearDates,
              ),
          ],
        ),
      );
    });
  }

  Widget _chip({required IconData icon, required String label}) => Chip(
    avatar: Icon(icon, size: 18, color: const Color(0xFF334155)),
    label: Text(label),
    backgroundColor: Colors.white,
    shape: const StadiumBorder(side: BorderSide(color: Color(0xFFE2E8F0))),
  );

  String _sortLabel(ReviewsSort s) {
    switch (s) {
      case ReviewsSort.newest:
        return 'Newest';
      case ReviewsSort.oldest:
        return 'Oldest';
      case ReviewsSort.highest:
        return 'Highest rating';
      case ReviewsSort.lowest:
        return 'Lowest rating';
    }
  }
}
