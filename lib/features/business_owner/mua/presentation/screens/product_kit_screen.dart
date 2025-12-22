import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/product_kit_controller.dart';
import '../../data/mua_models.dart';

/// Product Kit checklist screen for MUA
class ProductKitScreen extends StatelessWidget {
  const ProductKitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductKitController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Product Kit'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Obx(() => Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${controller.packedCount}/${controller.totalCount} packed',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context, controller),
        backgroundColor: const Color(0xFFB8192E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'Your kit is empty',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add products to track your makeup kit',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchItems(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Progress bar
              _buildProgressBar(controller),
              const SizedBox(height: 16),
              
              // Items grouped by category
              ...controller.groupedByCategory.entries.map((entry) {
                return _buildCategorySection(entry.key, entry.value, controller);
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProgressBar(ProductKitController controller) {
    final progress = controller.totalCount > 0 
        ? controller.packedCount / controller.totalCount 
        : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Packing Progress', style: TextStyle(fontWeight: FontWeight.w500)),
              Text(
                '${(progress * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB8192E)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFFB8192E)),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<ProductKitItem> items, ProductKitController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFB8192E)),
          ),
        ),
        ...items.map((item) => _buildItemTile(item, controller)),
      ],
    );
  }

  Widget _buildItemTile(ProductKitItem item, ProductKitController controller) {
    return Dismissible(
      key: Key('kit_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => controller.deleteItem(item.id),
      child: Obx(() {
        final isBusy = controller.isBusy(item.id);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: ListTile(
            leading: isBusy
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Checkbox(
                    value: item.isPacked,
                    onChanged: isBusy ? null : (_) => controller.togglePacked(item.id),
                    activeColor: const Color(0xFF4CAF50),
                  ),
            title: Text(
              item.name,
              style: TextStyle(
                decoration: item.isPacked ? TextDecoration.lineThrough : null,
                color: item.isPacked ? Colors.grey : Colors.black,
              ),
            ),
            subtitle: item.brand != null
                ? Text(item.brand!, style: TextStyle(color: Colors.grey[600], fontSize: 12))
                : null,
            trailing: item.quantity > 1
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('x${item.quantity}', style: const TextStyle(fontSize: 12)),
                  )
                : null,
          ),
        );
      }),
    );
  }

  void _showAddDialog(BuildContext context, ProductKitController controller) {
    final nameController = TextEditingController();
    final brandController = TextEditingController();
    final quantityController = TextEditingController(text: '1');
    final selectedCategory = ProductCategory.foundation.obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Add Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Product Name *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: brandController,
                decoration: const InputDecoration(labelText: 'Brand (optional)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Obx(() => DropdownButtonFormField<ProductCategory>(
                value: selectedCategory.value,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ProductCategory.values.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat.display));
                }).toList(),
                onChanged: (val) => selectedCategory.value = val!,
              )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              
              final item = ProductKitItem(
                id: 0,
                shopId: 0,
                name: nameController.text.trim(),
                brand: brandController.text.trim().isNotEmpty ? brandController.text.trim() : null,
                category: selectedCategory.value.value,
                quantity: int.tryParse(quantityController.text) ?? 1,
                createdAt: DateTime.now(),
              );
              
              final success = await controller.createItem(item);
              if (success) Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB8192E)),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
