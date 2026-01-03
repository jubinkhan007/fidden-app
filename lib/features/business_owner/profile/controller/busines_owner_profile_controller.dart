// lib/features/business_owner/profile/controller/busines_owner_profile_controller.dart
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/profile/data/stripe_models.dart';
import 'package:fidden/features/business_owner/profile/screens/stripe_webview_screen.dart';
import 'package:fidden/features/business_owner/profile/services/shop_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:fidden/core/services/Auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../subscription/controller/subscription_controller.dart';
import '../data/business_profile_model.dart';
import '../../../user/profile/controller/profile_controller.dart';
import '../../home/dashboard/dashboard_controller.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// Simple, UI-friendly (start,end) for a day. Stored as "hh:mm AM/PM".
@immutable
class Range {
  final String start; // e.g. "09:00 AM"
  final String end; // e.g. "06:00 PM"
  const Range(this.start, this.end);

  Range copyWith({String? start, String? end}) =>
      Range(start ?? this.start, end ?? this.end);
}

typedef BusinessHoursMap = Map<String, List<Range>>; // monday->[Range(),...]

class BusinessOwnerProfileController extends GetxController {
  // ---- UI state ----
  final RxSet<String> openDays = <String>{}.obs;
  var startDay = ''.obs;
  var endDay = ''.obs;
  var startTime = ''.obs;
  var endTime = ''.obs;
  var isLoading = false.obs;
  var isDeleting = false.obs;

  var lat = "".obs;
  var long = "".obs;

  var profileImage = Rxn<File>();
  var imagePath = ''.obs;
  var documents = <File>[].obs;

  // Cancellation policy fields (strings bound to inputs)
  final freeCancellationHours = ''.obs; // e.g. "24"
  final cancellationFeePercentage = ''.obs; // e.g. "50"
  final noRefundHours = ''.obs; // e.g. "4"

  // Deposit UI state
  final isDepositRequired = false.obs;
  final defaultDepositPercentage = ''.obs;

  // Shop timezone (IANA format, e.g., "America/New_York")
  final timeZone = 'America/New_York'.obs;

  // Social Links
  final instagramUrl = ''.obs;
  final tiktokUrl = ''.obs;
  final youtubeUrl = ''.obs;
  final websiteUrl = ''.obs;

  // Niche selection
  final RxList<String> selectedNiches =
      <String>[].obs; // First = primary, rest = capabilities

  static const List<Map<String, String>> availableNiches = [
    {'key': 'tattoo_artist', 'label': 'Tattoo Artist', 'emoji': '🖋️'},
    {'key': 'barber', 'label': 'Barber', 'emoji': '✂️'},
    {'key': 'hairstylist', 'label': 'Hairstylist/Loctician', 'emoji': '💇'},
    {'key': 'nail_tech', 'label': 'Nail Tech', 'emoji': '💅'},
    {'key': 'makeup_artist', 'label': 'Makeup Artist', 'emoji': '💄'},
    {'key': 'esthetician', 'label': 'Esthetician', 'emoji': '🧖'},
    {'key': 'massage_therapist', 'label': 'Massage Therapist', 'emoji': '💆'},
    {'key': 'fitness_trainer', 'label': 'Fitness Trainer', 'emoji': '🏋️'},
    {'key': 'other', 'label': 'Other', 'emoji': '🔧'},
  ];

  final RxBool _fetchingProfile = false.obs;

  // ---- Subscription context ----
  final sub = Get.isRegistered<SubscriptionController>()
      ? Get.find<SubscriptionController>()
      : Get.put(SubscriptionController());

  bool get _isFoundation => sub.isFoundation;
  bool get _isMomentum => sub.isMomentum;
  bool get _isIcon => sub.isIcon;

  // What each tier can edit
  bool get canEditDeposit => _isMomentum || _isIcon;
  bool get canEditPolicy => _isIcon;

  // For upgrade messages
  // void _toastUpgradeForPolicy() =>
  //     AppSnackBar.showSuccess('Upgrade to Icon to edit cancellation policy.');
  // void _toastUpgradeForDeposit() =>
  //     AppSnackBar.showSuccess('Upgrade your plan to edit deposit settings.');

  // Stripe verify
  final isCheckingStripeStatus = false.obs;
  final Rxn<StripeVerifyResponse> stripeStatus = Rxn<StripeVerifyResponse>();
  bool _awaitingOnboarding = false;

  // Loaded profile (handles both wrapped and raw shapes)
  var profileDetails = GetBusinesModel(data: null).obs;
  final RxMap<String, List<Range>> businessHours = <String, List<Range>>{}.obs;

  // Add a Completer to manage the initial loading state
  Completer<void> _initCompleter = Completer<void>();

  /// Other controllers can wait on this to know when the profile is ready.
  Future<void> get onProfileLoaded => _initCompleter.future;

  // ---------------- Lifecycle ----------------
  @override
  void onInit() {
    super.onInit();
    _init(); // keep onInit lean

    // If tokens refresh after we mounted, refetch profile quietly AND re-seed UI
    ever(AuthService.tokenRefreshCount, (_) async {
      await fetchProfileDetails(silentAuthErrors: true);
      _seedUiFromProfileData(); // FIX: Re-seed UI observables after token refresh
      await checkStripeStatusIfPossible();
    });

    WidgetsBinding.instance.addObserver(
      _LifecycleObserver(
        onResumed: () async {
          if (_awaitingOnboarding) {
            _awaitingOnboarding = false;
            await checkStripeStatusIfPossible();
          }
        },
      ),
    );
  }

