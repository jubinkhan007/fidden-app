// lib/features/business_owner/coupons/controller/coupon_controller.dart
import 'dart:developer';
import 'package:get/get.dart';
import 'package:fidden/core/services/Auth_service.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/coupons/data/coupon_model.dart';

class CouponController extends GetxController {
  final coupons = <Coupon>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  Future<void> fetchCoupons() async {
    isLoading(true);
    try {
      final res = await NetworkCaller()
          .getRequest(AppUrls.getOwnerCoupons, token: AuthService.accessToken);

      if (!res.isSuccess) {
        Get.snackbar('Error', res.errorMessage ?? 'Failed to load coupons');
        return;
      }

      final data = res.responseData;
      if (data is List) {
        coupons.value = data.whereType<Map<String, dynamic>>().map(Coupon.fromJson).toList();
      } else if (data is Map && data['results'] is List) {
        coupons.value = (data['results'] as List).whereType<Map<String, dynamic>>().map(Coupon.fromJson).toList();
      } else {
        log('Unexpected coupon response shape: ${data.runtimeType}');
        Get.snackbar('Error', 'Unexpected response format');
      }
    } catch (e, st) {
      log('Error fetching coupons: $e', stackTrace: st);
      Get.snackbar('Error', '$e');
    } finally {
      isLoading(false);
    }
  }

  Future<bool> createCoupon(CouponDraft draft) async {
    isSaving(true);
    try {
      final res = await NetworkCaller().postRequest(
        AppUrls.getOwnerCoupons,
        token: AuthService.accessToken,
        body: draft.toCreateJson(),
      );
      if (!res.isSuccess) {
        Get.snackbar('Create failed', res.errorMessage ?? 'Could not create coupon');
        return false;
      }

      final data = res.responseData;
      if (data is Map<String, dynamic>) {
        final created = Coupon.fromJson(data);
        coupons.insert(0, created);
      } else {
        await fetchCoupons();
      }
      return true;
    } catch (e, st) {
      log('Error creating coupon: $e', stackTrace: st);
      Get.snackbar('Error', '$e');
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> updateCoupon(int id, CouponDraft draft) async {
    isSaving(true);
    try {
      final url = AppUrls.updateCoupon(id);
      final res = await NetworkCaller().patchRequest(
        url,
        token: AuthService.accessToken,
        body: draft.toUpdateJson(),
      );
      if (!res.isSuccess) {
        Get.snackbar('Update failed', res.errorMessage ?? 'Could not update coupon');
        return false;
      }

      final data = res.responseData;
      if (data is Map<String, dynamic>) {
        final updated = Coupon.fromJson(data);
        final idx = coupons.indexWhere((c) => c.id == id);
        if (idx != -1) {
          coupons[idx] = updated;
        } else {
          await fetchCoupons();
        }
      } else {
        await fetchCoupons();
      }
      return true;
    } catch (e, st) {
      log('Error updating coupon: $e', stackTrace: st);
      Get.snackbar('Error', '$e');
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> setActive(int id, bool active) async {
    isSaving(true);
    try {
      final url = AppUrls.updateCoupon(id);
      final res = await NetworkCaller().patchRequest(
        url,
        token: AuthService.accessToken,
        body: {"is_active": active},
      );
      if (!res.isSuccess) {
        Get.snackbar('Failed', res.errorMessage ?? 'Could not change status');
        return false;
      }

      final idx = coupons.indexWhere((c) => c.id == id);
      if (idx != -1) {
        final c = coupons[idx];
        coupons[idx] = Coupon(
          id: c.id,
          code: c.code,
          description: c.description,
          amount: c.amount,
          inPercentage: c.inPercentage,
          discountType: c.discountType,
          shop: c.shop,
          services: c.services,
          validityDate: c.validityDate,
          isActive: active,
          maxUsagePerUser: c.maxUsagePerUser,
          createdAt: c.createdAt,
          updatedAt: DateTime.now(),
        );
      } else {
        await fetchCoupons();
      }
      return true;
    } catch (e, st) {
      log('Error toggling coupon: $e', stackTrace: st);
      Get.snackbar('Error', '$e');
      return false;
    } finally {
      isSaving(false);
    }
  }

  Future<bool> deleteCoupon(int id) async {
    isSaving(true);
    try {
      final url = AppUrls.updateCoupon(id);
      final res = await NetworkCaller().deleteRequest(url, token: AuthService.accessToken);
      if (!res.isSuccess) {
        Get.snackbar('Delete failed', res.errorMessage ?? 'Could not delete coupon');
        return false;
      }
      coupons.removeWhere((c) => c.id == id);
      return true;
    } catch (e, st) {
      log('Error deleting coupon: $e', stackTrace: st);
      Get.snackbar('Error', '$e');
      return false;
    } finally {
      isSaving(false);
    }
  }
}
