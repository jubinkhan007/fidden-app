import 'dart:math' as math;
import 'package:fidden/features/user/home/controller/home_controller.dart';
import 'package:fidden/features/user/home/data/category_model.dart';
import 'package:fidden/features/user/home/data/promotion_offers_model.dart';
import 'package:fidden/features/user/home/data/trending_service_model.dart';
import 'package:fidden/features/user/home/presentation/screen/widgets/sticky_map_button.dart';
import 'package:fidden/features/user/map/map_screen.dart';
import 'package:fidden/features/user/shops/data/all_shops_model.dart';
import 'package:fidden/features/user/shops/presentation/screens/all_shops_screen.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/all_services_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'shop_details_screen.dart';

/// Quick responsive helpers
class R {
  final BuildContext context;
  final Size size;
  final double sw; // screen width
  final double sh; // screen height
  final double s; // scale vs 375x812
  R._(this.context, this.size, this.sw, this.sh, this.s);
  factory R.of(BuildContext c) {
    final size = MediaQuery.of(c).size;
    final baseW = 375.0, baseH = 812.0;
    final s = math.min(size.width / baseW, size.height / baseH);
    return R._(c, size, size.width, size.height, s.clamp(0.75, 1.35));
  }
  double w(double v) => v * s;
  double h(double v) => v * s;
  double sp(double v) =>
      v * s * MediaQuery.of(context).textScaleFactor.clamp(0.9, 1.1);
  BorderRadius r(double v) => BorderRadius.circular(w(v));
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    Get.put(HomeController());
    final c = Get.find<HomeController>();

    return Scaffold(
      body: Obx(() {
        // your existing content (skeleton vs actual)
        final Widget content = c.isLoading.value
            ? _HomeSkeleton(r: r)
            : SafeArea(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _Header(r: r)),
                    SliverToBoxAdapter(child: _PromoCarousel(r: r)),
                    SliverToBoxAdapter(child: _Categories(r: r)),
                    SliverToBoxAdapter(child: _TrendingServices(r: r)),
                    SliverToBoxAdapter(child: _PopularShops(r: r)),
                    // keeps last items from hiding behind the button
                    SliverToBoxAdapter(child: SizedBox(height: r.h(90))),
                  ],
                ),
              );

        return Stack(
          children: [
            content,
            // 👇 sticky floating button overlay
            StickyShowMapButton(
              r: r,
              onTap: () {
                // TODO: route to the map screen for shops
                Get.to(() => const MapScreen());
              },
            ),
          ],
        );
      }),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton({required this.r});
  final R r;

  Widget _bar({double h = 16, double w = double.infinity}) => Container(
    height: h,
    width: w,
    decoration: BoxDecoration(
      color: const Color(0xFFF0F2F6),
      borderRadius: BorderRadius.circular(8),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: r.w(20), vertical: r.h(16)),
        children: [
          // header card
          Container(
            height: r.h(120),
            decoration: BoxDecoration(
              color: const Color(0xFFECEEF3),
              borderRadius: r.r(24),
            ),
          ),
          SizedBox(height: r.h(16)),

          // promo
          Container(
            height: r.h(160),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F6),
              borderRadius: r.r(24),
            ),
          ),
          SizedBox(height: r.h(20)),

          // categories strip
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(right: r.w(12)),
                child: Container(
                  width: r.w(72),
                  height: r.w(72),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F2F6),
                    borderRadius: r.r(22),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: r.h(24)),

          // “Trending Services” title bar
          _bar(h: 22, w: r.w(180)),
          SizedBox(height: r.h(12)),

          // trending cards (2 placeholders)
          SizedBox(
            height: r.h(220),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 2,
              separatorBuilder: (_, __) => SizedBox(width: r.w(14)),
              itemBuilder: (_, __) => Container(
                width: r.w(300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: r.r(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: r.h(140),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F6),
                        borderRadius: BorderRadius.only(
                          topLeft: r.r(16).topLeft,
                          topRight: r.r(16).topRight,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(r.w(14)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _bar(h: 18, w: r.w(180)),
                          SizedBox(height: r.h(8)),
                          _bar(h: 14, w: r.w(120)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: r.h(24)),

          // “Popular Shops” title bar
          _bar(h: 22, w: r.w(180)),
          SizedBox(height: r.h(12)),

          // popular shops avatars
          Row(
            children: List.generate(
              3,
              (_) => Padding(
                padding: EdgeInsets.only(right: r.w(22)),
                child: Column(
                  children: [
                    Container(
                      width: r.w(64),
                      height: r.w(64),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0F2F6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(height: r.h(8)),
                    _bar(h: 12, w: r.w(70)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.r});
  final R r;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(r.w(20), r.h(8), r.w(20), r.h(16)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF350713), Color(0xFF3E0B17)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: r.r(24).topLeft,
          bottomRight: r.r(24).topRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: r.h(18)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: r.sp(22),
                      ),
                    ),
                    SizedBox(height: r.h(6)),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: r.w(16),
                          color: const Color(0xFFFFE082),
                        ),
                        SizedBox(width: r.w(6)),
                        Text(
                          'California, US',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: r.sp(14),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: r.w(48),
                    height: r.w(48),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4D1020),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: r.w(22),
                    ),
                  ),
                  Positioned(
                    right: r.w(2),
                    top: r.w(2),
                    child: Container(
                      width: r.w(16),
                      height: r.w(16),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: r.sp(10),
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: r.h(12)),
          Container(
            height: r.h(52),
            decoration: BoxDecoration(
              color: const Color(0xFF3F1220),
              borderRadius: r.r(18),
            ),
            padding: EdgeInsets.symmetric(horizontal: r.w(16)),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white70, size: r.w(22)),
                SizedBox(width: r.w(10)),
                Expanded(
                  child: Text(
                    'Search here...',
                    style: TextStyle(color: Colors.white70, fontSize: r.sp(15)),
                  ),
                ),
                Container(
                  width: r.w(36),
                  height: r.w(36),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A1B2D),
                    borderRadius: r.r(12),
                  ),
                  child: Icon(Icons.tune, color: Colors.white, size: r.w(18)),
                ),
              ],
            ),
          ),
          SizedBox(height: r.h(6)),
        ],
      ),
    );
  }
}

