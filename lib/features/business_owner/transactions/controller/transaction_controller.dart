import 'package:fidden/core/models/response_data.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/profile/controller/busines_owner_profile_controller.dart';
import 'package:fidden/features/business_owner/transactions/data/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  var transactions = <Transaction>[].obs;
  var isLoading = true.obs;
  var nextUrl = ''.obs;
  var isLoadingMore = false.obs;
  final ScrollController scrollController = ScrollController();
  final BusinessOwnerProfileController _profileController = Get.find<BusinessOwnerProfileController>();

  @override
  void onInit() {
    super.onInit();
    fetchTransactions();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        fetchMoreTransactions();
      }
    });
  }

  Future<void> fetchTransactions() async {
  try {
    isLoading(true);

    final shopIdAny = _profileController.profileDetails.value.data?.id;
    final int? shopId = shopIdAny is int
        ? shopIdAny as int
        : int.tryParse('$shopIdAny'); // handles string IDs too
    if (shopId == null) return;

    final ResponseData res =
        await NetworkCaller().getRequest(AppUrls.transactions(shopId));

    if (res.isSuccess && res.responseData is Map<String, dynamic>) {
      final model = TransactionModel.fromJson(
          res.responseData as Map<String, dynamic>);
      transactions.value = model.results?.data ?? [];
      nextUrl.value = model.next ?? '';
    }
  } finally {
    isLoading(false);
  }
}

Future<void> fetchMoreTransactions() async {
  if (nextUrl.value.isEmpty || isLoadingMore.value) return;

  try {
    isLoadingMore(true);
    final ResponseData res = await NetworkCaller().getRequest(nextUrl.value);

    if (res.isSuccess && res.responseData is Map<String, dynamic>) {
      final model = TransactionModel.fromJson(
          res.responseData as Map<String, dynamic>);
      transactions.addAll(model.results?.data ?? []);
      nextUrl.value = model.next ?? '';
    }
  } finally {
    isLoadingMore(false);
  }
}

}