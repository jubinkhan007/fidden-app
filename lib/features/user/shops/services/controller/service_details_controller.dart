// lib/features/user/shops/services/controller/service_details_controller.dart
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/core/utils/timezone_helper.dart';
import 'package:fidden/features/user/shops/data/shop_details_model.dart';
import 'package:fidden/features/user/shops/services/data/service_details_model.dart';
import 'package:fidden/features/user/shops/services/data/time_slots_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../presentation/widgets/18+_required.dart';

class ServiceDetailsController extends GetxController {
  ServiceDetailsController(this.serviceId);

  final int serviceId;

  final isLoadingDetails = false.obs;
  final isLoadingSlots = false.obs;
  final didLoadSlotsOnce = false.obs;

  final details = Rxn<ServiceDetailsModel>();
  final acknowledged18Plus = false.obs;
  final slots = <SlotItem>[].obs;

  // date state
  final selectedDate = DateTime.now().obs; // today by default
  final next7Days = <DateTime>[].obs;

  // selected slot
  final selectedSlotId = RxnInt();
  final selectedSlotIso = RxnString(); // NEW: for rule-based slots logic

  void selectSlot(SlotItem s) {
    // If slot has a real ID, use it
    if (s.id > 0) {
      selectedSlotId.value = s.id;
      selectedSlotIso.value = null;
    } else {
      // Otherwise use the UTC ISO string as key
      selectedSlotId.value = 0; // or null
      selectedSlotIso.value =
          s.startAtUtcIso ?? s.startTimeUtc.toIso8601String();
    }
  }

  bool isSlotSelected(SlotItem s) {
    if (s.id > 0) {
      return selectedSlotId.value == s.id;
    }
    // Fallback equality check for computed slots
    final iso = s.startAtUtcIso ?? s.startTimeUtc.toIso8601String();
    return selectedSlotIso.value == iso;
  }

  // ───────── NEW: simple in-memory cache for slots (keyed by yyyy-MM-dd)
  final Map<String, List<SlotItem>> _slotsCache = {}; // NEW

  // ───────── NEW: Add-on Services Logic
  final shopServices = <Service>[].obs; // Available add-ons
  final selectedAddOns = <Service>[].obs; // Selected add-ons

  // Shop's timezone for displaying slot times
  final shopTimeZone = 'America/New_York'.obs;

  void toggleAddOn(Service service) {
    if (selectedAddOns.contains(service)) {
      selectedAddOns.remove(service);
    } else {
      selectedAddOns.add(service);
    }
  }

  double get effectivePrice {
    final d = details.value;
    if (d == null) return 0;
    final p = d.discountPrice ?? d.price ?? '0';
    double total = double.tryParse(p) ?? 0;

    // Add add-ons price
    for (var s in selectedAddOns) {
      total += (s.discountPrice ?? s.price ?? 0);
    }
    return total;
  }

  int get totalDuration {
    final d = details.value;
    int total = d?.duration ?? 0;
    for (var s in selectedAddOns) {
      total += (s.duration ?? 0);
    }
    return total;
  }

  @override
  void onInit() {
    super.onInit();
    _buildNext7Days();
    fetchServiceDetails();
  }

  void _buildNext7Days() {
    final now = DateTime.now();
    next7Days.assignAll(
      List.generate(7, (i) {
        final d = now.add(Duration(days: i));
        return DateTime(d.year, d.month, d.day);
      }),
    );
  }

