// lib/features/user/shops/services/presentation/screen/service_details_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/booking/presentation/screens/booking_details_screen.dart';
import 'package:fidden/features/user/booking/presentation/screens/booking_summary_screen.dart';
import 'package:fidden/features/user/home/presentation/screen/shop_details_screen.dart';
import 'package:fidden/features/user/shops/services/controller/service_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vector_math/vector_math_64.dart' show Matrix4;
import 'package:fidden/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key, required this.serviceId});
  final int serviceId;

  static const fallbackImg =
      'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0';

  @override
  Widget build(BuildContext context) {
    final RxBool _bookingBusy = false.obs; // ← spinner state
    final tag = 'svc_${serviceId}';
final c = Get.isRegistered<ServiceDetailsController>(tag: tag)
    ? Get.find<ServiceDetailsController>(tag: tag)
    : Get.put(ServiceDetailsController(serviceId), tag: tag, permanent: true);

    //  Ensure we have a WishlistController to manage the heart state
    final wishlist = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          final d = c.details.value;

          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: false,
                    floating: false,
                    snap: false,
                    elevation: 0,
                    backgroundColor: Colors.white,
                    automaticallyImplyLeading: false,
                    expandedHeight: 260,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: [
                          Positioned.fill(
                            child: CachedNetworkImage(
                              imageUrl: (d?.serviceImg?.isNotEmpty ?? false)
                                  ? d!.serviceImg!
                                  : fallbackImg,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey[300]),
                              errorWidget: (_, __, ___) =>
                                  Image.network(fallbackImg, fit: BoxFit.cover),
                            ),
                          ),
                          // top bar icons
                          Positioned(
                            top: 8,
                            left: 8,
                            right: 8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _roundIcon(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  onTap: () => Navigator.of(context).pop(),
                                ),
                                Row(
                                  children: [
                                    //  FAVORITE (reactive)
                                    Obx(() {
                                      final isFav = wishlist.isServiceFavorite(
                                        serviceId,
                                      );
                                      return _roundIcon(
                                        icon: isFav
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        onTap: () => wishlist
                                            .toggleServiceFavoriteByServiceId(
                                              serviceId,
                                            ),
                                      );
                                    }),
                                    const SizedBox(width: 8),
                                    //  SHARE
                                    _roundIcon(
                                      icon: Icons.ios_share_rounded,
                                      onTap: () => _shareService(d),
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

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          CustomText(
                            text: d?.title ?? '—',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            maxLines: 2,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Price
                          Row(
                            children: [
                              ...() {
                                double? _toDouble(String? s) {
                                  if (s == null) return null;
                                  final cleaned = s.replaceAll(
                                    RegExp(r'[^0-9.\-]'),
                                    '',
                                  );
                                  return double.tryParse(cleaned);
                                }

                                final currentStr =
                                    (d?.discountPrice != null &&
                                            d!.discountPrice!.trim().isNotEmpty)
                                        ? d.discountPrice
                                        : d?.price;
                                final current = _toDouble(currentStr) ?? 0.0;
                                final original = _toDouble(d?.price);

                                final showOriginal =
                                    (original != null && original > current);

                                return [
                                  CustomText(
                                    text: '\$${currentStr ?? '0'}',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  if (showOriginal) ...[
                                    const SizedBox(width: 10),
                                    Text(
                                      '\$${d!.price}',
                                      style: TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey.shade600,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(width: 6),
                                  Text(
                                    '/ session',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ];
                              }(),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Shop row
                          if (d != null)
                            _ShopRow(
                              name: d.shopName,
                              rating: d.avgRating ?? 0,
                              reviews: d.reviewCount ?? 0,
                              onView: () => Get.to(
                                () =>
                                    ShopDetailsScreen(id: d.shopId.toString()),
                              ),
                            ),

                          const SizedBox(height: 18),
                          Divider(color: Colors.grey.shade300, height: 1),
                          const SizedBox(height: 18),

                          // About
                          CustomText(
                            text: 'About',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                          const SizedBox(height: 10),
                          _ExpandableText(
                            text: d?.description ?? '—',
                            maxLines: 5,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontSize: 15,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                            linkStyle: TextStyle(
                              color: Get.theme.primaryColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Duration
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 20,
                                color: Colors.grey.shade700,
                              ),
                              CustomText(text: 'Duration: '),
                              const SizedBox(width: 4),
                              Text(
                                '${d?.duration ?? 0} minutes',
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // Select a date
                          CustomText(
                            text: 'Available Dates',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          const SizedBox(height: 0),

                          Obx(() {
                            final selected = c.selectedDate.value;

                            // allow any future date (you can cap with +90 days if you like)
                            final now    = DateTime.now();
                            final today  = DateTime(now.year, now.month, now.day);
                            final firstDay = DateTime(today.year - 1, 1, 1);   // far past (for nav)
                            final lastDay  = DateTime(today.year + 1, 12, 31); // far future (for nav)

                            bool isPast(DateTime d) => d.isBefore(today);

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Month label stays in sync with calendar page
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    DateFormat('MMMM yyyy').format(selected),
                                    style: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                TableCalendar(
                                  firstDay: firstDay,
                                  lastDay: lastDay,
                                  focusedDay: selected,                   // keep calendar focused
                                  calendarFormat: CalendarFormat.month,   // <-- full month
                                  availableGestures: AvailableGestures.horizontalSwipe,
                                  startingDayOfWeek: StartingDayOfWeek.sunday,
                                  headerStyle: const HeaderStyle(
                                    formatButtonVisible: false,
                                    titleCentered: true,
                                    leftChevronVisible: true,
                                    rightChevronVisible: true,
                                  ),

                                  selectedDayPredicate: (d) =>
                                  d.year == selected.year &&
                                      d.month == selected.month &&
                                      d.day == selected.day,

                                  // Disable past days and shop closed days
                                  enabledDayPredicate: (day) => !isPast(day) && !c.isClosedDay(day),

                                  onDaySelected: (sel, foc) {
                                    if (isPast(sel) || c.isClosedDay(sel)) return;
                                    c.fetchSlotsForDate(sel); // updates selectedDate & loads slots
                                  },

                                  // keep the label in sync when user flips months
                                  onPageChanged: (focused) {
                                    // move focus but don't trigger slot load
                                    c.selectedDate.value = DateTime(focused.year, focused.month, c.selectedDate.value.day.clamp(1, 28));
                                  },

                                  calendarBuilders: CalendarBuilders(
                                    defaultBuilder: (ctx, day, foc) {
                                      final disabled = isPast(day) || c.isClosedDay(day);
                                      return Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: disabled ? Colors.grey.shade400 : const Color(0xFF120D1C),
                                          ),
                                        ),
                                      );
                                    },
                                    outsideBuilder: (ctx, day, foc) {
                                      final disabled = isPast(day) || c.isClosedDay(day);
                                      return Center(
                                        child: Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: disabled ? Colors.grey.shade300 : Colors.grey.shade600,
                                          ),
                                        ),
                                      );
                                    },
                                    selectedBuilder: (ctx, day, foc) => Center(
                                      child: Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: Get.theme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          '${day.day}',                 // ← show the number
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),

                                    todayBuilder: (ctx, day, foc) => Center(
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF120D1C),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),


                          const SizedBox(height: 0),

                          // Select a time
                          CustomText(
                            text: 'Select a time',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                          const SizedBox(height: 12),
                          Obx(() {
  // Show shimmer while:
  // - details still loading, OR
  // - first slots load hasn’t finished yet, OR
  // - a fetch is in progress
  final showShimmer = c.isLoadingDetails.value ||
                      !c.didLoadSlotsOnce.value ||
                      c.isLoadingSlots.value;

  if (showShimmer) {
    return SlotsShimmer(); // now real shimmer (see below)
  }

  if (c.slots.isEmpty) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        'No time slots available.',
        style: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }

  return Wrap(
    spacing: 10,
    runSpacing: 10,
    children: c.slots.map((s) {
      final isSel = c.selectedSlotId.value == s.id;
      final label = c.fmtTimeLocal(s.startTimeUtc);
      return TimeChip(
        text: label,
        selected: isSel,
        available: s.available,
        onTap: () => c.selectedSlotId.value = s.id,
      );
    }).toList(),
  );
}),

                          const SizedBox(height: 26),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Floating bottom bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x14000000),
                        offset: Offset(0, -6),
                        blurRadius: 16,
                      ),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(
                            () => Text(
                              'Total: \$${c.effectivePrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 0),
                        Expanded(
                          flex: 2,
                          child: Obx(() {
                            final busy = _bookingBusy.value;
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Get.theme.primaryColor,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 0,
                              ),
                              onPressed: busy
    ? null
    : () async {
        if (_bookingBusy.value) return;
        _bookingBusy.value = true;
        try {
          final slotId = c.selectedSlotId.value;
          if (slotId == null) {
            Get.snackbar(
              'Select a time',
              'Please select a time slot to continue.',
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }

          // find the selected slot to format the date/time
          DateTime? slotStartLocal;
          try {
            final slot = c.slots.firstWhere((s) => s.id == slotId);
            slotStartLocal = slot.startTimeUtc.toLocal();
          } catch (_) {}

          final slotLabel = (slotStartLocal != null)
              ? DateFormat('MMMM d, yyyy, h.mm a').format(slotStartLocal)
              : '—';

          String? currentPriceStr;
          String? originalPriceStr;
          final details = c.details.value;
          if (details != null) {
            final hasDiscount = (details.discountPrice != null &&
                details.discountPrice!.trim().isNotEmpty);
            currentPriceStr = hasDiscount ? details.discountPrice : details.price;
            originalPriceStr = details.price;
          }

          // ✅ No API call here. Just navigate with arguments.
          //    Use the selected slotId as the bookingId to keep the arg name.
          final args = {
            'bookingId': slotId, // ← passing slotId as the bookingId
            'serviceName': details?.title ?? '',
            'shopName': details?.shopName ?? '',
            'service_img': details?.serviceImg ?? '',
            'shopAddress': details?.shopAddress ?? '',
            'serviceDurationMinutes': details?.duration ?? 0,
            'selectedSlotLabel': slotLabel,
            'price': originalPriceStr ?? '',
            'discountPrice':
                (details?.discountPrice?.trim().isNotEmpty ?? false)
                    ? details?.discountPrice
                    : null,

            // keep a reference payload if the summary screen needs context
            'booking': {
              'slot_id': slotId,
              'service_id': details?.id,
              'shop_id': details?.shopId,
            },
            'preload': {
    'selectedDate': c.selectedDate.value.toIso8601String(),
    'slots': c.slots.map((s) => {
      'id': s.id,
      'start': s.startTimeUtc.toIso8601String(),
      'end': s.endTimeUtc.toIso8601String(),
      'available': s.available,
      'service': s.service,
      'shop': s.shop,
      'capLeft': s.capacityLeft,
    }).toList(),
  },
          };

          Get.to(() => BookingSummaryScreen(), arguments: args);
        } catch (e) {
          AppSnackBar.showError('Could not continue: $e');
        } finally {
          _bookingBusy.value = false;
        }
      },

                              // ─── Spinner or label ────────────────────────
                              child: busy
                                  ? const SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Book Now',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                      ),
                                    ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // --- helpers (unchanged) ---
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _roundIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white.withOpacity(0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: Colors.black),
        ),
      ),
    );
  }

  //  NEW: Share helper
  void _shareService(dynamic d) {
    final title = (d?.title ?? 'this service').toString();
    final shop = (d?.shopName ?? '').toString();
    final price = (d?.discountPrice?.toString()?.isNotEmpty == true)
        ? d?.discountPrice
        : d?.price;

    final msg = StringBuffer()
      ..writeln(
        'Check out "$title"${shop.isNotEmpty ? ' at $shop' : ''} on Fidden.',
      )
      ..write(price != null ? 'Price: \$$price' : '');

    Share.share(msg.toString());
  }
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.onView,
  });

  final String name;
  final double rating;
  final int reviews;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(radius: 18, backgroundColor: Color(0xFFE9EDF5)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: name,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                maxLines: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFFFC107),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${rating.toStringAsFixed(1)}  (${reviews} reviews)',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onView,
          child: Text(
            'View',
            style: TextStyle(
              color: Get.theme.primaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _DatePill extends StatelessWidget {
  const _DatePill({
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = '${_wkday(date.weekday)}\n${date.day} ${_mon(date.month)}';
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Get.theme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Get.theme.primaryColor : Colors.grey.shade300,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            height: 1.25,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  String _wkday(int w) =>
      const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][w - 1];
  String _mon(int m) => const [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ][m - 1];
}

class TimeChip extends StatelessWidget {
  const TimeChip({
    required this.text,
    required this.selected,
    required this.available,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final bool available;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bgColor = !available
        ? Colors.grey.shade200
        : (selected ? Get.theme.primaryColor : Colors.white);

    final txtColor = !available
        ? Colors.grey.shade500
        : (selected ? Colors.white : Colors.black);

    final borderColor = !available
        ? Colors.grey.shade300
        : (selected ? Get.theme.primaryColor : Colors.grey.shade300);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: available ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
          boxShadow: (selected)
              ? [
                  BoxShadow(
                    color: Get.theme.primaryColor.withOpacity(0.15),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(color: txtColor, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// Still in the same file, replace your old SlotsShimmer with:

class SlotsShimmer extends StatefulWidget {
  const SlotsShimmer({super.key});

  @override
  State<SlotsShimmer> createState() => _SlotsShimmerState();
}

class _SlotsShimmerState extends State<SlotsShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))
        ..repeat();

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (context, _) {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(8, (i) => _ShimmerChip(progress: _ac.value)),
        );
      },
    );
  }
}

class _ShimmerChip extends StatelessWidget {
  const _ShimmerChip({required this.progress});
  final double progress;

  @override
  Widget build(BuildContext context) {
    // simple moving gradient using animated stops
    final base = const Color(0xFFECEFF4);
    final hi = const Color(0xFFF5F7FB);

    // move a highlight across [0,1] by sliding the stops
    final mid = progress.clamp(0.0, 1.0);
    final start = (mid - 0.25).clamp(0.0, 1.0);
    final end = (mid + 0.25).clamp(0.0, 1.0);

    return Container(
      width: 90,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E7EE)),
      ),
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [base, hi, base],
            stops: [start, mid, end],
            tileMode: TileMode.clamp,
          ).createShader(rect);
        },
        blendMode: BlendMode.srcATop,
        child: Container(
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}


/// Convenience gradient transform

// class GradientTranslation extends GradientTransform {
//   final double dx, dy;
//   const GradientTranslation(this.dx, this.dy);

//   @override
//   Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
//     // This now correctly uses the Matrix4 class from the Flutter framework
//     return Matrix4.translationValues(dx, dy, 0.0);
//   }
// }


class _ExpandableText extends StatefulWidget {
  const _ExpandableText({
    required this.text,
    this.maxLines = 5,
    required this.style,
    this.linkStyle,
  });

  final String text;
  final int maxLines;
  final TextStyle style;
  final TextStyle? linkStyle;

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText>
    with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
    )..layout(maxWidth: MediaQuery.of(context).size.width);

    final overflows = tp.didExceedMaxLines;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: Text(
            widget.text,
            maxLines: _expanded ? null : widget.maxLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: widget.style,
          ),
        ),
        if (overflows)
          TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => setState(() => _expanded = !_expanded),
            child: Text(
              _expanded ? 'Show Less' : 'Show More',
              style: widget.linkStyle ??
                  const TextStyle(
                    color: Color(0xff111827),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
      ],
    );
  }
}
