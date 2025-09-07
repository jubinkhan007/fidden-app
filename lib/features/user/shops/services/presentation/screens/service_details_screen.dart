// lib/features/user/shops/services/presentation/screen/service_details_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/user/home/presentation/screen/shop_details_screen.dart';
import 'package:fidden/features/user/shops/services/controller/service_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

//  NEW
import 'package:fidden/features/user/wishlist/controller/wishlist_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:table_calendar/table_calendar.dart';

class ServiceDetailsScreen extends StatelessWidget {
  const ServiceDetailsScreen({super.key, required this.serviceId});
  final int serviceId;

  static const fallbackImg =
      'https://plus.unsplash.com/premium_photo-1661645788141-8196a45fb483?q=80&w=1170&auto=format&fit=crop&ixlib=rb-4.1.0';

  @override
  Widget build(BuildContext context) {
    final c = Get.put(ServiceDetailsController(serviceId));

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

                            final now = DateTime.now();
                            final today = DateTime(
                              now.year,
                              now.month,
                              now.day,
                            );
                            final windowEnd = today.add(
                              const Duration(days: 6),
                            );

                            // Show the whole current month to avoid the “first day missing” bug,
                            // but only ENABLE today..+6.
                            final firstVisible = DateTime(
                              today.year,
                              today.month,
                              1,
                            );
                            final lastVisible = DateTime(
                              today.year,
                              today.month + 1,
                              0,
                            );

                            bool inWindow(DateTime d) =>
                                !d.isBefore(today) && !d.isAfter(windowEnd);

                            return TableCalendar(
                              firstDay: firstVisible,
                              lastDay: lastVisible,
                              focusedDay:
                                  selected.isBefore(firstVisible) ||
                                      selected.isAfter(lastVisible)
                                  ? today
                                  : selected,

                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                leftChevronVisible: true,
                                rightChevronVisible: true,
                              ),
                              startingDayOfWeek: StartingDayOfWeek.sunday,
                              availableGestures: AvailableGestures.none,

                              selectedDayPredicate: (d) =>
                                  d.year == selected.year &&
                                  d.month == selected.month &&
                                  d.day == selected.day,

                              onDaySelected: (sel, foc) {
                                if (!inWindow(sel))
                                  return; // only allow today..+6
                                c.selectedDate.value = sel;
                                c.fetchSlotsForDate(sel);
                              },

                              enabledDayPredicate:
                                  inWindow, // disable past/future outside window

                              calendarStyle: CalendarStyle(
                                outsideDaysVisible: false,
                                todayDecoration: const BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Get.theme.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                selectedTextStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                                // We’ll still set these, but builders below will enforce them.
                                defaultTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF120D1C),
                                ),
                                weekendTextStyle: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF120D1C),
                                ),
                                disabledTextStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              // Force the day text style to bold + #120D1C
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (ctx, day, foc) => Center(
                                  child: Text(
                                    '${day.day}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: inWindow(day)
                                          ? const Color(0xFF120D1C)
                                          : Colors.grey.shade400,
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
                                selectedBuilder: (ctx, day, foc) => Container(
                                  width: 35,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Get.theme.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    '', // we'll draw the number below
                                  ),
                                ),
                                // draw the selected number on top in white + bold
                                // (alternative to selectedTextStyle when overriding builders)
                                markerBuilder: (ctx, day, evts) {
                                  if (day.year == selected.year &&
                                      day.month == selected.month &&
                                      day.day == selected.day) {
                                    return Center(
                                      child: Text(
                                        '${day.day}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    );
                                  }
                                  return null;
                                },
                              ),
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
                            if (c.isLoadingSlots.value) {
                              return _SlotsShimmer();
                            }
                            if (c.slots.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
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
                                final label = c.fmtTimeLocal(
                                  s.startTimeUtc,
                                ); // local
                                return _TimeChip(
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
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Get.theme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            onPressed: () {
                              final slotId = c.selectedSlotId.value;
                              if (slotId == null) {
                                Get.snackbar(
                                  'Select a time',
                                  'Please select a time slot to continue.',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }
                              Get.snackbar(
                                'Proceed to book',
                                'Slot #$slotId on ${c.selectedDate.value.toString().substring(0, 10)}',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                            child: const Text(
                              'Book Now',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ),
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
    // (Optional) deep link/URL if you have one
    // final url = 'https://fidden.app/service/$serviceId';

    final msg = StringBuffer()
      ..writeln(
        'Check out "$title"${shop.isNotEmpty ? ' at $shop' : ''} on Fidden.',
      )
      ..write(price != null ? 'Price: \$$price' : '');
    // ..writeln()
    // ..write(url);

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

class _TimeChip extends StatelessWidget {
  const _TimeChip({
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
      onTap: available ? onTap : null, // ⬅️ disabled if not available
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

class _SlotsShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // simple shimmer stub (no Shimmer dep to keep it light)
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        6,
        (i) => Container(
          width: 90,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFECEFF4),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

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
    // measure overflow
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
              style:
                  widget.linkStyle ??
                  TextStyle(
                    color: Color(0xff111827),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
      ],
    );
  }
}
