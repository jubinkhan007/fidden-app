import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/portfolio_controller.dart';
import 'portfolio_upload_screen.dart';
import 'portfolio_detail_screen.dart';

class PortfolioGridScreen extends StatelessWidget {
  const PortfolioGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PortfolioController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate),
            onPressed: () => Get.to(() => const PortfolioUploadScreen()),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.portfolioItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.portfolioItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(controller.errorMessage.value),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.fetchPortfolioItems,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (controller.portfolioItems.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library_outlined, size: 80, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No portfolio items yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => const PortfolioUploadScreen()),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Your First Work'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPortfolioItems,
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: controller.portfolioItems.length,
            itemBuilder: (context, index) {
              final item = controller.portfolioItems[index];
              return _PortfolioCard(
                imageUrl: item.imageUrl,
                title: item.description,
                tags: item.tags,
                onTap: () => Get.to(() => PortfolioDetailScreen(item: item)),
              );
            },
          ),
        );
      }),
    );
  }
}

class _PortfolioCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final List<String> tags;
  final VoidCallback onTap;

  const _PortfolioCard({
    required this.imageUrl,
    required this.title,
    required this.tags,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48, color: Colors.grey),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isEmpty ? 'Untitled' : title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: tags.take(2).map((tag) {
                        return Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 10)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
