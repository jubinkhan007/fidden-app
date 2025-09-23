import 'package:fidden/features/user/booking/controller/booking_summary_controller.dart';
import 'package:fidden/features/user/shops/services/data/time_slots_model.dart';
import 'package:fidden/features/user/shops/services/presentation/screens/service_details_screen.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer';
import 'package:intl/intl.dart';
import 'package:fidden/features/user/shops/services/controller/service_details_controller.dart';
import 'package:table_calendar/table_calendar.dart';

// same format you used when creating selectedSlotLabel
final _slotFmt = DateFormat('MMMM d, yyyy, h.mm a');
// --- FIX: Converted to StatefulWidget for safe argument handling ---
class BookingSummaryScreen extends StatefulWidget {
  const BookingSummaryScreen({super.key});

  @override
  State<BookingSummaryScreen> createState() => _BookingSummaryScreenState();
}

class _BookingSummaryScreenState extends State<BookingSummaryScreen> {
  // --- All properties are now state variables ---
  late final String serviceName;
  late final String shopName;
  late final String serviceImg;
  late final String shopAddress;
  late final int serviceDuration;
  late String selectedSlot;
  late final double servicePrice;
  late final double? discountPrice;
  late int bookingId; // <-- Will hold the booking ID
  final _openingSheet = false.obs;


  final controller = Get.put(BookingSummaryController());
  late final TapGestureRecognizer _termsTap;

  @override
  void initState() {
    super.initState();
    // --- FIX: Arguments are now safely accessed in initState ---
    final Map<String, dynamic> args = Get.arguments ?? {};

    serviceName = args['serviceName'] ?? '';
    serviceImg = args['service_img'] ?? '';
    shopName = args['shopName'] ?? '';
    shopAddress = args['shopAddress'] ?? '';
    serviceDuration = args['serviceDurationMinutes'] ?? 0;
    selectedSlot = args['selectedSlotLabel'] ?? '';
    servicePrice = (args['price'] is num)
        ? (args['price'] as num).toDouble()
        : double.tryParse('${args['price']}') ?? 0.0;
    discountPrice = (args['discountPrice'] == null)
        ? null
        : double.tryParse('${args['discountPrice']}');

    // Safely get the bookingId
    bookingId = args['bookingId'] as int? ?? 0;

    // Log an error if the bookingId is missing, for easier debugging
    if (bookingId == 0) {
      log('Error: Booking ID is missing on the summary screen.');
    }
    _termsTap = TapGestureRecognizer()..onTap = () {
    Get.toNamed(AppRoute.termsAndCondition); // your GetPage route name
  };
  }

