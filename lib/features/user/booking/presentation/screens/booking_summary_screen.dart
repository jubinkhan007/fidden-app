import 'package:fidden/features/user/booking/controller/booking_summary_controller.dart';
import 'package:fidden/features/user/coupons/data/user_coupon_model.dart';
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

  UserCoupon? _appliedCoupon; // from the select screen
double get _basePrice => discountPrice ?? servicePrice;
double get _couponDiscount {
  if (_appliedCoupon == null) return 0;
  final c = _appliedCoupon!;
  final raw = c.inPercentage ? (_basePrice * c.amount / 100.0) : c.amount;
  return raw.clamp(0, _basePrice); // don’t drop below zero
}
double get _payable => (_basePrice - _couponDiscount);

// helper to open select screen
Future<void> _chooseCoupon() async {
  final args = (Get.arguments as Map<String, dynamic>?) ?? {};
  final booking = (args['booking'] as Map<String, dynamic>?) ?? {};
  final serviceId = booking['service_id'] as int? ?? args['serviceId'] as int? ?? 0;
  final shopId    = booking['shop_id'] as int? ?? args['shopId'] as int? ?? 0;

  if (serviceId == 0 || shopId == 0) {
    Get.snackbar('Unavailable', 'Missing shop/service to lookup coupons.');
    return;
  }




  final res = await Get.toNamed('/select-coupon', arguments: {
    'shopId': shopId,
    'serviceId': serviceId,
  });

  if (res == null) {
    setState(() => _appliedCoupon = null); // cleared
  } else if (res is UserCoupon) {
    setState(() => _appliedCoupon = res);
  }
}

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

    // Extract shopId like you already do elsewhere
    final booking = (args['booking'] as Map<String, dynamic>?) ?? {};
    final int shopId = booking['shop_id'] as int? ?? args['shopId'] as int? ?? 0;

    if (shopId > 0) {
      controller.fetchPolicy(shopId); // <-- fetch immediately
    }

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

