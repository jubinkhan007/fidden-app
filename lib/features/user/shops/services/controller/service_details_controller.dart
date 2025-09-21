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

  final details = Rxn<ServiceDetailsModel>();
  final slots = <SlotItem>[].obs;

  // date state
  final selectedDate = DateTime.now().obs; // today by default
  final next7Days = <DateTime>[].obs;

  // selected slot
  final selectedSlotId = RxnInt();

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
  await fetchSlotsForDate(selectedDate.value);
}else {
        AppSnackBar.showError(res.errorMessage ?? 'Failed to load service.');
      }
    } catch (e) {
      AppSnackBar.showError('Error loading service: $e');
    } finally {
      isLoadingDetails.value = false;
    }
  }

  Future<void> fetchSlotsForDate(DateTime date) async {
    final d = details.value;
    if (d == null) return;

    selectedDate.value = DateTime(date.year, date.month, date.day);
    selectedSlotId.value = null;
    isLoadingSlots.value = true;

    try {
      final uri = Uri.parse('${AppUrls.serviceDetails}/${d.shopId}/slots/')
          .replace(
            queryParameters: {
              'service': serviceId.toString(),
              'date': _fmtDate(selectedDate.value),
            },
          );

      final res = await NetworkCaller().getRequest(
        uri.toString(),
        token: AuthService.accessToken,
      );

      if (res.isSuccess && res.responseData is Map<String, dynamic>) {
        final parsed = SlotsResponse.fromJson(res.responseData);
        final now = DateTime.now();
        List<SlotItem> processedSlots = parsed.slots;

        // If the selected date is today, check for past time slots
        if (_isSameDay(date, now)) {
          processedSlots = parsed.slots.map((slot) {
            // If the slot is already unavailable from the backend, keep it that way.
            if (!slot.available) {
              return slot;
            }

            // Check if the slot's start time is in the past.
            if (slot.startTimeUtc.toLocal().isBefore(now)) {
              // It's in the past, so we override `available` to false.
              // Since SlotItem is immutable, we must create a new one.
              return SlotItem(
                id: slot.id,
                shop: slot.shop,
                service: slot.service,
                startTimeUtc: slot.startTimeUtc,
                endTimeUtc: slot.endTimeUtc,
                capacityLeft: slot.capacityLeft,
                available: false, // Mark as unavailable
              );
            }
            // Otherwise, it's an available slot in the future.
            return slot;
          }).toList();
        }

        slots.assignAll(processedSlots);
      } else {
        AppSnackBar.showError(res.errorMessage ?? 'Failed to load slots.');
      }
    } catch (e) {
      AppSnackBar.showError('Error loading slots: $e');
    } finally {
      isLoadingSlots.value = false;
    }
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
      return DateTime.monday;    // 1
    case 'tue':
    case 'tuesday':
      return DateTime.tuesday;   // 2
    case 'wed':
    case 'wednesday':
      return DateTime.wednesday; // 3
    case 'thu':
    case 'thursday':
      return DateTime.thursday;  // 4
    case 'fri':
    case 'friday':
      return DateTime.friday;    // 5
    case 'sat':
    case 'saturday':
      return DateTime.saturday;  // 6
    case 'sun':
    case 'sunday':
      return DateTime.sunday;    // 7
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
