import 'package:fidden/features/business_owner/profile/controller/review_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../state/reviews_filter_controller.dart';
import '../utils/review_filters.dart';
import 'bottom_sheets/reviews_filter_sheet.dart';
import 'widgets/chips_bar.dart';
import 'widgets/loading_empty.dart';
import 'widgets/review_card.dart';
import 'widgets/search_bar.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReviewController());
    final f = Get.put(ReviewsFilterController());

    // Seed service options NOW from your loaded reviews (until API arrives).
    // Later: replace this with API-driven service list.
    ever(c.reviews, (_) {
      final names =
          c.reviews
              .map((e) => e.serviceName.trim())
              .where((e) => e.isNotEmpty)
              .toSet()
              .toList()
            ..sort();
      f.serviceOptions.assignAll(
        names.map((n) => ServiceOption(id: n, name: n)),
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Reviews'),
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Filters',
            icon: const Icon(Icons.tune),
            onPressed: () => openReviewsFilterSheet(f, context),
          ),
        ],
      ),
      body: Obx(() {
        if (c.isLoading.value) return const ReviewsLoadingList();
        if (c.reviews.isEmpty) {
          return const ReviewsEmptyState(
            title: 'No reviews yet',
            subtitle: 'You’ll see new reviews from customers here.',
          );
        }

        final filtered = applyReviewFilters(reviews: c.reviews, f: f);

        return RefreshIndicator(
          onRefresh: () async => c.fetchReviews?.call(), // keep if you add it
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: ReviewsSearchBar(
                    hint: 'Search by name, service, comment…',
                    onChanged: (t) => f.query.value = t,
                    onClear: () => f.query.value = '',
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: ReviewsChipsBar(
                  filters: f,
                  onTapFilterSheet: () => openReviewsFilterSheet(f, context),
                  onClearDates: () {
                    f.dateFrom.value = null;
                    f.dateTo.value = null;
                  },
                ),
              ),
              if (filtered.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: ReviewsEmptyState(
                      title: 'No results',
                      subtitle:
                          'Try adjusting your search or clearing filters.',
                    ),
                  ),
                )
              else
                SliverList.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => ReviewCard(review: filtered[i]),
                ),
            ],
          ),
        );
      }),
    );
  }
}
