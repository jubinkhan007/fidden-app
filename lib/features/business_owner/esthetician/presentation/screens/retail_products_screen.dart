import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/retail_products_controller.dart';
import '../../data/esthetician_models.dart';
import 'retail_product_form_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen displaying retail products
class RetailProductsScreen extends StatelessWidget {
  const RetailProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RetailProductsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Retail Products'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Category filter chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 36,
              child: Obx(
                () => ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip(
                      'All',
                      controller.filterCategory.value.isEmpty,
                      () => controller.fetchProducts(category: ''),
                    ),
                    ...RetailCategory.values.map(
                      (cat) => _buildFilterChip(
                        cat.display,
                        controller.filterCategory.value == cat.value,
                        () => controller.fetchProducts(category: cat.value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Products grid
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return Center(child: Text(controller.errorMessage.value));
              }

              final products = controller.products;
              if (products.isEmpty) {
                return const Center(child: Text('No products found'));
              }

              return GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return _ProductCard(product: product);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const RetailProductFormScreen());
          controller.fetchProducts();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: Colors.purple[100],
        checkmarkColor: Colors.purple,
        labelStyle: TextStyle(
          color: selected ? Colors.purple : Colors.grey[700],
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final RetailProduct product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showDetailSheet(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.grey[100],
                child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                    ? Image.network(
                        product.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.shopping_bag,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.shopping_bag,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                      ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.brand != null && product.brand!.isNotEmpty)
                    Text(
                      product.brand!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (product.price != null)
                        Text(
                          '\$${product.price!.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.purple[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const Spacer(),
                      if (!product.inStock)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.red[700],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Image
              if (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 16),

              // Brand
              if (product.brand != null && product.brand!.isNotEmpty)
                Text(
                  product.brand!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    letterSpacing: 1,
                  ),
                ),

              // Name
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Price & Category
              const SizedBox(height: 8),
              Row(
                children: [
                  if (product.price != null)
                    Text(
                      '\$${product.price!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.purple[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple[50],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      product.categoryDisplay ?? product.category,
                      style: TextStyle(fontSize: 12, color: Colors.purple[700]),
                    ),
                  ),
                ],
              ),

              // Description
              if (product.description != null &&
                  product.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  product.description!,
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],

              // Stock & Active status
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    product.inStock ? Icons.check_circle : Icons.cancel,
                    color: product.inStock ? Colors.green : Colors.red,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(product.inStock ? 'In Stock' : 'Out of Stock'),
                  const SizedBox(width: 16),
                  Icon(
                    product.isActive ? Icons.visibility : Icons.visibility_off,
                    color: product.isActive ? Colors.green : Colors.grey,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(product.isActive ? 'Active' : 'Inactive'),
                ],
              ),

              // Purchase link
              if (product.purchaseLink != null &&
                  product.purchaseLink!.isNotEmpty) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(product.purchaseLink!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      }
                    },
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Purchase'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],

              // Edit button
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await Get.to(
                      () => RetailProductFormScreen(existingProduct: product),
                    );
                    if (Get.isRegistered<RetailProductsController>()) {
                      Get.find<RetailProductsController>().fetchProducts();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Product'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
