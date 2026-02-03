import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/user/shops/presentation/screens/shop_details_screen.dart';
import 'package:fidden/features/user/shops/controller/all_shops_controller.dart';
import 'package:fidden/features/user/shops/widgets/fav_button.dart';
import 'package:fidden/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:fidden/features/user/wishlist/data/wishlist_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/utils/constants/app_sizes.dart';

class AllShopsScreen extends StatefulWidget {
  const AllShopsScreen({super.key});

  @override
  State<AllShopsScreen> createState() => _AllShopsScreenState();
}

class _AllShopsScreenState extends State<AllShopsScreen> {
  final controller = Get.put(AllShopsController());
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // kick off first load
    controller.fetchAllShops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      controller.searchShops(query); // will call fetchAllShops(query: q)
    });
  }

  /// Build verification badge based on shop status
  Widget _buildVerificationBadge(String status) {
    IconData icon;
    String label;
    Color bgColor;
    Color iconColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
        icon = Icons.verified;
        label = 'Verified';
        bgColor = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF16A34A);
        textColor = const Color(0xFF166534);
        break;
      case 'unverified':
        icon = Icons.info_outline;
        label = 'Unverified';
        bgColor = const Color(0xFFFEF3C7);
        iconColor = const Color(0xFFF59E0B);
        textColor = const Color(0xFF92400E);
        break;
      case 'pending':
        icon = Icons.hourglass_top;
        label = 'Pending';
        bgColor = const Color(0xFFF3F4F6);
        iconColor = const Color(0xFF6B7280);
        textColor = const Color(0xFF374151);
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: iconColor),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistController =
        Get.find<WishlistController>(); //  Get the controller

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: CustomText(
          text: "All Shops",
          fontSize: getWidth(20),
          fontWeight: FontWeight.w700,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                suffixIcon: (_searchController.text.isNotEmpty)
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          controller.searchShops(''); // resets list
                          setState(() {}); // to rebuild and hide the clear icon
                        },
                      )
                    : null,
                hintText: "Search shops...",
                prefixIcon: const Icon(Icons.search),
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
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final hasData = controller.hasLocalData;
              final items = controller.allShops.value.shops ?? const [];

              // 1) No cache yet + loading => shimmer
              if (!hasData && controller.isLoading.value) {
                return _buildShimmerEffect();
              }

              // 2) Finished loading and still empty => true empty state
              if (!controller.isLoading.value && items.isEmpty) {
                return const Center(child: CustomText(text: "No shops found"));
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final shop = controller.allShops.value.shops![index];
                  final badgeText =
                      (shop.badge != null && shop.badge!.trim().isNotEmpty)
                      ? shop.badge!.trim()
                      : null;
                  final fav = shop.isFavorite ?? false;
                  final imageUrl =
                      (shop.shop_img != null &&
                          shop.shop_img!.trim().isNotEmpty)
                      ? shop.shop_img!
                      : "https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D";

                  return GestureDetector(
                    onTap: () {
                      if (shop.id != null) {
                        Get.to(
                          () => ShopDetailsScreen(id: shop.id!.toString()),
                        );
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(18),
                                  topRight: Radius.circular(18),
                                ),
                                child: Container(
                                  height: 155, // Reduced ~15% from 180
                                  width: double.infinity,
                                  color: const Color(
                                    0xFFF0F4F8,
                                  ), // Light background for logos
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit
                                        .contain, // Changed from cover to contain
                                    placeholder: (_, __) =>
                                        Container(color: Colors.grey[200]),
                                    errorWidget: (_, __, ___) => Image.network(
                                      "https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),

                              // Badge
                              if (badgeText != null)
                                Positioned(
                                  top: 12,
                                  left: 12,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Text(
                                      badgeText, // ✅ from API
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Colors.deepOrange,
                                      ),
                                    ),
                                  ),
                                ),

                              // Favorite
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Obx(() {
                                  final isFavorite = wishlistController
                                      .isShopFavorite(shop.id!);
                                  return FavButton(
                                    isActive: isFavorite,
                                    onTap: () {
                                      final favoriteShop = FavoriteShop(
                                        id: shop.id,
                                        name: shop.name,
                                        address: shop.address,
                                        shopImg: shop.shop_img,
                                      );
                                      wishlistController
                                          .toggleShopFavoriteByShopId(shop.id!);
                                    },
                                  );
                                }),
                              ),
                            ],
                          ),
                          // Info
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomText(
                                        text: shop.name ?? '',
                                        fontSize: getWidth(18),
                                        fontWeight: FontWeight.bold,
                                        maxLines: 1,
                                        textOverflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (shop.status != null &&
                                        shop.status!.isNotEmpty)
                                      _buildVerificationBadge(shop.status!),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                CustomText(
                                  text: shop.address ?? '',
                                  color: Colors.grey.shade700,
                                  fontSize: 14,
                                  maxLines: 1,
                                  textOverflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    // Show rating with star OR "New" badge - never 0.0
                                    ...() {
                                      final hasReviews = (shop.reviewCount ?? 0) > 0;
                                      final rating = shop.avgRating ?? 0.0;
                                      final showRating = hasReviews && rating > 0;

                                      if (showRating) {
                                        return [
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${rating.toStringAsFixed(1)} (${shop.reviewCount})",
                                            style: TextStyle(
                                              color: Colors.grey.shade800,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ];
                                      } else {
                                        // Show "New" badge only - no "0.0" or "No reviews yet"
                                        return [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE8F5E9),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'New',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF2E7D32),
                                              ),
                                            ),
                                          ),
                                        ];
                                      }
                                    }(),
                                    const Spacer(),
                                    // Distance in miles format: "X.X mi"
                                    if (controller.isLocationAvailable.value &&
                                        shop.distance != null &&
                                        shop.distance! > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(
                                            100,
                                          ),
                                        ),
                                        child: Text(
                                          // Convert km to miles (1 km = 0.621371 mi)
                                          "${(shop.distance! * 0.621371).toStringAsFixed(1)} mi",
                                          style: TextStyle(
                                            color: Colors.blue.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 195, // Reduced to match card height reduction
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
          );
        },
      ),
    );
  }
}
