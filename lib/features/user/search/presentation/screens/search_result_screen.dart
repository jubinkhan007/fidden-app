import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:fidden/core/commom/widgets/fallBack_image.dart'; // NetThumb
import 'package:fidden/features/user/home/presentation/screen/shop_details_screen.dart';
import 'package:fidden/features/user/search/controller/global_search_controller.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/service_details_screen.dart';

class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({
    super.key,
    this.initialQuery = '',
    this.initialLocation, // "lat,long"
  });

  final String initialQuery;
  final String? initialLocation;

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen>
    with SingleTickerProviderStateMixin {
  late final GlobalSearchController c;
  late final TextEditingController searchTEC;
  Timer? _debounce;

  final _servicesScroll = ScrollController();
  final _shopsScroll = ScrollController();

  @override
  void initState() {
    super.initState();
    c = Get.put(
      GlobalSearchController(
        initialQuery: widget.initialQuery,
        initialLocation: widget.initialLocation,
      ),
    );

    searchTEC = TextEditingController(text: widget.initialQuery);

    WidgetsBinding.instance.addPostFrameCallback((_) => c.init());

    _servicesScroll.addListener(_onServicesScroll);
    _shopsScroll.addListener(_onShopsScroll);
  }

  void _onServicesScroll() {
    if (_servicesScroll.position.pixels >
            _servicesScroll.position.maxScrollExtent - 250 &&
        !c.isLoadingMore.value) {
      c.loadMore();
    }
  }

  void _onShopsScroll() {
    if (_shopsScroll.position.pixels >
            _shopsScroll.position.maxScrollExtent - 250 &&
        !c.isLoadingMore.value) {
      c.loadMore();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _servicesScroll.dispose();
    _shopsScroll.dispose();
    searchTEC.dispose();
    super.dispose();
  }

  void _onQueryChanged(String q) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      c.query.value = q.trim();
      c.search(reset: true);
    });
  }

  Future<void> _refresh() async => c.search(reset: true);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _SearchField(
              controller: searchTEC,
              onChanged: _onQueryChanged,
              onSubmitted: (_) => c.search(reset: true),
              onClear: () {
                searchTEC.clear();
                _onQueryChanged('');
              },
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Obx(
              () => TabBar(
                isScrollable: false,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.black54,
                indicatorColor: theme.primaryColor,
                indicatorWeight: 3,
                tabs: [
                  _TabWithCount(label: 'Services', count: c.services.length),
                  _TabWithCount(label: 'Shops', count: c.shops.length),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            _ServicesTab(
              controller: c,
              scrollController: _servicesScroll,
              onRefresh: _refresh,
            ),
            _ShopsTab(
              controller: c,
              scrollController: _shopsScroll,
              onRefresh: _refresh,
            ),
          ],
        ),
      ),
    );
  }
}

/// Search field with live clear button (no setState needed)
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 0, 8),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE6E8ED)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onSubmitted: onSubmitted,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Search services or shops…',
                border: InputBorder.none,
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox(width: 6);
              return IconButton(
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: Colors.black54,
                ),
                onPressed: onClear,
                tooltip: 'Clear',
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Tab label with a small count pill
class _TabWithCount extends StatelessWidget {
  const _TabWithCount({required this.label, required this.count});
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF1F5),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({
    required this.controller,
    required this.scrollController,
    required this.onRefresh,
  });

  final GlobalSearchController controller;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value && controller.services.isEmpty;

      if (loading) {
        return const _ShimmerList();
      }
      if (controller.services.isEmpty) {
        return const _EmptyState(text: 'No services found.');
      }

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          itemCount:
              controller.services.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= controller.services.length) {
              return const _BottomLoader();
            }
            final s = controller.services[i];
            return _ResultCard(
              imageUrl: s.image,
              title: s.title ?? '',
              subtitle: s.extraInfo ?? '',
              rating: s.rating,
              reviews: s.reviews,
              onTap: () => Get.to(() => ServiceDetailsScreen(serviceId: s.id)),
            );
          },
        ),
      );
    });
  }
}

class _ShopsTab extends StatelessWidget {
  const _ShopsTab({
    required this.controller,
    required this.scrollController,
    required this.onRefresh,
  });

  final GlobalSearchController controller;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value && controller.shops.isEmpty;

      if (loading) {
        return const _ShimmerList();
      }
      if (controller.shops.isEmpty) {
        return const _EmptyState(text: 'No shops found.');
      }

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
          itemCount:
              controller.shops.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (_, i) {
            if (i >= controller.shops.length) {
              return const _BottomLoader();
            }
            final s = controller.shops[i];
            return _ResultCard(
              imageUrl: s.image,
              title: s.title ?? '',
              subtitle: s.extraInfo ?? '',
              rating: s.rating,
              reviews: s.reviews,
              onTap: () => Get.to(() => ShopDetailsScreen(id: s.id.toString())),
            );
          },
        ),
      );
    });
  }
}

/// Modern card style for results
class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.rating,
    this.reviews,
  });

  final String? imageUrl;
  final String title;
  final String subtitle;
  final double? rating;
  final int? reviews;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: const Color(0xFFF0F2F6)),
          ),
          child: Row(
            children: [
              // Image
              NetThumb(url: imageUrl, w: 72, h: 72, borderRadius: 12),

              const SizedBox(width: 12),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13.5,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          (rating ?? 0).toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${reviews ?? 0} reviews)',
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.black26,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder list
class _ShimmerList extends StatelessWidget {
  const _ShimmerList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 16),
      itemCount: 6,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: const Color(0xFFE8EBF1),
        highlightColor: const Color(0xFFF6F8FC),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    Container(height: 16, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(height: 12, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, color: Colors.white),
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

/// Bottom loader when paging
class _BottomLoader extends StatelessWidget {
  const _BottomLoader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 18),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Friendly empty state
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 56,
            color: Color(0xFF9CA3AF),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
