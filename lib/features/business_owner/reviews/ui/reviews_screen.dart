// lib/features/business_owner/reviews/presentation/reviews_screen.dart
import 'package:fidden/features/business_owner/reviews/state/review_controller.dart';
import 'package:fidden/features/business_owner/reviews/state/reviews_filter_controller.dart';
import 'package:fidden/features/business_owner/reviews/utils/review_filters.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bottom_sheets/reviews_filter_sheet.dart';
import 'widgets/chips_bar.dart';
import 'widgets/loading_empty.dart';
import 'widgets/review_card.dart';
import 'widgets/search_bar.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key, required this.shopId});
  final String shopId;

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ReviewController());
    final f = Get.put(ReviewsFilterController());

    // fetch once
    WidgetsBinding.instance.addPostFrameCallback((_) => c.fetchReviews(shopId));

    // build service options when reviews change
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

      // ⬇️ No Obx here — the shell never rebuilds
      body: RefreshIndicator(
        onRefresh: () => c.fetchReviews(shopId),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Static header: always stays in the tree
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: ReviewsSearchBar(
                  controller: f.searchCtrl,
                  hint: 'Search by name, service, comment…',
                  onChanged: (t) {
                    f.query.value = t;
                    c.search(shopId, t);
                  },
                  onClear: () {
                    f.query.value = '';
                    c.search(shopId, '');
                  },
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

            // ⬇️ Only the list area reacts to changes
            Obx(() {
              // thin top progress indicator while fetching, without nuking UI
              final loadingBar = c.isLoading.value
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    )
                  : const SliverToBoxAdapter(child: SizedBox.shrink());

              if (c.reviews.isEmpty && !c.isLoading.value) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: const ReviewsEmptyState(
                      title: 'No reviews yet',
                      subtitle: "You'll see new reviews from customers here.",
                    ),
                  ),
                );
              }

              final filtered = applyReviewFilters(reviews: c.reviews, f: f);

              if (!c.isLoading.value && filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: const ReviewsEmptyState(
                      title: 'No results',
                      subtitle:
                          'Try adjusting your search or clearing filters.',
                    ),
                  ),
                );
              }

              return SliverList(
                // include the loading bar as a first item when loading
                delegate: SliverChildListDelegate([
                  if (c.isLoading.value) const SizedBox(height: 2),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: List.generate(
                        filtered.length,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ReviewCard(review: filtered[i]),
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            }),
          ],
        ),
      ),
    );
  }
}
