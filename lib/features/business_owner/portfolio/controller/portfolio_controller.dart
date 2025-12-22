import 'dart:io';
import 'package:get/get.dart';
import '../data/portfolio_item_model.dart';
import '../services/portfolio_service.dart';

class PortfolioController extends GetxController {
  final PortfolioService _portfolioService = PortfolioService();

  final RxList<PortfolioItem> portfolioItems = <PortfolioItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString currentNiche = ''.obs;  // Track current niche filter

  @override
  void onInit() {
    super.onInit();
    // Don't auto-fetch; let dashboard controllers fetch with their niche
  }

  /// Fetch portfolio items, optionally filtered by niche
  /// [niche] - 'tattoo', 'nail', 'makeup', 'barber', 'hair'
  Future<void> fetchPortfolioItems({String? niche}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      currentNiche.value = niche ?? '';
      
      final items = await _portfolioService.getPortfolioItems(niche: niche);
      portfolioItems.value = items;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPortfolioItem({
    required File image,
    required List<String> tags,
    required String description,
    String? categoryTag,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Use provided categoryTag or fall back to currentNiche
      final effectiveTag = categoryTag ?? (currentNiche.value.isNotEmpty ? currentNiche.value : null);
      
      final newItem = await _portfolioService.createPortfolioItem(
        image: image,
        tags: tags,
        description: description,
        categoryTag: effectiveTag,
      );
      
      portfolioItems.insert(0, newItem); // Add to beginning
      Get.back(); // Close upload screen
      Get.snackbar('Success', 'Portfolio item added successfully');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to add portfolio item');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updatePortfolioItem({
    required int id,
    List<String>? tags,
    String? description,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final updatedItem = await _portfolioService.updatePortfolioItem(
        id: id,
        tags: tags,
        description: description,
      );
      
      final index = portfolioItems.indexWhere((item) => item.id == id);
      if (index != -1) {
        portfolioItems[index] = updatedItem;
      }
      
      Get.back(); // Close edit screen
      Get.snackbar('Success', 'Portfolio item updated');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to update portfolio item');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deletePortfolioItem(int id) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _portfolioService.deletePortfolioItem(id);
      
      portfolioItems.removeWhere((item) => item.id == id);
      Get.snackbar('Success', 'Portfolio item deleted');
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to delete portfolio item');
    } finally {
      isLoading.value = false;
    }
  }
}