// helper (put inside the widget or a utils file)
  bool _isSelectedSlotInFuture({required Map<String, dynamic>? args, required int slotId}) {
    final preload = args?['preload'] as Map<String, dynamic>?;
    if (preload == null) return true; // can't verify, let backend decide
    final slots = (preload['slots'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    final m = slots.firstWhereOrNull((e) => e['id'] == slotId);
    if (m == null) return true; // not found, defer to backend
    final startIso = m['start'] as String?;
    if (startIso == null) return true;
    final startLocal = DateTime.parse(startIso).toLocal();
    return startLocal.isAfter(DateTime.now());
  }
  final args = Get.arguments as Map<String, dynamic>?;

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

              const SizedBox(height: 24),
              _buildSectionTitle("Coupon", color: primaryTextColor),
const SizedBox(height: 12),
if (_appliedCoupon != null) ...[
  Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: Container(
        width: 44, height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(_appliedCoupon!.shortAmountLabel,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      title: Text(_appliedCoupon!.code, style: const TextStyle(fontWeight: FontWeight.w800)),
      subtitle: Text(_appliedCoupon!.description, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: IconButton(
        icon: const Icon(Icons.close_rounded),
        onPressed: () => setState(() => _appliedCoupon = null),
        tooltip: 'Remove',
      ),
    ),
  ),
  const SizedBox(height: 10),
],
SizedBox(
  width: double.infinity,
  child: OutlinedButton.icon(
    onPressed: _chooseCoupon,
    icon: const Icon(Icons.local_offer_rounded),
    label: Text(_appliedCoupon == null ? 'Apply coupon' : 'Change coupon',
        style: const TextStyle(fontWeight: FontWeight.w800)),
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
),
// const SizedBox(height: 12),
//               const TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Enter promo code',
//                   border: OutlineInputBorder(),
//                 ),
//               ),


              // ─── Payment Section ────────────────────────
              const SizedBox(height: 24),
              _buildSectionTitle("Pay with", color: primaryTextColor),
              const SizedBox(height: 12),
              Obx(() => Column(
                children: [
                  _PaymentOptionTile(
                    title: 'Credit / Debit Card',
                    icon: Icons.credit_card,
                    value: 'stripe',
                    groupValue: controller.selectedPaymentMethod.value,
                    onChanged: (v) => controller.setPaymentMethod(v!),
                  ),
                  const SizedBox(height: 8),
                  _PaymentOptionTile(
                    title: 'PayPal',
                    icon: Icons.paypal, // Or use Icons.payment if paypal icon isn't available
                    value: 'paypal',
                    groupValue: controller.selectedPaymentMethod.value,
                    onChanged: (v) => controller.setPaymentMethod(v!),
                  ),
                ],
              )),

              const SizedBox(height: 32),

              // ─── Price Breakdown ────────────────────────
              _buildSectionTitle("Price Breakdown", color: primaryTextColor),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _PriceRow(label: 'Service Price', amount: servicePrice),
                    if (discountPrice != null)
                      _PriceRow(
                        label: 'Discount',
                        amount: '-${(servicePrice - (double.tryParse(discountPrice.toString()) ?? 0)).toStringAsFixed(2)}',
                        isDiscount: true,
                      ),
                    const Divider(height: 24),
                    _PriceRow(
                      label: 'Total Amount',
                      amount: servicePrice,
                      isTotal: true,
                    ),
                    
                    // NEW: Deposit Amount Display
                    Obx(() {
                      if (controller.isDepositRequired.value) {
                        final deposit = controller.getDepositAmount(servicePrice);
                        if (deposit > 0) {
                          return Column(
                            children: [
                              const SizedBox(height: 8),
                              _PriceRow(
                                label: 'Deposit to Pay Now (${controller.defaultDepositPercentage.value}%)',
                                amount: deposit,
                                isTotal: true, // bold
                                color: Get.theme.primaryColor,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Remaining amount will be paid at the shop.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          );
                        }
                      }
                      return const SizedBox.shrink();
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              _buildSectionTitle(
                "Cancellation policy",
                color: primaryTextColor,
              ),
              const SizedBox(height: 8),
              Obx(() {
                final p = controller.policy.value;
                if (p == null) {
                  return const Text(
                    'Loading policy…',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
                  );
                }

                // Optional: show the exact free-cancel deadline relative to selected time
                DateTime? start;
                try { start = _slotFmt.parse(selectedSlot).toLocal(); } catch (_) {}
                String extra = '';
                if (start != null) {
                  final freeDeadline = start.subtract(Duration(hours: p.freeH));
                  extra = ' (until ${DateFormat('MMM d, h:mm a').format(freeDeadline)})';
                }

                final parts = <String>[
                  'Free cancellation up to ${p.freeH}h$extra.',
                  if (p.feePct > 0) 'A ${p.feePct}% fee may apply within ${p.freeH}h.',
                  if (p.noRefundH > 0) 'No refunds within the last ${p.noRefundH}h.',
                ];

                return Text(
                  parts.join(' '),
                  style: const TextStyle(color: Color(0xFF6B7280), fontSize: 14, height: 1.4),
                );
              }),
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
              const SizedBox(height: 100), // spacer for bottom bar
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(() {
               final busy = controller.isPaying.value;
               return ElevatedButton(
                onPressed: (controller.isTermsAgreed.value && !busy)
                    ? () {
                  // HARD client guard
                  if (!_isSelectedSlotInFuture(args: args, slotId: bookingId)) {
                    Get.defaultDialog(
                      title: 'This slot has passed',
                      middleText: 'Please pick another time. We’ll find you a new opening.',
                      textConfirm: 'OK',
                      onConfirm: Get.back,
                    );
                    return;
                  }

                  // NEW: Pass add_on_ids
                  final rawAddOns = (Get.arguments as Map?)?['add_on_ids'];
                  final addOnIds = (rawAddOns is List) 
                      ? rawAddOns.map((e) => int.tryParse('$e') ?? 0).where((e) => e > 0).toList()
                      : <int>[];

                  controller.processPayment(
                    slotId: bookingId,
                    couponId: _appliedCoupon?.id,
                    addOnIds: addOnIds,
                    successArgs: {
                      'serviceName': serviceName,
                      'dateTimeText': selectedSlot,
                      'shopName': shopName,
                      'location': shopAddress,
                      'bookingId': bookingId,
                      'service_img': serviceImg,
                      'price': servicePrice,
                      'discountPrice': discountPrice,
                      'appliedCoupon': _appliedCoupon == null ? null : {
                        'id': _appliedCoupon!.id,
                        'code': _appliedCoupon!.code,
                      },
                    },
                  );
                }
                    : null,

                child: busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Confirm & Pay',
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
              );
            }),
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

  if (initLocal != null) {
    final d = DateTime(initLocal.year, initLocal.month, initLocal.day);
    c.selectedDate.value = d;
  }

  // ★ preselect the time chip by id (you already keep the slot id in bookingId)
  if (bookingId != 0) {
    c.selectedSlotId.value = bookingId;
  }

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
  // show today's number even if not selected
  todayBuilder: (ctx, day, foc) => Center(
    child: Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(width: 2),          // subtle ring
        shape: BoxShape.circle,
      ),
      child: Text(
        '${day.day}',
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    ),
  ),
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
        '${day.day}',
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    ),
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
                        final localStart = c.toShopTz(sel.startTimeUtc); // Use shop timezone, not device local
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









class _PaymentOptionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentOptionTile({
    required this.title,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    // Use your primary color or hardcode it
    const activeColor = Color(0xFFDC143C);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected ? activeColor : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? activeColor.withOpacity(0.05) : Colors.white,
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: activeColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        title: Row(
          children: [
            Icon(icon, color: isSelected ? activeColor : Colors.grey.shade700),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? const Color(0xFF111827) : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final dynamic amount; // String or double
  final bool isDiscount;
  final bool isTotal;
  final Color? color;

  const _PriceRow({
    required this.label,
    required this.amount,
    this.isDiscount = false,
    this.isTotal = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    String valueText;
    if (amount is num) {
      valueText = '\$${(amount as num).toStringAsFixed(2)}';
    } else {
      valueText = amount.toString();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: color ?? (isTotal ? Colors.black : Colors.grey.shade600),
            ),
          ),
          Text(
            valueText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isDiscount ? Colors.green : (isTotal ? Colors.black : Colors.black87)),
            ),
          ),
        ],
      ),
    );
  }
}