class _PromoCarousel extends GetView<HomeController> {
  const _PromoCarousel({required this.r});
  final R r;

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    final idx = 0.obs;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.w(20), vertical: r.h(12)),
      child: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.promotions.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            SizedBox(
              height: r.h(160),
              child: PageView.builder(
                controller: pageController,
                onPageChanged: (i) => idx.value = i,
                itemCount: controller.promotions.length,
                itemBuilder: (_, i) {
                  final promo = controller.promotions[i];
                  return _PromoCard(r: r, promo: promo);
                },
              ),
            ),
            SizedBox(height: r.h(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.promotions.length, (i) {
                return Obx(() {
                  final active = i == idx.value;
                  return Container(
                    width: active ? r.w(18) : r.w(6),
                    height: r.w(6),
                    margin: EdgeInsets.symmetric(horizontal: r.w(4)),
                    decoration: BoxDecoration(
                      color: active ? Colors.black87 : Colors.black26,
                      borderRadius: r.r(12),
                    ),
                  );
                });
              }),
            ),
            SizedBox(height: r.h(14)),
          ],
        );
      }),
    );
  }
}

class _PromoCard extends StatelessWidget {
  const _PromoCard({required this.r, required this.promo});
  final R r;
  final PromotionModel promo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: r.w(4)),
      decoration: BoxDecoration(
        borderRadius: r.r(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF421220), Color(0xFF0D0B13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(r.w(20)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promo.title ?? "Special Offer",
                  style: TextStyle(
                    color: Colors.white,
                    height: 1.05,
                    fontWeight: FontWeight.w700,
                    fontSize: r.sp(22),
                  ),
                ),
                SizedBox(height: r.h(4)),
                Flexible(
                  child: Text(
                    promo.subtitle ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: r.sp(13),
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: r.w(8)),
          Text(
            '${promo.amount?.split('.').first}%',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: r.sp(44),
            ),
          ),
        ],
      ),
    );
  }
}

class _Categories extends GetView<HomeController> {
  const _Categories({required this.r});
  final R r;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.w(20)),
      child: Obx(() {
        // Skeleton while loading
        if (controller.isLoading.value && controller.categories.isEmpty) {
          return _catsSkeleton(r);
        }

        final cats = controller.categories;
        if (cats.isEmpty) return const SizedBox.shrink();

        // Use Wrap so chips pack tightly
        return Wrap(
          spacing: r.w(12),
          runSpacing: r.h(12),
          children: cats.map((cat) {
            // --- 🚀 CHANGE IS HERE ---
            return GestureDetector(
              onTap: () {
                // Navigate to the AllServicesScreen with category info
                Get.to(
                  () => AllServicesScreen(
                    categoryId: cat.id,
                    categoryName: cat.name,
                  ),
                  transition: Transition.cupertino,
                );
              },
              // Make sure your _Cat widget doesn't handle gestures itself
              // to avoid conflicts.
              child: _Cat(
                label: cat.name ?? '',
                icon: Icons.cut,
                tint: const Color(0xFFEEF3FF),
              ),
            );
            // --- END CHANGE ---
          }).toList(),
        );
      }),
    );
  }
}

Widget _catsSkeleton(R r) {
  Widget tile() => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: r.w(72),
        height: r.w(72),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F6),
          borderRadius: r.r(22),
        ),
      ),
      SizedBox(height: r.h(10)),
      Container(
        width: r.w(60),
        height: r.h(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F6),
          borderRadius: r.r(6),
        ),
      ),
    ],
  );

  return Wrap(
    spacing: r.w(12),
    runSpacing: r.h(12),
    children: List.generate(4, (_) => tile()),
  );
}

