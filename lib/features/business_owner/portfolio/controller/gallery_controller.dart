import 'dart:io';

import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/portfolio/data/gallery_item_model.dart';
import 'package:get/get.dart';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';

/// Gallery Controller for all service providers
/// Manages gallery items with CRUD operations and public gallery access
class GalleryController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxList<GalleryItemModel> galleryItems = <GalleryItemModel>[].obs;
  
  // For public gallery pagination
  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchGallery();
  }

  /// Fetch owner's gallery items
  Future<void> fetchGallery() async {
    try {
      isLoading(true);
      final response = await NetworkCaller().getRequest(AppUrls.galleryList);

      if (response.isSuccess) {
        final List<dynamic> data = response.responseData as List<dynamic>;
        galleryItems.value = data
            .map((json) => GalleryItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (response.statusCode != 401) {
          AppSnackBar.showError('Failed to load gallery');
        }
      }
    } catch (e) {
      AppSnackBar.showError('Error loading gallery: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Upload a new gallery item
  /// [imagePath] - The image file path to upload
  /// [caption] - Optional caption for the image
  /// [serviceId] - Optional link to a specific service
  /// [categoryTag] - Optional category tag (e.g., "Fade", "Balayage")
  /// [isPublic] - Whether to show in public client gallery
  Future<bool> uploadGalleryItem({
    required String imagePath,
    String? caption,
    int? serviceId,
    String? categoryTag,
    bool isPublic = true,
  }) async {
    try {
      isLoading(true);

      final body = <String, String>{
        'is_public': isPublic.toString(),
      };
      if (caption != null && caption.isNotEmpty) {
        body['caption'] = caption;
      }
      if (serviceId != null) {
        body['service'] = serviceId.toString();
      }
      if (categoryTag != null && categoryTag.isNotEmpty) {
        body['category_tag'] = categoryTag;
      }

      final response = await NetworkCaller().multipartRequest(
        AppUrls.galleryList,
        method: 'POST',
        body: body,
        photo: File(imagePath),
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess('Photo added to gallery');
        await fetchGallery(); // Refresh list
        return true;
      } else {
        AppSnackBar.showError(
          response.errorMessage ?? 'Failed to upload image',
        );
        return false;
      }
    } catch (e) {
      AppSnackBar.showError('Error uploading image: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Update a gallery item
  Future<bool> updateGalleryItem({
    required int id,
    String? caption,
    int? serviceId,
    String? categoryTag,
    bool? isPublic,
  }) async {
    try {
      isLoading(true);

      final body = <String, dynamic>{};
      if (caption != null) body['caption'] = caption;
      if (serviceId != null) body['service'] = serviceId;
      if (categoryTag != null) body['category_tag'] = categoryTag;
      if (isPublic != null) body['is_public'] = isPublic;

      final response = await NetworkCaller().patchRequest(
        AppUrls.galleryItem(id),
        body: body,
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess('Gallery item updated');
        await fetchGallery(); // Refresh list
        return true;
      } else {
        AppSnackBar.showError('Failed to update item');
        return false;
      }
    } catch (e) {
      AppSnackBar.showError('Error updating item: $e');
      return false;
    } finally {
      isLoading(false);
    }
  }

  /// Delete a gallery item
  Future<bool> deleteGalleryItem(int id) async {
    try {
      final response = await NetworkCaller().deleteRequest(
        AppUrls.galleryItem(id),
      );

      if (response.isSuccess) {
        galleryItems.removeWhere((item) => item.id == id);
        AppSnackBar.showSuccess('Photo removed from gallery');
        return true;
      } else {
        AppSnackBar.showError('Failed to delete item');
        return false;
      }
    } catch (e) {
      AppSnackBar.showError('Error deleting item: $e');
      return false;
    }
  }

  /// Toggle public visibility of a gallery item
  Future<bool> togglePublicVisibility(int id, bool currentState) async {
    return await updateGalleryItem(id: id, isPublic: !currentState);
  }

  /// Fetch public gallery for a shop (client-facing, paginated)
  Future<PaginatedGallery?> fetchPublicGallery(int shopId, {int page = 1}) async {
    try {
      if (page == 1) {
        isLoading(true);
      } else {
        isLoadingMore(true);
      }

      final response = await NetworkCaller().getRequest(
        AppUrls.shopGallery(shopId, page: page),
      );

      if (response.isSuccess) {
        final data = response.responseData as Map<String, dynamic>;
        final paginated = PaginatedGallery.fromJson(data);
        
        currentPage.value = paginated.currentPage;
        totalPages.value = paginated.numPages;
        totalCount.value = paginated.count;
        
        if (page == 1) {
          galleryItems.value = paginated.results;
        } else {
          galleryItems.addAll(paginated.results);
        }
        
        return paginated;
      } else {
        if (response.statusCode != 401) {
          AppSnackBar.showError('Failed to load gallery');
        }
        return null;
      }
    } catch (e) {
      AppSnackBar.showError('Error loading gallery: $e');
      return null;
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  /// Load next page of public gallery
  Future<void> loadMorePublicGallery(int shopId) async {
    if (currentPage.value < totalPages.value && !isLoadingMore.value) {
      await fetchPublicGallery(shopId, page: currentPage.value + 1);
    }
  }

  /// Check if there are more pages to load
  bool get hasMore => currentPage.value < totalPages.value;
}