  Future<void> _init() async {
    // If _init is already running (e.g., from another controller), just wait.
    if (isLoading.isTrue && !_initCompleter.isCompleted) {
      await _initCompleter.future;
      return;
    }
    // Reset completer if we are re-running this (e.g., pull-to-refresh)
    if (_initCompleter.isCompleted) {
      _initCompleter = Completer<void>();
    }

    isLoading.value = true;
    try {
      // 1. Fetch all profile data *first*.
      await fetchProfileDetails(silentAuthErrors: true);

      // 2. NOW, seed the UI with the data we just fetched.
      _seedUiFromProfileData();

      await checkStripeStatusIfPossible();
    } catch (e) {
      if (kDebugMode) log('Error during _init: $e');
    } finally {
      isLoading.value = false;
      // 3. Signal that *everything* (fetch + UI seeding) is done.
      if (!_initCompleter.isCompleted) {
        _initCompleter.complete();
      }
    }
  }

  /// Seeds all UI-bound observables from the current [profileDetails].
  /// Called after initial fetch and after token refresh to ensure UI stays in sync.
  void _seedUiFromProfileData() {
    final data = profileDetails.value.data;
    if (data == null) return;

    // Open days
    final fromApiOpenDays = data.openDays;
    if (fromApiOpenDays != null && fromApiOpenDays.isNotEmpty) {
      openDays
        ..clear()
        ..addAll(fromApiOpenDays.map(_normalizeDay));
    }

    // Times
    startTime.value = data.startTime ?? '';
    endTime.value = data.endTime ?? '';

    // Cancellation policy (defaults when missing)
    freeCancellationHours.value = (data.freeCancellationHours ?? 24).toString();
    cancellationFeePercentage.value = (data.cancellationFeePercentage ?? 0)
        .toString();
    noRefundHours.value = (data.noRefundHours ?? 0).toString();

    // Deposit
    defaultDepositPercentage.value = (data.defaultDepositPercentage ?? 0)
        .toString();
    isDepositRequired.value = data.isDepositRequired ?? false;

    // Generic debug log for fetched data
    debugPrint(
      '👤 ProfileController: Seeding UI. Data Timezone: ${data.timeZone}',
    );

    // Timezone
    if (data.timeZone != null && data.timeZone!.isNotEmpty) {
      timeZone.value = data.timeZone!;
      debugPrint(
        '👤 ProfileController: Updated timeZone observable to: ${timeZone.value}',
      );
    } else {
      debugPrint(
        '👤 ProfileController: Timezone is null/empty in data! Keeping default: ${timeZone.value}',
      );
    }

    // Social links
    instagramUrl.value = data.instagramUrl ?? '';
    tiktokUrl.value = data.tiktokUrl ?? '';
    youtubeUrl.value = data.youtubeUrl ?? '';
    websiteUrl.value = data.websiteUrl ?? '';

    // Niches (first = primary, rest = capabilities)
    if (data.niches != null && data.niches!.isNotEmpty) {
      selectedNiches.value = List<String>.from(data.niches!);
    } else if (data.primaryNiche != null) {
      // Fallback to primary_niche + capabilities if niches not available
      selectedNiches.value = [data.primaryNiche!, ...?data.capabilities];
    }

    // Business hours
    _seedBusinessHoursFromData(data);
    ensureBusinessHoursForOpenDays();
  }

  void _seedBusinessHoursFromData(Data? d) {
    // Prefer API business_hours - already converted to AM/PM by the model
    if (d?.businessHours != null && d!.businessHours!.isNotEmpty) {
      businessHours
        ..clear()
        ..addAll(
          d.businessHours!.map(
            (k, v) => MapEntry(
              k.toLowerCase(), // Already full day name from model (e.g., "monday")
              v
                  .map((pair) => Range(pair.$1, pair.$2))
                  .toList(), // Already AM/PM format
            ),
          ),
        );
      return;
    }

    // Fallback: openDays + single legacy range
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final open = (d?.openDays ?? []).map((e) => e.toLowerCase()).toSet();

    final s = (d?.startTime != null && d!.startTime!.isNotEmpty)
        ? d.startTime!
        : (startTime.value.isNotEmpty ? startTime.value : '09:00 AM');

    final e = (d?.endTime != null && d!.endTime!.isNotEmpty)
        ? d.endTime!
        : (endTime.value.isNotEmpty ? endTime.value : '06:00 PM');

    final Map<String, List<Range>> m = {};
    for (final day in days) {
      if (open.contains(day)) {
        m[day] = [Range(s, e)];
      } else {
        m[day] = []; // closed
      }
    }
    businessHours
      ..clear()
      ..addAll(m);
  }

  /// Convert 24-hour time (e.g., "09:00", "18:30") to AM/PM format (e.g., "09:00 AM", "06:30 PM")
  String _from24ToUi(String time24) {
    // If already in AM/PM format, return as-is
    if (time24.toUpperCase().contains('AM') ||
        time24.toUpperCase().contains('PM')) {
      return time24;
    }

    try {
      final parts = time24.split(':');
      if (parts.length < 2) return time24;

      int hour = int.parse(parts[0]);
      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;

      return '${hour.toString().padLeft(2, '0')}:$minute $period';
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }

  void onDefaultTimeChanged({required bool isStart, required String value}) {
    final oldStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
    final oldEnd = endTime.value.isNotEmpty ? endTime.value : '06:00 PM';

    if (isStart) {
      startTime.value = value;
    } else {
      endTime.value = value;
    }

    _propagateDefaultChange(oldStart: oldStart, oldEnd: oldEnd);
  }

  /// Robust time comparison (ignores leading zeros, spacing, case)
  bool _areTimesEqual(String t1, String t2) {
    String norm(String s) {
      // "09:00 AM" -> "9:00am"
      // "9:00 a.m." -> "9:00am"
      var n = s
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'\s+'), '')
          .replaceAll('.', '');
      if (n.startsWith('0') && n.length > 1) {
        n = n.substring(1);
      }
      return n;
    }

