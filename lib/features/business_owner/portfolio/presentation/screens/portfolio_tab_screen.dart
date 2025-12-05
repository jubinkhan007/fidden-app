import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/features/business_owner/portfolio/controller/portfolio_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';

/// Portfolio Tab Screen for Tattoo Artists
/// Displays grid of portfolio items with image, tags, and description
class PortfolioTabScreen extends StatelessWidget {
  const PortfolioTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PortfolioController());

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.portfolioItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.portfolioItems.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPortfolio,
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate columns: ~180px per card, min 2, max 4
              final crossAxisCount = (constraints.maxWidth / 180).clamp(2, 4).toInt();
              return GridView.builder(
                padding: EdgeInsets.all(getWidth(16)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: getWidth(12),
                  mainAxisSpacing: getHeight(12),
                  childAspectRatio: 0.85,
                ),
                itemCount: controller.portfolioItems.length,
                itemBuilder: (context, index) {
                  final item = controller.portfolioItems[index];
                  return _PortfolioCard(item: item);
                },
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add portfolio item screen
          Get.snackbar('Coming Soon', 'Add portfolio item feature');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library, size: getWidth(64), color: Colors.grey),
          SizedBox(height: getHeight(16)),
          CustomText(
            text: 'No portfolio items yet',
            fontSize: getWidth(18),
            fontWeight: FontWeight.w600,
            color: Colors.grey[700]!,
          ),
          SizedBox(height: getHeight(8)),
          CustomText(
            text: 'Tap + to add your first work',
            fontSize: getWidth(14),
            color: Colors.grey,
          ),
        ],
      ),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final dynamic item; // PortfolioItem

  const _PortfolioCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: item.imageUrl != null
                  ? Image.network(
                      item.imageUrl!,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 48),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.photo, size: 48),
                    ),
            ),
          ),
          // Tags & Description
          Padding(
            padding: EdgeInsets.all(getWidth(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.tags.isNotEmpty)
                  Wrap(
                    spacing: 4,
                    children: item.tags.take(2).map<Widget>((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: TextStyle(fontSize: getWidth(10)),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.all(2),
                      );
                    }).toList(),
                  ),
                if (item.description.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: getHeight(4)),
                    child: Text(
                      item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: getWidth(12)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
