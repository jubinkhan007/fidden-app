import 'package:fidden/features/business_owner/reviews/state/reviews_filter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> openReviewsFilterSheet(
  ReviewsFilterController f,
  BuildContext context,
) async {
  await Get.bottomSheet(
    SafeArea(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Obx(() {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 4,
                width: 48,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const Text(
                'Filters',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 14),

              // Service dropdown (by name for now)
              Row(
                children: [
                  const Text(
                    'Service',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  DropdownButton<String>(
                    value: f.selectedServiceName.value.isEmpty
                        ? null
                        : f.selectedServiceName.value,
                    hint: const Text('Any'),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Any')),
                      ...f.serviceOptions.map(
                        (s) => DropdownMenuItem(
                          value: s.name,
                          child: Text(s.name),
                        ),
                      ),
                    ],
                    onChanged: (v) => f.selectedServiceName.value = v ?? '',
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Min rating
              Row(
                children: [
                  const Text(
                    'Min rating',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  DropdownButton<int>(
                    value: f.minRating.value,
                    onChanged: (v) => f.minRating.value = v ?? 0,
                    items: [0, 1, 2, 3, 4, 5]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e == 0 ? 'Any' : '$e.0+'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Has reply
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: f.hasReplyOnly.value,
                onChanged: (v) => f.hasReplyOnly.value = v,
                title: const Text('Has reply only'),
              ),

              // Sort
              Row(
                children: [
                  const Text(
                    'Sort by',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  DropdownButton<ReviewsSort>(
                    value: f.sort.value,
                    onChanged: (v) => f.sort.value = v ?? ReviewsSort.newest,
                    items: ReviewsSort.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(_sortLabel(e)),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Dates
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: Text(f.formatDate(f.dateFrom.value)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2018),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDate: f.dateFrom.value ?? DateTime.now(),
                        );
                        if (picked != null) f.dateFrom.value = picked;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_month),
                      label: Text(f.formatDate(f.dateTo.value)),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2018),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                          initialDate: f.dateTo.value ?? DateTime.now(),
                        );
                        if (picked != null) f.dateTo.value = picked;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        f.query.value = '';
                        f.minRating.value = 0;
                        f.hasReplyOnly.value = false;
                        f.sort.value = ReviewsSort.newest;
                        f.dateFrom.value = null;
                        f.dateTo.value = null;
                        f.selectedServiceName.value = '';
                        Get.back();
                      },
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    ),
  );
}

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
