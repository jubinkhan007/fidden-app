// lib/main.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

class SalonApp extends StatelessWidget {
  const SalonApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salon UI',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF7F7F9),
        fontFamily: 'SF Pro',
      ),
      home: const HomeScreen(),
    );
  }
}

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
    // scale based on the limiting dimension for better pixel-consistency
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
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header(r: r)),
            //SliverToBoxAdapter(child: _SearchBar(r: r)),
            SliverToBoxAdapter(child: _PromoCarousel(r: r)),
            SliverToBoxAdapter(child: _Categories(r: r)),
            SliverToBoxAdapter(child: _TrendingServices(r: r)),
            SliverToBoxAdapter(child: _RecentBooking(r: r)),
            SliverToBoxAdapter(child: _PopularShops(r: r)),
            SliverToBoxAdapter(child: SizedBox(height: r.h(90))),
          ],
        ),
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
                      'Hi, Aaron Ramsdale',
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
                    decoration: BoxDecoration(
                      color: const Color(0xFF4D1020),
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

class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel({required this.r});
  final R r;
  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  int idx = 0;
  final controller = PageController(viewportFraction: 1.0);
  @override
  Widget build(BuildContext context) {
    final r = widget.r;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.w(20), vertical: r.h(12)),
      child: Column(
        children: [
          //SizedBox(width: r.w(160)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              // width: r.w(700),
              height: r.h(160),
              child: PageView.builder(
                controller: controller,
                onPageChanged: (i) => setState(() => idx = i),
                itemCount: 3,
                itemBuilder: (_, i) => Container(
                  margin: EdgeInsets.only(bottom: r.h(10)),
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
                          mainAxisSize: MainAxisSize.min, // 👈 important
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's\nSpecial Offer",
                              style: TextStyle(
                                color: Colors.white,
                                height: 1.05,
                                fontWeight: FontWeight.w700,
                                fontSize: r.sp(22),
                              ),
                            ),
                            SizedBox(height: r.h(4)), // reduce spacing
                            Flexible(
                              // 👈 prevents overflow
                              child: Text(
                                'Get a discount for every service order!\nOnly valid for today',
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
                        '30%',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: r.sp(44),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: r.h(0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == idx;
              return Container(
                width: active ? r.w(18) : r.w(6),
                height: r.w(6),
                margin: EdgeInsets.symmetric(horizontal: r.w(4)),
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.white38,
                  borderRadius: r.r(12),
                ),
              );
            }),
          ),
          SizedBox(height: r.h(14)),
        ],
      ),
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({required this.r});
  final R r;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: r.w(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          _Cat(icon: Icons.cut, label: 'Haircare', tint: Color(0xFFEEF3FF)),
          _Cat(
            icon: Icons.auto_awesome,
            label: 'Skincare',
            tint: Color(0xFFFFEEF4),
          ),
          _Cat(
            icon: Icons.back_hand,
            label: 'Nailcare',
            tint: Color(0xFFF2EFFF),
          ),
          _Cat(
            icon: Icons.grid_view_rounded,
            label: 'More',
            tint: Color(0xFFEFF6FF),
          ),
        ],
      ),
    );
  }
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

class _TrendingServices extends StatelessWidget {
  const _TrendingServices({required this.r});
  final R r;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          'Trending Services',
          r: r,
          actionLabel: 'See All',
          onTap: () {},
        ),
        SizedBox(
          height: r.h(280),
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: r.w(20)),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => _TrendingCard(r: r, index: i),
            separatorBuilder: (_, __) => SizedBox(width: r.w(14)),
            itemCount: 2,
          ),
        ),
      ],
    );
  }
}

