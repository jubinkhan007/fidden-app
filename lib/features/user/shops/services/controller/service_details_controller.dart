// lib/features/user/shops/services/controller/service_details_controller.dart
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
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

  Future<void> fetchServiceDetails() async {
    isLoadingDetails.value = true;
    try {
      final url = Uri.parse('${AppUrls.allServices}/$serviceId');
      final res = await NetworkCaller().getRequest(
        url.toString(),
        token: AuthService.accessToken,
      );

      if (res.isSuccess && res.responseData is Map<String, dynamic>) {
        details.value = ServiceDetailsModel.fromJson(res.responseData);
        // load slots for today by default
        await fetchSlotsForDate(selectedDate.value);
      } else {
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
        slots.assignAll(parsed.slots);
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
}
