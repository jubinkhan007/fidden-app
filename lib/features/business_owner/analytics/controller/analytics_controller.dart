import 'dart:convert';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/analytics/data/analytics_model.dart';
import 'package:get/get.dart';

class AnalyticsController extends GetxController {
  final _networkCaller = NetworkCaller();
  var analyticsData = AnalyticsModel().obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAnalytics();
  }

  Future<void> fetchAnalytics() async {
    try {
      isLoading(true);
      final response = await _networkCaller.getRequest(AppUrls.analytics);

      dynamic data = response.responseData;
      // Some backends send raw JSON string for 403 responses
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          data = {'detail': data};
        }
      }

      if (response.isSuccess) {
        if (data['detail'] != null) {
          // foundation plan or restricted
          analyticsData(AnalyticsModel(detail: data['detail']));
        } else {
          analyticsData(AnalyticsModel.fromJson(data));
        }
      } else {
        // Handle 403 or other error
        analyticsData(AnalyticsModel(
          detail: data['detail'] ?? 'No analytics available for your current plan.',
        ));
      }
    } catch (e) {
      // fallback for unexpected errors
      analyticsData(AnalyticsModel(detail: 'Failed to load analytics data.'));
    } finally {
      isLoading(false);
    }
  }
}
