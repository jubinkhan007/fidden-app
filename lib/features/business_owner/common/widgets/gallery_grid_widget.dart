import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/features/business_owner/portfolio/data/gallery_item_model.dart';
import 'package:fidden/features/business_owner/portfolio/controller/gallery_controller.dart';

/// Reusable gallery grid widget for all niches
/// Displays a grid of gallery items with optional filtering by niche
class GalleryGridWidget extends StatelessWidget {
  final String? niche;
  final List<String>? tags;
  final String? category;
  final Function(GalleryItemModel)? onItemTap;
  final int crossAxisCount;
  final double spacing;
  final Widget Function(GalleryItemModel)? itemBuilder;
  final Widget? emptyWidget;

  const GalleryGridWidget({
    super.key,
    this.niche,
    this.tags,
    this.category,
    this.onItemTap,
    this.crossAxisCount = 3,
    this.spacing = 4,
    this.itemBuilder,
    this.emptyWidget,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GalleryController());
    
    // Fetch based on niche if provided
    if (niche != null) {
      controller.fetchGalleryByNiche(
        niche: niche!,
        tags: tags,
        category: category,
      );
    } else {
      controller.fetchGallery();
    }

    return Obx(() {
      if (controller.isLoading.value && controller.galleryItems.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.galleryItems.isEmpty) {
        return emptyWidget ?? _buildDefaultEmptyState();
      }

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
        ),
        itemCount: controller.galleryItems.length,
        itemBuilder: (context, index) {
          final item = controller.galleryItems[index];
          
          if (itemBuilder != null) {
            return GestureDetector(
              onTap: () => onItemTap?.call(item),
              child: itemBuilder!(item),
            );
          }
          
          return GestureDetector(
            onTap: () => onItemTap?.call(item),
            child: _buildDefaultItem(item),
          );
        },
      );
    });
  }

  Widget _buildDefaultItem(GalleryItemModel item) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            item.thumbnailUrl ?? item.imageUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image, color: Colors.grey),
            ),
          ),
          if (item.lookType != null)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.lookTypeDisplay ?? item.lookType!,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No items yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
