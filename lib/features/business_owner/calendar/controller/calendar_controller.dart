import 'dart:async';

import 'package:fidden/features/business_owner/calendar/data/calendar_event_model.dart';
import 'package:fidden/features/business_owner/calendar/data/calendar_repository.dart';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Reuse existing provider model if available, or fetch raw list.
// Assuming we can use a simple map or specialized model for the filter.
// For now using dynamic or a simple class to hold provider info for the filter chip.
class FilterProvider {
  final int? id;
  final String name;
  FilterProvider({this.id, required this.name});
}

class CalendarController extends GetxController {
  final CalendarRepository _repository = CalendarRepository();
  final NetworkCaller _networkCaller = NetworkCaller();

  // State
  final RxBool isLoading = false.obs;
  final RxBool isProvidersLoading = false.obs;
  final RxList<CalendarEventModel> events = <CalendarEventModel>[].obs;
  final RxList<FilterProvider> providers = <FilterProvider>[].obs;

  // Filters
  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rxn<int> selectedProviderId = Rxn<int>();

  // Shop Context
  final RxnInt shopId = RxnInt();

  // Debounce for rapid date changes
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Initialize with "All Providers"
    providers.add(FilterProvider(id: null, name: "All Providers"));

    // Sync with global shopId
    shopId.value = myShopId.value;
    ever<int?>(myShopId, (id) {
      if (id != null && id != shopId.value) {
        shopId.value = id;
        refreshAll();
      }
    });

    if (shopId.value != null) {
      refreshAll();
    }
  }

  void refreshAll() {
    fetchProviders();
    loadEvents();
  }

  /// Called when screen is ready
  void init(int id) {
    if (shopId.value == id) return;
    shopId.value = id;
    refreshAll();
  }

  /// Fetch providers for the filter list (One-time only)
  Future<void> fetchProviders() async {
    final id = shopId.value;
    if (id == null) return;

    try {
      isProvidersLoading.value = true;
      final url = AppUrls.shopProviders(id);

      final response = await _networkCaller.getRequest(
        url,
        token: AuthService.accessToken,
      );

      if (response.isSuccess && response.responseData != null) {
        final dynamic data = response.responseData;
        if (data is List) {
          final fetchedProviders = data.map((e) {
            final map = e as Map<String, dynamic>;
            return FilterProvider(
              id: map['id'] as int?,
              name: map['name'] ?? 'Unknown',
            );
          }).toList();

          providers.assignAll([
            FilterProvider(id: null, name: "All Providers"),
            ...fetchedProviders,
          ]);
        }
      }
    } catch (e) {
      debugPrint("Error loading providers: $e");
    } finally {
      isProvidersLoading.value = false;
    }
  }

  void onDateSelected(DateTime date) {
    selectedDate.value = date;

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      loadEvents();
    });
  }

  void onProviderSelected(int? providerId) {
    if (selectedProviderId.value == providerId) return;
    selectedProviderId.value = providerId;
    loadEvents();
  }

  Future<void> loadEvents() async {
    final id = shopId.value;
    if (id == null) return;

    try {
      isLoading.value = true;

      final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate.value);

      final fetchedEvents = await _repository.fetchCalendarEvents(
        shopId: id,
        startDate: dateStr,
        endDate: dateStr,
        providerId: selectedProviderId.value,
      );

      events.assignAll(fetchedEvents);
    } catch (e) {
      if (e.toString().contains("403")) {
        AppSnackBar.showError("Access Denied: Only shop owners can view this.");
      } else {
        AppSnackBar.showError("Failed to load events.");
      }
    } finally {
      isLoading.value = false;
    }
  }

  void refreshEvents() {
    loadEvents();
  }
}
