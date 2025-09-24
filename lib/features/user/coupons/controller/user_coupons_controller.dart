import 'package:get/get.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/core/services/Auth_service.dart';
import '../data/user_coupon_model.dart';

class UserCouponsController extends GetxController {
  final isLoading = false.obs;
  final coupons = <UserCoupon>[].obs;

  Future<void> fetch({required int shopId, required int serviceId}) async {
    isLoading.value = true;
    try {
      
      final res = await NetworkCaller().getRequest(AppUrls.UserCoupon(shopId,serviceId), token: AuthService.accessToken);
      if (!res.isSuccess) {
        coupons.clear();
        return;
      }
      final data = res.responseData;
      if (data is List) {
        coupons.assignAll(
          data.whereType<Map<String, dynamic>>().map(UserCoupon.fromJson),
        );
      } else {
        coupons.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }
}
