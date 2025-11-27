import 'dart:io';

import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/portfolio/data/portfolio_model.dart';
import 'package:get/get.dart';
import 'package:fidden/core/commom/widgets/app_snackbar.dart';

/// Portfolio Controller for Tattoo Artists
/// Manages portfolio items with optimized loading and error handling
class PortfolioController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList<PortfolioItem> portfolioItems = <PortfolioItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPortfolio();
  }

  /// Fetch portfolio items from backend
  Future<void> fetchPortfolio() async {
    try {
      isLoading(true);
      final response = await NetworkCaller().getRequest(AppUrls.portfolioList);

      if (response.isSuccess) {
        final List<dynamic> data = response.responseData as List<dynamic>;
        portfolioItems.value = data
            .map((json) => PortfolioItem.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        if (response.statusCode != 401) {
          AppSnackBar.showError('Failed to load portfolio');
        }
      }
    } catch (e) {
      AppSnackBar.showError('Error loading portfolio: \$e');
    } finally {
      isLoading(false);
    }
  }

  /// Create a new portfolio item
  /// [shopId] - The shop ID
  /// [imagePath] - The image file path to upload
  /// [tags] - List of tags
  /// [description] - Item description
  Future<void> createPortfolioItem({
    required int shopId,
    required String imagePath,
    required List<String> tags,
    required String description,
  }) async {
    try {
      isLoading(true);

      // Convert tags list to comma-separated string for multipart form
      final tagsString = tags.join(',');

      final response = await NetworkCaller().multipartRequest(
        AppUrls.portfolioList,
        method: 'POST',
        body: {
          'shop': shopId.toString(),
          'tags': tagsString,
          'description': description,
        },
        photo: File(imagePath),
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess('Portfolio item added successfully');
        await fetchPortfolio(); // Refresh list
      } else {
        AppSnackBar.showError(
          response.errorMessage ?? 'Failed to create portfolio item',
        );
      }
    } catch (e) {
      AppSnackBar.showError('Error creating portfolio item: $e');
    } finally {
      isLoading(false);
    }
  }

  /// Delete a portfolio item
  Future<void> deletePortfolioItem(int id) async {
    try {
      final response = await NetworkCaller().deleteRequest(
        AppUrls.portfolioItem(id),
      );

      if (response.isSuccess) {
        portfolioItems.removeWhere((item) => item.id == id);
        AppSnackBar.showSuccess('Portfolio item deleted');
      } else {
        AppSnackBar.showError('Failed to delete item');
      }
    } catch (e) {
      AppSnackBar.showError('Error deleting item: \$e');
    }
  }

  /// Update portfolio item description/tags
  Future<void> updatePortfolioItem({
    required int id,
    String? description,
    List<String>? tags,
  }) async {
    try {
      isLoading(true);

      final body = <String, dynamic>{};
      if (description != null) body['description'] = description;
      if (tags != null) body['tags'] = tags;

      final response = await NetworkCaller().patchRequest(
        AppUrls.portfolioItem(id),
        body: body,
      );

      if (response.isSuccess) {
        AppSnackBar.showSuccess('Portfolio item updated');
        await fetchPortfolio(); // Refresh list
      } else {
        AppSnackBar.showError('Failed to update item');
      }
    } catch (e) {
      AppSnackBar.showError('Error updating item: \$e');
    } finally {
      isLoading(false);
    }
  }
}