class _TrendingCard extends StatelessWidget {
  const _TrendingCard({required this.r, required this.index});
  final R r;
  final int index;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                  index == 0
                      ? 'https://images.unsplash.com/photo-1582095133179-bfd08e2fc6b3?q=80&w=1200&auto=format&fit=crop'
                      : 'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
                  height: r.h(160),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: r.h(10),
                left: r.w(10),
                child: _Chip(
                  label: index == 0 ? 'Top Pro' : 'Popular',
                  icon: index == 0
                      ? Icons.emoji_events
                      : Icons.local_fire_department,
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
                  index == 0 ? 'Blowout & Styling' : "Men's Fade Haircut",
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
                        index == 0 ? 'Oak Street, CA' : 'Oak Street, CA',
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
                      index == 0 ? '\$89' : '\$20',
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
                      '5.0',
                      style: TextStyle(
                        fontSize: r.sp(14),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: r.w(8)),
                    Text(
                      '(58 Reviews)',
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
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: r.w(10), vertical: r.h(6)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: r.r(100),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: r.w(14), color: const Color(0xFF6B2A3B)),
          SizedBox(width: r.w(6)),
          Text(
            label,
            style: TextStyle(fontSize: r.sp(12), fontWeight: FontWeight.w700),
          ),
        ],
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

class _RecentBooking extends StatelessWidget {
  const _RecentBooking({required this.r});
  final R r;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          'Recently Booking',
          r: r,
          actionLabel: 'See All',
          onTap: () {},
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: r.w(20)),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: r.r(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: EdgeInsets.all(r.w(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Dec 22, 2024',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: r.sp(14),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Remind me',
                      style: TextStyle(
                        color: const Color(0xFF858896),
                        fontSize: r.sp(13),
                      ),
                    ),
                    SizedBox(width: r.w(8)),
                    Switch(
                      value: true,
                      onChanged: (_) {},
                      activeColor: const Color(0xFF6B2A3B),
                    ),
                  ],
                ),
                SizedBox(height: r.h(8)),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: r.r(12),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1582095133179-bfd08e2fc6b3?q=80&w=600&auto=format&fit=crop',
                        width: r.w(88),
                        height: r.w(88),
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: r.w(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Blowout & Styling',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: r.sp(16),
                            ),
                          ),
                          SizedBox(height: r.h(6)),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule,
                                size: r.w(16),
                                color: const Color(0xFF6B6F7C),
                              ),
                              SizedBox(width: r.w(6)),
                              Text(
                                '123 Oak Street, CA 98765',
                                style: TextStyle(
                                  color: const Color(0xFF6B6F7C),
                                  fontSize: r.sp(13),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: r.h(10)),
                          Text(
                            'Services:',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: r.sp(13),
                            ),
                          ),
                          SizedBox(height: r.h(4)),
                          Text(
                            'Undercut Haircut, Regular Shaving,\nNatural Hair Wash',
                            style: TextStyle(
                              color: const Color(0xFF6B6F7C),
                              fontSize: r.sp(13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularShops extends StatelessWidget {
  const _PopularShops({required this.r});
  final R r;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          'Popular Shops',
          r: r,
          actionLabel: 'See All',
          onTap: () {},
        ),
        SizedBox(
          height: r.h(130),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: r.w(20)),
            scrollDirection: Axis.horizontal,
            itemBuilder: (_, i) => _ShopItem(index: i),
            separatorBuilder: (_, __) => SizedBox(width: r.w(22)),
            itemCount: 5,
          ),
        ),
      ],
    );
  }
}

class _ShopItem extends StatelessWidget {
  const _ShopItem({required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    final r = R.of(context);
    final names = ['Glow & Go', 'FreshCuts', 'NailFix', 'Beauty', 'Deem port'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: r.w(64),
          height: r.w(64),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10),
            ],
            image: const DecorationImage(
              image: NetworkImage(
                'https://avatars.githubusercontent.com/u/9919?s=200&v=4',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: r.h(8)),
        SizedBox(
          width: r.w(86),
          child: Text(
            names[index % names.length],
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
              '5.0',
              style: TextStyle(fontSize: r.sp(12), fontWeight: FontWeight.w700),
            ),
            SizedBox(width: r.w(4)),
            Text(
              '(58)',
              style: TextStyle(
                fontSize: r.sp(12),
                color: const Color(0xFF6B6F7C),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
