import 'package:fidden/features/business_owner/portfolio/data/gallery_item_model.dart';
import 'package:fidden/features/user/shops/presentation/widgets/gallery_preview_section.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Full gallery screen for customers to view all public gallery items
/// Receives gallery items from shop details (gallery_preview)
class FullGalleryScreen extends StatelessWidget {
  final List<GalleryPreviewItem> items;
  final String? shopName;

  const FullGalleryScreen({
    super.key,
    required this.items,
    this.shopName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(shopName != null 
            ? '$shopName\'s Gallery' 
            : 'Gallery'),
        centerTitle: true,
        elevation: 0,
      ),
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, 
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No photos yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(2),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _GalleryGridTile(
                  item: item,
                  onTap: () => _openLightbox(context, index),
                );
              },
            ),
    );
  }

  void _openLightbox(BuildContext context, int initialIndex) {
    final lightboxItems = items
        .map((e) => LightboxItem(
              imageUrl: e.imageUrl ?? '',
              caption: e.caption,
            ))
        .toList();

    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        pageBuilder: (context, animation, secondaryAnimation) {
          return GalleryLightbox(
            items: lightboxItems,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }
}

class _GalleryGridTile extends StatelessWidget {
  final GalleryPreviewItem item;
  final VoidCallback onTap;

  const _GalleryGridTile({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.thumbnailUrl ?? item.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: imageUrl != null
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.photo, size: 32),
              ),
            )
          : Container(
              color: Colors.grey[300],
              child: const Icon(Icons.photo, size: 32),
            ),
    );
  }
}