    return norm(t1) == norm(t2);
  }

  /// Update businessHours for days that were still using the old defaults,
  /// and seed any open-but-empty day with the new defaults.
  void _propagateDefaultChange({
    required String oldStart,
    required String oldEnd,
  }) {
    final defStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
    final defEnd = endTime.value.isNotEmpty ? endTime.value : '06:00 PM';

    // compare in lowercase for safety
    final openLower = openDays.map((d) => d.toLowerCase()).toSet();

    for (final day in [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ]) {
      final ranges = businessHours[day] ?? const [];

      if (openLower.contains(day)) {
        if (ranges.isEmpty) {
          // open day with no custom hours -> seed with new defaults
          businessHours[day] = [Range(defStart, defEnd)];
        } else if (ranges.length == 1) {
          // Check if it matches the OLD user setting OR the system fallback (9-6)
          // This fixes the issue where days stuck at 9-6 wouldn't update
          final r = ranges.first;
          final matchesOld =
              _areTimesEqual(r.start, oldStart) &&
              _areTimesEqual(r.end, oldEnd);
          final matchesSystemDefault =
              _areTimesEqual(r.start, '09:00 AM') &&
              _areTimesEqual(r.end, '06:00 PM');

          if (matchesOld || matchesSystemDefault) {
            businessHours[day] = [Range(defStart, defEnd)];
          }
        }
      } else {
        // closed days stay empty
        businessHours[day] = const [];
      }
    }
    businessHours.refresh();
  }

  // Parse "hh:mm AM/PM" -> "HH:mm"
  String _uiTo24(String ui) {
    final reg = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$',
      caseSensitive: false,
    );
    final m = reg.firstMatch(ui.trim());
    if (m == null) {
      // Try 24-hour format
      final m24 = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*$').firstMatch(ui.trim());
      if (m24 != null) {
        return '${m24.group(1)!.padLeft(2, '0')}:${m24.group(2)!}';
      }
      return ui;
    }
    int h = int.parse(m.group(1)!);
    final mm = m.group(2)!;
    final ap = m.group(3)!.toUpperCase();
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return '${h.toString().padLeft(2, '0')}:$mm';
  }

  bool _isValidRange(Range r) {
    // very light validation: start < end when converted to minutes
    int _mins(String ui) {
      // Try 12-hour format
      final m = RegExp(
        r'(\d{1,2}):(\d{2})\s*([AP]M)',
        caseSensitive: false,
      ).firstMatch(ui);
      if (m != null) {
        int hh = int.parse(m.group(1)!);
        final mm = int.parse(m.group(2)!);
        final ap = m.group(3)!.toUpperCase();
        if (ap == 'PM' && hh != 12) hh += 12;
        if (ap == 'AM' && hh == 12) hh = 0;
        return hh * 60 + mm;
      }

      // Try 24-hour format
      final m24 = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*$').firstMatch(ui.trim());
      if (m24 != null) {
        int hh = int.parse(m24.group(1)!);
        final mm = int.parse(m24.group(2)!);
        return hh * 60 + mm;
      }

      throw FormatException("Invalid time format: $ui");
    }

    try {
      return _mins(r.start) < _mins(r.end);
    } catch (_) {
      return false;
    }
  }

  bool _isValidDay(List<Range> ranges) =>
      ranges.isEmpty || ranges.every(_isValidRange); // empty == closed OK

  // ---------------- Stripe onboarding helpers ----------------
  Future<void> checkStripeStatusIfPossible() async {
    final shopId = profileDetails.value.data?.id?.toString();
    if (shopId == null || shopId.isEmpty) return;

    isCheckingStripeStatus.value = true;
    try {
      final res = await ShopApi().verifyStripeOnboarding(
        shopId: int.parse(shopId),
        token: AuthService.accessToken ?? '',
      );
      stripeStatus.value = res;
    } catch (_) {
      // keep quiet
    } finally {
      isCheckingStripeStatus.value = false;
    }
  }

  Future<void> startStripeOnboarding(int shopId) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final link = await ShopApi().getStripeOnboardingLink(
        shopId: shopId,
        token: AuthService.accessToken ?? '',
      );
      Get.back(); // close loader
      _awaitingOnboarding = true;
      final completed = await Get.to<bool>(
        () => StripeWebViewScreen(onboardingUrl: link.url),
      );

      // Always re-verify when you come back
      await Future.delayed(const Duration(milliseconds: 200));
      await checkStripeStatusIfPossible();

      if (completed == true) {
        AppSnackBar.showSuccess('Stripe onboarding complete.');
      }
    } catch (_) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackBar.showError(
        'Could not start Stripe onboarding. Please try again.',
      );
    }
  }

  // ---------------- Pickers ----------------
  Future<void> pickDocuments() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        documents.addAll(
          result.paths.where((p) => p != null).map((p) => File(p!)),
        );
        documents.refresh();
      }
    } catch (e) {
      AppSnackBar.showError("Error picking files: $e");
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      profileImage.value = File(picked.path);
      imagePath.value = picked.path;
    }
  }

  void initializeSchedule({
    required String startDayVal,
    required String endDayVal,
    required String startTimeVal,
    required String endTimeVal,
  }) {
    startDay.value = startDayVal;
    endDay.value = endDayVal;
    startTime.value = startTimeVal;
    endTime.value = endTimeVal;
  }

  void pickDay({required bool isStart}) async {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    String? selectedDay = await showDialog<String>(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: const Text('Select Day'),
        content: SizedBox(
          height: 300,
          width: 200,
          child: ListView(
            children: days
                .map(
                  (day) => ListTile(
                    title: Text(day),
                    onTap: () => Navigator.pop(context, day),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );

    if (selectedDay != null) {
      if (isStart) {
        startDay.value = selectedDay;
      } else {
        endDay.value = selectedDay;
      }
    }
  }

  void pickTime({required bool isStart}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final now = DateTime.now();
      final full = DateTime(
        now.year,
        now.month,
        now.day,
        picked.hour,
        picked.minute,
      );

      final formatted = DateFormat('hh:mm a')
          .format(full)
          .toLowerCase()
          .replaceAll('am', 'a.m.')
          .replaceAll('pm', 'p.m.');

      if (isStart) {
        startTime.value = formatted;
      } else {
        endTime.value = formatted;
      }
    }
  }

  // ---------------- Networking: read ----------------
  Future<void> fetchProfileDetails({bool silentAuthErrors = false}) async {
    // Reentrancy guard: if a fetch is already running, just return.
    if (_fetchingProfile.value) return;

    _fetchingProfile.value = true;
    isLoading.value = true;

    try {
      // 1) Ensure we actually have a valid token
      final String? token = await AuthService.getValidAccessToken();
      if (token == null || token.isEmpty) {
        if (!silentAuthErrors) AppSnackBar.showError('You are not logged in.');
        profileDetails.value = GetBusinesModel(data: null);
        return;
      }

      // 2) Do the request (with a retry on 401)
      Future _doGet(String auth) => NetworkCaller().getRequest(
        AppUrls.getMBusinessProfile,
        token: auth,
        treat404AsEmpty: true,
        emptyPayload: const {"data": null},
      );

      var resp = await _doGet(token);
      final sc = resp.statusCode ?? 0;
      if (sc == 401 || sc == 403) {
        final String? retryToken = await AuthService.getValidAccessToken();
        if (retryToken != null && retryToken.isNotEmpty) {
          resp = await _doGet(retryToken);
        }
      }

      if (resp.isSuccess && resp.responseData is Map<String, dynamic>) {
        if (kDebugMode) {
          print('👤 RAW PROFILE JSON: ${resp.responseData}');
        }
        profileDetails.value = GetBusinesModel.fromJson(resp.responseData);
        _populateBusinessHoursFromModel(profileDetails.value.data);

        // Sync myShopId to trigger BusinessOwnerController fetching
        if (profileDetails.value.data?.id != null) {
          final sid = int.tryParse(profileDetails.value.data!.id!);
          if (sid != null) {
            myShopId.value = sid;
            debugPrint('👤 ProfileController: Set global myShopId to $sid');
          }
        }
      } else {
        profileDetails.value = GetBusinesModel(data: null);
      }
    } catch (e) {
      profileDetails.value = GetBusinesModel(data: null);
      if (!silentAuthErrors) {
        AppSnackBar.showError(
          'An error occurred while fetching profile details.',
        );
      }
      if (kDebugMode) log('Fetch profile details error: $e');
    } finally {
      _fetchingProfile.value = false;
      isLoading.value = false;
      if (!_initCompleter.isCompleted) _initCompleter.complete();
    }
  }

  /// Update shop niches via PATCH /api/shop/{id}/
  /// The first niche becomes primary_niche, the rest become capabilities.
  Future<bool> updateNiches(List<String> niches) async {
    if (niches.isEmpty) {
      AppSnackBar.showError('Please select at least one niche.');
      return false;
    }

    final shopId = profileDetails.value.data?.id;
    if (shopId == null) {
      AppSnackBar.showError('Shop ID not found.');
      return false;
    }

    final token = await AuthService.getValidAccessToken();
    if (token == null) {
      AppSnackBar.showError('Unauthorized. Please login again.');
      return false;
    }

    isLoading.value = true;
    try {
      final url = AppUrls.editBusinessProfile(shopId.toString());
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'niches': niches}),
      );

      log('PATCH niches: $url -> ${response.statusCode}');

      if (response.statusCode == 200) {
        // Update local state
        selectedNiches.value = List<String>.from(niches);

        // Re-fetch full profile to get updated data
        await fetchProfileDetails();

        // Also update ProfileController so dashboard chips update
        if (Get.isRegistered<ProfileController>()) {
          final pc = Get.find<ProfileController>();
          pc.shopNiches.value = List<String>.from(niches);
          if (niches.isNotEmpty) {
            pc.shopNiche.value = niches.first;
          }

          // Cache the updated niches for persistence
          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('cached_shop_niches', niches);
          if (niches.isNotEmpty) {
            await prefs.setString('selected_niche', niches.first);
          }
        }

        // Refresh DashboardController if available
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().refreshChips();
        }

        AppSnackBar.showSuccess('Niches updated successfully!');
        return true;
      } else {
        // Log the full response for debugging
        log('PATCH niches failed: ${response.statusCode}');
        log('Response body: ${response.body}');

        try {
          final errorBody = jsonDecode(response.body);
          final msg =
              errorBody['detail'] ?? errorBody['error'] ?? errorBody.toString();
          AppSnackBar.showError('Failed: $msg');
        } catch (_) {
          AppSnackBar.showError('Failed to update niches: ${response.body}');
        }
        return false;
      }
    } catch (e) {
      log('updateNiches error: $e');
      AppSnackBar.showError('Error updating niches: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _populateBusinessHoursFromModel(Data? data) {
    if (data == null) return;

    // 1. Populate start/end time observables
    if (data.startTime != null && data.startTime!.isNotEmpty) {
      startTime.value = data.startTime!;
    }
    if (data.endTime != null && data.endTime!.isNotEmpty) {
      endTime.value = data.endTime!;
    }

    // 2. Populate openDays
    if (data.openDays != null) {
      openDays.clear();
      openDays.addAll(data.openDays!);
    }

    // 3. Populate businessHours map
    if (data.businessHours != null) {
      businessHours.clear();
      data.businessHours!.forEach((day, ranges) {
        // Convert tuple (start, end) to Range object
        final rangeList = ranges.map((r) => Range(r.$1, r.$2)).toList();
        businessHours[day] = rangeList;
      });
    } else {
      // Fallback: if businessHours is missing but we have openDays,
      // seed them with the default start/end times.
      ensureBusinessHoursForOpenDays();
    }

    businessHours.refresh();
  }

  // ---------------- Validation helpers ----------------
  int? _intOrNull(String s) => int.tryParse(s.trim());

  bool _validPolicy(int freeH, int feePct, int noRefundH) {
    if (freeH < 0 || noRefundH < 0) return false;
    if (feePct < 0 || feePct > 100) return false;
    if (noRefundH >= freeH)
      return false; // no-refund must be inside free window
    return true;
  }

  // ---- Day key maps for API <-> UI ----
  static const Map<String, String> _uiLowerFull_to_apiShort = {
    'monday': 'mon',
    'tuesday': 'tue',
    'wednesday': 'wed',
    'thursday': 'thu',
    'friday': 'fri',
    'saturday': 'sat',
    'sunday': 'sun',
  };

  static const Map<String, String> _apiShort_to_uiLowerFull = {
    'mon': 'monday',
    'tue': 'tuesday',
    'wed': 'wednesday',
    'thu': 'thursday',
    'fri': 'friday',
    'sat': 'saturday',
    'sun': 'sunday',
  };

  String _toApiDayKeyShort3(String anyUiKey) {
    final k = anyUiKey.trim().toLowerCase(); // "monday" etc.
    return _uiLowerFull_to_apiShort[k] ?? k; // -> "mon"
  }

  String _fromApiDayKeyShort3(String apiKey) {
    final k = apiKey.trim().toLowerCase(); // "mon" etc.
    return _apiShort_to_uiLowerFull[k] ?? k; // -> "monday"
  }

  Map<String, dynamic> _serializeBusinessHoursForApi() {
    final Map<String, dynamic> out = {};
    businessHours.forEach((uiKeyLower, ranges) {
      final apiKey = _toApiDayKeyShort3(uiKeyLower); // <-- "mon"
      out[apiKey] = ranges.isEmpty
          ? []
          : ranges.map((r) => [_uiTo24(r.start), _uiTo24(r.end)]).toList();
    });
    return out;
  }

  List<String> _deriveCloseDaysFromBH() {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days.where((d) => (businessHours[d]?.isEmpty ?? true)).toList();
  }

  void ensureBusinessHoursForOpenDays() {
    final defaultStart = startTime.value.isNotEmpty
        ? startTime.value
        : '09:00 AM';
    final defaultEnd = endTime.value.isNotEmpty ? endTime.value : '06:00 PM';

    // Canonical title-case names in openDays, but BH map keys are lowercase.
    final openSet = openDays.map((d) => d.toLowerCase()).toSet();

    for (final d in [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ]) {
      final isOpen = openSet.contains(d);
      final cur = businessHours[d];

      if (isOpen) {
        // if missing or empty -> give one default interval
        if (cur == null || cur.isEmpty) {
          businessHours[d] = [Range(defaultStart, defaultEnd)];
        }
      } else {
        // closed -> keep empty list
        businessHours[d] = const [];
      }
    }
    businessHours.refresh();
  }

  /// Set open days from UI picker (always canonicalize to Monday..Sunday).
  void setOpenDays(Set<String> days) {
    final norm = days.map(_normalizeDay).where((e) => e.isNotEmpty).toSet();

    // Update openDays
    openDays
      ..clear()
      ..addAll(norm);

    // Also reflect this in per-day businessHours:
    // - if a day is open but has no ranges yet, give it one default range
    // - if a day is closed, clear its ranges
    final defaultStart = startTime.value.isNotEmpty
        ? startTime.value
        : '09:00 AM';
    final defaultEnd = endTime.value.isNotEmpty ? endTime.value : '06:00 PM';

    for (final dLower in _allDaysLower) {
      final dTitle = _normalizeDay(dLower);
      final shouldBeOpen = norm.contains(dTitle);
      final current = businessHours[dLower] ?? <Range>[];

      if (shouldBeOpen) {
        if (current.isEmpty) {
          businessHours[dLower] = [Range(defaultStart, defaultEnd)];
        } else {
          businessHours[dLower] = current; // keep user edits
        }
      } else {
        businessHours[dLower] = []; // closed
      }
    }
    businessHours.refresh();
  }

  /// Title-case a weekday ("monday" -> "Monday")
  String _titleCaseDay(String d) =>
      d.isEmpty ? d : d[0].toUpperCase() + d.substring(1).toLowerCase();

  /// Derive openDays from businessHours (used when toggling day switches).
  void syncOpenDaysFromBH() {
    final Set<String> open = {};
    for (final dLower in _allDaysLower) {
      final isOpen = (businessHours[dLower]?.isNotEmpty ?? false);
      if (isOpen) open.add(_normalizeDay(dLower));
    }
    openDays
      ..clear()
      ..addAll(open);
  }

  /// Ensure businessHours matches `openDays`.
  /// - Any *open* day with no ranges gets a single default interval
  ///   using the current startTime/endTime (or overrides if provided).
  /// - Any *closed* day gets cleared ([]).
  void applyOpenDaysToBH({String? overrideStart, String? overrideEnd}) {
    // ensure all 7 keys exist
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    for (final d in days) {
      businessHours.putIfAbsent(d, () => []);
    }

    final defaultStart =
        overrideStart ??
        (startTime.value.isNotEmpty ? startTime.value : '09:00 AM');
    final defaultEnd =
        overrideEnd ?? (endTime.value.isNotEmpty ? endTime.value : '06:00 PM');

    // normalize set for lookup
    final openSet = openDays.map((e) => e.toLowerCase()).toSet();

    for (final d in days) {
      if (openSet.contains(d)) {
        // if no custom ranges yet, seed with default
        if (businessHours[d] == null || businessHours[d]!.isEmpty) {
          businessHours[d] = [Range(defaultStart, defaultEnd)];
        }
      } else {
        // closed: clear ranges
        businessHours[d] = [];
      }
    }

    businessHours.refresh();
    // keep the two sources of truth consistent
    syncOpenDaysFromBH();
  }

  // --- Canonical days and normalizer ---
  static const List<String> _allDaysTitle = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  static const List<String> _allDaysLower = <String>[
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static const Map<String, String> _dayCanonical = {
    // monday
    'm': 'Monday', 'mon': 'Monday', 'monday': 'Monday',
    // tuesday
    't': 'Tuesday', 'tue': 'Tuesday', 'tues': 'Tuesday', 'tuesday': 'Tuesday',
    // wednesday
    'w': 'Wednesday',
    'wed': 'Wednesday',
    'weds': 'Wednesday',
    'wednesday': 'Wednesday',
    // thursday
    'thu': 'Thursday',
    'thur': 'Thursday',
    'thurs': 'Thursday',
    'thursday': 'Thursday',
    // friday
    'f': 'Friday', 'fri': 'Friday', 'friday': 'Friday',
    // saturday
    'sat': 'Saturday', 'saturday': 'Saturday',
    // sunday
    'sun': 'Sunday', 'sunday': 'Sunday',
  };

  String _normalizeDay(String s) {
    final k = s.trim().toLowerCase();
    if (_dayCanonical.containsKey(k)) return _dayCanonical[k]!;
    // fallback: TitleCase the input, but only first match wins
    return k.isEmpty ? '' : k[0].toUpperCase() + k.substring(1);
  }

  // ---------------- Networking: create ----------------
  Future<void> createBusinessProfile({
    required String businessName,
    required String businessAddress,
    required String aboutUs,
    required String capacity,
  }) async {
    isLoading.value = true;
    clearErrors();

    // Gather desired inputs from UI
    final freeH = _intOrNull(freeCancellationHours.value) ?? 24;
    final feePct = _intOrNull(cancellationFeePercentage.value) ?? 0;
    final noRefH = _intOrNull(noRefundHours.value) ?? 0;

    // Enforce tier restrictions BEFORE validating/sending
    final willSendPolicy =
        canEditPolicy; // Foundation/Momentum can't modify policy
    if (!willSendPolicy) {
      // Show info once so user knows why their changes won't apply
      //_toastUpgradeForPolicy();
    }

    // Validate only if we’re actually going to send policy
    if (willSendPolicy && !_validPolicy(freeH, feePct, noRefH)) {
      AppSnackBar.showError(
        'Invalid cancellation policy. '
        'Make sure 0 ≤ fee ≤ 100 and No-refund hours < Free-cancel hours.',
      );
      isLoading.value = false;
      return;
    }

    try {
      final uiStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
      final uiClose = endTime.value.isNotEmpty ? endTime.value : '06:00 PM';

      const allDays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final closed = allDays.where((d) => !openDays.contains(d)).toList();

      // Validate all ranges
      for (final entry in businessHours.entries) {
        if (!_isValidDay(entry.value)) {
          AppSnackBar.showError(
            'Invalid hours for ${entry.key.toUpperCase()}: End time must be after start time.',
          );
          isLoading.value = false;
          return;
        }
      }

      final closeDaysFromBh = _deriveCloseDaysFromBH();
      final bhPayload = _serializeBusinessHoursForApi();

      // DEBUG: Log business_hours payload to verify multi-interval format
      log('=== CREATE PROFILE: business_hours payload ===');
      log(jsonEncode(bhPayload));
      log('==============================================');

      // Build request
      final resp = await ShopApi().createShopWithImage(
        name: businessName,
        address: businessAddress,
        aboutUs: aboutUs,
        capacity: int.tryParse(capacity) ?? 0,
        startAtUi: uiStart,
        closeAtUi: uiClose,
        closeDays: closeDaysFromBh,
        latitude: lat.value.isEmpty ? null : lat.value,
        longitude: long.value.isEmpty ? null : long.value,
        imagePath: imagePath.value.isEmpty ? null : imagePath.value,
        documents: documents,
        // ⬇️ Only include policy fields when user is allowed to edit them
        freeCancellationHours: willSendPolicy ? freeH : null,
        cancellationFeePercentage: willSendPolicy ? feePct : null,
        noRefundHours: willSendPolicy ? noRefH : null,
        token: AuthService.accessToken ?? '',
        extraJson: {"business_hours": bhPayload, "time_zone": timeZone.value},
        // ⬇️ IF ShopApi supports deposit, include it only when allowed:
        // isDepositRequired: canEditDeposit ? isDepositRequired.value : null,
        // depositAmount:     canEditDeposit ? depositAmount.value : null,
      );

      if (resp.isSuccess) {
        profileDetails.value = GetBusinesModel.fromJson(resp.responseData);
        AppSnackBar.showSuccess("Business Profile created successfully!");
        final svc = Get.isRegistered<BusinessOwnerController>()
            ? Get.find<BusinessOwnerController>()
            : null;
        await svc?.refreshGuardsAndServices();
        Get.offNamed('/all-services');
      } else {
        log(
          'Create profile failed: ${resp.statusCode}, error: ${resp.errorMessage}',
        );
        AppSnackBar.showError(
          resp.errorMessage.isNotEmpty ? resp.errorMessage : 'Create failed.',
        );
      }
    } catch (e) {
      log('Create profile error: $e');
      AppSnackBar.showError('Failed to create business profile.');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Networking: update ----------------
  Future<void> updateBusinessProfile({
    required businessName,
    required businessAddress,
    required String aboutUs,
    required String id,
    required String capacity,
    List<String>? openDays,
    List<String>? closeDays,
    String? startAt,
    String? closeAt,
  }) async {
    try {
      isLoading.value = true;

      // --- derive UI times (must be AM/PM) ---
      final uiStart = (startAt?.isNotEmpty ?? false)
          ? startAt!
          : (startTime.value.isNotEmpty
                ? startTime.value
                : (profileDetails.value.data?.startTime ?? '09:00 AM'));

      final uiClose = (closeAt?.isNotEmpty ?? false)
          ? closeAt!
          : (endTime.value.isNotEmpty
                ? endTime.value
                : (profileDetails.value.data?.endTime ?? '06:00 PM'));

      String _normalizeAmPm(String s) => s
          .replaceAll('.', '')
          .toUpperCase()
          .replaceAll('AM', 'AM')
          .replaceAll('PM', 'PM');
      final normStart = _normalizeAmPm(uiStart);
      final normClose = _normalizeAmPm(uiClose);

      // --- days ---
      const allDays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final open = (openDays != null && openDays.isNotEmpty)
          ? openDays
          : this.openDays.toList();
      final closed = (closeDays != null && closeDays.isNotEmpty)
          ? closeDays
          : allDays.where((d) => !open.contains(d)).toList();

      // --- policy ---
      final freeH = int.tryParse(freeCancellationHours.value.trim()) ?? 24;
      final feePct = int.tryParse(cancellationFeePercentage.value.trim()) ?? 0;
      final noRefH = int.tryParse(noRefundHours.value.trim()) ?? 0;

      final sendPolicy = canEditPolicy;
      if (sendPolicy) {
        if (!_validPolicy(freeH, feePct, noRefH)) {
          AppSnackBar.showError(
            'Invalid cancellation policy. Make sure 0 ≤ fee ≤ 100 and No-refund hours < Free-cancel hours.',
          );
          return;
        }
      }

      // --- NEW: deposit guard + normalize ---
      int? depositPercentageToSend;

      //bool? requireDepositToSend;
      if (canEditDeposit) {
        final raw = defaultDepositPercentage.value.trim();

        // Strip everything except digits (and optional dot), e.g. " 68% " -> "68"
        final sanitized = raw.replaceAll(RegExp(r'[^0-9]'), '');
        final parsed = int.tryParse(sanitized);

        if (parsed == null) {
          AppSnackBar.showError('Deposit % must be a whole number (e.g., 10).');
          return;
        }
        if (parsed < 1 || parsed > 100) {
          AppSnackBar.showError('Deposit % must be between 1 and 100.');
          return;
        }

        depositPercentageToSend = parsed;
      }
      // If cannot edit deposit on current plan, do not send those fields (server keeps existing)

      for (final entry in businessHours.entries) {
        if (!_isValidDay(entry.value)) {
          AppSnackBar.showError(
            'Invalid hours for ${entry.key.toUpperCase()}: End time must be after start time.',
          );
          return;
        }
      }

      final closeDaysFromBh = _deriveCloseDaysFromBH();
      final bhPayload = _serializeBusinessHoursForApi();

      // DEBUG: Log what we're sending
      log('=== UPDATE PROFILE DEBUG ===');
      log('imagePath: "${imagePath.value}"');
      log('instagramUrl: "${instagramUrl.value}"');
      log('tiktokUrl: "${tiktokUrl.value}"');
      log('===========================');

      final resp = await ShopApi().updateShopWithImage(
        id: id,
        name: businessName,
        address: businessAddress,
        aboutUs: aboutUs,
        capacity: int.tryParse(capacity) ?? 0,
        startAtUi: normStart,
        closeAtUi: normClose,
        closeDays: closeDaysFromBh,
        latitude: lat.value.isEmpty ? null : lat.value,
        longitude: long.value.isEmpty ? null : long.value,
        imagePath: imagePath.value.isEmpty ? null : imagePath.value,
        documents: documents,
        token: AuthService.accessToken ?? '',
        extraJson: {
          "business_hours": bhPayload,
          "time_zone": timeZone.value,
          // Always send social links (even empty) so backend can clear them
          "instagram_url": instagramUrl.value,
          "tiktok_url": tiktokUrl.value,
          "youtube_url": youtubeUrl.value,
          "website_url": websiteUrl.value,
        },

        // ✅ send policy only if allowed
        freeCancellationHours: sendPolicy ? freeH : null,
        cancellationFeePercentage: sendPolicy ? feePct : null,
        noRefundHours: sendPolicy ? noRefH : null,

        // ✅ NEW: send deposit only if allowed
        //isDepositRequired: canEditDeposit ? requireDepositToSend : null,
        defaultDepositPercentage: canEditDeposit
            ? depositPercentageToSend
            : null,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        AppSnackBar.showSuccess("Business Profile updated successfully!");

        // FIX: Evict old image BEFORE fetching new data
        final oldUrl = profileDetails.value.data?.image;
        if (oldUrl != null && oldUrl.isNotEmpty) {
          await CachedNetworkImage.evictFromCache(oldUrl);
          try {
            await DefaultCacheManager().removeFile(oldUrl);
          } catch (_) {}
        }

        // 1) Fetch profile to get latest data (including new image URL)
        await fetchProfileDetails(silentAuthErrors: true);

        // 2) Now evict NEW image URL with cache busting
        final newUrl = profileDetails.value.data?.image;
        if (newUrl != null && newUrl.isNotEmpty) {
          // Evict the new URL
          await CachedNetworkImage.evictFromCache(newUrl);

          // Also create a cache-busted version for the UI
          final busted =
              '$newUrl${newUrl.contains('?') ? '&' : '?'}v=${DateTime.now().millisecondsSinceEpoch}';

          final m = profileDetails.value;
          if (m.data != null) {
            m.data!.image = busted;
            profileDetails.value = m; // trigger GetX update
            profileDetails.refresh();
          }
        }

        // 3) Navigate after state is fresh
        Get.offNamed('/all-services');
      } else {
        AppSnackBar.showError('Update failed');
      }
      // --- END MODIFIED BLOCK ---
    } catch (e) {
      log('Update error: $e');
      AppSnackBar.showError('Failed to update business profile.');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Raw multipart PUT helper (unchanged) ----------------
  Future<void> _sendPutRequestWithHeadersAndImagesOnly(
    String url,
    Map<String, dynamic> body,
    String? imagePath,
    String? token,
  ) async {
    if (token == null || token.isEmpty) {
      AppSnackBar.showError('Token is invalid or expired.');
      return;
    }

    try {
      var request = http.MultipartRequest('PUT', Uri.parse(url));
      request.headers.addAll({'Authorization': token});
      request.fields['bodyData'] = jsonEncode(body);

      if (imagePath != null && imagePath.isNotEmpty) {
        log('Attaching image: $imagePath');
        request.files.add(
          await http.MultipartFile.fromPath('businessProfileImage', imagePath),
        );
      }

      var response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        AppSnackBar.showSuccess("Business Profile updated successfully!");
      } else {
        var errorResponse = await response.stream.bytesToString();
        log('Response error: $errorResponse');
        AppSnackBar.showError(errorResponse);
      }
    } catch (e) {
      log('Request error: $e');
      AppSnackBar.showError(
        "Failed to update business profile. Please try again.",
      );
    }
  }

  // ---------------- Delete ----------------
  Future<bool> deleteBusinessProfile(String shopId) async {
    isDeleting.value = true;
    try {
      final response = await NetworkCaller().deleteRequest(
        AppUrls.deleteShop(shopId),
        token: AuthService.accessToken,
      );

      if (Get.isDialogOpen ?? false) Get.back();

      if (!response.isSuccess) {
        AppSnackBar.showError(
          response.errorMessage ?? 'Failed to delete profile.',
        );
        return false;
      }

      AppSnackBar.showSuccess("Business Profile deleted successfully!");

      // reset local state
      profileDetails.value = GetBusinesModel(data: null);
      openDays.clear();
      startTime.value = '';
      endTime.value = '';

      if (Get.isRegistered<BusinessOwnerController>()) {
        await Get.find<BusinessOwnerController>().refreshGuardsAndServices();
      }
      return true;
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      AppSnackBar.showError('An error occurred while deleting the profile.');
      return false;
    } finally {
      isDeleting.value = false;
    }
  }

  // ---------------- Misc helpers ----------------
  final RxMap<String, String> fieldErrors = <String, String>{}.obs;
  void clearErrors() => fieldErrors.clear();
  void setFieldError(String field, String message) {
    fieldErrors[field] = message;
    fieldErrors.refresh();
  }

  String _toApiTime(String ui) {
    final m = RegExp(
      r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$',
      caseSensitive: false,
    ).firstMatch(ui);
    if (m == null) return ui;
    int h = int.parse(m.group(1)!);
    final mm = int.parse(m.group(2)!);
    final ap = m.group(3)!.toUpperCase();
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return '${h.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:00';
  }

  String? _buildLocation(String latStr, String longStr) {
    final lat = double.tryParse(latStr);
    final lon = double.tryParse(longStr);
    if (lat == null || lon == null) return null;
    return '$lat,$lon';
  }
}

class _LifecycleObserver with WidgetsBindingObserver {
  final Future<void> Function() onResumed;
  _LifecycleObserver({required this.onResumed});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResumed();
    }
  }
}
