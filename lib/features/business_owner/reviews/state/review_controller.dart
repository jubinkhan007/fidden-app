// lib/features/business_owner/reviews/state/review_controller.dart
import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/review_model.dart';

class ReviewController extends GetxController {
  final reviews = <Review>[].obs;
  final isLoading = false.obs;

  // keep "replying" feature as-is
  final _replyingIds = <String>{}.obs;
  bool isReplying(String id) => _replyingIds.contains(id);

  // --- NEW: remember the last query + debounce ---
  String _lastQuery = '';
  Timer? _debounce;

  /// Call on every keystroke from the search bar
  void search(String shopId, String q) {
    _lastQuery = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchReviews(shopId, query: q.trim().isEmpty ? null : q.trim());
    });
  }

  Future<void> fetchReviews(String shopId, {String? query}) async {
    isLoading.value = true;
    try {
      final url = (query == null || query.isEmpty)
          ? AppUrls.shopReviews(shopId)
          : '${AppUrls.shopReviews(shopId)}?search=${Uri.encodeQueryComponent(query)}';

      final res = await NetworkCaller().getRequest(
        url,
        token: AuthService.accessToken,
      );

      if (!res.isSuccess || res.responseData == null) {
        reviews.clear();
        return;
      }

      // 🔧 NEW: accept either Map or JSON string
      dynamic data = res.responseData;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          reviews.clear();
          return;
        }
      }
      if (data is! Map<String, dynamic>) {
        reviews.clear();
        return;
      }

      final Map<String, dynamic> root = data as Map<String, dynamic>;

      // supports both: {results:{...}} and flat {...}
      final Map<String, dynamic> payload =
          (root['results'] is Map<String, dynamic>)
          ? root['results'] as Map<String, dynamic>
          : root;

      final List<Review> list = (payload['reviews'] as List? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(_mapApiReview)
          .toList();

      reviews.assignAll(list);
    } catch (e) {
      reviews.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Pull-to-refresh should keep current search text
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

  // ---- mapping helper (unchanged except id toString) ----
  Review _mapApiReview(Map<String, dynamic> j) {
    // take newest reply if present
    String? replyText;
    final replies = (j['reply'] as List? ?? j['replies'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList();
    if (replies.isNotEmpty) {
      replies.sort((a, b) {
        final ad =
            DateTime.tryParse(a['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final bd =
            DateTime.tryParse(b['created_at']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bd.compareTo(ad);
      });
      replyText = replies.first['message']?.toString();
    }

    final authorName = (j['user_name'] as String?)?.trim();
    final userId = j['user_id']?.toString();
    final fallbackAuthor = (authorName?.isNotEmpty == true)
        ? authorName!
        : (userId != null ? 'User #$userId' : 'User');

    return Review(
      id: (j['id'] ?? '').toString(),
      author: fallbackAuthor,
      avatarUrl: (j['user_img'] as String?)?.trim(),
      rating: ((j['rating'] as num?) ?? 0).toDouble(),
      comment: (j['review'] as String?)?.trim() ?? '',
      date:
          DateTime.tryParse(j['created_at']?.toString() ?? '') ??
          DateTime.now(),
      serviceName: (j['service_name'] as String?)?.trim() ?? '',
      reply: replyText,
    );
  }
}
