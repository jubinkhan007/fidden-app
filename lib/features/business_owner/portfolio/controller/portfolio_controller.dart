import 'dart:io';
import 'package:get/get.dart';
import '../data/portfolio_item_model.dart';
import '../services/portfolio_service.dart';

class PortfolioController extends GetxController {
  final PortfolioService _portfolioService = PortfolioService();

  final RxList<PortfolioItem> portfolioItems = <PortfolioItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPortfolioItems();
  }

  Future<void> fetchPortfolioItems() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final items = await _portfolioService.getPortfolioItems();
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
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final newItem = await _portfolioService.createPortfolioItem(
        image: image,
        tags: tags,
        description: description,
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
