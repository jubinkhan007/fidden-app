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
                                child: CachedNetworkImage(
                                  imageUrl: imageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) =>
                                      Container(color: Colors.grey[200]),
                                  errorWidget: (_, __, ___) => Image.network(
                                    "https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
                                    fit: BoxFit.cover,
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
                                CustomText(
                                  text: shop.name ?? '',
                                  fontSize: getWidth(18),
                                  fontWeight: FontWeight.bold,
                                  maxLines: 1,
                                  textOverflow: TextOverflow.ellipsis,
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
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${shop.avgRating?.toStringAsFixed(1) ?? "0.0"} "
                                      "(${shop.reviewCount ?? 0} reviews)",
                                      style: TextStyle(
                                        color: Colors.grey.shade800,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    if (controller.isLocationAvailable.value)
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
                                          "${((shop.distance ?? 0)).toStringAsFixed(2)} km",
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
            height: 220,
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