class _Cat extends StatelessWidget {
  const _Cat({required this.icon, required this.label, required this.tint});
  final IconData icon;
  final String label;
  final Color tint;
  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    return Column(
      children: [
        Container(
          width: r.w(72),
          height: r.w(72),
          decoration: BoxDecoration(color: tint, borderRadius: r.r(22)),
          child: Icon(icon, size: r.w(28), color: const Color(0xFF6B2A3B)),
        ),
        SizedBox(height: r.h(10)),
        Text(
          label,
          style: TextStyle(fontSize: r.sp(14), color: const Color(0xFF383A42)),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(
    this.title, {
    required this.r,
    this.actionLabel,
    this.onTap,
  });
  final String title;
  final String? actionLabel;
  final VoidCallback? onTap;
  final R r;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(r.w(20), r.h(22), r.w(20), r.h(12)),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: r.sp(20),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1C1D22),
            ),
          ),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onTap,
              child: Text(
                actionLabel!,
                style: TextStyle(
                  fontSize: r.sp(14),
                  color: const Color(0xFF6B2A3B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrendingServices extends GetView<HomeController> {
  const _TrendingServices({required this.r});
  final R r;
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final services = controller.trendingServices.value.results;
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (services == null || services.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            'Trending Services',
            r: r,
            actionLabel: 'See All',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AllServicesScreen()),
              );
            },
          ),
          SizedBox(
            height: r.h(280),
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: r.w(20)),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => _TrendingCard(r: r, service: services[i]),
              separatorBuilder: (_, __) => SizedBox(width: r.w(14)),
              itemCount: services.length,
            ),
          ),
        ],
      );
    });
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.r, required this.service});
  final R r;
  final TrendingService service;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          Get.to(() => ShopDetailsScreen(id: service.shopId.toString())),
      child: Container(
        width: r.w(300),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: r.r(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: r.r(16).topLeft,
                    topRight: r.r(16).topRight,
                  ),
                  child: Image.network(
                    service.serviceImg ??
                        'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0',
                    height: r.h(160),
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) => Container(
                      height: r.h(160),
                      color: Colors.grey.shade200,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: r.h(10),
                  right: r.w(10),
                  child: _Fav(r: r),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(r.w(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title ?? '',
                    style: TextStyle(
                      fontSize: r.sp(16),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF22242A),
                    ),
                  ),
                  SizedBox(height: r.h(8)),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: r.w(16),
                        color: const Color(0xFF6B6F7C),
                      ),
                      SizedBox(width: r.w(6)),
                      Expanded(
                        child: Text(
                          service.shopAddress ?? '',
                          style: TextStyle(
                            fontSize: r.sp(13),
                            color: const Color(0xFF6B6F7C),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: r.h(12)),
                  Row(
                    children: [
                      Text(
                        '\$${service.discountPrice ?? service.price ?? '0'}',
                        style: TextStyle(
                          fontSize: r.sp(18),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.star,
                        size: r.w(16),
                        color: const Color(0xFFF7B500),
                      ),
                      SizedBox(width: r.w(4)),
                      Text(
                        service.avgRating?.toStringAsFixed(1) ?? '0.0',
                        style: TextStyle(
                          fontSize: r.sp(14),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: r.w(8)),
                      Text(
                        '(${service.reviewCount} Reviews)',
                        style: TextStyle(
                          fontSize: r.sp(13),
                          color: const Color(0xFF6B6F7C),
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
  }
}

class _Fav extends StatefulWidget {
  const _Fav({required this.r});
  final R r;
  @override
  State<_Fav> createState() => _FavState();
}

class _FavState extends State<_Fav> {
  bool liked = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => liked = !liked),
      child: Container(
        width: widget.r.w(36),
        height: widget.r.w(36),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
          ],
        ),
        child: Icon(
          liked ? Icons.favorite : Icons.favorite_border,
          color: const Color(0xFF6B2A3B),
          size: widget.r.w(20),
        ),
      ),
    );
  }
}

class _PopularShops extends GetView<HomeController> {
  const _PopularShops({required this.r});
  final R r;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shops = controller.popularShops.value.shops;
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (shops == null || shops.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            'Popular Shops',
            r: r,
            actionLabel: 'See All',
            onTap: () => Get.to(() => const AllShopsScreen()),
          ),
          SizedBox(
            height: r.h(130),
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.fromLTRB(r.w(20), 0, 0, 0),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) => _ShopItem(shop: shops[i]),
              separatorBuilder: (_, __) => SizedBox(width: r.w(0)),
              itemCount: shops.length,
            ),
          ),
        ],
      );
    });
  }
}

class _ShopItem extends StatelessWidget {
  const _ShopItem({required this.shop});
  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    return GestureDetector(
      onTap: () => Get.to(() => ShopDetailsScreen(id: shop.id.toString())),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: r.w(64),
            height: r.w(64),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: r.h(8)),
          SizedBox(
            width: r.w(86),
            child: Text(
              shop.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: r.sp(14), fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(height: r.h(4)),
          Row(
            children: [
              Icon(Icons.star, size: r.w(14), color: const Color(0xFFF7B500)),
              SizedBox(width: r.w(4)),
              Text(
                shop.avgRating?.toStringAsFixed(1) ?? '0.0',
                style: TextStyle(
                  fontSize: r.sp(12),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: r.w(4)),
              Text(
                '(${shop.reviewCount})',
                style: TextStyle(
                  fontSize: r.sp(12),
                  color: const Color(0xFF6B6F7C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
