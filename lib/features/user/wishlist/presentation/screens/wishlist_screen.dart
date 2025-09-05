import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/user/home/presentation/screen/shop_details_screen.dart';
import 'package:fidden/features/user/shops/presentation/screens/all_shops_screen.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/all_services_screen.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/service_details_screen.dart';
import 'package:fidden/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tab;
  late final WishlistController c;

  @override
  void initState() {
    super.initState();
    c = Get.put(WishlistController(), permanent: true);
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshAll();
    });
  }

  Future<void> _refreshAll() async {
    await Future.wait([c.fetchFavoriteShops(), c.fetchFavoriteServices()]);
  }

  Future<void> _refreshCurrentTab() {
    if (_tab.index == 0) return c.fetchFavoriteShops();
    return c.fetchFavoriteServices();
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF7F8FA);
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'My Wishlist',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Obx(
            () => TabBar(
              controller: _tab,
              indicatorColor: Colors.black,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800),
              tabs: [
                Tab(text: 'Shops (${c.favoriteShops.length})'),
                Tab(text: 'Services (${c.favoriteServices.length})'),
              ],
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCurrentTab,
        child: TabBarView(
          controller: _tab,
          children: [
            _ShopsTab(controller: c),
            _ServicesTab(controller: c),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
//                        WIDGETS SECTION
// ===================================================================

class _ShopsTab extends StatelessWidget {
  const _ShopsTab({required this.controller});
  final WishlistController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingShops.value) {
        return const _ShimmerList();
      }
      if (controller.favoriteShops.isEmpty) {
        return const _EmptyState(
          title: 'No favorite shops yet',
          subtitle: 'Browse shops and tap the heart to save them here.',
          ctaLabel: 'Browse Shops',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: controller.favoriteShops.length,
        separatorBuilder: (_, __) {
          return Column(
            children: [
              Padding(padding: EdgeInsetsGeometry.fromLTRB(0, 12, 0, 0)),
              Divider(height: 0, indent: 16, endIndent: 16),
              Padding(padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 12)),
            ],
          );
        },
        itemBuilder: (context, i) {
          final s = controller.favoriteShops[i];
          return _NewWishlistCard(
            key: ValueKey('shop_${s.id}_${i}'),
            imageUrl: s.shopImg,
            title: s.name ?? '—',
            subtitle: s.address ?? '—',
            onTap: () => Get.to(() => ShopDetailsScreen(id: s.id!.toString())),
            onRemove: () =>
                controller.removeShopFromWishlistByWishlistId(s.id!),
          );
        },
      );
    });
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({required this.controller});
  final WishlistController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingServices.value) {
        return const _ShimmerList();
      }
      if (controller.favoriteServices.isEmpty) {
        return const _EmptyState(
          title: 'No favorite services yet',
          subtitle: 'Find a service you like and add it to your wishlist.',
          ctaLabel: 'Browse Services',
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: controller.favoriteServices.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, i) {
          final s = controller.favoriteServices[i];
          return _NewWishlistCard(
            key: ValueKey('service_${s.id}_${i}'),
            imageUrl: s.serviceImg,
            title: s.title ?? '—',
            subtitle: s.shopAddress ?? '—',
            price: s.price,
            onTap: () {
              final sid = s.serviceNo ?? s.id;
              if (sid != null) {
                Get.to(() => ServiceDetailsScreen(serviceId: sid));
              }
            },
            onRemove: () =>
                controller.removeServiceFromWishlistByWishlistId(s.id!),
          );
        },
      );
    });
  }
}

//  UPDATED Wishlist Card Layout
class _NewWishlistCard extends StatelessWidget {
  const _NewWishlistCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.price,
    required this.onTap,
    required this.onRemove,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  final String? price;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final placeholder =
        'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 8.0,
        ), // Reduced vertical padding
        child: Row(
          crossAxisAlignment: CrossAxisAlignment
              .center, //  Aligns items vertically in the center
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? placeholder,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: const Color(0xFFEFF1F5)),
                errorWidget: (_, __, ___) =>
                    Container(color: const Color(0xFFEFF1F5)),
              ),
            ),
            const SizedBox(width: 16),
            // Details Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment
                    .center, //  Vertically centers content in column
                children: [
                  Text(
                    title,
                    maxLines: 1, //  Changed to 1 line for consistent alignment
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  if (price != null && price!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '\$$price/person',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16), // Spacing between text and button
            OutlinedButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Remove'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Other widgets (_EmptyState, _ShimmerList, etc.) remain the same
// ...

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite_border_rounded,
              size: 56,
              color: Colors.black54,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () {
                if (ctaLabel.contains('Shop')) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllShopsScreen(),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllServicesScreen(),
                    ),
                  );
                }
              },
              child: Text(ctaLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE8EBF1),
      highlightColor: const Color(0xFFF6F8FC),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(height: 14, width: 150, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
