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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Portfolio Manager'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
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
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8, // Slightly taller than wide
            ),
            itemCount: controller.portfolioItems.length,
            itemBuilder: (context, index) {
              final item = controller.portfolioItems[index];
              return _PortfolioImageCard(
                imageUrl: item.imageUrl,
                onTap: () => Get.to(() => PortfolioDetailScreen(item: item)),
              );
            },
          ),
        );
      }),
    );
  }
}

class _PortfolioImageCard extends StatelessWidget {
  final String? imageUrl;
  final VoidCallback onTap;

  const _PortfolioImageCard({
    required this.imageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(16),
          ),
          child: imageUrl != null
              ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 48, color: Colors.grey),
                    ),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                )
              : Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image, size: 48, color: Colors.grey),
                  ),
                ),
        ),
      ),
    );
  }
}
