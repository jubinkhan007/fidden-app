import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/review_model.dart';
import '../data/reviews_repository.dart';

class ReviewController extends GetxController {
  final reviews = <Review>[].obs;
  final isLoading = false.obs; // spinner only on true cold start
  final _replyingIds = <String>{}.obs;
  bool isReplying(String id) => _replyingIds.contains(id);

  // cache
  final _repo = ReviewsRepository();
  String? _shopId; // remember last shop for refreshCurrent
  DateTime _lastCacheTs = DateTime.fromMillisecondsSinceEpoch(0);

  // debounce search
  String _lastQuery = '';
  Timer? _debounce;

  /// Call once from screen with the active shopId
  Future<void> initForShop(String shopId) async {
    _shopId = shopId;

    // 1) Seed from cache (instant UI)
    final snap = await _repo.readCache(shopId);
    _lastCacheTs = snap.ts;
    if (snap.list.isNotEmpty) {
      reviews.assignAll(snap.list);
      isLoading(false);
    }

    // 2) If no cache or stale → background refresh
    if (snap.list.isEmpty || _repo.isStale(snap.ts)) {
      unawaited(fetchReviews(shopId)); // will flip spinner only if still empty
    }
  }

  /// User types in the search bar
  void search(String shopId, String q) {
    _lastQuery = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchReviews(shopId, query: q.trim().isEmpty ? null : q.trim());
    });
  }

  Future<void> fetchReviews(String shopId, {String? query}) async {
    // show spinner only if we have nothing to show yet
    if (reviews.isEmpty) isLoading.value = true;

    try {
      final url = (query == null || query.isEmpty)
          ? AppUrls.shopReviews(shopId)
          : '${AppUrls.shopReviews(shopId)}?search=${Uri.encodeQueryComponent(query)}';

      final res = await NetworkCaller().getRequest(
        url,
        token: AuthService.accessToken,
      );

      if (!res.isSuccess || res.responseData == null) {
        // no remote updates; keep whatever is on screen
        return;
      }

      dynamic data = res.responseData;
      if (data is String) {
        try { data = jsonDecode(data); } catch (_) { return; }
      }
      if (data is! Map<String, dynamic>) return;

      final Map<String, dynamic> root = data;
      final Map<String, dynamic> payload =
      (root['results'] is Map<String, dynamic>)
          ? root['results'] as Map<String, dynamic>
          : root;

      final List<Review> list = (payload['reviews'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(Review.fromApi)
          .toList();

      reviews.assignAll(list);

      // persist ONLY for the base list (no search), so returning to screen is instant
      if (query == null || query.isEmpty) {
        await _repo.writeCache(shopId, list);
        _lastCacheTs = DateTime.now();
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Pull-to-refresh should keep current query
  Future<void> refreshCurrent(String shopId) =>
      fetchReviews(shopId, query: _lastQuery.isEmpty ? null : _lastQuery);

  Future<void> sendReply({
    required Review review,
    required String message,
  }) async {
    if (message.trim().isEmpty) return;
    final id = review.id;

    _replyingIds.add(id);
    _replyingIds.refresh();

    try {
      final res = await NetworkCaller().postRequest(
        AppUrls.replyReviews(id),
        token: AuthService.accessToken,
        body: {'message': message.trim()},
      );

      if (res.isSuccess) {
        review.reply = message.trim(); // optimistic update
        reviews.refresh();

        // also persist updated list (keeps cache fresh when coming back)
        if (_shopId != null) {
          await _repo.writeCache(_shopId!, reviews.toList());
        }

        Get.snackbar('Reply sent', 'Your reply has been posted.');
      } else {
        final detail = res.responseData is Map
            ? (res.responseData['detail'] ?? 'Failed to send reply')
            : 'Failed to send reply';
        Get.snackbar('Error', detail.toString());
      }
    } catch (e) {
      if (kDebugMode) debugPrint('sendReply error: $e');
      Get.snackbar('Error', 'Could not send reply. Please try again.');
    } finally {
      _replyingIds.remove(id);
      _replyingIds.refresh();
    }
  }
}
