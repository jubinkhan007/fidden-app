import 'package:get/get.dart';
import '../data/hairstylist_models.dart';
import '../services/hairstylist_service.dart';

/// Controller for product recommendations
class ProductRecommendationController extends GetxController {
  final HairstylistService _service = HairstylistService();

  final RxList<ProductRecommendation> recommendations =
      <ProductRecommendation>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString filterCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecommendations();
  }

  /// Fetch all recommendations
  Future<void> fetchRecommendations({int? clientId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      recommendations.value = await _service.getRecommendations(
        clientId: clientId,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Create a recommendation
  Future<bool> createRecommendation(Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final newRec = await _service.createRecommendation(data);
      recommendations.insert(0, newRec);
      Get.back();
      Get.snackbar('Success', 'Recommendation added');
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to add recommendation');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Delete a recommendation
  Future<bool> deleteRecommendation(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      await _service.deleteRecommendation(id);
      recommendations.removeWhere((r) => r.id == id);
      Get.snackbar('Success', 'Recommendation deleted');
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to delete recommendation');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get filtered recommendations
  List<ProductRecommendation> get filteredRecommendations {
    if (filterCategory.value.isEmpty) return recommendations;
    return recommendations
        .where((r) => r.category == filterCategory.value)
        .toList();
  }

  /// Group recommendations by category
  Map<String, List<ProductRecommendation>> get recommendationsByCategory {
    final grouped = <String, List<ProductRecommendation>>{};
    for (final rec in recommendations) {
      final category = rec.categoryDisplay ?? 'Other';
      grouped.putIfAbsent(category, () => []).add(rec);
    }
    return grouped;
  }

  /// Group recommendations by client
  Map<String, List<ProductRecommendation>> get recommendationsByClient {
    final grouped = <String, List<ProductRecommendation>>{};
    for (final rec in recommendations) {
      final client = rec.clientName ?? 'Unknown Client';
      grouped.putIfAbsent(client, () => []).add(rec);
    }
    return grouped;
  }
}
