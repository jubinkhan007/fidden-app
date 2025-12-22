import 'package:get/get.dart';
import '../data/esthetician_models.dart';
import '../services/esthetician_service.dart';

/// Controller for retail products
class RetailProductsController extends GetxController {
  final EstheticianService _service = EstheticianService();

  final RxList<RetailProduct> products = <RetailProduct>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString filterCategory = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  /// Fetch retail products
  Future<void> fetchProducts({String? category}) async {
    isLoading.value = true;
    errorMessage.value = '';
    if (category != null) {
      filterCategory.value = category;
    }

    try {
      products.value = await _service.getRetailProducts(
        category: filterCategory.value.isNotEmpty ? filterCategory.value : null,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  /// Filtered products by category
  List<RetailProduct> get filteredProducts {
    if (filterCategory.value.isEmpty) return products;
    return products.where((p) => p.category == filterCategory.value).toList();
  }

  /// Active products only
  List<RetailProduct> get activeProducts =>
      products.where((p) => p.isActive).toList();

  /// Create new product
  Future<void> createProduct(Map<String, dynamic> data) async {
    await _service.createRetailProduct(data);
    await fetchProducts();
  }

  /// Update product
  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await _service.updateRetailProduct(id, data);
    await fetchProducts();
  }

  /// Delete product
  Future<void> deleteProduct(int id) async {
    await _service.deleteRetailProduct(id);
    await fetchProducts();
  }
}
