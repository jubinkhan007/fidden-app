// lib/features/business_owner/profile/controller/busines_owner_profile_controller.dart
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/business_owner/home/controller/business_owner_controller.dart';
import 'package:fidden/features/business_owner/profile/data/stripe_models.dart';
import 'package:fidden/features/business_owner/profile/screens/stripe_webview_screen.dart';
import 'package:fidden/features/business_owner/profile/services/shop_api.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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


/// Simple, UI-friendly (start,end) for a day. Stored as "hh:mm AM/PM".
@immutable
class Range {
  final String start; // e.g. "09:00 AM"
  final String end;   // e.g. "06:00 PM"
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
  final freeCancellationHours = ''.obs;     // e.g. "24"
  final cancellationFeePercentage = ''.obs; // e.g. "50"
  final noRefundHours = ''.obs;             // e.g. "4"

  // Deposit UI state
  final isDepositRequired = false.obs;
  final defaultDepositPercentage = ''.obs;

  // ---- Subscription context ----
  final sub = Get.isRegistered<SubscriptionController>()
      ? Get.find<SubscriptionController>()
      : Get.put(SubscriptionController());

  bool get _isFoundation => sub.isFoundation;
  bool get _isMomentum   => sub.isMomentum;
  bool get _isIcon       => sub.isIcon;

  // What each tier can edit
  bool get canEditDeposit => _isMomentum || _isIcon;
  bool get canEditPolicy  => _isIcon;

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

  // ---------------- Lifecycle ----------------
  @override
  void onInit() {
    super.onInit();
    _init(); // keep onInit lean

    // If tokens refresh after we mounted, refetch profile quietly
    ever(AuthService.tokenRefreshCount, (_) async {
      await fetchProfileDetails(silentAuthErrors: true);
      await checkStripeStatusIfPossible();
    });

    WidgetsBinding.instance.addObserver(
      _LifecycleObserver(onResumed: () async {
        if (_awaitingOnboarding) {
          _awaitingOnboarding = false;
          await checkStripeStatusIfPossible();
        }
      }),
    );
  }

  Future<void> _init() async {
    await AuthService.waitForToken();
    await fetchProfileDetails(silentAuthErrors: true);

    // Seed UI from API
    final data = profileDetails.value.data;
    final fromApiOpenDays = data?.openDays;
    if (fromApiOpenDays != null && fromApiOpenDays.isNotEmpty) {
      openDays
        ..clear()
        ..addAll(fromApiOpenDays.map(_normalizeDay));
    }



    startTime.value = data?.startTime ?? startTime.value;
    endTime.value   = data?.endTime   ?? endTime.value;

    // Cancellation policy (defaults when missing)
    freeCancellationHours.value     = (data?.freeCancellationHours ?? 24).toString();
    cancellationFeePercentage.value = (data?.cancellationFeePercentage ?? 0).toString();
    noRefundHours.value             = (data?.noRefundHours ?? 0).toString();

    // Deposit (best-effort – BusinessProfileModel has defaultDepositPercentage)
    defaultDepositPercentage.value = (data?.defaultDepositPercentage ?? 0).toString();

    isDepositRequired.value  =  data?.isDepositRequired ?? false;
    // NEW: Seed per-day hours
    _seedBusinessHoursFromData(data);
    ensureBusinessHoursForOpenDays();
    await checkStripeStatusIfPossible();
  }


