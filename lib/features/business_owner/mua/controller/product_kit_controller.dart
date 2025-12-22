import 'package:get/get.dart';
import '../data/mua_models.dart';
import '../services/mua_service.dart';

/// Controller for Product Kit checklist
class ProductKitController extends GetxController {
  final MUAService _service = MUAService();

  final RxList<ProductKitItem> items = <ProductKitItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedCategory = ''.obs;
  final RxSet<int> _busyIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchItems();
  }

  bool isBusy(int id) => _busyIds.contains(id);

  Future<void> fetchItems({String? category}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final data = await _service.getProductKit(category: category);
      items.assignAll(data);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String? category) {
    selectedCategory.value = category ?? '';
    fetchItems(category: category);
  }

  Future<bool> createItem(ProductKitItem item) async {
    try {
      final created = await _service.createProductKitItem(item);
      items.insert(0, created);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product');
      return false;
    }
  }

  Future<void> togglePacked(int id) async {
    final index = items.indexWhere((i) => i.id == id);
    if (index == -1) return;

    try {
      _busyIds.add(id);
      _busyIds.refresh();

      final current = items[index];
      final updated = await _service.togglePacked(id, !current.isPacked);
      items[index] = updated;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update status');
    } finally {
      _busyIds.remove(id);
      _busyIds.refresh();
    }
  }

  Future<void> deleteItem(int id) async {
    try {
      _busyIds.add(id);
      _busyIds.refresh();

      await _service.deleteProductKitItem(id);
      items.removeWhere((i) => i.id == id);
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete item');
    } finally {
      _busyIds.remove(id);
      _busyIds.refresh();
    }
  }

  // Stats
  int get totalCount => items.length;
  int get packedCount => items.where((i) => i.isPacked).length;
  int get unpackedCount => items.where((i) => !i.isPacked).length;

  // Group by category
  Map<String, List<ProductKitItem>> get groupedByCategory {
    final grouped = <String, List<ProductKitItem>>{};
    for (final item in items) {
      final cat = item.categoryDisplay ?? item.category;
      grouped.putIfAbsent(cat, () => []).add(item);
    }
    return grouped;
  }
}
