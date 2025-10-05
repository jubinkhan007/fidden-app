import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ReviewsShimmerList extends StatelessWidget {
  const ReviewsShimmerList({super.key, this.count = 8});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        children: List.generate(count, (i) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 40, height: 40, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(height: 14, width: 140, color: Colors.white),
                          const SizedBox(height: 8),
                          Container(height: 12, width: 200, color: Colors.white),
                          const SizedBox(height: 6),
                          Container(height: 12, width: 260, color: Colors.white),
                          const SizedBox(height: 12),
                          Container(height: 12, width: 100, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
