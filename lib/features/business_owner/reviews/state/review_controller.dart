// lib/features/business_owner/reviews/controller/review_controller.dart
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/services/Auth_service.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../data/review_model.dart';

class ReviewController extends GetxController {
  final reviews = <Review>[].obs;
  final isLoading = false.obs;

  // Call this from the screen (or onInit if you pass shopId into the controller)
  Future<void> fetchReviews(String shopId) async {
    isLoading.value = true;
    try {
      final res = await NetworkCaller().getRequest(
        AppUrls.shopReviews(shopId),
        token: AuthService.accessToken,
      );

      if (!res.isSuccess || res.responseData is! Map) {
        if (kDebugMode)
          debugPrint('[reviews] bad response: ${res.responseData}');
        reviews.clear();
        return;
      }

      final map = res.responseData as Map<String, dynamic>;
      final list = (map['reviews'] as List? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(_mapApiReview)
          .toList();

      reviews.assignAll(list);
    } catch (e) {
      if (kDebugMode) debugPrint('[reviews] error: $e');
      reviews.clear();
    } finally {
      isLoading.value = false;
    }
  }

  /// Client-side reply (local only). Replace with POST when your API is ready.
  void addReply(Review review, String replyText) {
    review.reply = replyText;
    reviews.refresh();
  }

  // ---- mapping helper ----
  Review _mapApiReview(Map<String, dynamic> j) {
    // replies: take latest message if exists
    String? replyText;
    final replies =
        (j['reply'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
        const [];
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
    final fallbackAuthor = authorName?.isNotEmpty == true
        ? authorName!
        : (userId != null ? 'User #$userId' : 'User');

    return Review(
      author: fallbackAuthor,
      avatarUrl: (j['user_img'] as String?)?.trim() ?? '',
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
