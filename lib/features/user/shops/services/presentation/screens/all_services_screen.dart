// lib/features/user/shops/services/presentation/screens/all_services_screen.dart

import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/user/shops/data/shop_details_model.dart';
import 'package:fidden/features/user/shops/services/controller/all_services_controller.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/service_details_screen.dart'; // Import the details screen
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../../../core/utils/constants/app_sizes.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllServicesController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: CustomText(
          text: "All Services",
          fontSize: getWidth(20),
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _SearchBar(
              controller: controller.searchController,
              onChanged: (q) {
                // The controller's listener already handles the debounce logic
              },
              onFilterTap: () {
                // Hook up a bottom sheet or filter page
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  (controller.allServices.value.results ?? []).isEmpty) {
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, __) => const _ShimmerCard(),
                );
              }

              final results = controller.allServices.value.results;
              if (results == null || results.isEmpty) {
                return const Center(
                  child: CustomText(
                    text: "No services found",
                    fontWeight: FontWeight.w600,
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final service = results[index];

                  final imageUrl =
                      (service.serviceImg != null &&
                          service.serviceImg!.isNotEmpty)
                      ? service.serviceImg!
                      : service.randomPlaceholderImage;

                  final rating = (service.avgRating ?? 0).toDouble();
                  final reviewCount = service.reviewCount ?? 0;

                  final hasDiscount =
                      (service.discountPrice != null &&
                      service.discountPrice != "0.00");
                  final displayPrice = hasDiscount
                      ? service.discountPrice
                      : service.price;
                  final originalPrice = hasDiscount ? service.price : null;

                  return _ServiceCard(
                    heroTag: 'service_${service.id ?? index}',
                    imageUrl: imageUrl,
                    title: service.title ?? '',
                    address: service.shopAddress ?? '',
                    rating: rating,
                    reviewCount: reviewCount,
                    price: displayPrice?.toString(),
                    originalPrice: originalPrice?.toString(),
                    isFavorite: service.isFavorite ?? false,
                    badge: service.badge,
                    // --- 🚀 CHANGE IS HERE ---
                    onTap: () {
                      if (service.id != null) {
                        // Navigate to the Service Details Screen
                        Get.to(
                          () => ServiceDetailsScreen(serviceId: service.id!),
                          transition: Transition.cupertino,
                        );
                      }
                    },
                    onFavoriteToggle: () {
                      // Hook to your favorite toggle
                      // controller.toggleFavorite(service.id)
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// pill search with a filter button
class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Search for services...',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.black.withOpacity(0.6),
                  width: 1.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onFilterTap,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

/// Modern service card
class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.heroTag,
    required this.imageUrl,
    required this.title,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.price,
    required this.originalPrice,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
    this.badge,
  });

  final String heroTag;
  final String imageUrl;
  final String title;
  final String address;
  final double rating;
  final int reviewCount;
  final String? price;
  final String? originalPrice;
  final bool isFavorite;
  final String? badge;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 8),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Column(
            children: [
              // Image with gradient + top badges
              Stack(
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) =>
                              Container(color: const Color(0xFFEFF1F5)),
                          errorWidget: (_, __, ___) =>
                              Container(color: const Color(0xFFEFF1F5)),
                        ),
                      ),
                    ),
                  ),

                  // Gradient overlay bottom
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Badge (e.g., "Popular", "Trending")
                  if (badge != null && badge!.trim().isNotEmpty)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _ChipBadge(text: badge!),
                    ),

                  // Favorite button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _FavButton(
                      isActive: isFavorite,
                      onTap: onFavoriteToggle,
                    ),
                  ),

                  // Price pill bottom-right
                  if (price != null)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: _PricePill(
                        price: price!,
                        originalPrice: originalPrice,
                      ),
                    ),
                ],
              ),

              // Text content
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: title,
                      fontSize: getWidth(18),
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.place_rounded,
                          size: 18,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        // Rating stars + score
                        RatingBarIndicator(
                          rating: rating.clamp(0, 5),
                          itemBuilder: (_, __) => const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFC107),
                          ),
                          itemSize: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${rating.toStringAsFixed(1)}  ·  $reviewCount reviews',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        // “View” affordance
                        Row(
                          children: [
                            Text(
                              // --- 🚀 CHANGE IS HERE ---
                              'View Service', // Changed from 'View Shop'
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black.withOpacity(0.85),
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Price pill (supports strikethrough original)
class _PricePill extends StatelessWidget {
  const _PricePill({required this.price, this.originalPrice});
  final String price;
  final String? originalPrice;

  @override
  Widget build(BuildContext context) {
    final hasOriginal =
        originalPrice != null && originalPrice!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            '\$$price',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
          ),
          if (hasOriginal) ...[
            const SizedBox(width: 8),
            Text(
              '\$$originalPrice',
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.grey.shade600,
                decoration: TextDecoration.lineThrough,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Floating favorite button
class _FavButton extends StatelessWidget {
  const _FavButton({required this.isActive, required this.onTap});
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.9),
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            isActive ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isActive ? Colors.red : Colors.black,
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// Soft badge chip
class _ChipBadge extends StatelessWidget {
  const _ChipBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3CD),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: const Color(0xFFFFE08A)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
          color: Color(0xFF6B4E00),
          height: 1.1,
        ),
      ),
    );
  }
}

/// Polished shimmer placeholder
class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EBF1),
      highlightColor: const Color(0xFFF6F8FC),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _shimmerBar(width: 180, height: 20),
                  const SizedBox(height: 10),
                  _shimmerBar(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _shimmerBar(width: 90, height: 14),
                      const Spacer(),
                      _shimmerBar(width: 50, height: 14),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}
