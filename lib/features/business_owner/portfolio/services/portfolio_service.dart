import 'dart:io';
import 'package:dio/dio.dart';
import '../data/portfolio_item_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

class PortfolioService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get all portfolio items for the current shop
  Future<List<PortfolioItem>> getPortfolioItems() async {
    final response = await _networkCaller.getRequest(
      AppUrls.portfolio,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is List) {
      return (response.responseData as List)
          .map((item) => PortfolioItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Failed to fetch portfolio items');
  }

  /// Create a new portfolio item
  Future<PortfolioItem> createPortfolioItem({
    required File image,
    required List<String> tags,
    required String description,
  }) async {
    try {
      final dio = Dio();
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
        'tags': tags,
        'description': description,
      });

      final response = await dio.post(
        AppUrls.portfolio,
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AuthService.accessToken}',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return PortfolioItem.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to create portfolio item');
    } catch (e) {
      throw Exception('Failed to create portfolio item: $e');
    }
  }

  /// Update a portfolio item
  Future<PortfolioItem> updatePortfolioItem({
    required int id,
    List<String>? tags,
    String? description,
  }) async {
    final body = <String, dynamic>{};
    if (tags != null) body['tags'] = tags;
    if (description != null) body['description'] = description;

    final response = await _networkCaller.patchRequest(
      '${AppUrls.portfolio}$id/',
      body: body,
      token: AuthService.accessToken,
    );

    if (response.isSuccess && response.responseData is Map<String, dynamic>) {
      return PortfolioItem.fromJson(response.responseData);
    }

    throw Exception('Failed to update portfolio item');
  }

  /// Delete a portfolio item
  Future<void> deletePortfolioItem(int id) async {
    final response = await _networkCaller.deleteRequest(
      '${AppUrls.portfolio}$id/',
      token: AuthService.accessToken,
    );

    if (!response.isSuccess) {
      throw Exception('Failed to delete portfolio item');
    }
  }
}