  @override
void dispose() {
  _termsTap.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    const Color primaryTextColor = Color(0xFF111827);
    const Color secondaryTextColor = Color(0xFF6B7280);
    const Color backgroundColor = Color(0xFFF9FAFB);

    // --- FIX: WillPopScope now correctly calls the controller with the bookingId ---
    return WillPopScope(
  onWillPop: () async {
    final realBookingId = controller.paymentBookingId.value; // 0 until paymentIntent returns
    if (realBookingId > 0) {
      await controller.cancelBooking(realBookingId);
    }
    return true;
  },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('Booking Summary'),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("Service Details", color: primaryTextColor),
              const SizedBox(height: 12),
              _ServiceDetailsCard(
                serviceName: serviceName,
                shopName: shopName,
                shopAddress: shopAddress,
                duration: serviceDuration,
                serviceImg: serviceImg, // Pass the image URL
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Date & Time", color: primaryTextColor),
              const SizedBox(height: 12),
              Obx(() => _DateTimeCard(
  selectedSlot: selectedSlot,
  opening: _openingSheet.value,        // <— NEW
  onEdit: () async {
    _openingSheet.value = true;
    try {
      await _openScheduleSheet();
    } finally {
      _openingSheet.value = false;
    }
  },
)),
              const SizedBox(height: 24),
              _buildSectionTitle("Pricing Details", color: primaryTextColor),
              const SizedBox(height: 12),
              _PricingDetailsCard(
                servicePrice: servicePrice,
                discountPrice: discountPrice,
              ),
              const SizedBox(height: 24),
              _buildSectionTitle("Pay with", color: primaryTextColor),
              const SizedBox(height: 12),
              const _PaymentMethodCard(),
              const SizedBox(height: 24),
              _buildSectionTitle("Coupon", color: primaryTextColor),
              const SizedBox(height: 12),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'Enter promo code',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              _buildSectionTitle(
                "Cancellation policy",
                color: primaryTextColor,
              ),
              const SizedBox(height: 8),
              const Text(
                'Appointments can be canceled or rescheduled up to 24 hours in advance with no fee.',
                style: TextStyle(color: secondaryTextColor, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: controller.isTermsAgreed.value,
                      onChanged: controller.toggleTermsAgreement,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                          children: [
                            const TextSpan(text: 'I also agree to the '),
                            TextSpan(
                              text: 'Terms & Conditions',
                              style: const TextStyle(color: Colors.blue),
                              recognizer: _termsTap,
                            ),
                            const TextSpan(text: ' and '),
                            const TextSpan(
                              text: 'Cancellation Policy.',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => ElevatedButton(
                onPressed:
                    (controller.isTermsAgreed.value &&
                        !controller.isPaying.value)
                    ? () => controller.payForBooking(
                        slotId: bookingId,
                        successArgs: {
    'serviceName': serviceName,
    'dateTimeText': selectedSlot, // Use 'dateTimeText' key
    'shopName': shopName,
    'location': shopAddress, // Use 'location' key
    'bookingId': bookingId,
    'service_img': serviceImg,
    'price': servicePrice,
    'discountPrice': discountPrice,
},
                      )
                    : null,

                child: controller.isPaying.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC143C),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required Color color}) {
    return Text(
      title,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
    );
  }

DateTime? _parseSelectedSlot() {
  try {
    if (selectedSlot.trim().isEmpty) return null;
    return _slotFmt.parse(selectedSlot).toLocal();
  } catch (_) {
    return null;
  }
}

Future<void> _openScheduleSheet() async {
  final args = Get.arguments as Map<String, dynamic>? ?? {};
  final booking = (args['booking'] as Map<String, dynamic>?) ?? {};
  final serviceId = booking['service_id'] as int? ?? 0;
  if (serviceId == 0) {
    Get.snackbar('Unavailable', 'Cannot edit time without a service id.');
    return;
  }

  // Reuse a stable, permanent controller (cached)
  final tag = 'svc_$serviceId';
  final c = Get.isRegistered<ServiceDetailsController>(tag: tag)
      ? Get.find<ServiceDetailsController>(tag: tag)
      : Get.put(ServiceDetailsController(serviceId), tag: tag, permanent: true);

  // parse the current selected slot (for preselect after data arrives)
  final initLocal = _parseSelectedSlot();

  // Seed from preload if present (fast path, no network)
  final preload = (args['preload'] as Map<String, dynamic>?) ?? {};
  if (preload.isNotEmpty) {
    final preSlots = (preload['slots'] as List?) ?? const [];
    if (preSlots.isNotEmpty) {
      final sel = DateTime.tryParse(preload['selectedDate'] ?? '');
      final seeded = preSlots.map((m) => SlotItem(
        id: m['id'],
        shop: m['shop'],
        service: m['service'],
        startTimeUtc: DateTime.parse(m['start']),
        endTimeUtc: DateTime.parse(m['end']),
        capacityLeft: m['capLeft'],
        available: m['available'],
      )).toList();
      if (sel != null) {
        c.seedPreloadedSlots(selected: sel, preloaded: seeded); // fills cache + UI
      } else {
        c.slots.assignAll(seeded); // fallback
      }
    }
  }

  // 🔹 SHOW THE SHEET *NOW* — no awaits above this line
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      final media = MediaQuery.of(context);
      final height = media.size.height * 0.80;
      return SizedBox(
        height: height,
        child: Obx(() {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final windowEnd = today.add(const Duration(days: 6));
          final firstVisible = DateTime(today.year, today.month, 1);
          final lastVisible  = DateTime(today.year, today.month + 1, 0);
          bool inWindow(DateTime d) => !d.isBefore(today) && !d.isAfter(windowEnd);

          return Column(
            children: [
              const SizedBox(height: 8),
              Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 12),
              const Text('Select a new date & time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),

              // Calendar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TableCalendar(
                  firstDay: firstVisible,
                  lastDay: lastVisible,
                  focusedDay: c.selectedDate.value,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false, titleCentered: true,
                    leftChevronVisible: true, rightChevronVisible: true,
                  ),
                  startingDayOfWeek: StartingDayOfWeek.sunday,
                  availableGestures: AvailableGestures.none,
                  selectedDayPredicate: (d) =>
                      d.year == c.selectedDate.value.year &&
                      d.month == c.selectedDate.value.month &&
                      d.day == c.selectedDate.value.day,
                  onDaySelected: (sel, foc) async {
                    if (!inWindow(sel) || c.isClosedDay(sel)) return;
                    c.selectedDate.value = sel;
                    // fire & forget; cache returns instantly if warm
                    c.fetchSlotsForDate(sel, useCache: true);
                  },
                  enabledDayPredicate: (day) {
                    if (!inWindow(day)) return false;
                    return !c.isClosedDay(day);
                  },
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (ctx, day, foc) {
                      final disabled = !inWindow(day) || c.isClosedDay(day);
                      return Center(child: Text('${day.day}',
                        style: TextStyle(fontWeight: FontWeight.w800,
                          color: disabled ? Colors.grey.shade400 : const Color(0xFF120D1C))));
                    },
                    todayBuilder: (ctx, day, foc) => const Center(
                      child: Text('',
                        style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF120D1C))),
                    ),
                    selectedBuilder: (ctx, day, foc) => Center(
                      child: Container(width: 36, height: 36,
                        decoration: BoxDecoration(color: Get.theme.primaryColor, shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text('${day.day}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Slots
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Select a time',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.grey.shade900)),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Obx(() {
                    if (c.isLoadingSlots.value && c.slots.isEmpty) {
                      return SlotsShimmer();
                    }
                    if (c.slots.isEmpty) {
                      return Center(child: Text('No time slots available.', style: TextStyle(color: Colors.grey.shade700)));
                    }
                    return SingleChildScrollView(
                      child: Wrap(
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
                      ),
                    );
                  }),
                ),
              ),

              // Update button
              SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Obx(() {
                  final canUpdate = c.selectedSlotId.value != null;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: canUpdate ? () {
                        final selId = c.selectedSlotId.value!;
                        final sel = c.slots.firstWhere((e) => e.id == selId);
                        final localStart = sel.startTimeUtc.toLocal();
                        setState(() {
                          bookingId   = selId;
                          selectedSlot = _slotFmt.format(localStart);
                        });
                        Navigator.of(context).pop();
                      } : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Get.theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Text('Update', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      );
    },
  );

  // AFTER the sheet is shown: kick off any missing data loads in the background
  if (c.details.value == null) {
    // don’t block UI; when it finishes it will warm the cache
    c.fetchServiceDetails();
  }

  // preselect current slot day and load from cache/network in background
  final dayToLoad = initLocal != null
      ? DateTime(initLocal.year, initLocal.month, initLocal.day)
      : c.selectedDate.value;

  c.fetchSlotsForDate(dayToLoad, useCache: true).then((_) {
    if (initLocal != null) {
      for (final s in c.slots) {
        final diff = s.startTimeUtc.toLocal().difference(initLocal).inMinutes.abs();
        if (diff <= 1) {
          c.selectedSlotId.value = s.id;
          break;
        }
      }
    }
  });
}



}

// --- WIDGETS ---

class _ServiceDetailsCard extends StatelessWidget {
  final String serviceName;
  final String shopName;
  final String shopAddress;
  final int duration;
  final String serviceImg; // Added serviceImg

  const _ServiceDetailsCard({
    required this.serviceName,
    required this.shopName,
    required this.shopAddress,
    required this.duration,
    required this.serviceImg,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              // --- FIX: Use the actual service image URL ---
              child: Image.network(
                serviceImg.isNotEmpty
                    ? serviceImg
                    : 'https://placehold.co/80x80/cccccc/ffffff?text=Service',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported, size: 80),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shopName,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shopAddress,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$duration minutes',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
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

class _DateTimeCard extends StatelessWidget {
  final String selectedSlot;
  final VoidCallback onEdit;
  final bool opening; // NEW

  const _DateTimeCard({
    required this.selectedSlot,
    required this.onEdit,
    this.opening = false, // default
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: const Text('Experience Date & Time'),
        subtitle: Text(selectedSlot),
        trailing: opening
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.edit_calendar_rounded),
                onPressed: onEdit,
                tooltip: 'Edit date & time',
              ),
      ),
    );
  }
}



class _PricingDetailsCard extends StatelessWidget {
  final double servicePrice;
  final double? discountPrice;
  const _PricingDetailsCard({required this.servicePrice, this.discountPrice});

  @override
  Widget build(BuildContext context) {
    final double total = (discountPrice ?? servicePrice);
    final bool hasDiscount =
        discountPrice != null && discountPrice! < servicePrice;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _priceRow('Service Fee', '\$${servicePrice.toStringAsFixed(2)}'),
            if (hasDiscount) ...[
              const SizedBox(height: 8),
              _priceRow(
                'Discount',
                '- \$${(servicePrice - discountPrice!).toStringAsFixed(2)}',
              ),
            ],
            const Divider(height: 24),
            _priceRow(
              'Total Amount',
              '\$${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const ListTile(
        leading: Icon(Icons.payment, color: Colors.deepPurple),
        title: Text('Stripe'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}


