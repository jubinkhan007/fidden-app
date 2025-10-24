// lib/features/user/shops/services/controller/book_appointment_controller.dart

import 'dart:developer';

import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/commom/widgets/error_snakbar.dart';
import 'package:fidden/core/commom/widgets/success_snakbar.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
// --- FIX: Import the correct time slot model ---
import 'package:fidden/features/user/shops/services/data/time_slots_model.dart';
import 'package:fidden/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BookAppointmentController extends GetxController {
  // Observables for state management
  final RxBool isLoading = false.obs;
  final RxString selectedDate = ''.obs;
  final RxInt selectedTimeSlotId = 0.obs;
  final RxString selectedTimeSlotLabel = ''.obs;
  // --- FIX: Use the correct SlotItem model ---
  final RxList<SlotItem> morningSlots = <SlotItem>[].obs;
  final RxList<SlotItem> afternoonSlots = <SlotItem>[].obs;
  final RxList<SlotItem> eveningSlots = <SlotItem>[].obs;

  // --- REFACTORED: This method now matches the correct API logic ---
  Future<void> getTimeSlots({
    required String date,
    required String serviceId,
    required int shopId, // <-- shopId is now required
  }) async {
    isLoading.value = true;
    selectedDate.value = date;
    morningSlots.clear();
    afternoonSlots.clear();
    eveningSlots.clear();

    try {
      // Build the URL with query parameters, like in the example
      final uri = Uri.parse(
        AppUrls.getSlotsForShop(shopId),
      ).replace(queryParameters: {'service': serviceId, 'date': date});

      final response = await NetworkCaller().getRequest(uri.toString());

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        final parsed = SlotsResponse.fromJson(response.responseData);

        // Categorize the flat list of slots into morning, afternoon, and evening
        for (var slot in parsed.slots) {
          final localStartTime = slot.startTimeUtc.toLocal();
          if (localStartTime.hour < 12) {
            morningSlots.add(slot);
          } else if (localStartTime.hour < 17) {
            afternoonSlots.add(slot);
          } else {
            eveningSlots.add(slot);
          }
        }
      }
    } catch (e) {
      AppSnackBar.showError("Failed to load time slots. $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Method to handle booking confirmation
  Future<void> bookAppointment() async {
    if (selectedTimeSlotId.value == 0) {
      AppSnackBar.showError("Please select a time slot.");
      return;
    }
    isLoading.value = true;

    final response = await NetworkCaller().postRequest(
      AppUrls.slotBooking,
      body: {'slot_id': selectedTimeSlotId.value},
    );

    isLoading.value = false;

    if (response.isSuccess) {
      AppSnackBar.showSuccess("Slot booked temporarily. Please confirm.");

      final responseData = response.responseData as Map<String, dynamic>? ?? {};
      final bookingId = responseData['id'];

      final previousArgs = Get.arguments as Map<String, dynamic>? ?? {};

      Get.toNamed(
        AppRoute.bookingSummaryScreen,
        arguments: {
          ...previousArgs,
          'selectedSlotLabel': selectedTimeSlotLabel.value,
          'bookingId': bookingId,
        },
      );
    } else {
      AppSnackBar.showError(response.errorMessage ?? "Failed to book slot.");
    }
  }

  // Method to update selected time slot
  void selectTimeSlot(int id, String label) {
    selectedTimeSlotId.value = id;
    selectedTimeSlotLabel.value = label;
  }
}
