import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/portfolio_item_model.dart';
import '../../../../core/utils/constants/api_constants.dart';
import '../../../../core/services/network_caller.dart';
import '../../../../core/services/Auth_service.dart';

class PortfolioService {
  final NetworkCaller _networkCaller = NetworkCaller();

  /// Get all portfolio items for the current shop
  /// [niche] - optional filter: 'tattoo', 'nail', 'makeup', 'barber', 'hair'
  Future<List<PortfolioItem>> getPortfolioItems({String? niche}) async {
    String url = AppUrls.portfolio;
    if (niche != null && niche.isNotEmpty) {
      url = '${AppUrls.portfolio}?niche=$niche';
    }

    final response = await _networkCaller.getRequest(
      url,
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
  /// [categoryTag] - niche identifier: 'tattoo', 'nail', 'makeup', 'barber', 'hair'
  Future<PortfolioItem> createPortfolioItem({
    required File image,
    required List<String> tags,
    required String description,
    String? categoryTag,
  }) async {
    try {
      final dio = Dio();

      // Prepare form data map
      final formMap = <String, dynamic>{
        'image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
        'description': description,
      };

      // Add tags as JSON string (API expects JSON array)
      if (tags.isNotEmpty) {
        formMap['tags'] = jsonEncode(tags);
      }

      // Add category_tag if provided
      if (categoryTag != null && categoryTag.isNotEmpty) {
        formMap['category_tag'] = categoryTag;
      }

      debugPrint(
        '[Portfolio] Creating item with tags: ${formMap['tags']}, category: $categoryTag',
      );

      final formData = FormData.fromMap(formMap);

      final response = await dio.post(
        AppUrls.portfolio,
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer ${AuthService.accessToken}'},
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return PortfolioItem.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception(
        'Failed to create portfolio item: ${response.statusCode}',
      );
    } on DioException catch (e) {
      final message = e.response?.data?.toString() ?? e.message;
      throw Exception('Failed to add portfolio item: $message');
    } catch (e) {
      throw Exception('Failed to add portfolio item: $e');
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
