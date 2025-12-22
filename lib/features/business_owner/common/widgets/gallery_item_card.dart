import 'package:flutter/material.dart';
import 'package:fidden/features/business_owner/portfolio/data/gallery_item_model.dart';

/// Reusable gallery item card widget
/// Can be used in grids, lists, or as a standalone card
class GalleryItemCard extends StatelessWidget {
  final GalleryItemModel item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCaption;
  final bool showLookType;
  final bool showClientName;
  final double? width;
  final double? height;
  final double borderRadius;

  const GalleryItemCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.showCaption = false,
    this.showLookType = true,
    this.showClientName = false,
    this.width,
    this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                item.thumbnailUrl ?? item.imageUrl ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 48, color: Colors.grey),
                ),
              ),
              
              // Gradient overlay for text
              if (showCaption || showLookType || showClientName)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (showCaption && item.caption != null && item.caption!.isNotEmpty)
                          Text(
                            item.caption!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        if (showClientName && item.clientName != null)
                          Text(
                            item.clientName!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 11,
                            ),
                          ),
                        if (showLookType && item.lookType != null) ...[
                          const SizedBox(height: 4),
                          _buildLookTypeChip(),
                        ],
                      ],
                    ),
                  ),
                ),
              
              // Private indicator
              if (!item.isPublic)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLookTypeChip() {
    Color chipColor;
    switch (item.lookType) {
      case 'bridal':
        chipColor = const Color(0xFFE91E63);
        break;
      case 'glam':
        chipColor = const Color(0xFFFFD700);
        break;
      case 'natural':
        chipColor = const Color(0xFF8BC34A);
        break;
      case 'editorial':
        chipColor = const Color(0xFF9C27B0);
        break;
      case 'sfx':
        chipColor = const Color(0xFFFF5722);
        break;
      default:
        chipColor = const Color(0xFF607D8B);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        item.lookTypeDisplay ?? item.lookType!,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
