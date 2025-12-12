import 'dart:io';

import 'package:fidden/core/commom/widgets/custom_text.dart';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';
import 'package:fidden/features/business_owner/portfolio/controller/gallery_controller.dart';
import 'package:fidden/features/business_owner/portfolio/data/gallery_item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fidden/core/utils/constants/app_sizes.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Gallery Tab Screen for all Service Providers
/// Displays grid of gallery items with upload, edit, and delete functionality
class GalleryTabScreen extends StatelessWidget {
  const GalleryTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GalleryController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Gallery'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.galleryItems.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.galleryItems.isEmpty) {
            return _buildEmptyState(context, controller);
          }

          return RefreshIndicator(
            onRefresh: controller.fetchGallery,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 3 columns for grid
                return GridView.builder(
                  padding: EdgeInsets.only(
                    left: getWidth(4),
                    right: getWidth(4),
                    top: getWidth(4),
                    bottom: 80, // Extra padding for FAB
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: controller.galleryItems.length,
                  itemBuilder: (context, index) {
                    final item = controller.galleryItems[index];
                    return _GalleryGridItem(
                      item: item,
                      onTap: () => _showItemDetails(context, item, controller),
                    );
                  },
                );
              },
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUploadDialog(context, controller),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add_photo_alternate, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, GalleryController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: getWidth(80), color: Colors.grey[400]),
          SizedBox(height: getHeight(16)),
          CustomText(
            text: 'No photos yet',
            fontSize: getWidth(20),
            fontWeight: FontWeight.w600,
            color: Colors.grey[700]!,
          ),
          SizedBox(height: getHeight(8)),
          CustomText(
            text: 'Add photos to showcase your work to clients',
            fontSize: getWidth(14),
            color: Colors.grey[500]!,
          ),
          SizedBox(height: getHeight(24)),
          ElevatedButton.icon(
            onPressed: () => _showUploadDialog(context, controller),
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Your First Photo'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: getWidth(24),
                vertical: getHeight(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

void _showUploadDialog(BuildContext context, GalleryController controller) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,        // ✅ keep this
    backgroundColor: Colors.transparent,
    builder: (context) => _UploadGallerySheet(controller: controller),
  );
}


  void _showItemDetails(BuildContext context, GalleryItemModel item, GalleryController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _GalleryItemDetailSheet(
        item: item,
        controller: controller,
      ),
    );
  }
}

/// Grid item widget for gallery
class _GalleryGridItem extends StatelessWidget {
  final GalleryItemModel item;
  final VoidCallback onTap;

  const _GalleryGridItem({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.thumbnailUrl ?? item.imageUrl;
    
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null)
            CachedNetworkImage(
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
                child: const Icon(Icons.broken_image, size: 32),
              ),
            )
          else
            Container(
              color: Colors.grey[300],
              child: const Icon(Icons.photo, size: 32),
            ),
          // Private indicator
          if (!item.isPublic)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(
                  Icons.visibility_off,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Upload dialog sheet
class _UploadGallerySheet extends StatefulWidget {
  final GalleryController controller;

  const _UploadGallerySheet({required this.controller});

  @override
  State<_UploadGallerySheet> createState() => _UploadGallerySheetState();
}

class _UploadGallerySheetState extends State<_UploadGallerySheet> {
  File? _selectedImage;
  final _captionController = TextEditingController();
  final _categoryTagController = TextEditingController();
  bool _isPublic = true;
  bool _isUploading = false;

  @override
  void dispose() {
    _captionController.dispose();
    _categoryTagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  Future<void> _upload() async {
    if (_selectedImage == null) {
      AppSnackBar.showError('Please select an image');
      return;
    }

    setState(() => _isUploading = true);

    final success = await widget.controller.uploadGalleryItem(
      imagePath: _selectedImage!.path,
      caption: _captionController.text.trim().isEmpty 
          ? null 
          : _captionController.text.trim(),
      categoryTag: _categoryTagController.text.trim().isEmpty 
          ? null 
          : _categoryTagController.text.trim(),
      isPublic: _isPublic,
    );

    setState(() => _isUploading = false);

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

@override
Widget build(BuildContext context) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    padding: EdgeInsets.only(
      left: 20,
      right: 20,
      top: 20,
      // keyboard inset only; SafeArea already handled system bottom
      bottom: MediaQuery.of(context).viewInsets.bottom + 20,
    ),
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            const Text(
              'Add to Gallery',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Image picker
            if (_selectedImage == null)
              Row(
                children: [
                  Expanded(
                    child: _ImagePickerButton(
                      icon: Icons.photo_library,
                      label: 'Choose from Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ImagePickerButton(
                      icon: Icons.camera_alt,
                      label: 'Take a Photo',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                ],
              )
            else
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _selectedImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Caption field
            TextField(
              controller: _captionController,
              decoration: InputDecoration(
                labelText: 'Caption (optional)',
                hintText: 'Describe this work...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // Category tag field
            TextField(
              controller: _categoryTagController,
              decoration: InputDecoration(
                labelText: 'Category Tag (optional)',
                hintText: 'e.g., Fade, Balayage, Gel Nails',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),

            // Public toggle
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    _isPublic ? Icons.visibility : Icons.visibility_off,
                    color: _isPublic ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Show in Client Gallery',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          _isPublic 
                              ? 'Clients can see this photo'
                              : 'Only visible to you',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isPublic,
                    onChanged: (value) => setState(() => _isPublic = value),
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Upload button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _upload,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Add to Gallery', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class _ImagePickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImagePickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.grey[600]),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Gallery item detail sheet with edit/delete options
class _GalleryItemDetailSheet extends StatefulWidget {
  final GalleryItemModel item;
  final GalleryController controller;

  const _GalleryItemDetailSheet({
    required this.item,
    required this.controller,
  });

  @override
  State<_GalleryItemDetailSheet> createState() => _GalleryItemDetailSheetState();
}

class _GalleryItemDetailSheetState extends State<_GalleryItemDetailSheet> {
  late bool _isPublic;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _isPublic = widget.item.isPublic;
  }

  Future<void> _toggleVisibility() async {
    setState(() => _isUpdating = true);
    
    final success = await widget.controller.togglePublicVisibility(
      widget.item.id,
      _isPublic,
    );
    
    if (success) {
      setState(() {
        _isPublic = !_isPublic;
        _isUpdating = false;
      });
    } else {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _deleteItem() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await widget.controller.deleteGalleryItem(widget.item.id);
      if (success && mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.item.imageUrl ?? widget.item.thumbnailUrl;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Image
          if (imageUrl != null)
            Flexible(
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48),
                ),
              ),
            ),

          // Details
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.item.caption != null && widget.item.caption!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      widget.item.caption!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                if (widget.item.categoryTag != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Chip(
                      label: Text(widget.item.categoryTag!),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),

                if (widget.item.serviceName != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(Icons.spa, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          widget.item.serviceName!,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                const Divider(),

                // Visibility toggle
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _isPublic ? Icons.visibility : Icons.visibility_off,
                    color: _isPublic ? Colors.green : Colors.grey,
                  ),
                  title: const Text('Show in Client Gallery'),
                  subtitle: Text(
                    _isPublic ? 'Visible to clients' : 'Hidden from clients',
                  ),
                  trailing: _isUpdating
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Switch(
                          value: _isPublic,
                          onChanged: (_) => _toggleVisibility(),
                          activeColor: Colors.green,
                        ),
                ),

                // Delete button
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text(
                    'Delete Photo',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: _deleteItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
