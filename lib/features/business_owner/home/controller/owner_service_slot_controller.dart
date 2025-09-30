// lib/features/business_owner/home/controller/service_slots_controller.dart
import 'dart:developer';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/user/shops/services/data/time_slots_model.dart';
import 'package:fidden/features/business_owner/home/model/get_single_service_model.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// lib/features/business_owner/home/controller/service_slots_controller.dart
class OwnerServiceSlotsController extends GetxController {
  OwnerServiceSlotsController({required this.shopId, required this.serviceId});
  final int shopId;
  final int serviceId;

  final isLoadingService = false.obs;
  final isLoadingSlots = false.obs;

  final RxString fetchedForDate = ''.obs;
  final RxList<SlotItem> slots = <SlotItem>[].obs;

  /// Current working set (editable)
  final RxSet<String> disabledTimes = <String>{}.obs;

  /// Original from server (for change detection)
  final Set<String> _initialDisabled = <String>{};

  /// Whether disabledTimes differs from _initialDisabled
  final hasUnsavedChanges = false.obs;

  final _dFmt = DateFormat('yyyy-MM-dd');
  final _todFmt = DateFormat('HH:mm');

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await fetchServiceDisabledTimes();
    await fetchOneDaySlots(); // today, fall forward
  }

  Future<void> refresh() async => _init();

  Future<void> fetchServiceDisabledTimes() async {
    isLoadingService.value = true;
    try {
      final resp = await NetworkCaller().getRequest(
        AppUrls.getSingleService('$serviceId'),
        token: AuthService.accessToken,
      );
      if (!resp.isSuccess || resp.responseData is! Map<String, dynamic>) return;

      final data = resp.responseData as Map<String, dynamic>;
      final list = (data['disabled_times'] as List?)?.cast<String>() ?? const [];

      _initialDisabled
        ..clear()
        ..addAll(list.map(_normalize));

      disabledTimes
        ..clear()
        ..addAll(_initialDisabled);

      _recomputeUnsaved();
    } finally {
      isLoadingService.value = false;
    }
  }

  Future<void> fetchOneDaySlots({int maxDaysAhead = 2}) async {
    isLoadingSlots.value = true;
    try {
      final start = DateTime.now();
      bool loadedAny = false;
      for (int i = 0; i <= maxDaysAhead; i++) {
        final day = DateTime(start.year, start.month, start.day).add(Duration(days: i));
        final key = _dFmt.format(day);
        if (await _fetchForDate(key)) {
          loadedAny = true;
          break;
        }
      }
      if (!loadedAny) {
        slots.clear();
        fetchedForDate.value = _dFmt.format(start);
      }
    } finally {
      isLoadingSlots.value = false;
    }
  }

  Future<bool> _fetchForDate(String key) async {
    final url = AppUrls.ownerSlots(shopId: shopId, serviceId: serviceId, date: key);
    final resp = await NetworkCaller().getRequest(url, token: AuthService.accessToken);
    if (!resp.isSuccess) return false;

    final raw = resp.responseData;
    final listJson = raw is Map<String, dynamic>
        ? (raw['slots'] as List?) ?? const []
        : (raw is List ? raw : const []);

    final list = listJson
        .map((e) => SlotItem.fromJson(e as Map<String, dynamic>))
        .toList();

    // mark disabled by service (local set)
    final dset = disabledTimes;
    final marked = list.map((s) {
      final hhmm = _normalize(_todFmt.format(s.startTimeUtc.toLocal()));
      return s.copyWith(disabledByService: dset.contains(hhmm));
    }).toList();

    slots.assignAll(marked);
    fetchedForDate.value = key;
    return slots.isNotEmpty;
  }

  String _normalize(String s) {
    final parts = s.trim().replaceAll('.', ':').replaceAll('-', ':').split(':');
    final h = parts.isNotEmpty ? parts[0].padLeft(2, '0') : '00';
    final m = parts.length > 1 ? parts[1].padLeft(2, '0') : '00';
    return '$h:$m';
  }

  /// Toggle locally only — no API call here.
  void toggleDisableFor(String hhmm) {
    final key = _normalize(hhmm);
    if (disabledTimes.contains(key)) {
      disabledTimes.remove(key);
    } else {
      disabledTimes.add(key);
    }

    // Re-mark current list for immediate visual feedback
    final dset = disabledTimes;
    slots.assignAll(slots.map((s) {
      final k = _normalize(_todFmt.format(s.startTimeUtc.toLocal()));
      return s.copyWith(disabledByService: dset.contains(k));
    }).toList());

    _recomputeUnsaved();
  }

  void _recomputeUnsaved() {
    hasUnsavedChanges.value =
    !(Set<String>.from(disabledTimes).containsAll(_initialDisabled) &&
        _initialDisabled.containsAll(disabledTimes));
  }

  /// What to save on Update
  List<String> get disabledStartTimesForSave => disabledTimes.toList()..sort();

  /// Helper to merge into an existing service payload
  void applyToPayload(Map<String, dynamic> body) {
    body['disabled_start_times'] = disabledStartTimesForSave;
  }

  /// Call this after a successful save to reset the dirty state.
  void markSaved() {
    _initialDisabled
      ..clear()
      ..addAll(disabledTimes);
    _recomputeUnsaved();
  }
}
