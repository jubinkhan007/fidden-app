import 'dart:math';
// lib/features/user/map/map_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/user/shops/presentation/screens/shop_details_screen.dart';
import 'package:fidden/features/user/map/map_controller.dart';
import 'package:fidden/features/user/shops/data/all_shops_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shimmer/shimmer.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(MapScreenController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: Obx(() {
        return Stack(
          children: [
            // --- Map ---
            GoogleMap(
              initialCameraPosition: c.camera,
              onMapCreated: c.onMapCreated,
              // IMPORTANT: only enable when the app actually has permission.
              myLocationEnabled: c.hasLocationPermission.value,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: c.markers.value,
              onCameraMove: c.onCameraMove,
              onCameraIdle: c.onCameraIdle,
              onTap: (_) => c.clearSelection(),
            ),

            // --- Top overlay: search + filters + permission banner ---
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _SearchBar(controller: c),
                  const SizedBox(height: 8),
                  _FilterChips(controller: c),
                  if (!c.hasLocationPermission.value)
                    _PermissionBanner(onEnable: c.requestPermissionAndCenter),
                ],
              ),
            ),

            // --- “Search this area” pill ---
            Obx(
              () => AnimatedSlide(
                offset: c.showSearchThisArea.value
                    ? Offset.zero
                    : const Offset(0, -0.3),
                duration: const Duration(milliseconds: 200),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 110),
                    child: ElevatedButton.icon(
                      onPressed: c.searchThisArea,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Search this area'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        elevation: 6,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // --- Selected shop peek card (tap marker) ---
            Obx(
              () => c.selectedShop.value == null
                  ? const SizedBox.shrink()
                  : _SelectedShopCard(
                      shop: c.selectedShop.value!,
                      onClose: c.clearSelection,
                    ),
            ),

            // --- Bottom list: draggable sheet of nearby shops ---
            _BottomSheetList(controller: c),

            // --- My location FAB ---
            Positioned(
              right: 16,
              bottom: 24 + 16,
              child: FloatingActionButton(
                onPressed: c.requestPermissionAndCenter,
                heroTag: 'recenter',
                backgroundColor: Colors.white,
                elevation: 3,
                child: const Icon(Icons.my_location, color: Colors.black),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final MapScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        children: [
          TextField(
            controller: controller.searchController,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: 'Search shops on map...',
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
                borderSide: const BorderSide(color: Colors.black54, width: 1.1),
              ),
              suffixIcon: AnimatedBuilder(
                animation: controller.searchController,
                builder: (_, __) {
                  final hasText = controller.searchController.text.isNotEmpty;
                  return hasText
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            controller.searchController.clear();
                            controller.fetchNearby();
                            controller.suggestions.clear();
                          },
                        )
                      : const SizedBox.shrink();
                },
              ),
            ),
          ),

          // Suggestions dropdown
          Obx(() {
            if (controller.suggestions.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.only(top: 52),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: controller.suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final s = controller.suggestions[i];
                  return ListTile(
                    dense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    leading: const Icon(Icons.place_outlined),
                    title: Text(s.name ?? ''),
                    subtitle: Text(
                      s.address ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => controller.goToShop(s),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.controller});
  final MapScreenController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        children: [
          _chip(
            label: 'Nearest',
            selected: controller.nearest.value,
            onTap: () async {
              controller.nearest.value = !controller.nearest.value;
              await controller.fetchNearby(
                query: controller.searchController.text.trim(),
              );
            },
          ),
          _chip(
            label: 'Top rated',
            selected: controller.topRated.value,
            onTap: () async {
              controller.topRated.value = !controller.topRated.value;
              await controller.fetchNearby(
                query: controller.searchController.text.trim(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({required this.onEnable});
  final VoidCallback onEnable;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8, color: Colors.white, borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Location is off', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('Enable location to center the map on you and find nearby places.'),
            const SizedBox(height: 10),
            FilledButton(onPressed: onEnable, child: const Text('Enable location')),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.text, required this.loading, this.onUse});
  final String? text;
  final bool loading;
  final VoidCallback? onUse;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12, borderRadius: BorderRadius.circular(14), color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(color: const Color(0xFFEFF1F5), borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(8),
                  child: const Icon(Icons.place_outlined),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: loading
                      ? Row(
                          key: const ValueKey('addr-loading'),
                          children: const [
                            SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.2)),
                            SizedBox(width: 8),
                            Flexible(child: Text('Resolving address...', maxLines: 1, overflow: TextOverflow.ellipsis)),
                          ],
                        )
                      : Text(
                          text ?? 'Tap on map to choose a location',
                          key: ValueKey('addr-${text ?? "<none>"}'),
                          style: const TextStyle(fontWeight: FontWeight.w600, height: 1.35),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(onPressed: onUse, child: const Text('Use this location')),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomSheetList extends StatelessWidget {
  const _BottomSheetList({required this.controller});
  final MapScreenController controller;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.12,
      maxChildSize: 0.55,
      builder: (context, scrollController) {
        return Obx(() {
          if (controller.isLoading.value && controller.shops.isEmpty) {
            return _ShimmerList(scrollController: scrollController);
          }
          if (controller.shops.isEmpty) {
            return Container(
              decoration: _sheetDeco,
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: const [
                  Center(child: CustomText(text: 'No shops found')),
                ],
              ),
            );
          }
          return Container(
            decoration: _sheetDeco,
            child: ListView.separated(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
              itemCount: controller.shops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _ShopListItem(shop: controller.shops[i]),
            ),
          );
        });
      },
    );
  }

  BoxDecoration get _sheetDeco => BoxDecoration(
    color: Colors.white,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 16,
        offset: const Offset(0, -6),
      ),
    ],
  );
}

class _ShopListItem extends StatelessWidget {
  const _ShopListItem({required this.shop});
  final Shop shop;

  @override
  Widget build(BuildContext context) {
    final imageUrl = (shop.shop_img != null && shop.shop_img!.isNotEmpty)
        ? shop.shop_img!
        : 'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop';

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => Get.to(() => ShopDetailsScreen(id: shop.id.toString())),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 92,
                height: 78,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey.shade200),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      shop.address ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(shop.avgRating ?? 0).toStringAsFixed(1)}  (${shop.reviewCount ?? 0} reviews)',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (shop.distance != null)
                          Text(
                            '${(shop.distance! / 1000).toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedShopCard extends StatelessWidget {
  const _SelectedShopCard({required this.shop, required this.onClose});
  final Shop shop;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final imageUrl = (shop.shop_img != null && shop.shop_img!.isNotEmpty)
        ? shop.shop_img!
        : 'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop';

    return Positioned(
      left: 16,
      right: 16,
      bottom: 124, // keep above FAB and sheet
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => ShopDetailsScreen(id: shop.id.toString())),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 110,
                    height: 92,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey.shade200),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 8,
                      top: 10,
                      bottom: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          shop.address ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Color(0xFFFFC107),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${(shop.avgRating ?? 0).toStringAsFixed(1)}  (${shop.reviewCount ?? 0})',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: onClose,
                              icon: const Icon(Icons.close, size: 18),
                              splashRadius: 18,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerList extends StatelessWidget {
  const _ShimmerList({required this.scrollController});
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, __) => Shimmer.fromColors(
          baseColor: const Color(0xFFE8EBF1),
          highlightColor: const Color(0xFFF6F8FC),
          child: Container(
            height: 82,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
