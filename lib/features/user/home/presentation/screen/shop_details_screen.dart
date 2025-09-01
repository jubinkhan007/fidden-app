import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/show_progress_indicator.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:fidden/core/utils/constants/icon_path.dart';
import 'package:fidden/core/utils/constants/image_path.dart';
import 'package:fidden/features/user/home/controller/shop_details_controller.dart';
import 'package:fidden/features/user/shops/data/shop_details_model.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/service_details_screen.dart';
import 'package:fidden/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:fidden/features/user/wishlist/data/wishlist_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'book_appoint_ment_screen.dart';

const fallbackImg =
    'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0';

class ShopDetailsScreen extends StatelessWidget {
  final String id;
  const ShopDetailsScreen({super.key, required this.id});

  // ----- UI Colors -----
  Color get _bg => const Color(0xffF4F4F4);
  Color get _ink => const Color(0xff111827);
  Color get _muted => const Color(0xff6B7280);
  Color get _brand => const Color(0xff7A49A5);
  Color get _chipBg => const Color(0xffEDEFFB);
  Color get _divider => const Color(0xffE5E7EB);
  Color get _warning => const Color(0xffFACC15);
  Color get _cta => const Color(0xffDC143C);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShopDetailsController());
    final wishlistController = Get.find<WishlistController>(); //the controller

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchShopDetails(id);
    });

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: _bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: CustomText(
          text: "Shop Details",
          color: const Color(0xff212121),
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: ShowProgressIndicator());
        }
        final data = controller.shopDetails.value;
        if (data.id == null) {
          return Center(
            child: CustomText(text: "No Shop Found", color: _muted),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: getHeight(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---- Header photo with overlaid icons ----
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    // Wrap with Stack to overlay widgets
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: Image.network(
                          data.shopImg ?? fallbackImg,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: _divider),
                        ),
                      ),
                      // -- Positioned icons on the top right --
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Row(
                          children: [
                            // --- WRAP WITH OBX ---
                            Obx(() {
                              final isFavorite = wishlistController
                                  .isShopFavorite(data.id ?? 0);
                              return _buildIcon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border_rounded,
                                onTap: () {
                                  if (data.id != null) {
                                    // Create a temporary shop object to pass
                                    final shop = FavoriteShop(
                                      id: data.id,
                                      name: data.name,
                                      address: data.address,
                                      shopImg: data.shopImg,
                                    );
                                    wishlistController.toggleShopFavorite(shop);
                                  }
                                },
                                isFavorite: isFavorite,
                              );
                            }),
                            // --- END OBX ---
                            SizedBox(width: getWidth(8)),
                            _buildIcon(
                              Icons.ios_share_rounded,
                              onTap: () {
                                /* Share logic */
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: getHeight(12)),

              // ---- Title + meta ----
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: data.name ?? '',
                      fontSize: getWidth(16),
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                    SizedBox(height: getHeight(6)),
                    Row(
                      children: [
                        Image.asset(
                          IconPath.locationIcon,
                          height: getHeight(16),
                          width: getWidth(16),
                        ),
                        SizedBox(width: getWidth(8)),
                        Expanded(
                          child: Text(
                            data.address ?? '',
                            style: TextStyle(
                              fontSize: getWidth(14),
                              color: _brand.withOpacity(.7),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: getHeight(6)),
                    Row(
                      children: [
                        Image.asset(
                          IconPath.ratingIcon,
                          height: getHeight(16),
                          width: getWidth(16),
                        ),
                        SizedBox(width: getWidth(8)),
                        Text(
                          "${data.avgRating?.toStringAsFixed(1) ?? '0.0'} ",
                          style: TextStyle(
                            fontSize: getWidth(14),
                            color: _brand.withOpacity(.7),
                          ),
                        ),
                        Text(
                          "(${data.reviewCount ?? 0})",
                          style: TextStyle(
                            fontSize: getWidth(14),
                            color: _brand.withOpacity(.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: getHeight(18)),

              // ---- Segmented Tabs (About / Review) ----
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getWidth(20)),
                child: Row(
                  children: [
                    _TabChip(
                      label: "About",
                      icon: IconPath.aboutIcon,
                      selected: controller.selectedTab.value == 0,
                      onTap: () => controller.selectTab(0),
                      brand: _brand,
                      chipBg: _chipBg,
                    ),
                    SizedBox(width: getWidth(6)),
                    _TabChip(
                      label: "Review",
                      icon: IconPath.ratingIcon,
                      selected: controller.selectedTab.value == 1,
                      onTap: () => controller.selectTab(1),
                      brand: _brand,
                      chipBg: _chipBg,
                    ),
                  ],
                ),
              ),
              SizedBox(height: getHeight(14)),

              // ---- Tab Content ----
              Padding(
                padding: EdgeInsets.symmetric(horizontal: getWidth(24)),
                child: Obx(() {
                  switch (controller.selectedTab.value) {
                    case 0:
                      return _AboutSection(
                        data: data,
                        titleColor: _ink,
                        bodyColor: _muted,
                        divider: _divider,
                      );
                    case 1:
                      return _ReviewSection(
                        reviews: data.reviews ?? [],
                        star: _warning,
                        starBg: _divider,
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                }),
              ),
              SizedBox(height: getHeight(8)),
            ],
          ),
        );
      }),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          getWidth(24),
          0,
          getWidth(24),
          getHeight(16),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
          child: SizedBox(
            width: double.infinity,
            height: getHeight(54),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                backgroundColor: _cta,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              onPressed: () {
                // You might need to adjust this navigation logic
                // based on how your booking flow works now.
                // Get.to(() => AppointmentScreen(businessId: id));
              },
              child: Text(
                "Booking Now",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: getWidth(16),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build the icons
  Widget _buildIcon(
    IconData icon, {
    required VoidCallback onTap,
    bool isFavorite = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.45),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isFavorite ? Colors.redAccent : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

// --------------------------- Widgets ---------------------------

class _TabChip extends StatelessWidget {
  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;
  final Color brand;
  final Color chipBg;

  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.brand,
    required this.chipBg,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? chipBg : const Color(0xffF4F4F4);
    final border = selected ? Border.all(color: brand, width: 1.5) : null;
    final fg = selected ? brand : const Color(0xff898989);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: getHeight(10),
          horizontal: getWidth(18),
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: border,
        ),
        child: Row(
          children: [
            Image.asset(
              icon,
              height: getHeight(22),
              width: getWidth(22),
              color: fg,
            ),
            SizedBox(width: getWidth(6)),
            Text(
              label,
              style: TextStyle(
                fontSize: getWidth(16),
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutSection extends StatefulWidget {
  final ShopDetailsModel data;
  final Color titleColor, bodyColor, divider;

  const _AboutSection({
    required this.data,
    required this.titleColor,
    required this.bodyColor,
    required this.divider,
  });

  @override
  State<_AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<_AboutSection> {
  bool _isExpanded = false;
  final int _maxLines = 3; // Max lines to show when collapsed

  // Helper function to format the time
  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return 'N/A';
    }
    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, hour, minute);
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      return timeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final aboutUsText = widget.data.aboutUs ?? '';
    // Use a LayoutBuilder to check if the text will actually overflow
    final textSpan = TextSpan(
      text: aboutUsText,
      style: TextStyle(fontSize: getWidth(14)),
    );
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: _maxLines,
      textDirection: Directionality.of(context),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        textPainter.layout(maxWidth: constraints.maxWidth);
        final isTextOverflowing = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: "About Us",
              fontSize: getWidth(17),
              fontWeight: FontWeight.w600,
              color: widget.titleColor,
            ),
            SizedBox(height: getHeight(8)),
            // Animated text section
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Text(
                aboutUsText,
                maxLines: _isExpanded ? null : _maxLines,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: getWidth(14),
                  color: widget.bodyColor,
                  height: 1.45,
                ),
              ),
            ),
            // Show More/Less button
            if (isTextOverflowing)
              TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    EdgeInsets.fromLTRB(0, 5, 0, 0),
                  ),
                  minimumSize: WidgetStateProperty.all(Size(0, 0)),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? "Show Less" : "Show More",
                  style: TextStyle(color: Get.theme.primaryColor),
                ),
              ),
            SizedBox(height: getHeight(18)),
            CustomText(
              text: "Opening Hours",
              fontSize: getWidth(17),
              fontWeight: FontWeight.w600,
              color: widget.titleColor,
            ),
            SizedBox(height: getHeight(10)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Monday - Sunday", // Placeholder
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  "${_formatTime(widget.data.startAt)} - ${_formatTime(widget.data.closeAt)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            SizedBox(height: getHeight(16)),
            Divider(color: widget.divider, height: 1),
            SizedBox(height: getHeight(16)),
            _ServiceSection(
              services: widget.data.services ?? [],
              priceColor: widget.titleColor,
              subtitleColor: widget.bodyColor,
            ),
          ],
        );
      },
    );
  }
}

class _ServiceSection extends StatelessWidget {
  final List<Service> services;
  final Color priceColor;
  final Color subtitleColor;

  const _ServiceSection({
    required this.services,
    required this.priceColor,
    required this.subtitleColor,
  });

  void _openServiceDetails(Service s) {
    final id = s.id;
    if (id != null) {
      Get.to(() => ServiceDetailsScreen(serviceId: id));
    } else {
      Get.snackbar('Unavailable', 'This service has no ID.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: getHeight(24)),
        child: Center(
          child: CustomText(
            text: "No Services Available",
            color: subtitleColor,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: "Our Services",
          fontSize: getWidth(16),
          fontWeight: FontWeight.w700,
        ),
        SizedBox(height: getHeight(12)),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          separatorBuilder: (_, __) => SizedBox(height: getHeight(12)),
          itemBuilder: (_, i) {
            final s = services[i];
            final price = (s.discountPrice != null && s.discountPrice! > 0)
                ? s.discountPrice
                : s.price;

            // safe image provider (avoid empty-string NetworkImage)
            final ImageProvider avatarImage =
                (s.serviceImg != null && s.serviceImg!.isNotEmpty)
                ? NetworkImage(s.serviceImg!)
                : const AssetImage(ImagePath.profileImage);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () => _openServiceDetails(s),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: getHeight(6)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: getWidth(28),
                            backgroundImage: avatarImage,
                            backgroundColor: const Color(0xffE5E7EB),
                          ),
                          SizedBox(width: getWidth(12)),
                          SizedBox(
                            width: getWidth(200),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.title ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: getWidth(16),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: getHeight(2)),
                                Text(
                                  s.description ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: getWidth(13),
                                    color: subtitleColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "\$${price?.toStringAsFixed(0) ?? '0'}",
                        style: TextStyle(
                          fontSize: getWidth(16),
                          fontWeight: FontWeight.w600,
                          color: priceColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final List<Review> reviews;
  final Color star;
  final Color starBg;

  const _ReviewSection({
    required this.reviews,
    required this.star,
    required this.starBg,
  });

  @override
  Widget build(BuildContext context) {
    if (reviews.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: getHeight(24)),
        child: const Center(child: Text("No reviews yet")),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (_, i) {
        final r = reviews[i];
        return _ReviewCard(
          image: r.profileImage ?? '',
          name: r.userName ?? '',
          review: r.review ?? '',
          rating: (r.rating ?? 0).toDouble(),
          star: star,
          starBg: starBg,
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String image;
  final String name;
  final String review;
  final double rating;
  final Color star;
  final Color starBg;

  const _ReviewCard({
    required this.image,
    required this.name,
    required this.review,
    required this.rating,
    required this.star,
    required this.starBg,
  });

  @override
  Widget build(BuildContext context) {
    final full = rating.floor().clamp(0, 5);

    return Card(
      elevation: 0,
      margin: EdgeInsets.only(bottom: getHeight(12)),
      child: Padding(
        padding: EdgeInsets.all(getWidth(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: getWidth(26),
              child: ClipOval(
                child: (image.isNotEmpty && image != 'null')
                    ? Image.network(
                        image,
                        fit: BoxFit.cover,
                        width: getWidth(52),
                        height: getWidth(52),
                      )
                    : Image.asset(
                        ImagePath.profileImage,
                        fit: BoxFit.cover,
                        width: getWidth(52),
                        height: getWidth(52),
                      ),
              ),
            ),
            SizedBox(width: getWidth(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: getWidth(16),
                    ),
                  ),
                  SizedBox(height: getHeight(6)),
                  Row(
                    children: [
                      for (int i = 0; i < 5; i++)
                        Padding(
                          padding: EdgeInsets.only(right: getWidth(2)),
                          child: Icon(
                            Icons.star,
                            size: getWidth(18),
                            color: i < full ? star : starBg,
                          ),
                        ),
                      SizedBox(width: getWidth(6)),
                      Text(
                        "(${rating.toStringAsFixed(1)})",
                        style: TextStyle(fontSize: getWidth(13)),
                      ),
                    ],
                  ),
                  SizedBox(height: getHeight(8)),
                  Text(
                    review,
                    style: TextStyle(fontSize: getWidth(14), height: 1.45),
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

// ─────────────────────────── optional: schedule tab (unchanged UI) ───────────────────────────
// Keep your original SchedTab if you want; Figma screens don’t show it.
// If you still need it visually aligned, you can keep your existing SchedTab implementation.
// (Omitted here for brevity.)
