import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/business_owner/home/screens/all_service_screen.dart';
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
    // Ensure a single instance and reuse it everywhere
    c = Get.put(WishlistController(), permanent: true);
    _tab = TabController(length: 2, vsync: this);

    // Always refresh when we land on this screen
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
              isScrollable: false,
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
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = controller.favoriteShops[i];
          return Dismissible(
            key: ValueKey('shop_${s.id}_${i}'),
            direction: DismissDirection.endToStart,
            background: _swipeBg(),
            onDismissed: (_) =>
                controller.removeShopFromWishlistByWishlistId(s.id!),
            child: _WishlistCard(
              imageUrl: s.shopImg,
              title: s.name ?? '—',
              subtitle: s.address ?? '—',
              trailing: _RemoveIconButton(
                onTap: () =>
                    controller.removeShopFromWishlistByWishlistId(s.id!),
              ),
              onTap: () =>
                  Get.to(() => ShopDetailsScreen(id: s.id!.toString())),
            ),
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
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final s = controller.favoriteServices[i];
          return Dismissible(
            key: ValueKey('service_${s.id}_${i}'),
            direction: DismissDirection.endToStart,
            background: _swipeBg(),
            // NOTE: If your controller expects wishlistId, this passes wishlist id.
            onDismissed: (_) =>
                controller.removeServiceFromWishlistByWishlistId(s.id!),
            child: _WishlistCard(
              imageUrl: s.serviceImg,
              title: s.title ?? '—',
              subtitle: s.shopAddress ?? '—',
              price: s.price,
              trailing: _RemoveIconButton(
                onTap: () =>
                    controller.removeServiceFromWishlistByWishlistId(s.id!),
              ),
              onTap: () {
                // If your model uses a different field name, change s.serviceId accordingly.
                final sid = s.id; // mapped from JSON key "service_id"
                if (sid != null) {
                  Get.to(() => ServiceDetailsScreen(serviceId: sid));
                } else {
                  Get.snackbar(
                    'Unavailable',
                    'Service id missing for this item.',
                  );
                }
              },
            ),
          );
        },
      );
    });
  }
}

class _WishlistCard extends StatelessWidget {
  const _WishlistCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.price,
    required this.trailing,
    this.onTap,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  final String? price;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final placeholder =
        'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop';

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl ?? placeholder,
                        fit: BoxFit.cover,
                        placeholder: (_, __) =>
                            Container(color: const Color(0xFFEFF1F5)),
                        errorWidget: (_, __, ___) =>
                            Container(color: const Color(0xFFEFF1F5)),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
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
                  if (price != null && price!.trim().isNotEmpty)
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\$${price!}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: title,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            maxLines: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    trailing,
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

class _RemoveIconButton extends StatelessWidget {
  const _RemoveIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(Icons.delete_outline, color: Colors.red),
        ),
      ),
    );
  }
}

Widget _swipeBg() => Container(
  alignment: Alignment.centerRight,
  padding: const EdgeInsets.symmetric(horizontal: 20),
  decoration: BoxDecoration(
    color: Colors.red.withOpacity(0.15),
    borderRadius: BorderRadius.circular(16),
  ),
  child: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
);

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
            // Optional CTA (wire up navigation if you want)
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
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
