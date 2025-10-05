// lib/features/business_owner/transactions/controller/transaction_controller.dart
import 'dart:async';

import 'package:fidden/core/models/response_data.dart';
import 'package:fidden/core/services/network_caller.dart';
import 'package:fidden/core/utils/constants/api_constants.dart';
import 'package:fidden/features/business_owner/profile/controller/busines_owner_profile_controller.dart';
import 'package:fidden/features/business_owner/transactions/data/transaction_model.dart';
import 'package:fidden/features/business_owner/transactions/data/transactions_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionController extends GetxController {
  final repo = TransactionsRepository();

  final transactions = <Transaction>[].obs;
  final nextUrl = ''.obs;

  final isLoading = true.obs;       // only true on cold start (no cache)
  final isRefreshing = false.obs;   // background refresh flag
  final isLoadingMore = false.obs;

  final ScrollController scrollController = ScrollController();
  final _profile = Get.find<BusinessOwnerProfileController>();

  int? _shopId;

  @override
  void onInit() {
    super.onInit();
    _init();
    scrollController.addListener(_onScroll);
  }

  Future<void> _init() async {
    // Seed from cache first (instant UI)
    final cached = await repo.readCache();
    if (cached.list.isNotEmpty) {
      transactions.assignAll(cached.list);
      nextUrl.value = cached.next;
      isLoading(false); // render immediately
    }

    // Resolve shop id
final dynamic shopIdAny = _profile.profileDetails.value.data?.id;

if (shopIdAny is int) {
  _shopId = shopIdAny; // now definitely int
} else if (shopIdAny is String) {
  _shopId = int.tryParse(shopIdAny);
} else {
  _shopId = int.tryParse(shopIdAny?.toString() ?? '');
}

    // If no cache OR cache stale → refresh in background
    if (cached.list.isEmpty || repo.isStale(cached.ts)) {
      unawaited(refreshTransactions()); // no spinner if we already have cache
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      fetchMoreTransactions();
    }
  }

  Future<void> refreshTransactions() async {
    if (_shopId == null || isRefreshing.value) return;
    try {
      isRefreshing(true);

      final ResponseData res =
          await NetworkCaller().getRequest(AppUrls.transactions(_shopId!));

      if (res.isSuccess && res.responseData is Map<String, dynamic>) {
        final model = TransactionModel.fromJson(res.responseData as Map<String, dynamic>);
        final list = model.results?.data ?? <Transaction>[];
        transactions.assignAll(list);
        nextUrl.value = model.next ?? '';
        // persist
        await repo.writeCache(list, nextUrl.value);
      }
    } finally {
      isLoading(false);
      isRefreshing(false);
    }
  }

  Future<void> fetchTransactions() async {
    // kept for pull-to-refresh API in your UI
    return refreshTransactions();
  }

  Future<void> fetchMoreTransactions() async {
    if (nextUrl.value.isEmpty || isLoadingMore.value) return;
    try {
      isLoadingMore(true);
      final ResponseData res = await NetworkCaller().getRequest(nextUrl.value);
      if (res.isSuccess && res.responseData is Map<String, dynamic>) {
        final model = TransactionModel.fromJson(res.responseData as Map<String, dynamic>);
        final more = model.results?.data ?? <Transaction>[];
        transactions.addAll(more);
        nextUrl.value = model.next ?? '';
        // update cache so back/return scrolls are instant
        await repo.writeCache(transactions.toList(), nextUrl.value);
      }
    } finally {
      isLoadingMore(false);
    }
  }
}
