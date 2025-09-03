import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum ReviewsSort { newest, oldest, highest, lowest }

class ServiceOption {
  final String id; // optional if you later switch to id from API
  final String name;
  ServiceOption({required this.id, required this.name});
}

class ReviewsFilterController extends GetxController {
  // text search
  final query = ''.obs;

  // rating
  final minRating = 0.obs; // 0..5

  // replies
  final hasReplyOnly = false.obs;

  // sort
  final sort = ReviewsSort.newest.obs;

  // dates
  final dateFrom = Rxn<DateTime>();
  final dateTo = Rxn<DateTime>();

  // NEW: service filter (by name for now; switch to id later)
  final selectedServiceName = ''.obs; // empty = any

  // Options to show in dropdown (derive from reviews or load from API)
  final serviceOptions = <ServiceOption>[].obs;

  // helper
  String formatDate(DateTime? d) =>
      d == null ? 'Any' : DateFormat('MMM d').format(d);
}
