// lib/features/user/shops/services/controller/service_details_controller.dart
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/data/shop_details_model.dart';
import 'package:fidden/features/user/shops/services/data/service_details_model.dart';
import 'package:fidden/features/user/shops/services/data/time_slots_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ServiceDetailsController extends GetxController {
  ServiceDetailsController(this.serviceId);

  final int serviceId;

  final isLoadingDetails = false.obs;
  final isLoadingSlots = false.obs;
  final didLoadSlotsOnce = false.obs;

  final details = Rxn<ServiceDetailsModel>();
  final slots = <SlotItem>[].obs;

  // date state
  final selectedDate = DateTime.now().obs; // today by default
  final next7Days = <DateTime>[].obs;

  // selected slot
  final selectedSlotId = RxnInt();

  // ───────── NEW: simple in-memory cache for slots (keyed by yyyy-MM-dd)
  final Map<String, List<SlotItem>> _slotsCache = {}; // NEW

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
  String fmtTimeLocal(DateTime utc) =>
      DateFormat('h:mm a').format(utc.toLocal());

  // Helper to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

        // fetch shop details to get close_days
        final shopResp = await NetworkCaller().getRequest(
          AppUrls.shopDetails((svc.shopId.toString())),
          token: AuthService.accessToken,
        );
        if (shopResp.isSuccess && shopResp.responseData is Map<String, dynamic>) {
          final shop = ShopDetailsModel.fromJson(shopResp.responseData);
          applyClosedDays(shop.closeDays);
        }

        _snapSelectedToNextOpenInWindow();
        await fetchSlotsForDate(selectedDate.value, mutateSelection: true);

        // ───────── NEW: warm the cache (today..+6) in the background
        prefetchNext7Days(); // fire & forget
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
    final uri = Uri.parse('${AppUrls.serviceDetails}/${d.shopId}/slots/')
        .replace(queryParameters: {
      'service': serviceId.toString(),
      'date': key,
    });

    final res = await NetworkCaller().getRequest(
      uri.toString(),
      token: AuthService.accessToken,
    );

    if (res.isSuccess && res.responseData is Map<String, dynamic>) {
      final parsed = SlotsResponse.fromJson(res.responseData);
      final now = DateTime.now();
      List<SlotItem> processed = parsed.slots;

      // If "today", mark past times unavailable
      if (_isSameDay(day, now)) {
        processed = processed.map((slot) {
          if (!slot.available) return slot;
          if (slot.startTimeUtc.toLocal().isBefore(now)) {
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

      // write-through cache
      _slotsCache[key] = processed;

      // only update visible list if we're fetching the currently selected day
      if (mutateSelection && _isSameDay(selectedDate.value, day)) {
        slots.assignAll(processed);
      }
    } else {
      AppSnackBar.showError(res.errorMessage ?? 'Failed to load slots.');
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
    final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
    fetchSlotsForDate(d, useCache: true, mutateSelection: false); // <-- key change
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
  }

  double get effectivePrice {
    final d = details.value;
    if (d == null) return 0;
    final p = d.discountPrice ?? d.price ?? '0';
    return double.tryParse(p) ?? 0;
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
      ..addAll((closeDays ?? const [])
          .map((e) => _weekdayFromString('$e'))
          .whereType<int>());
  }

  void _snapSelectedToNextOpenInWindow() {
    // today..+6 like your UI
    final start = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final d = DateTime(start.year, start.month, start.day).add(Duration(days: i));
      if (!isClosedDay(d)) {
        selectedDate.value = d;
        return;
      }
    }
  }
}