  String _fmtDate(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  /// Format slot time in shop's timezone
  String fmtTimeLocal(DateTime utc) =>
      TimezoneHelper.formatInTimezone(utc, shopTimeZone.value);

  /// Format directly from ISO string (e.g. 2026-03-09T09:00:00-05:00)
  /// This ensures we show exactly what the backend sent (09:00) without double conversion
  String fmtTimeLocalFromIso(String iso) {
    try {
      // Parse DateTime with offset intact
      final dt = DateTime.parse(iso);
      // Format only time part
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  /// Convert UTC DateTime to shop's timezone DateTime
  DateTime toShopTz(DateTime utc) =>
      TimezoneHelper.toTimezone(utc, shopTimeZone.value);

  // Helper to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Check if slot falls on the given day in the shop's timezone
  bool _isSlotOnDayInShopTz(SlotItem slot, DateTime selectedDay) {
    final slotLocal = toShopTz(slot.startTimeUtc);
    return slotLocal.year == selectedDay.year &&
        slotLocal.month == selectedDay.month &&
        slotLocal.day == selectedDay.day;
  }

  Future<void> fetchServiceDetails() async {
    if (isLoadingDetails.value) return;
    isLoadingDetails.value = true;
    try {
      final url = Uri.parse('${AppUrls.allServices}$serviceId/');
      final res = await NetworkCaller().getRequest(
        url.toString(),
        token: AuthService.accessToken,
      );

      if (res.isSuccess && res.responseData is Map<String, dynamic>) {
        final svc = ServiceDetailsModel.fromJson(res.responseData);
        details.value = svc;

        // ── NEW: show 18+ warning if needed, once
        if (svc.requiresAge18Plus && !acknowledged18Plus.value) {
          final ok = await ensure18PlusAcknowledged();
          if (!ok) {
            // User declined; go back
            Get.back();
            return;
          }
          acknowledged18Plus.value = true;
        }

        // (rest of your code...)
        final shopResp = await NetworkCaller().getRequest(
          AppUrls.shopDetails((svc.shopId.toString())),
          token: AuthService.accessToken,
        );
        if (shopResp.isSuccess &&
            shopResp.responseData is Map<String, dynamic>) {
          final shop = ShopDetailsModel.fromJson(shopResp.responseData);
          applyClosedDays(shop.closeDays);

          // Store shop timezone for slot display
          if (shop.timeZone != null && shop.timeZone!.isNotEmpty) {
            shopTimeZone.value = shop.timeZone!;
          }

          // Store other services as potential add-ons
          if (shop.services != null) {
            shopServices.assignAll(
              shop.services!.where((s) => s.id != serviceId).toList(),
            );
          }
        }

        _snapSelectedToNextOpenInWindow();
        // Force refresh slots on entry to ensure real-time availability
        await fetchSlotsForDate(
          selectedDate.value,
          mutateSelection: true,
          force: true,
        );
        prefetchNext7Days();
      } else {
        AppSnackBar.showError(res.errorMessage ?? 'Failed to load service.');
      }
    } catch (e) {
      AppSnackBar.showError('Error loading service: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  /// Fetch slots for a date.
  /// [useCache]: read from cache if available.
  /// [force]: bypass cache and refresh from network.
  // signature
  Future<void> fetchSlotsForDate(
    DateTime date, {
    bool useCache = true,
    bool force = false,
    bool mutateSelection = true, // NEW
  }) async {
    final d = details.value;
    if (d == null) return;

    // Work on a normalized day for keying/cache
    final day = DateTime(date.year, date.month, date.day);
    final key = _fmtDate(day);

    if (mutateSelection) {
      selectedDate.value = day;
      selectedSlotId.value = null;
    }

    // Serve from cache
    if (useCache && !force && _slotsCache.containsKey(key)) {
      if (mutateSelection) {
        slots.assignAll(_slotsCache[key]!);
        didLoadSlotsOnce.value = true;
      }
      return;
    }

    isLoadingSlots.value = true;
    try {
      // Fetch current date's slots using NEW Rule-Based Availability API
      final uri = AppUrls.availability(
        shopId: d.shopId ?? 0,
        serviceId: serviceId,
        date: key,
      );

      final res = await NetworkCaller().getRequest(
        uri,
        token: AuthService.accessToken,
      );

      List<SlotItem> allSlots = [];

      // lib/features/user/shops/services/controller/service_details_controller.dart
      if (res.isSuccess && res.responseData is Map<String, dynamic>) {
        final parsed = SlotsResponse.fromJson(res.responseData);
        allSlots.addAll(parsed.slots);

        // Store timezone if available from slots response
        if (parsed.timezoneId != null && parsed.timezoneId!.isNotEmpty) {
          shopTimeZone.value = parsed.timezoneId!;
        }

        // Debug: Log first 3 slots
        for (var i = 0; i < parsed.slots.length && i < 3; i++) {
          final s = parsed.slots[i];
          final displayTime = s.startAtIso != null
              ? fmtTimeLocalFromIso(s.startAtIso!) // Use ISO string directly
              : fmtTimeLocal(s.startTimeUtc); // Fallback
          debugPrint(
            '🎰 Slot[${s.id}]: UTC=${s.startTimeUtc} → ShopTz=$displayTime',
          );
        }
      }

      // Also fetch next UTC day to capture slots that span timezone boundary
      // e.g., Dec 9 ET spans Dec 9 UTC afternoon and Dec 10 UTC morning
      final nextDay = day.add(const Duration(days: 1));
      final nextKey = _fmtDate(nextDay);

      final nextUri = AppUrls.availability(
        shopId: d.shopId ?? 0,
        serviceId: serviceId,
        date: nextKey,
      );

      final nextRes = await NetworkCaller().getRequest(
        nextUri.toString(),
        token: AuthService.accessToken,
      );

      if (nextRes.isSuccess && nextRes.responseData is Map<String, dynamic>) {
        final nextParsed = SlotsResponse.fromJson(nextRes.responseData);
        allSlots.addAll(nextParsed.slots);
      }

      List<SlotItem> processed = allSlots;

      // Mark past times unavailable based on shop's current time
      // Convert current time to shop timezone for accurate comparison
      final nowInShopTz = toShopTz(DateTime.now().toUtc());
      final todayInShopTz = DateTime(
        nowInShopTz.year,
        nowInShopTz.month,
        nowInShopTz.day,
      );

      // Check if selected day is "today" in shop timezone
      if (day.year == todayInShopTz.year &&
          day.month == todayInShopTz.month &&
          day.day == todayInShopTz.day) {
        processed = processed.map((slot) {
          if (!slot.available) return slot;
          // Compare slot time with current time in shop timezone
          final slotInShopTz = toShopTz(slot.startTimeUtc);
          if (slotInShopTz.isBefore(nowInShopTz)) {
            return SlotItem(
              id: slot.id,
              shop: slot.shop,
              service: slot.service,
              startTimeUtc: slot.startTimeUtc,
              endTimeUtc: slot.endTimeUtc,
              capacityLeft: slot.capacityLeft,
              available: false,
            );
          }
          return slot;
        }).toList();
      }

      // Filter slots that fall on the selected day in shop timezone
      // This handles cases where UTC date ≠ shop timezone date
      processed = processed.where((s) => _isSlotOnDayInShopTz(s, day)).toList();

      // Sort slots by their local time (shop timezone)
      processed.sort((a, b) {
        final aLocal = toShopTz(a.startTimeUtc);
        final bLocal = toShopTz(b.startTimeUtc);
        return aLocal.compareTo(bLocal);
      });

      // write-through cache
      _slotsCache[key] = processed;

      // only update visible list if we're fetching the currently selected day
      if (mutateSelection && _isSameDay(selectedDate.value, day)) {
        slots.assignAll(processed);
      }
    } catch (e) {
      AppSnackBar.showError('Error loading slots: $e');
    } finally {
      isLoadingSlots.value = false;
      didLoadSlotsOnce.value = true;
    }
  }

  // ───────── NEW: warm up cache for today..+6 without blocking UI
  // Warm cache WITHOUT touching selection
  void prefetchNext7Days() {
    final start = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final d = DateTime(
        start.year,
        start.month,
        start.day,
      ).add(Duration(days: i));
      fetchSlotsForDate(
        d,
        useCache: true,
        mutateSelection: false,
      ); // <-- key change
    }
  }

  // ───────── NEW: seed cache and UI from preloaded data (Option B handoff)
  void seedPreloadedSlots({
    required DateTime selected,
    required List<SlotItem> preloaded,
  }) {
    final key = _fmtDate(selected);
    _slotsCache[key] = preloaded;
    selectedDate.value = DateTime(selected.year, selected.month, selected.day);
    slots.assignAll(preloaded);
    selectedSlotId.value = null;
    selectedSlotIso.value = null; // NEW
  }

  final closedWeekdays = <int>{}.obs; // 1=Mon … 7=Sun

  int? _weekdayFromString(String s) {
    final v = s.trim().toLowerCase();
    switch (v) {
      case 'mon':
      case 'monday':
        return DateTime.monday; // 1
      case 'tue':
      case 'tuesday':
        return DateTime.tuesday; // 2
      case 'wed':
      case 'wednesday':
        return DateTime.wednesday; // 3
      case 'thu':
      case 'thursday':
        return DateTime.thursday; // 4
      case 'fri':
      case 'friday':
        return DateTime.friday; // 5
      case 'sat':
      case 'saturday':
        return DateTime.saturday; // 6
      case 'sun':
      case 'sunday':
        return DateTime.sunday; // 7
    }
    return null;
  }

  bool isClosedDay(DateTime d) => closedWeekdays.contains(d.weekday);

  // call this right after you fetch /shops/details/{shop_id}
  void applyClosedDays(List<dynamic>? closeDays) {
    closedWeekdays
      ..clear()
      ..addAll(
        (closeDays ?? const [])
            .map((e) => _weekdayFromString('$e'))
            .whereType<int>(),
      );
  }

  void _snapSelectedToNextOpenInWindow() {
    // today..+6 like your UI
    final start = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final d = DateTime(
        start.year,
        start.month,
        start.day,
      ).add(Duration(days: i));
      if (!isClosedDay(d)) {
        selectedDate.value = d;
        return;
      }
    }
  }
}
