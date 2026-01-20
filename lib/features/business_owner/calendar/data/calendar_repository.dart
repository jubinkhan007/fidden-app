import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/calendar/data/calendar_event_model.dart';
import 'package:flutter/cupertino.dart';

class CalendarRepository {
  final NetworkCaller _networkCaller;

  CalendarRepository({NetworkCaller? networkCaller})
    : _networkCaller = networkCaller ?? NetworkCaller();

  /// Fetch calendar events for the given date range and optional provider properties.
  Future<List<CalendarEventModel>> fetchCalendarEvents({
    required int shopId,
    required String startDate, // YYYY-MM-DD
    required String endDate, // YYYY-MM-DD
    int? providerId,
  }) async {
    try {
      final url = AppUrls.calendar(
        shopId: shopId,
        startDate: startDate,
        endDate: endDate,
        providerId: providerId,
      );

      final response = await _networkCaller.getRequest(
        url,
        token: AuthService.accessToken,
        treat404AsEmpty: true,
        emptyPayload: [],
      );

      if (!response.isSuccess || response.responseData == null) {
        return [];
      }

      final dynamic data = response.responseData;
      if (data is! List) return [];

      // Parse list
      return data
          .map((e) => CalendarEventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("Error fetching calendar events: $e");
      // Re-throw to let controller handle UI feedback
      rethrow;
    }
  }
}