  void _seedBusinessHoursFromData(Data? d) {
    // Prefer API business_hours
    if (d?.businessHours != null && d!.businessHours!.isNotEmpty) {
      businessHours
        ..clear()
        ..addAll(d.businessHours!.map((k, v) => MapEntry(
          k.toLowerCase(),
          v.map((pair) => Range(pair.$1, pair.$2)).toList(),
        )));
      return;
    }

    // Fallback: openDays + single legacy range
    const days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
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

  void onDefaultTimeChanged({required bool isStart, required String value}) {
    final oldStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
    final oldEnd   = endTime.value.isNotEmpty   ? endTime.value   : '06:00 PM';

    if (isStart) {
      startTime.value = value;
    } else {
      endTime.value = value;
    }

    _propagateDefaultChange(oldStart: oldStart, oldEnd: oldEnd);
  }

  /// Update businessHours for days that were still using the old defaults,
  /// and seed any open-but-empty day with the new defaults.
  void _propagateDefaultChange({required String oldStart, required String oldEnd}) {
    final defStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
    final defEnd   = endTime.value.isNotEmpty   ? endTime.value   : '06:00 PM';

    // compare in lowercase for safety
    final openLower = openDays.map((d) => d.toLowerCase()).toSet();

    for (final day in ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']) {
      final ranges = businessHours[day] ?? const [];

      if (openLower.contains(day)) {
        if (ranges.isEmpty) {
          // open day with no custom hours -> seed with new defaults
          businessHours[day] = [Range(defStart, defEnd)];
        } else if (ranges.length == 1 &&
            ranges.first.start == oldStart &&
            ranges.first.end == oldEnd) {
          // still using old default -> update to new default
          businessHours[day] = [Range(defStart, defEnd)];
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
    final reg = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$', caseSensitive: false);
    final m = reg.firstMatch(ui.trim());
    if (m == null) return ui;
    int h = int.parse(m.group(1)!);
    final mm = m.group(2)!;
    final ap = m.group(3)!.toUpperCase();
    if (ap == 'PM' && h != 12) h += 12;
    if (ap == 'AM' && h == 12) h = 0;
    return '${h.toString().padLeft(2,'0')}:$mm';
  }

  bool _isValidRange(Range r) {
    // very light validation: start < end when converted to minutes
    int _mins(String ui) {
      final m = RegExp(r'(\d{1,2}):(\d{2})\s*([AP]M)', caseSensitive: false).firstMatch(ui)!;
      int hh = int.parse(m.group(1)!);
      final mm = int.parse(m.group(2)!);
      final ap = m.group(3)!.toUpperCase();
      if (ap == 'PM' && hh != 12) hh += 12;
      if (ap == 'AM' && hh == 12) hh = 0;
      return hh*60 + mm;
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
      AppSnackBar.showError('Could not start Stripe onboarding. Please try again.');
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
      'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday',
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
                .map((day) => ListTile(
              title: Text(day),
              onTap: () => Navigator.pop(context, day),
            ))
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
      final full = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

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
    isLoading.value = true;
    try {
      await AuthService.waitForToken();

      final response = await NetworkCaller().getRequest(
        AppUrls.getMBusinessProfile,
        token: AuthService.accessToken,
        treat404AsEmpty: true,
        emptyPayload: const {"data": null},
      );

      if (response.isSuccess && response.responseData is Map<String, dynamic>) {
        profileDetails.value = GetBusinesModel.fromJson(response.responseData);
        return;
      }

      final sc = response.statusCode ?? 0;
      final err = (response.errorMessage ?? '').toLowerCase();

      if (sc == 401 || sc == 403 || err.contains('shop')) {
        profileDetails.value = GetBusinesModel(data: null);
        return;
      }

      profileDetails.value = GetBusinesModel(data: null);
      if (!silentAuthErrors) {
        AppSnackBar.showError(response.errorMessage ?? 'Failed to fetch profile.');
      }
    } catch (e) {
      profileDetails.value = GetBusinesModel(data: null);
      if (!silentAuthErrors) {
        AppSnackBar.showError('An error occurred while fetching profile details.');
      }
      if (kDebugMode) log('Fetch profile details error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------- Validation helpers ----------------
  int? _intOrNull(String s) => int.tryParse(s.trim());

  bool _validPolicy(int freeH, int feePct, int noRefundH) {
    if (freeH < 0 || noRefundH < 0) return false;
    if (feePct < 0 || feePct > 100) return false;
    if (noRefundH >= freeH) return false; // no-refund must be inside free window
    return true;
  }


  // ---- Day key maps for API <-> UI ----
  static const Map<String, String> _uiLowerFull_to_apiShort =
  {
    'monday': 'mon',
    'tuesday': 'tue',
    'wednesday': 'wed',
    'thursday': 'thu',
    'friday': 'fri',
    'saturday': 'sat',
    'sunday': 'sun',
  };

  static const Map<String, String> _apiShort_to_uiLowerFull =
  {
    'mon': 'monday',
    'tue': 'tuesday',
    'wed': 'wednesday',
    'thu': 'thursday',
    'fri': 'friday',
    'sat': 'saturday',
    'sun': 'sunday',
  };

  String _toApiDayKeyShort3(String anyUiKey) {
    final k = anyUiKey.trim().toLowerCase();     // "monday" etc.
    return _uiLowerFull_to_apiShort[k] ?? k;     // -> "mon"
  }

  String _fromApiDayKeyShort3(String apiKey) {
    final k = apiKey.trim().toLowerCase();       // "mon" etc.
    return _apiShort_to_uiLowerFull[k] ?? k;     // -> "monday"
  }


  Map<String, dynamic> _serializeBusinessHoursForApi() {
    final Map<String, dynamic> out = {};
    businessHours.forEach((uiKeyLower, ranges) {
      final apiKey = _toApiDayKeyShort3(uiKeyLower);  // <-- "mon"
      out[apiKey] = ranges.isEmpty
          ? []
          : ranges.map((r) => [_uiTo24(r.start), _uiTo24(r.end)]).toList();
    });
    return out;
  }


  List<String> _deriveCloseDaysFromBH() {
    const days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
    return days.where((d) => (businessHours[d]?.isEmpty ?? true)).toList();
  }


  void ensureBusinessHoursForOpenDays() {
    final defaultStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
    final defaultEnd   = endTime.value.isNotEmpty   ? endTime.value   : '06:00 PM';

    // Canonical title-case names in openDays, but BH map keys are lowercase.
    final openSet = openDays.map((d) => d.toLowerCase()).toSet();

    for (final d in ['monday','tuesday','wednesday','thursday','friday','saturday','sunday']) {
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
  final defaultStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
  final defaultEnd   = endTime.value.isNotEmpty   ? endTime.value   : '06:00 PM';

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
  ///   using the current startTime/endTime.
  /// - Any *closed* day gets cleared ([]).
  void applyOpenDaysToBH() {
    // ensure all 7 keys exist
    const days = ['monday','tuesday','wednesday','thursday','friday','saturday','sunday'];
    for (final d in days) {
      businessHours.putIfAbsent(d, () => []);
    }

    final defaultStart = startTime.value.isNotEmpty ? startTime.value : '09:00 AM';
    final defaultEnd   = endTime.value.isNotEmpty   ? endTime.value   : '06:00 PM';

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
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
  ];
  static const List<String> _allDaysLower = <String>[
    'monday','tuesday','wednesday','thursday','friday','saturday','sunday'
  ];

  static const Map<String, String> _dayCanonical = {
    // monday
    'm': 'Monday', 'mon': 'Monday', 'monday': 'Monday',
    // tuesday
    't': 'Tuesday', 'tue': 'Tuesday', 'tues': 'Tuesday', 'tuesday': 'Tuesday',
    // wednesday
    'w': 'Wednesday', 'wed': 'Wednesday', 'weds': 'Wednesday', 'wednesday': 'Wednesday',
    // thursday
    'thu': 'Thursday', 'thur': 'Thursday', 'thurs': 'Thursday', 'thursday': 'Thursday',
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
    final willSendPolicy = canEditPolicy; // Foundation/Momentum can't modify policy
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

      const allDays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
      final closed = allDays.where((d) => !openDays.contains(d)).toList();

      // Validate all ranges
      for (final entry in businessHours.entries) {
        if (!_isValidDay(entry.value)) {
          AppSnackBar.showError('Invalid hours for ${entry.key.toUpperCase()}: check start/end.');
          isLoading.value = false;
          return;
        }
      }

      final closeDaysFromBh = _deriveCloseDaysFromBH();
      final bhPayload = _serializeBusinessHoursForApi();

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
        extraJson: { "business_hours": bhPayload },
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
        log('Create profile failed: ${resp.statusCode}, error: ${resp.errorMessage}');
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

      String _normalizeAmPm(String s) =>
          s.replaceAll('.', '').toUpperCase().replaceAll('AM', 'AM').replaceAll('PM', 'PM');
      final normStart = _normalizeAmPm(uiStart);
      final normClose = _normalizeAmPm(uiClose);

      // --- days ---
      const allDays = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
      final open = (openDays != null && openDays.isNotEmpty) ? openDays : this.openDays.toList();
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
          AppSnackBar.showError('Invalid hours for ${entry.key.toUpperCase()}: check start/end.');
          return;
        }
      }

      final closeDaysFromBh = _deriveCloseDaysFromBH();
      final bhPayload = _serializeBusinessHoursForApi();

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
        extraJson: { "business_hours": bhPayload },

        // ✅ send policy only if allowed
        freeCancellationHours: sendPolicy ? freeH : null,
        cancellationFeePercentage: sendPolicy ? feePct : null,
        noRefundHours: sendPolicy ? noRefH : null,

        // ✅ NEW: send deposit only if allowed
        //isDepositRequired: canEditDeposit ? requireDepositToSend : null,
        defaultDepositPercentage: canEditDeposit ? depositPercentageToSend : null,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        AppSnackBar.showSuccess("Business Profile updated successfully!");
        await fetchProfileDetails();
        Get.offNamed('/all-services');
      } else {
        AppSnackBar.showError('Update failed');
      }
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
      AppSnackBar.showError("Failed to update business profile. Please try again.");
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
        AppSnackBar.showError(response.errorMessage ?? 'Failed to delete profile.');
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
    final m = RegExp(r'^\s*(\d{1,2}):(\d{2})\s*([AP]M)\s*$', caseSensitive: false).firstMatch(ui);
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
