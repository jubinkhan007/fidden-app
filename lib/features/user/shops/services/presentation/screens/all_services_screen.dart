// lib/features/user/shops/services/presentation/screens/all_services_screen.dart

import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/user/shops/data/shop_details_model.dart';
import 'package:fidden/features/user/shops/services/controller/all_services_controller.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/service_details_screen.dart'; // Import the details screen
import 'package:fidden/features/user/shops/services/presentation/screens/service_filter_screen.dart';
import 'package:fidden/features/user/shops/widgets/fav_button.dart';
import 'package:fidden/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:fidden/features/user/wishlist/data/wishlist_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../../../../core/utils/constants/app_sizes.dart';

class AllServicesScreen extends StatelessWidget {
  const AllServicesScreen({super.key, this.categoryId, this.categoryName});
  final int? categoryId;
  final String? categoryName;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AllServicesController());

    // This callback ensures the controller's state is updated every time this screen is shown.
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   controller.filterByCategory(categoryId);
    // });

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
        // ---  DYNAMICALLY SET TITLE ---
        title: CustomText(
          text: categoryName ?? "All Services", // Use category name if provided
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
              onChanged: (_) {}, // debounce handled in controller
              onFilterTap: () async {
                final f = controller.filters;
                final Map<String, dynamic>? result = await Get.to(
                      () => ServiceFilterScreen(
                    initialCategoryId: f['category'] as int?,
                    initialMinPrice: f['min_price'] as int?,
                    initialMaxPrice: f['max_price'] as int?,
                    initialDuration: f['duration'] as int?,
                    initialDistance: f['distance'] as int?,
                    initialRating: (f['rating'] as num?)?.toDouble(),
                    sliderMin: 0, sliderMax: 500,
                  ),
                  transition: Transition.downToUp,
                );
                if (result != null) {
                  if (result['__reset'] == true) {
                    await controller.clearFilters();
                  } else {
                    result.removeWhere((k, v) => v == null);
                    await controller.applyFilters(result);
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: Obx(() {
              final hasData = controller.hasLocalData;
              final results = controller.allServices.value.results ?? const [];

              // 1) No cache yet + fetching => shimmer
              if (!hasData && controller.isLoading.value) {
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: 6,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (_, __) => const _ShimmerCard(),
                );
              }

              // 2) After load finished, still empty => true empty state
              if (!controller.isLoading.value && results.isEmpty) {
                return const Center(
                  child: CustomText(
                    text: "No services found",
                    fontWeight: FontWeight.w600,
                  ),
                );
              }

              // 3) Normal list (will also show cached data while fetching fresh)
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: results.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final service = results[index];
                  // ... existing card building code unchanged ...
                  // (keep your _ServiceCard usage)
                  final imageUrl = (service.serviceImg != null && service.serviceImg!.isNotEmpty)
                      ? service.serviceImg!
                      : service.randomPlaceholderImage;
                  final rating = (service.avgRating ?? 0).toDouble();
                  final reviewCount = service.reviewCount ?? 0;
                  final hasDiscount = (service.discountPrice != null && service.discountPrice != "0.00");
                  final displayPrice = hasDiscount ? service.discountPrice : service.price;
                  final originalPrice = hasDiscount ? service.price : null;
                  final distanceKm = service.distance;
                  final String? distanceLabel = (distanceKm != null)
                      ? '${distanceKm.toStringAsFixed(1)} km' : null;

                  return _ServiceCard(
                    service: service,
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
                    distanceLabel: distanceLabel,
                    onTap: () {
                      if (service.id != null) {
                        Get.to(() => ServiceDetailsScreen(serviceId: service.id!),
                            transition: Transition.cupertino);
                      }
                    },
                    onFavoriteToggle: () {},
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
    required this.service,
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
    this.distanceLabel,
  });

  final dynamic service;
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
  final String? distanceLabel;

  @override
  Widget build(BuildContext context) {
    final wishlistController =
        Get.find<WishlistController>(); //  Get the controller

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
                    child: Obx(() {
                      final isFavorite = wishlistController.isServiceFavorite(
                        service.id!,
                      );
                      return FavButton(
                        isActive: isFavorite,
                        onTap: () {
                          final favoriteService = FavoriteService(
                            id: service.id,
                            title: service.title,
                            price: service.price,
                            serviceImg: service.serviceImg,
                            shopAddress: service.shopAddress,
                          );
                          wishlistController.toggleServiceFavoriteByServiceId(
                            service.id,
                          );
                        },
                      );
                    }),
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

                        if (distanceLabel != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            distanceLabel!,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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
                              // ---  CHANGE IS HERE ---
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

  // Safe numeric parser: strips currency/commas & parses
  double? _toDouble(String? s) {
    if (s == null) return null;
    final cleaned = s.replaceAll(RegExp(r'[^0-9.\-]'), '');
    return double.tryParse(cleaned);
  }

  @override
  Widget build(BuildContext context) {
    final p = _toDouble(price);
    final o = _toDouble(originalPrice);

    // show original only when it's a valid number and strictly greater than price
    final showOriginal = (p != null && o != null && o > p);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            // keep original string for display, or format p if you prefer
            '\$$price',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
          ),
          if (showOriginal) ...[
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
