import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/hairstylist/controller/product_recommendation_controller.dart';
import 'package:fidden/features/business_owner/hairstylist/data/hairstylist_models.dart';
import 'package:fidden/features/business_owner/hairstylist/presentation/screens/product_recommendation_form_screen.dart';

/// Screen displaying product recommendations
class ProductRecommendationsScreen extends StatelessWidget {
  const ProductRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductRecommendationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Product Recommendations'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Obx(
            () => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${controller.recommendations.length} items',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category filter chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Obx(
                () => Row(
                  children: [
                    _FilterChip(
                      label: 'All',
                      isSelected: controller.filterCategory.value.isEmpty,
                      onTap: () => controller.filterCategory.value = '',
                    ),
                    ...HairProductCategory.values.map(
                      (cat) => _FilterChip(
                        label: cat.display,
                        isSelected:
                            controller.filterCategory.value == cat.value,
                        onTap: () =>
                            controller.filterCategory.value = cat.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.recommendations.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = controller.filteredRecommendations;

              if (items.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.recommend_outlined,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No recommendations yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Product recommendations will appear here',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchRecommendations(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final rec = items[index];
                    return _RecommendationCard(recommendation: rec);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Get.to(() => const ProductRecommendationFormScreen());
          controller.fetchRecommendations(); // Refresh after returning
        },
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE63946) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final ProductRecommendation recommendation;

  const _RecommendationCard({required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    recommendation.category,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getCategoryIcon(recommendation.category),
                  color: _getCategoryColor(recommendation.category),
                ),
              ),
              const SizedBox(width: 12),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.productName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (recommendation.brand != null)
                      Text(
                        recommendation.brand!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),

              // Category chip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getCategoryColor(
                    recommendation.category,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recommendation.categoryDisplay ?? recommendation.category,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getCategoryColor(recommendation.category),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Client name
          if (recommendation.clientName != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'For: ${recommendation.clientName}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

          // Notes
          if (recommendation.notes != null && recommendation.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  recommendation.notes!,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ),
            ),

          // Purchase link
          if (recommendation.purchaseLink != null &&
              recommendation.purchaseLink!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: GestureDetector(
                onTap: () {
                  // TODO: Launch URL
                },
                child: Row(
                  children: [
                    Icon(Icons.link, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 4),
                    Text(
                      'View Product',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'shampoo':
        return Icons.water_drop_outlined;
      case 'conditioner':
        return Icons.water_drop;
      case 'treatment':
        return Icons.science_outlined;
      case 'oil':
        return Icons.opacity;
      case 'styling':
        return Icons.style_outlined;
      case 'protectant':
        return Icons.shield_outlined;
      case 'leave_in':
        return Icons.shower_outlined;
      case 'mask':
        return Icons.face_outlined;
      case 'color':
        return Icons.palette_outlined;
      case 'tool':
        return Icons.handyman_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'shampoo':
        return Colors.blue;
      case 'conditioner':
        return Colors.teal;
      case 'treatment':
        return Colors.purple;
      case 'oil':
        return Colors.amber;
      case 'styling':
        return Colors.pink;
      case 'protectant':
        return Colors.orange;
      case 'leave_in':
        return Colors.cyan;
      case 'mask':
        return Colors.green;
      case 'color':
        return Colors.red;
      case 'tool':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }
}
